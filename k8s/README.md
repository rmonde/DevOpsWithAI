# k8s/

Kubernetes manifests that describe how the application runs inside AKS. Each file is a declarative spec — you tell Kubernetes the desired state and it figures out how to get there.

---

## Purpose

Deploy all four services (Auth, Books, User, DB) to the AKS cluster provisioned by `Infrastructure/`. The manifests handle configuration injection, secret management, persistent storage, network exposure, and health checking — the same concerns Docker Compose handles locally, but in a production-grade way.

---

## What Does It Contain (and Why)?

```
k8s/
├── configmap.yml           Non-sensitive config shared across services
├── secret.yml              Sensitive credentials (base64-encoded)
├── db-pvc.yml              Persistent volume claim for PostgreSQL data
├── db-deployment.yml       PostgreSQL deployment (1 replica)
├── db-service.yml          Internal ClusterIP service for the database
├── auth-deployment.yml     Auth-service deployment (2 replicas)
├── auth-service.yml        ClusterIP service for auth
├── books-deployment.yml    Books-service deployment
├── books-service.yml       ClusterIP service for books
├── user-deployment.yml     User-service deployment
└── user-service.yml        ClusterIP service for users
```

### `configmap.yml` — Non-sensitive shared configuration
Stores `DATABASE_HOST`, `DATABASE_NAME`, and `DATABASE_PORT`. ConfigMaps are stored in plain text in etcd, so only non-sensitive values belong here. All app deployments reference this ConfigMap for their DB connection config.

**Why not just hardcode values in each deployment?** A ConfigMap is one place to change — update it and redeploy, no need to touch four separate deployment files.

### `secret.yml` — Sensitive credentials
Stores `DB_USERNAME` and `DB_PASSWORD` as base64-encoded strings. Kubernetes Secrets are kept separate from ConfigMaps so they can be managed with tighter RBAC policies in production (e.g. only the DB pod can read the DB password).

> Note: For a real production setup, use Azure Key Vault with the Secrets Store CSI driver instead of storing secrets in YAML files.

### `db-pvc.yml` — Persistent Volume Claim
Requests a 5Gi persistent disk from AKS for PostgreSQL data. Without this, database data would be lost every time the pod restarts (containers are ephemeral by default).

**Why a PVC and not a hostPath?** PVCs are cluster-managed — AKS provisions an Azure Managed Disk automatically and re-attaches it to the pod if it moves to a different node.

### `db-deployment.yml` — Database deployment
Runs 1 replica of the PostgreSQL image from ACR. Single replica because PostgreSQL requires special coordination (streaming replication) to run as multiple replicas — out of scope for this project.

### `auth-deployment.yml` (and books, user) — Application deployments
Each runs 2 replicas for basic availability — if one pod crashes or a node is drained, the other keeps serving traffic. Key features per deployment:

- **`initContainers`** — a `busybox` container that loops `nc -z db-service 5432` until the DB is reachable before the main container starts. This replaces the Docker Compose `depends_on: condition: service_healthy`.
- **`env` from ConfigMap + Secret** — no credentials or config baked into the image; values are injected at runtime.
- **`imagePullPolicy: Never`** — tells AKS to use locally loaded images. Change this to `Always` once images are pushed to ACR and the image reference is updated to `acrdevopswithai.azurecr.io/<service>:latest`.
- **`readinessProbe` + `livenessProbe`** — Kubernetes checks the service port before sending it traffic (readiness) and restarts it if it stops responding (liveness).

### `*-service.yml` files — Kubernetes Services
Each creates a `ClusterIP` service — an internal DNS name and stable IP inside the cluster. `db-service` is what `DATABASE_HOST: db-service` in the ConfigMap resolves to. App services use ClusterIP because they only need to talk to each other, not be exposed to the internet (an Ingress would handle external traffic in a full setup).

---

## How to Use It

### Prerequisites
1. AKS cluster provisioned and `kubectl` configured (see `Infrastructure/README.md`)
2. Docker images built and pushed to ACR:
   ```bash
   ACR=acrdevopswithai.azurecr.io
   az acr login --name acrdevopswithai
   docker build -t $ACR/auth-service:latest ./backend/Auth-service && docker push $ACR/auth-service:latest
   docker build -t $ACR/books-service:latest ./backend/Books-service && docker push $ACR/books-service:latest
   docker build -t $ACR/user-service:latest ./backend/User-service && docker push $ACR/user-service:latest
   docker build -t $ACR/db-service:latest ./backend/DB-service && docker push $ACR/db-service:latest
   ```
3. Update `image:` fields in each deployment YAML from `devopswithai-*:latest` to `acrdevopswithai.azurecr.io/*:latest`

### Deploy (apply order matters — DB and config first)
```bash
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secret.yml
kubectl apply -f k8s/db-pvc.yml
kubectl apply -f k8s/db-deployment.yml
kubectl apply -f k8s/db-service.yml

# Wait for DB to be ready
kubectl wait --for=condition=ready pod -l app=db --timeout=120s

kubectl apply -f k8s/auth-deployment.yml
kubectl apply -f k8s/auth-service.yml
kubectl apply -f k8s/books-deployment.yml
kubectl apply -f k8s/books-service.yml
kubectl apply -f k8s/user-deployment.yml
kubectl apply -f k8s/user-service.yml
```

Or apply everything at once (Kubernetes will retry until dependencies are satisfied):
```bash
kubectl apply -f k8s/
```

### Verify everything is running
```bash
kubectl get pods          # all pods should show Running
kubectl get services      # all services should show ClusterIP
kubectl get pvc           # db-pvc should show Bound
```

### Test a service from inside the cluster
```bash
kubectl run test --rm -it --image=curlimages/curl -- sh
# Inside the pod:
curl http://auth-service:3000/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Tear down
```bash
kubectl delete -f k8s/
```
