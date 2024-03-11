# Use a single-stage build
FROM python:3.8-alpine3.17

WORKDIR /app

# Combine update, package installation, and cleanup to reduce layer size
RUN apk add --no-cache gcc musl-dev python3-dev libffi-dev openssl-dev cargo postgresql-dev && \
    pip install --no-cache-dir pipenv && \
    apk del gcc musl-dev python3-dev libffi-dev openssl-dev cargo postgresql-dev

# Copy Pipfile and Pipfile.lock into the image
COPY Pipfile Pipfile.lock ./

# Install project dependencies
RUN pipenv install --deploy --system --ignore-pipfile

# Copy the rest of your application
COPY . .

CMD ["python", "./src/main.py"]
