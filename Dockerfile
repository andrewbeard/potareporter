FROM python:3.13-alpine AS base

ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PYTHONDONTWRITEBYTECODE=1
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
EXPOSE 7373

RUN adduser --gecos "" --disabled-password -s /sbin/nologin --home /tmp --uid 1000 potareporter && \
    mkdir -p /app
COPY pyproject.toml uv.lock /app/
WORKDIR /app
COPY src /app/src

FROM base AS dev
RUN apk add --no-cache uv && \
    uv sync --group dev --group test
CMD ["ash"]

FROM base AS prod
RUN --mount=type=cache,target=/root/.cache/uv \
    apk add --no-cache uv && \
    uv sync --locked --compile --extra uvloop && \
    apk del uv

USER potareporter
ENV PYTHONOPTIMIZE=1
CMD ["python", "src/potareporter.py"]