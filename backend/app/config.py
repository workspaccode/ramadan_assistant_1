"""Settings read from environment variables (prefix SYNC_)."""
from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    database_url: str = "sqlite:///./sync.db"
    max_body_bytes: int = 256 * 1024
    rate_limit_per_minute: int = 120

    @classmethod
    def from_env(cls) -> "Settings":
        d = cls()
        return cls(
            database_url=os.getenv("SYNC_DATABASE_URL", d.database_url),
            max_body_bytes=int(os.getenv("SYNC_MAX_BODY_BYTES", d.max_body_bytes)),
            rate_limit_per_minute=int(
                os.getenv("SYNC_RATE_LIMIT_PER_MINUTE", d.rate_limit_per_minute)
            ),
        )
