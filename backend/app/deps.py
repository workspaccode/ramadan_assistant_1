from __future__ import annotations

import re
from collections.abc import Iterator
from typing import Annotated

from fastapi import Depends, Header, HTTPException, Path, Request
from sqlalchemy.orm import Session

from app.models import User
from app.repositories import DocumentRepository, UserRepository
from app.schemas import DOC_ID_RE, NAMESPACE_RE
from app.services import AuthService, DocumentService

_BEARER = re.compile(r"^Bearer (\S+)$")


def get_session(request: Request) -> Iterator[Session]:
    with request.app.state.session_factory() as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]


def get_document_service(session: SessionDep) -> DocumentService:
    return DocumentService(DocumentRepository(session))


def current_user(
    request: Request, session: SessionDep,
    authorization: Annotated[str | None, Header()] = None,
) -> User:
    m = _BEARER.match(authorization or "")
    user = AuthService(UserRepository(session)).authenticate(m.group(1)) if m else None
    if user is None:
        raise HTTPException(401, "invalid credentials",
                            headers={"WWW-Authenticate": "Bearer"})
    if not request.app.state.rate_limiter.allow(user.id):
        raise HTTPException(429, "rate limit exceeded", headers={"Retry-After": "60"})
    return user


UserDep = Annotated[User, Depends(current_user)]
ServiceDep = Annotated[DocumentService, Depends(get_document_service)]
Namespace = Annotated[str, Path(pattern=NAMESPACE_RE.pattern)]
DocId = Annotated[str, Path(pattern=DOC_ID_RE.pattern)]


async def limited_body(request: Request) -> bytes:
    """Read the request body, rejecting anything over the configured cap."""
    cap = request.app.state.settings.max_body_bytes
    declared = request.headers.get("content-length")
    if declared and declared.isdigit() and int(declared) > cap:
        raise HTTPException(413, "payload too large")
    chunks: list[bytes] = []
    size = 0
    async for chunk in request.stream():
        size += len(chunk)
        if size > cap:
            raise HTTPException(413, "payload too large")
        chunks.append(chunk)
    return b"".join(chunks)
