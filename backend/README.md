# backend/

The application layer — four Python Flask services that together implement a simple books platform. Each service owns one domain and talks to a shared PostgreSQL database.

---

## Purpose

Demonstrate a microservices architecture where each service is independently deployable. Each has its own Dockerfile, its own dependencies, and its own responsibility — no shared application code between services.

---

## What Does It Contain (and Why)?

```
backend/
├── Auth-service/       Login endpoint — validates username + password
├── Books-service/      Book catalogue — list and search books
├── User-service/       User management — create and list users
└── DB-service/         PostgreSQL database with schema + seed data
```

### Auth-service (port 3000)
Exposes `POST /login`. Accepts a JSON body with `username` and `password`, queries the `users` table, and returns 200 on success or 401 on failure.

**Why a separate service?** Authentication logic is isolated so it can be secured, scaled, or swapped (e.g. for JWT) without touching the other services.

### Books-service (port 3001)
Exposes `GET /books`. Returns all books from the `books` table as JSON.

**Why a separate service?** The book catalogue has different scaling characteristics from user management. In production, you might scale Books-service horizontally under read load while keeping User-service at one replica.

### User-service (port 3002)
Exposes `GET /users` and `POST /users`. Lists all users and creates new ones.

**Why a separate service?** User lifecycle management (creation, profile updates) is distinct from authentication. Keeping them separate avoids one large monolithic service.

### DB-service (PostgreSQL 16)
A PostgreSQL 16 container built from `postgres:16-alpine`. On first startup it automatically runs `init.sql`, which:
- Creates the `users`, `user_profiles`, and `books` tables
- Seeds two test users (`admin`, `rahul`) and three books

**Why a custom Dockerfile?** By baking `init.sql` into the image, the database is always ready with the correct schema when the container starts — no separate migration step needed for local development.

---

### Dockerfile pattern (same for all three app services)

All three Flask services share the same multi-stage Dockerfile pattern:

| Stage | Base image | What it does |
|-------|-----------|--------------|
| `builder` | `python:3.12-slim` | Installs dependencies into `/install` with `--prefix` so they are isolated |
| `runtime` | `python:3.12-slim` | Copies only the installed packages (no build tools), runs as non-root `appuser` |

**Why multi-stage?** The final image contains no pip, no compiler, and no build cache — smaller attack surface and smaller image size.

**Why Gunicorn?** Flask's built-in server is single-threaded and not safe for production. Gunicorn spawns 2 worker processes per container, each handling requests concurrently.

**Why non-root user?** If a container is compromised, the attacker gets `appuser` (no sudo, no system access) rather than `root`.

---

## How to Use It

### Run locally with Docker Compose (recommended)
From the project root:
```bash
docker-compose up --build
```
Docker Compose starts all four services and waits for the database healthcheck before starting the app services.

### Run a single service in isolation
```bash
cd backend/Auth-service
docker build -t auth-service .
docker run -p 3000:3000 \
  -e DB_HOST=<host> \
  -e DB_NAME=books_db \
  -e DB_USER=postgres \
  -e DB_PASSWORD=admin123 \
  auth-service
```

### Test the endpoints
```bash
# Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# List books
curl http://localhost:3001/books

# List users
curl http://localhost:3002/users

# Create a user
curl -X POST http://localhost:3002/users \
  -H "Content-Type: application/json" \
  -d '{"name": "alice", "password": "pass", "email": "alice@example.com"}'
```

### Build and push to ACR (for AKS deployment)
```bash
ACR=acrdevopswithai.azurecr.io
az acr login --name acrdevopswithai

for service in Auth-service Books-service User-service DB-service; do
  docker build -t $ACR/${service,,}:latest ./backend/$service
  docker push $ACR/${service,,}:latest
done
```
