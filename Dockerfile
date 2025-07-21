FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -qq -y \
    build-essential libpq-dev --fix-missing --no-install-recommends

WORKDIR /app

# Copia primeiro o requirements.txt
COPY app/requirements.txt .

# Instala as dependências
RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap -a install

# Copia o resto da aplicação
COPY app/ .

# Variáveis de ambiente
ENV OTEL_SERVICE_NAME=svc-app
ENV OTEL_TRACES_EXPORTER=console,otlp 
ENV OTEL_METRICS_EXPORTER=console 
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=0.0.0.0:4317

# Comando para rodar a aplicação
CMD ["opentelemetry-instrument", "python3", "app.py"]
