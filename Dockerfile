FROM python:3.8-alpine

WORKDIR /app

# Install virtualenv
RUN pip install --no-cache-dir virtualenv
RUN virtualenv venv

# Activate virtual environment
ENV VIRTUAL_ENV /app/venv
ENV PATH /app/venv/bin:$PATH

# Install dependencies
COPY Pipfile Pipfile.lock ./
RUN pip install --no-cache-dir pipenv && \
    pipenv install --deploy --system --ignore-pipfile

COPY . .

RUN find /app/venv -type d -name '__pycache__' -exec rm -r {} + \
    && find /app/venv -type d -name 'tests' -exec rm -r {} + \
    && find /app/venv -type f -name '*.pyc' -exec rm -f {} +

CMD ["python", "./src/main.py"]
