# Infrastructure/

Terraform code that provisions the Azure cloud resources this project runs on. Infrastructure-as-code means the environment is reproducible, peer-reviewable, and destroyable with a single command — no manual portal clicks.

---

## Purpose

Provision and manage two Azure resources:
- **AKS cluster** — the Kubernetes cluster that runs the application services
- **ACR (Azure Container Registry)** — the private Docker registry the cluster pulls images from

Also establishes the AcrPull role assignment so AKS nodes can authenticate to ACR automatically without storing credentials anywhere.

---

## What Does It Contain (and Why)?

```
Infrastructure/
├── bootstrap/              One-time setup: creates the Terraform state storage account
│   ├── main.tf             Storage account + blob container in Azure
│   ├── variables.tf
│   ├── outputs.tf          Outputs the storage account name (needed for step 2 below)
│   └── terraform.tfvars
│
├── modules/
│   ├── aks/                Reusable AKS cluster module
│   │   ├── main.tf         azurerm_kubernetes_cluster resource
│   │   ├── variables.tf    Inputs: cluster name, node count, VM size, etc.
│   │   └── outputs.tf      Outputs: cluster name, kubeconfig, kubelet identity ID
│   │
│   └── acr/                Reusable ACR module
│       ├── main.tf         azurerm_container_registry resource
│       ├── variables.tf    Inputs: registry name, SKU, tags
│       └── outputs.tf      Outputs: registry name, login server, resource ID
│
├── main.tf                 Root config: provider, remote backend, resource group, module calls, role assignment
├── variables.tf            All input variables with descriptions and defaults
├── outputs.tf              Useful outputs after apply (cluster name, kubectl command, etc.)
└── terraform.tfvars        Concrete values for this environment
```

### Why `bootstrap/` is separate
Terraform needs a storage account to store its state file remotely — but the storage account itself has to be created first. `bootstrap/` solves this chicken-and-egg problem: it runs once with local state to create the storage account, then the main config uses that account as its backend for all subsequent runs.

### Why modules?
Each module (`aks/`, `acr/`) is a self-contained unit with its own inputs and outputs. This means the AKS and ACR configurations can be reasoned about, tested, and reused independently. Changes to one module don't require reading the other.

### Why `SystemAssigned` identity on AKS?
Azure manages the credentials automatically — no client secrets to rotate or store. The identity is tied to the cluster lifecycle (destroyed with it).

### Why scope `AcrPull` to the ACR resource (not the resource group)?
Least privilege — the cluster identity can only pull images from this specific registry, not perform any other operations on anything else in the resource group.

---

## How to Use It

### Prerequisites
- Terraform >= 1.5 installed
- Azure CLI logged in: `az login`
- Correct subscription active: `az account show`

### Step 1 — Bootstrap (run once)
Creates the storage account used to store Terraform state remotely.

```bash
cd Infrastructure/bootstrap
terraform init
terraform apply
# Note the storage_account_name output value
```

### Step 2 — Update the backend
Open `Infrastructure/main.tf` and replace `REPLACE_WITH_BOOTSTRAP_OUTPUT` in the `backend "azurerm"` block with the storage account name from Step 1.

```hcl
backend "azurerm" {
  resource_group_name  = "rg-devopswithai-tfstate"
  storage_account_name = "tfstatew0y5zv"   # <-- paste here
  container_name       = "tfstate"
  key                  = "devopswithai.tfstate"
}
```

### Step 3 — Deploy infrastructure
```bash
cd Infrastructure
terraform init      # connects to remote backend, downloads providers
terraform plan      # review what will be created
terraform apply     # provision AKS + ACR + role assignment (~5-10 min)
```

### Step 4 — Configure kubectl
```bash
# The exact command is printed as an output after apply:
az aks get-credentials --resource-group rg-devopswithai --name aks-devopswithai

# Verify the node is ready
kubectl get nodes
```

### Destroy (teardown order matters)
Destroy the main infrastructure first, then bootstrap — otherwise the state backend disappears before Terraform can record what it destroyed.

```bash
# 1. Destroy AKS, ACR, resource group
cd Infrastructure
terraform destroy

# 2. Destroy the state storage account
cd Infrastructure/bootstrap
terraform destroy
```

---

## Key variables (`terraform.tfvars`)

| Variable | Default | Description |
|---|---|---|
| `location` | `eastus` | Azure region |
| `resource_group_name` | `rg-devopswithai` | Main resource group |
| `cluster_name` | `aks-devopswithai` | AKS cluster name |
| `node_count` | `1` | Nodes in the default pool |
| `node_vm_size` | `Standard_D2s_v3` | Node VM size (`Standard_B2s` is not supported in AKS) |
| `acr_registry_name` | `acrdevopswithai` | Must be globally unique across Azure |
