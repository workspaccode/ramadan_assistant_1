import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import sessionmaker

from app.config import Settings
from app.main import create_app
from app.repositories import UserRepository
from app.security import hash_token


def _mk_client(max_body=256 * 1024, rate=1000):
    app = create_app(Settings("sqlite://", max_body, rate))
    sf = sessionmaker(app.state.engine)
    tokens = {}
    for n in ("alice", "bob"):
        tokens[n] = f"tok-{n}"
        with sf() as s:
            UserRepository(s).add(n, hash_token(tokens[n]))
    return TestClient(app), tokens


@pytest.fixture
def make_client():
    return _mk_client


@pytest.fixture
def ctx():
    return _mk_client()


def body(rev=1, deleted=False, data=None, **kw):
    d = {"revision": rev, "schemaVersion": 1, "updatedAt": "2026-03-01T10:00:00Z",
         "deleted": deleted,
         "data": None if deleted else (data if data is not None else {"v": rev})}
    d.update(kw)
    return d


def put(client, token, ns, id_, b, key=None):
    h = {"Authorization": f"Bearer {token}",
         "Idempotency-Key": key or f"{ns}/{id_}/{b['revision']}"}
    return client.put(f"/documents/{ns}/{id_}", json=b, headers=h)
