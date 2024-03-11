FROM python:3.8-alpine3.17 as build

ARG HOST
ARG TOKEN

WORKDIR /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev cargo postgresql-dev \
    && pip install --no-cache-dir pipenv \
    && pipenv install --deploy --system --ignore-pipfile \
    && apk del .build-deps

COPY Pipfile Pipfile.lock ./

FROM python:3.8-alpine3.17

WORKDIR /app

COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

COPY --from=build /app /app

RUN find /usr/local \
    \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
    && rm -rf /root/.cache

CMD ["python", "./src/main.py"]
