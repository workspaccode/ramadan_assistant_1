def test_privacy_is_public_html(ctx):
    client, _ = ctx
    r = client.get("/privacy")
    assert r.status_code == 200
    assert r.headers["content-type"].startswith("text/html")
    assert "Privacy Policy" in r.text
    assert "Optional sync to your own server" in r.text


def test_terms_is_public_html(ctx):
    client, _ = ctx
    r = client.get("/terms")
    assert r.status_code == 200
    assert "<html" in r.text


def test_documents_still_require_auth(ctx):
    client, _ = ctx
    assert client.get("/documents/notes").status_code in (401, 403)
