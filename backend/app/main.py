from __future__ import annotations

from fastapi import FastAPI
from sqlalchemy.orm import sessionmaker

from app.api import documents, legal
from app.config import Settings
from app.db import init_db, make_engine
from app.rate_limit import RateLimiter


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or Settings.from_env()
    engine = make_engine(settings.database_url)
    init_db(engine)
    app = FastAPI(title="Ramadan Assistant Sync", docs_url=None, redoc_url=None)
    app.state.settings = settings
    app.state.engine = engine
    app.state.session_factory = sessionmaker(engine, expire_on_commit=False)
    app.state.rate_limiter = RateLimiter(settings.rate_limit_per_minute)
    app.include_router(documents.router)
    app.include_router(legal.router)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    return app

