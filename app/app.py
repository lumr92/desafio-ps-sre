import psycopg2
import redis
import os
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics


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

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug = True)
