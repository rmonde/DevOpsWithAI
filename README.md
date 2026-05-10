# DevOpsWithAI

A hands-on learning project that containerises a Python Flask microservices application and deploys it to Azure Kubernetes Service (AKS). The project progresses through three layers: local Docker development → Docker Compose orchestration → Kubernetes on Azure.

---

## Purpose

Practice the full DevOps lifecycle — from writing a multi-service application, to containerising each service, to provisioning cloud infrastructure with Terraform, to deploying and managing the application on Kubernetes.

---

## What Does It Contain (and Why)?

```
DevOpsWithAI/
├── backend/            Flask microservices + Dockerfiles
├── Infrastructure/     Terraform code to provision Azure resources
├── k8s/                Kubernetes manifests for AKS deployment
├── docker-compose.yml  Local multi-service orchestration
└── .claude/            Claude Code settings (MCP servers for Azure + AKS)
```

### `backend/`
Four Flask services that together form a simple books application. Each service has its own Dockerfile so it can be built and deployed independently — this mirrors how real microservice teams work.

### `docker-compose.yml`
Wires all four services together locally. A single `docker-compose up` starts the full stack without needing Kubernetes or Azure. This is the fastest feedback loop during development.

### `Infrastructure/`
Terraform code that creates the Azure cloud resources the application runs on (AKS cluster, ACR registry). Infrastructure-as-code means the environment is reproducible and version-controlled, not a set of manual portal clicks.

### `k8s/`
Kubernetes manifests that describe how each service should run inside AKS — how many replicas, where to get its config and secrets, how to expose it on the network, and how to check it is healthy.

### `.claude/settings.json`
Configures two MCP (Model Context Protocol) servers so Claude Code can interact directly with Azure and AKS from within the IDE.

---

## Prerequisites

- Docker Desktop
- Azure CLI (`az`) — logged in via `az login`
- Terraform >= 1.5
- `kubectl`
- `helm` (optional, for future add-ons)

---

## How to Use It

### Local development (Docker Compose)
```bash
# Start the full stack locally
docker-compose up --build

# Services will be available at:
# Auth:  http://localhost:3000
# Books: http://localhost:3001
# Users: http://localhost:3002
```

### Cloud deployment (Terraform + Kubernetes)
Follow the READMEs in order:
1. [`Infrastructure/README.md`](Infrastructure/README.md) — provision AKS + ACR
2. [`backend/README.md`](backend/README.md) — build and push images to ACR
3. [`k8s/README.md`](k8s/README.md) — deploy to AKS

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│                   AKS Cluster               │
│                                             │
│  ┌────────────┐  ┌────────────┐             │
│  │auth-service│  │books-service│            │
│  │  :3000     │  │   :3001    │             │
│  └─────┬──────┘  └─────┬──────┘            │
│        │               │                   │
│  ┌─────┴───────────────┴──┐                │
│  │       db-service        │               │
│  │    PostgreSQL :5432     │               │
│  └────────────────────────┘                │
│                                             │
│  ┌────────────┐                             │
│  │user-service│                             │
│  │   :3002    │                             │
│  └────────────┘                             │
└─────────────────────────────────────────────┘
        ▲ pulls images from
┌───────────────────┐
│  Azure Container  │
│  Registry (ACR)   │
└───────────────────┘
```
