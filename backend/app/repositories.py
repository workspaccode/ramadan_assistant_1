from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models import Document, User


class UserRepository:
    def __init__(self, session: Session) -> None:
        self._s = session

    def add(self, name: str, token_hash: str) -> User:
        user = User(name=name, token_hash=token_hash)
        self._s.add(user)
        self._s.commit()
        return user

    def by_token_hash(self, token_hash: str) -> User | None:
        return self._s.scalar(select(User).where(User.token_hash == token_hash))


@dataclass(frozen=True)
class DocumentRecord:
    namespace: str
    doc_id: str
    revision: int
    schema_version: int
    updated_at: datetime
    deleted: bool
    data: dict | None


def _record(d: Document) -> DocumentRecord:
    return DocumentRecord(
        d.namespace, d.doc_id, d.revision, d.schema_version, d.updated_at,
        d.deleted, json.loads(d.data_json) if d.data_json else None,
    )


def _select_one(user_id: int, namespace: str, doc_id: str):
    return select(Document).where(
        Document.user_id == user_id, Document.namespace == namespace,
        Document.doc_id == doc_id,
    )


class DocumentRepository:
    def __init__(self, session: Session) -> None:
        self._s = session

    def get(self, user_id: int, namespace: str, doc_id: str) -> DocumentRecord | None:
        row = self._s.scalar(_select_one(user_id, namespace, doc_id))
        return _record(row) if row else None

    def list_live(self, user_id: int, namespace: str) -> list[DocumentRecord]:
        rows = self._s.scalars(
            select(Document)
            .where(Document.user_id == user_id, Document.namespace == namespace,
                   Document.deleted.is_(False))
            .order_by(Document.doc_id)
        )
        return [_record(r) for r in rows]

    def upsert_if_newer(self, user_id: int, rec: DocumentRecord) -> int:
        """Store rec unless a higher revision exists; return the stored revision.

        Equal revision is a no-op (idempotent replay). A conditional UPDATE
        guarantees concurrent writers cannot lower a revision.
        """
        values = dict(
            revision=rec.revision, schema_version=rec.schema_version,
            updated_at=rec.updated_at, deleted=rec.deleted,
            data_json=None if rec.deleted or rec.data is None else json.dumps(rec.data),
        )
        for _ in range(2):
            res = self._s.execute(
                update(Document)
                .where(Document.user_id == user_id, Document.namespace == rec.namespace,
                       Document.doc_id == rec.doc_id, Document.revision < rec.revision)
                .values(**values)
            )
            if res.rowcount:
                self._s.commit()
                return rec.revision
            row = self._s.scalar(_select_one(user_id, rec.namespace, rec.doc_id))
            if row is not None:
                self._s.commit()
                return row.revision
            try:
                self._s.add(Document(user_id=user_id, namespace=rec.namespace,
                                     doc_id=rec.doc_id, **values))
                self._s.commit()
                return rec.revision
            except IntegrityError:  # lost an insert race; retry as update
                self._s.rollback()
        raise RuntimeError("upsert failed")
