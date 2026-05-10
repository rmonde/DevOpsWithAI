import os
from flask import Flask, request, jsonify
import psycopg2

app = Flask(__name__)


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

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=3002)