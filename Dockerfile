FROM python:3.13-alpine

ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PYTHONDONTWRITEBYTECODE=1
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"

RUN adduser --gecos "" --disabled-password -s /sbin/nologin --home /tmp --uid 1000 potareporter && \
    apk add --no-cache uv && \
    mkdir -p /app

COPY pyproject.toml uv.lock /app/
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --compile

COPY src /app/src

EXPOSE 7373
USER potareporter
ENV PYTHONOPTIMIZE=1
CMD ["python", "src/potareporter.py"]