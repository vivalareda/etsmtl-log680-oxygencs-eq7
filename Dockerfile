FROM python:3.8-alpine

WORKDIR /app

COPY Pipfile.lock ./
RUN pip install --no-cache-dir $(jq -r '.default | to_entries[] | .key + .value.version' < Pipfile.lock)

COPY ./src ./src

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

CMD ["python", "./src/main.py"]
