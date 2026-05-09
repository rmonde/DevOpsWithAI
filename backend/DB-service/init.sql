-- Auth-service & User-service: core identity table
CREATE TABLE IF NOT EXISTS users (
    id       SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255)        NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User-service: extended profile info linked to users
CREATE TABLE IF NOT EXISTS user_profiles (
    id        SERIAL PRIMARY KEY,
    user_id   INTEGER REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255),
    email     VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Books-service: book catalog
CREATE TABLE IF NOT EXISTS books (
    id     SERIAL PRIMARY KEY,
    title  VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data for local testing
INSERT INTO users (username, password) VALUES
    ('admin', 'admin123'),
    ('rahul', 'pass123')
ON CONFLICT (username) DO NOTHING;

INSERT INTO books (title, author) VALUES
    ('The Pragmatic Programmer', 'David Thomas'),
    ('Clean Code', 'Robert C. Martin'),
    ('Docker Deep Dive', 'Nigel Poulton')
ON CONFLICT DO NOTHING;
