# Ramadan Assistant sync backend

Small FastAPI + SQLite service implementing the app's sync contract
(`PUT /documents/{namespace}/{id}`), plus restore reads.

## Run

```bash
python -m venv .venv
.venv/Scripts/pip install -r requirements.txt      # Linux/macOS: .venv/bin/pip
.venv/Scripts/python -m app.cli create-user alice  # prints a token ONCE
.venv/Scripts/python -m uvicorn app.main:create_app --factory --host 127.0.0.1 --port 8000
```

Docker: `docker build -t ramadan-sync . && docker run -p 8000:8000 -v sync-data:/data ramadan-sync`
(create users with `docker run --rm -v sync-data:/data ramadan-sync python -m app.cli create-user alice`).

Environment: `SYNC_DATABASE_URL` (default `sqlite:///./sync.db`),
`SYNC_MAX_BODY_BYTES` (262144), `SYNC_RATE_LIMIT_PER_MINUTE` (120 per user).

## TLS (required)

Tokens travel in the `Authorization` header, so **always run behind a TLS
reverse proxy** (Caddy, nginx, Traefik, a cloud load balancer) and give the app
an `https://` URL. Never expose plain HTTP on the internet. Bind uvicorn to
127.0.0.1 when the proxy is on the same host. The rate limiter is in-memory,
so run a single worker (or move limiting to the proxy).

## Point the app at it

In the app: Settings > Local data > Data sync URL = `https://your.host`
(no trailing slash), Data sync token = the token printed by `create-user`.

## API

| Method | Path | Notes |
|---|---|---|
| PUT | `/documents/{ns}/{id}` | body `{revision, schemaVersion, updatedAt, deleted, data}`; `Idempotency-Key: ns/id/revision`. 200 `{"revision": n}` when equal/newer; 409 `{"revision": stored}` when stale |
| GET | `/documents/{ns}` | live (non-deleted) documents, for restore |
| GET | `/documents/{ns}/{id}` | one document (tombstones included), 404 if unknown |
| GET | `/health` | liveness |
| GET | `/privacy` | public privacy policy (HTML, no auth) - the Play Console URL |
| GET | `/terms` | public terms of service (HTML, no auth) |

Equal revision is an idempotent no-op. Deletes are tombstones (`deleted=true`,
`data=null`) and are never resurrected by an older revision. `ns` matches
`^[a-z0-9][a-z0-9_-]{0,63}$`, `id` matches `^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$`.
Errors: 401 bad token, 413 body > cap, 422 validation, 429 rate limit.

Only SHA-256 hashes of tokens are stored; comparison is constant-time.
A lost token cannot be recovered: create a new user.

## Tests

```bash
.venv/Scripts/pip install -r requirements-dev.txt
.venv/Scripts/python -m pytest
```

## Legal pages

`/privacy` and `/terms` serve `app/static/legal/*.html`, which are copies of
`../legal/privacy_policy.html` and `../legal/terms_of_service.html` (the backend
image is built from this folder alone). After editing the originals run:

```
cp ../legal/privacy_policy.html app/static/legal/privacy.html
cp ../legal/terms_of_service.html app/static/legal/terms.html
```

Set the Play Console privacy URL to `https://<your-domain>/privacy`; the data
deletion link can be `https://<your-domain>/privacy#data-deletion`.
