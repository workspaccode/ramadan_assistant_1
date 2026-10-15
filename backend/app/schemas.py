from __future__ import annotations

import re
from datetime import datetime
from typing import Annotated, Any

from pydantic import BaseModel, ConfigDict, Field, model_validator

NAMESPACE_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")
DOC_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")


class DocumentIn(BaseModel):
    model_config = ConfigDict(extra="forbid")

    revision: Annotated[int, Field(ge=0)]
    schemaVersion: Annotated[int, Field(ge=0)]
    updatedAt: datetime
    deleted: bool
    data: dict[str, Any] | None = None

    @model_validator(mode="after")
    def _tombstone_has_no_data(self) -> "DocumentIn":
        if self.deleted:
            self.data = None
        elif self.data is None:
            raise ValueError("data is required unless deleted")
        return self


class Receipt(BaseModel):
    revision: int


class DocumentOut(BaseModel):
    namespace: str
    id: str
    revision: int
    schemaVersion: int
    updatedAt: datetime
    deleted: bool
    data: dict[str, Any] | None


class DocumentList(BaseModel):
    documents: list[DocumentOut]
