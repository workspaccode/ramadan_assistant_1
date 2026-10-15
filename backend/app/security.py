from __future__ import annotations

import hashlib
import hmac
import secrets


def generate_token() -> str:
    return secrets.token_urlsafe(32)


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def tokens_match(stored_hash: str, presented_token: str) -> bool:
    return hmac.compare_digest(stored_hash, hash_token(presented_token))
