import os
from flask import Flask, request, jsonify
import psycopg2
from prometheus_client import Counter, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

http_requests = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status_code'])

def _get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )
    return conn

@app.route('/users', methods=['GET'])
def get_users():
    conn = _get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users")
    users = cur.fetchall()
    cur.close()
    conn.close()
    
    return jsonify(users)

@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    conn = _get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO users (name, password, email) VALUES (%s, %s, %s)", (data['name'], data['password'], data['email']))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "User created successfully"}), 201

@app.after_request
def after_request(response):
    http_requests.labels(method=request.method, endpoint=request.path, status_code=response.status_code).inc()
    return response

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=3002, Debug=True)