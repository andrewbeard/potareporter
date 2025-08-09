FROM python:3.13-alpine AS base

ENV PYTHONUNBUFFERED=1
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
EXPOSE 7373

RUN adduser --gecos "" --disabled-password -s /sbin/nologin --home /tmp --uid 1000 potareporter && \
    mkdir -p /app
WORKDIR /app
COPY src /app/src

FROM base AS dev
COPY pyproject.toml uv.lock /app/

RUN apk add --no-cache uv && \
    uv sync --group dev --group test
CMD ["ash"]

FROM base AS prod
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    apk --no-cache -U upgrade && \
    apk add --no-cache uv && \
    uv sync --locked --compile --link-mode=copy --extra uvloop && \
    apk --no-cache del uv

USER potareporter
ENV PYTHONOPTIMIZE=1
CMD ["python", "src/potareporter.py"]
