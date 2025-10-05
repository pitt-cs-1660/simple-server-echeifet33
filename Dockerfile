###Build Stage
FROM python:3.12 AS builder

#UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml ./
RUN uv sync --no-install-project --no-editable

#Source Code
COPY . /cc_simple_server ./
RUN uv sync --no-editable

###Final Stage
FROM python:3.12-slim

#evnironment variables
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

#venv from build stage & non-root user
COPY --from=builder /app/.venv /app/.venv

# Copy tests directory into final stage
COPY --from=builder /app/tests ./tests

EXPOSE 8000

#Run server
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]