# Terraform + Azure Kubernetes Service (AKS) Demo

End-to-end demo: Provision AKS with Terraform, deploy NGINX Ingress via Helm, deploy a sample app, and demo autoscaling (HPA + Cluster Autoscaler).

## Structure
```plain
terraform-aks-demo/
├─ modules/
│  ├─ network/
│  ├─ aks/
│  └─ acr/
├─ envs/
│  └─ dev/
├─ workloads/
│  └─ manifests/     # Sample app + Ingress + HPA
└─ .github/workflows # (optional) CI with OIDC
```

## Prereqs
- Azure CLI (`az`) logged in
- Terraform >= 1.5
- kubectl, helm

## Quickstart (dev)
```bash
cd envs/dev
terraform init
terraform apply -auto-approve

# Or with custom vars
terraform apply -var-file=terraform.tfvars

# Configure kubectl (uses output kubeconfig)
terraform output -raw kubeconfig > kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Deploy NGINX Ingress via Helm (manual)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

# Apply sample app & HPA (optional: via kubectl)
kubectl apply -f ../workloads/manifests/01_app.yaml
kubectl apply -f ../workloads/manifests/02_ingress.yaml
kubectl apply -f ../workloads/manifests/03_hpa.yaml

# Verify
kubectl get nodes -o wide
kubectl get pods -A
kubectl get ingress -A
```

## Clean up
```bash
cd envs/dev
terraform destroy
```

> Tip: First `apply` may take ~10–15 mins depending on your SKU/region. Keep a pre-provisioned cluster for live sessions.
