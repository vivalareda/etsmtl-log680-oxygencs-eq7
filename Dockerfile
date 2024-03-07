FROM python:3.8-alpine

WORKDIR /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install --no-cache-dir pipenv \
    && apk del .build-deps

COPY Pipfile Pipfile.lock ./

RUN pipenv install --deploy --system --ignore-pipfile && \
    apk --no-cache del .build-deps
    
COPY . .

RUN find /usr/local \
    \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
    && rm -rf /root/.cache

CMD ["python", "./src/main.py"]
