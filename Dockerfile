FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -qq -y \
    build-essential libpq-dev --fix-missing --no-install-recommends

    # Definir diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copia primeiro o requirements.txt
COPY app/requirements.txt .

# Instala as dependências
RUN pip install --no-cache-dir -r requirements.txt
RUN opentelemetry-bootstrap -a install

# Expor portas
EXPOSE 5000 8080

# Copia o resto da aplicação
COPY app/ .

# Variáveis de ambiente
ENV OTEL_SERVICE_NAME=svc-app
ENV OTEL_TRACES_EXPORTER=console,otlp 
ENV OTEL_METRICS_EXPORTER=console 
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=0.0.0.0:4317
ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Comando para rodar a aplicação
CMD ["opentelemetry-instrument", "python3", "app.py"]
