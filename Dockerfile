FROM python:3.8-alpine

WORKDIR /app

RUN pip install --no-cache-dir pipenv

COPY Pipfile Pipfile.lock ./
RUN pipenv lock --keep-outdated --requirements > requirements.txt && \
    pip install --no-cache-dir -r requirements.txt

COPY ./src ./src

RUN find /usr/local -type d -name '__pycache__' -exec rm -r {} + \
    && find /usr/local -type d -name 'tests' -exec rm -r {} + \
    && find /usr/local -type f -name '*.pyc' -exec rm -f {} +

CMD ["python", "./src/main.py"]
