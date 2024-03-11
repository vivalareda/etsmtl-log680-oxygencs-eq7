# Build stage
FROM python:3.8-alpine3.17 as build

ARG HOST
ARG TOKEN

WORKDIR /app

# Ensure packages are installed for psycopg2-binary compilation if needed
RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev cargo postgresql-dev

# Copy Pipfile and Pipfile.lock into the image
COPY Pipfile Pipfile.lock ./

# Install pipenv and project dependencies
RUN pip install --no-cache-dir pipenv \
    && pipenv install --deploy --system --ignore-pipfile

# Cleanup unnecessary packages
RUN apk del .build-deps

FROM python:3.8-alpine3.17
WORKDIR /app
# Ensure you copy the entire project into the image, adjust if necessary to include only needed files
COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY . .

CMD ["python", "./src/main.py"]