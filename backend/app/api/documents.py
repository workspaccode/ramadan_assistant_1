from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Header, HTTPException
from fastapi.responses import JSONResponse
from pydantic import ValidationError

from app.deps import DocId, Namespace, ServiceDep, UserDep, limited_body
from app.repositories import DocumentRecord
from app.schemas import DocumentIn, DocumentList, DocumentOut, Receipt

router = APIRouter(prefix="/documents", tags=["documents"])


def _out(r: DocumentRecord) -> DocumentOut:
    return DocumentOut(namespace=r.namespace, id=r.doc_id, revision=r.revision,
                       schemaVersion=r.schema_version, updatedAt=r.updated_at,
                       deleted=r.deleted, data=r.data)


@router.put("/{namespace}/{doc_id}", response_model=Receipt)
async def put_document(
    namespace: Namespace, doc_id: DocId, user: UserDep, service: ServiceDep,
    raw: Annotated[bytes, Depends(limited_body)],
    idempotency_key: Annotated[str | None, Header()] = None,
):
    try:
        body = DocumentIn.model_validate_json(raw)
    except ValidationError as e:
        raise HTTPException(422, e.errors(include_url=False, include_context=False,
                                          include_input=False))
    if idempotency_key is not None and idempotency_key != f"{namespace}/{doc_id}/{body.revision}":
        raise HTTPException(400, "Idempotency-Key does not match request")
    result = service.put(user.id, namespace, doc_id, body)
    if not result.accepted:
        return JSONResponse({"revision": result.revision}, status_code=409)
    return Receipt(revision=result.revision)


@router.get("/{namespace}", response_model=DocumentList)
def list_documents(namespace: Namespace, user: UserDep, service: ServiceDep):
    return DocumentList(documents=[_out(r) for r in service.list_live(user.id, namespace)])


@router.get("/{namespace}/{doc_id}", response_model=DocumentOut)
def get_document(namespace: Namespace, doc_id: DocId, user: UserDep, service: ServiceDep):
    rec = service.get(user.id, namespace, doc_id)
    if rec is None:
        raise HTTPException(404, "not found")
    return _out(rec)
