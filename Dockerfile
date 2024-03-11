# Use multi-stage builds to minimize size
# Stage 1: Build Stage
FROM python:3.8-alpine3.16 as build

# Define build-time variables
ARG HOST
ARG TOKEN
ARG DB_NAME
ARG DB_USER
ARG DB_HOST
ARG DB_PASS

WORKDIR /app

# Combine update, upgrade and install commands into one RUN statement to reduce layers
RUN apk update && apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev postgresql-dev && \
    pip install --no-cache-dir pipenv && \
    pipenv lock && \
    pipenv install --deploy --system --ignore-pipfile

# Copy the Pipfiles and install dependencies in one layer
COPY Pipfile Pipfile.lock ./
RUN pipenv lock && pipenv install --deploy --system --ignore-pipfile

# Clean up unnecessary files to keep the build stage as small as possible
RUN apk del .build-deps && rm -rf /var/cache/apk/*

# Copy application code
COPY src/ src/

# Stage 2: Final Image
FROM python:3.8-alpine3.16

WORKDIR /app

# Copy Python dependencies and application code from the build stage
COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=build /app/src /app/src

CMD ["python", "./src/main.py"]
