import psycopg2
import redis
import os
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

# OpenTelemetry imports
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.resources import Resource
from prometheus_client import start_http_server

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ===== CONFIGURAÇÃO OPENTELEMETRY =====
def setup_telemetry():
    """Configura OpenTelemetry para traces e métricas"""
    
    # Resource com informações do serviço
    resource = Resource.create({
        "service.name": os.getenv("SERVICE_NAME", "svc-app"),
        "service.version": os.getenv("SERVICE_VERSION", "1.0.0"),
        "deployment.environment": os.getenv("ENVIRONMENT", "production"),
        "k8s.cluster.name": os.getenv("CLUSTER_NAME", "Desafio-cluster-eks-LucasMenezes"),
        "k8s.namespace.name": os.getenv("POD_NAMESPACE", "default"),
        "k8s.pod.name": os.getenv("POD_NAME", "app-desafio-sre"),
    })

    # === TRACING ===
    tracer_provider = TracerProvider(resource=resource)
    trace.set_tracer_provider(tracer_provider)

    # OTLP Exporter para traces
    if os.getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"):
        otlp_exporter = OTLPSpanExporter(
            endpoint=os.getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"),
            insecure=True
        )
        span_processor = BatchSpanProcessor(otlp_exporter)
        tracer_provider.add_span_processor(span_processor)
        logger.info("OTLP trace exporter configured")

    # === METRICS ===
    metric_readers = []
    
    # Prometheus reader 
    prometheus_reader = PrometheusMetricReader()
    metric_readers.append(prometheus_reader)

    # OTLP reader 
    if os.getenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"):
        otlp_metric_exporter = OTLPMetricExporter(
            endpoint=os.getenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"),
            insecure=True
        )
        otlp_reader = PeriodicExportingMetricReader(
            exporter=otlp_metric_exporter,
            export_interval_millis=5000
        )
        metric_readers.append(otlp_reader)
        logger.info("OTLP metrics exporter configured")

    meter_provider = MeterProvider(resource=resource, metric_readers=metric_readers)
    metrics.set_meter_provider(meter_provider)

    # Iniciar servidor Prometheus
    try:
        start_http_server(8080)
        logger.info("Prometheus metrics server started on port 8080")
    except Exception as e:
        logger.error(f"Failed to start Prometheus server: {e}")

    return trace.get_tracer(__name__), metrics.get_meter(__name__)

# Configurar opentelemetry
tracer, meter = setup_telemetry()

# ===== APLICAÇÃO FLASK =====
app = Flask(__name__)

# Instrumentação automática do Flask
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

@app.before_request
def before_request():
    """Middleware executado antes de cada requisição"""
    request.start_time = time.time()
    active_connections.add(1)

@app.after_request
def after_request(response):
    """Middleware executado após cada requisição"""
    # Calcular duração
    duration = time.time() - request.start_time
    
    # Registrar métricas
    labels = {
        "method": request.method,
        "endpoint": request.endpoint or "unknown",
        "status_code": str(response.status_code)
    }
    
    http_requests_total.add(1, labels)
    http_request_duration.record(duration, {
        "method": request.method,
        "endpoint": request.endpoint or "unknown"
    })
    
    active_connections.add(-1)
    
    return response


app = Flask(__name__)
metrics = PrometheusMetrics(app)
metrics.start_http_server(9999)

REDIS_HOST = os.getenv('REDIS_HOST', 'svc-redis')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))

POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'svc-postgres')
POSTGRES_PORT = int(os.getenv('POSTGRES_PORT', 5432))
POSTGRES_USER = os.getenv('POSTGRES_USER', 'postgres')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'senhafacil')
POSTGRES_DB = os.getenv('POSTGRES_DB', 'postgres')


@app.route("/")
def hello_world():
    return "App on"

@app.route('/redis')
def get_status_redis():
    try:
        # conecte-se ao Redis
        r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0)

        # verifique se a conexão foi estabelecida
        r.ping()

        # retorne uma mensagem indicando que a conexão foi bem-sucedida
        return "Conexão com o Redis estabelecida com sucesso!"
    except:
        # retorne uma mensagem indicando que a conexão falhou
        return "Falha ao conectar com o Redis."


@app.route('/postgres')
def get_status_postgres():
    try:
        # conecte-se ao PostgreSQL
        conn = psycopg2.connect(
            host=POSTGRES_HOST,
            port=POSTGRES_PORT,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
            database=POSTGRES_DB
        )

        # feche a conexão com o PostgreSQL
        conn.close()

        # retorne uma mensagem indicando que a conexão foi bem-sucedida
        return "Conexão com o PostgreSQL estabelecida com sucesso!"
    except Exception as e:
        # retorne uma mensagem indicando que a conexão falhou
        return "Falha ao conectar com o PostgreSQL."

@app.route('/error')
def get_error():
    # simule um erro 500
    error_message = "Ocorreu um erro interno no servidor."
    return jsonify({'error': error_message}), 500

# ===== ENDPOINTS DA APLICAÇÃO =====
@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": os.getenv("SERVICE_NAME", "svc-app"),
        "version": os.getenv("SERVICE_VERSION", "1.0.0")
    }), 200

if __name__ == '__main__':
    logger.info(f"Starting {os.getenv('SERVICE_NAME', 'svc-app')} v{os.getenv('SERVICE_VERSION', '1.0.0')}")
    app.run(host='0.0.0.0', port=5000, debug=False)