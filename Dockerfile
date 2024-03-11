FROM python:3.8-alpine3.16 as build

ARG HOST=${{secrets.HOST}}
ARG TOKEN=${{secrets.TOKEN}}
ARG DB_NAME=${{secrets.DB_NAME}}
ARG DB_USER=${{secrets.DB_USER}}
ARG DB_HOST=${{secrets.DB_HOST}}
ARG DB_PASS=${{secrets.DB_PASS}}

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev postgresql-dev

# Copy Pipfile and Pipfile.lock
COPY Pipfile Pipfile.lock ./

# Install Python dependencies
RUN pip install --no-cache-dir pipenv \
    && pipenv lock \
    && pipenv install --deploy --system --ignore-pipfile

# Remove build dependencies
RUN apk del .build-deps

# Copy the application code
COPY src/ src/

FROM python:3.8-alpine3.16

WORKDIR /app

# Copy Python dependencies from the build stage
COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

# Copy the application code
COPY --from=build /app/src /app/src

CMD ["python", "./src/main.py"]
