FROM python:3.8-alpine

WORKDIR /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install --no-cache-dir pipenv \
    && apk del .build-deps

COPY Pipfile Pipfile.lock ./

RUN pipenv install --deploy --system --ignore-pipfile

COPY . .

CMD ["python", "./src/main.py"]
