import os
from flask import Flask, jsonify, request
import psycopg2
from prometheus_client import make_wsgi_app, Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

http_requests = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status_code'])

# Endpoint to fetch all books
@app.route('/books', methods=['GET'])
def get_books():
    # Implement logic to fetch books from the database
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, author FROM books")
    books = cursor.fetchall()
    cursor.close()
    conn.close()

    books_list = []
    for book in books:
        books_list.append({
            'id': book[0],
            'title': book[1],
            'author': book[2]
        })

    return jsonify(books_list)


def search_books(self, book_name):
    # Implement logic to search for books by name in the database
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, author FROM books WHERE title ILIKE %s", (f'%{book_name}%',))
    books = cursor.fetchall()
    cursor.close()
    conn.close()

    books_list = []
    for book in books:
        books_list.append({
            'id': book[0],
            'title': book[1],
            'author': book[2]
        })

    return jsonify(books_list)

@app.after_request
def after_request(response):
    http_requests.labels(method=request.method, endpoint=request.path, status_code=response.status_code).inc()
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001, debug=True)
    