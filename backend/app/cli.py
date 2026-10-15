from __future__ import annotations

import argparse
import sys

from sqlalchemy.orm import sessionmaker

from app.config import Settings
from app.db import init_db, make_engine
from app.repositories import UserRepository
from app.security import generate_token, hash_token


def create_user(name: str, settings: Settings | None = None) -> str:
    settings = settings or Settings.from_env()
    engine = make_engine(settings.database_url)
    init_db(engine)
    token = generate_token()
    with sessionmaker(engine)() as session:
        UserRepository(session).add(name, hash_token(token))
    return token


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m app.cli")
    sub = p.add_subparsers(dest="cmd", required=True)
    cu = sub.add_parser("create-user", help="create a user and print a one-time token")
    cu.add_argument("name")
    args = p.parse_args(argv)
    try:
        token = create_user(args.name)
    except Exception as e:  # e.g. duplicate name
        print(f"error: {e}", file=sys.stderr)
        return 1
    print(f"User {args.name} created. Token (shown once, store it now):\n{token}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
