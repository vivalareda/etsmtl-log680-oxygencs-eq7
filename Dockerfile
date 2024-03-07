# Use an official lightweight Python image based on Alpine
FROM python:3.8-alpine

# Set the working directory in the container
WORKDIR /app

# Install build dependencies required for certain Python packages
RUN apk add --no-cache --virtual .build-deps gcc musl-dev libffi-dev

# Install pipenv using pip
RUN pip install --no-cache-dir pipenv

# Install dependencies using pipenv and cleanup build deps in one layer to keep image size small
RUN pipenv install --deploy --system --ignore-pipfile && \
    apk --no-cache del .build-deps

# Copy the application source code after installing dependencies
# to leverage Docker cache layers effectively.
COPY . .

# Clean up the Python bytecode files and pip cache to reduce image size.
RUN find /usr/local \
    \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
    && rm -rf /root/.cache

# Run the application
CMD ["python", "/app/src/main.py"]
