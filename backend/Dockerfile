FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /srv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
RUN useradd -r -u 10001 sync && mkdir /data && chown sync /data
USER sync
ENV SYNC_DATABASE_URL=sqlite:////data/sync.db
VOLUME /data
EXPOSE 8000
# Run behind a TLS-terminating reverse proxy.
CMD ["uvicorn", "app.main:create_app", "--factory", "--host", "0.0.0.0", "--port", "8000"]
