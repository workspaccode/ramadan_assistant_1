from tests.conftest import body, put


def auth(t, user="alice"):
    return {"Authorization": f"Bearer {t[user]}"}


def test_health(ctx):
    c, _ = ctx
    assert c.get("/health").json() == {"status": "ok"}


def test_auth_failures(ctx):
    c, _ = ctx
    assert c.put("/documents/habits/a", json=body()).status_code == 401
    assert put(c, "wrong", "habits", "a", body()).status_code == 401
    r = c.put("/documents/habits/a", json=body(), headers={"Authorization": "Basic x"})
    assert r.status_code == 401
    assert c.get("/documents/habits").status_code == 401


def test_create_and_get(ctx):
    c, t = ctx
    r = put(c, t["alice"], "habits", "a1", body(1))
    assert r.status_code == 200 and r.json() == {"revision": 1}
    assert c.get("/documents/habits/a1", headers=auth(t)).json()["data"] == {"v": 1}
    assert c.get("/documents/habits/zz", headers=auth(t)).status_code == 404


def test_idempotent_repeat(ctx):
    c, t = ctx
    assert put(c, t["alice"], "habits", "a", body(2)).json() == {"revision": 2}
    r = put(c, t["alice"], "habits", "a", body(2, data={"other": 1}))
    assert r.status_code == 200 and r.json() == {"revision": 2}
    assert c.get("/documents/habits/a", headers=auth(t)).json()["data"] == {"v": 2}


def test_newer_overwrites(ctx):
    c, t = ctx
    put(c, t["alice"], "habits", "a", body(1))
    assert put(c, t["alice"], "habits", "a", body(3)).json() == {"revision": 3}
    g = c.get("/documents/habits/a", headers=auth(t)).json()
    assert g["revision"] == 3 and g["data"] == {"v": 3}


def test_stale_409(ctx):
    c, t = ctx
    put(c, t["alice"], "habits", "a", body(5))
    r = put(c, t["alice"], "habits", "a", body(2))
    assert r.status_code == 409 and r.json() == {"revision": 5}
    assert c.get("/documents/habits/a", headers=auth(t)).json()["data"] == {"v": 5}


def test_tombstone_and_list(ctx):
    c, t = ctx
    put(c, t["alice"], "habits", "a", body(1))
    put(c, t["alice"], "habits", "b", body(1))
    ids = [d["id"] for d in c.get("/documents/habits", headers=auth(t)).json()["documents"]]
    assert ids == ["a", "b"]
    assert put(c, t["alice"], "habits", "a", body(2, deleted=True)).json() == {"revision": 2}
    docs = c.get("/documents/habits", headers=auth(t)).json()["documents"]
    assert [d["id"] for d in docs] == ["b"]
    g = c.get("/documents/habits/a", headers=auth(t)).json()
    assert g["deleted"] is True and g["data"] is None
    assert put(c, t["alice"], "habits", "a", body(1)).status_code == 409


def test_users_isolated(ctx):
    c, t = ctx
    put(c, t["alice"], "habits", "a", body(1))
    assert c.get("/documents/habits", headers=auth(t, "bob")).json()["documents"] == []
    assert put(c, t["bob"], "habits", "a", body(1)).status_code == 200


def test_validation(ctx):
    c, t = ctx
    a = t["alice"]
    assert put(c, a, "Bad NS", "a", body(), key="k").status_code == 422
    assert put(c, a, "habits", "a b", body(), key="k").status_code == 422
    assert put(c, a, "habits", "a", body(revision=-1)).status_code == 422
    assert put(c, a, "habits", "a", {**body(1), "data": None}).status_code == 422
    assert put(c, a, "habits", "a", body(updatedAt="nope")).status_code == 422
    assert put(c, a, "habits", "a", body(extra=1)).status_code == 422
    assert put(c, a, "habits", "a", body(1), key="habits/a/9").status_code == 400
    assert c.get("/documents/habits", headers=auth(t)).json()["documents"] == []


def test_body_size_limit(make_client):
    c, t = make_client(max_body=1024)
    big = body(1, data={"blob": "x" * 5000})
    assert put(c, t["alice"], "habits", "a", big).status_code == 413
    assert put(c, t["alice"], "habits", "a", body(1)).status_code == 200


def test_rate_limit(make_client):
    c, t = make_client(rate=3)
    codes = [put(c, t["alice"], "habits", "a", body(1)).status_code for _ in range(5)]
    assert codes == [200, 200, 200, 429, 429]
    assert put(c, t["bob"], "habits", "a", body(1)).status_code == 200
