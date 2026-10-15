"""Public, unauthenticated legal pages required by Google Play."""
from __future__ import annotations

from pathlib import Path

from fastapi import APIRouter, HTTPException
from fastapi.responses import HTMLResponse

router = APIRouter(tags=["legal"])

_LEGAL_DIR = Path(__file__).resolve().parent.parent / "static" / "legal"
_CACHE = {"Cache-Control": "public, max-age=3600"}


def _page(name: str) -> HTMLResponse:
    path = _LEGAL_DIR / f"{name}.html"
    if not path.is_file():
        raise HTTPException(status_code=404, detail="Not found")
    return HTMLResponse(path.read_text(encoding="utf-8"), headers=_CACHE)


@router.get("/privacy", response_class=HTMLResponse, include_in_schema=False)
def privacy() -> HTMLResponse:
    return _page("privacy")


@router.get("/terms", response_class=HTMLResponse, include_in_schema=False)
def terms() -> HTMLResponse:
    return _page("terms")
