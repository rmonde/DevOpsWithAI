import os
from flask import Flask, jsonify, request
import psycopg2

app = Flask(__name__)

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001)
    