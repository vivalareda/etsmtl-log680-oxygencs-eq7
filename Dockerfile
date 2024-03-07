FROM python:3.8-alpine

RUN apk add --no-cache --virtual .build-deps gcc musl-dev

RUN pip install --no-cache-dir pipenv

WORKDIR /app
COPY Pipfile Pipfile.lock ./
RUN pipenv install --deploy --system --ignore-pipfile

RUN apk del .build-deps

COPY . .

RUN find /usr/local \
    \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
    && rm -rf /root/.cache

CMD ["python", "./src/main.py"]
