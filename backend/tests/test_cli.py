from sqlalchemy.orm import sessionmaker

from app.cli import create_user
from app.config import Settings
from app.db import make_engine
from app.repositories import UserRepository
from app.security import hash_token


def test_create_user_stores_only_hash(tmp_path):
    s = Settings(f"sqlite:///{tmp_path / 't.db'}")
    token = create_user("carol", s)
    with sessionmaker(make_engine(s.database_url))() as sess:
        u = UserRepository(sess).by_token_hash(hash_token(token))
        assert u is not None and u.name == "carol" and u.token_hash != token
