import os
import psycopg2
from flask import Flask, request, jsonify
from prometheus_client import make_wsgi_app, Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

http_requests = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status_code'])

# This function checks if the provided username and password are valid by querying the PostgreSQL database.
def valide_user_credentials(username: str, password: str) -> bool:
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )
    cursor = conn.cursor()
    cursor.execute("SELECT password FROM users WHERE username = %s", (username,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return result is not None and result[0] == password

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    if not data or "username" not in data or "password" not in data:
        return jsonify({"error": "username and password are required"}), 400

    username = data["username"]
    password = data["password"]

    if valide_user_credentials(username, password):
        return jsonify({"message": "Login successful"}), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401

@app.after_request
def after_request(response):
    http_requests.labels(method=request.method, endpoint=request.path, status_code=response.status_code).inc()
    return response

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000, debug=True)
