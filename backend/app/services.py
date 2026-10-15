from __future__ import annotations

from dataclasses import dataclass

from app.models import User
from app.repositories import DocumentRecord, DocumentRepository, UserRepository
from app.schemas import DocumentIn
from app.security import hash_token, tokens_match


@dataclass(frozen=True)
class PutResult:
    revision: int
    accepted: bool  # False when a higher revision is already stored (stale)


class AuthService:
    def __init__(self, users: UserRepository) -> None:
        self._users = users

    def authenticate(self, token: str) -> User | None:
        user = self._users.by_token_hash(hash_token(token))
        if user is not None and tokens_match(user.token_hash, token):
            return user
        return None


class DocumentService:
    def __init__(self, docs: DocumentRepository) -> None:
        self._docs = docs

    def put(self, user_id: int, namespace: str, doc_id: str, body: DocumentIn) -> PutResult:
        rec = DocumentRecord(namespace, doc_id, body.revision, body.schemaVersion,
                             body.updatedAt, body.deleted, body.data)
        stored = self._docs.upsert_if_newer(user_id, rec)
        return PutResult(stored, accepted=stored <= body.revision)

    def get(self, user_id: int, namespace: str, doc_id: str) -> DocumentRecord | None:
        return self._docs.get(user_id, namespace, doc_id)

    def list_live(self, user_id: int, namespace: str) -> list[DocumentRecord]:
        return self._docs.list_live(user_id, namespace)
