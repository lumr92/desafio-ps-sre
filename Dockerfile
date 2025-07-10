FROM python:3.8.2-slim-buster

RUN apt-get update && apt-get install -qq -y \
    build-essential libpq-dev --fix-missing --no-install-recommends

WORKDIR /app

COPY /app/requirements.txt requirements.txt
RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap -a install
ENV OTEL_SERVICE_NAME=svc-app
ENV OTEL_TRACES_EXPORTER=console,otlp 
ENV OTEL_METRICS_EXPORTER=console 
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=0.0.0.0:4317 

COPY . .

CMD ["opentelemetry-instrument", "python3", "app.py"]
