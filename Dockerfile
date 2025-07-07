FROM python:3.13-alpine

ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PYTHONDONTWRITEBYTECODE=1

RUN adduser --gecos "" --disabled-password -s /sbin/nologin --home /tmp --uid 1000 potareporter && \
    pip install "poetry>=2.0.0,<3.0.0"  && \
    poetry config virtualenvs.create false && \
    mkdir -p /app

COPY pyproject.toml poetry.lock /app/
WORKDIR /app
RUN poetry install

COPY src /app/src

EXPOSE 7373
USER potareporter
RUN poetry config virtualenvs.create false
CMD ["poetry", "run", "python", "src/potareporter.py"]