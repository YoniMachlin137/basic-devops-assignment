# Basic DevOps Assignment

A complete local Kubernetes deployment featuring a Python Flask application with full observability stack (Prometheus, Grafana, Loki) managed by ArgoCD.

**Repository:** [https://github.com/yonimachlin137/basic-devops-assignment](https://github.com/yonimachlin137/basic-devops-assignment)

---

## 🏗️ Architecture

| Component | Description |
|-----------|-------------|
| **Python App** | Flask web application with Prometheus metrics |
| **ArgoCD** | GitOps continuous delivery |
| **Prometheus** | Metrics collection |
| **Grafana** | Dashboards and visualization |
| **Loki** | Log aggregation |
| **Promtail** | Log collection agent |

---

## 📋 Prerequisites

Install the following tools before starting:

```bash
# Install Kind (Kubernetes in Docker)
brew install kind

# Install kubectl
brew install kubectl

# Install Helm
brew install helm
```

---

## 🚀 One-Click Setup

Run the following script to deploy everything:

```bash
#!/bin/bash
set -e

echo "=== Creating Kind cluster ==="
kind create cluster --name devops-demo

echo "=== Installing ArgoCD ==="
cd helm-charts/argocd
helm dependency update
helm install argocd . -n argocd --create-namespace --wait

echo "=== Waiting for ArgoCD to be ready ==="
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo "=== ArgoCD will now deploy all applications ==="
echo "Applications being deployed:"
echo "  - python-app (default namespace)"
echo "  - kube-prometheus-stack (monitoring namespace)"
echo "  - loki (monitoring namespace)"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Save this as `setup.sh` and run:
```bash
chmod +x setup.sh
./setup.sh
```

---

## 📦 Manual Installation Steps (Only needed if automated setup didn't work)

If you prefer step-by-step installation:

### 1. Create Kind Cluster

```bash
kind create cluster --name devops-demo
```

### 2. Install ArgoCD (manages all other apps)

```bash
cd helm-charts/argocd
helm dependency update
helm install argocd . -n argocd --create-namespace
```

ArgoCD will automatically deploy:
- **python-app** - Flask application
- **kube-prometheus-stack** - Prometheus + Grafana
- **loki** - Log aggregation with Promtail

### 3. Wait for Deployments

```bash
# Check ArgoCD applications status
kubectl get applications -n argocd

# Watch pods come up
kubectl get pods -A -w
```

---

## 🔗 Access Applications

### Port Forward Commands

Run these commands to access the applications locally:

```bash
# ArgoCD UI (http://localhost:8080)
kubectl port-forward svc/argocd-server 8080:80 -n argocd &

# Grafana (http://localhost:3000)
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &

# Python App (http://localhost:5000)
kubectl port-forward svc/python-app-python-app 5000:80 &
```

### Access URLs

| Application | URL | Credentials |
|-------------|-----|-------------|
| ArgoCD | http://localhost:8080 | user: `admin`, password: see below |
| Grafana | http://localhost:3000 | user: `admin`, password: `admin` |
| Python App | http://localhost:5000 | - |

### Get ArgoCD Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## 🧪 Test the Python App

### Available Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Hello World |
| `/info` | App info (JSON) |
| `/health` | Health check |
| `/ready` | Readiness check |
| `/metrics` | Prometheus metrics |
| `/slow` | Simulated slow response (0.1-0.5s) |
| `/error` | Returns 500 error |
| `/random` | Random status codes |

### Quick Test

```bash
curl http://localhost:5000/
curl http://localhost:5000/info
curl http://localhost:5000/health
```

### Generate Load for Metrics

Run this script to generate traffic and populate Grafana dashboards:

```bash
#!/bin/bash
echo "Generating traffic to Python app..."

for i in {1..100}; do
  # Mix of different endpoints
  curl -s http://localhost:5000/ > /dev/null
  curl -s http://localhost:5000/info > /dev/null
  curl -s http://localhost:5000/slow > /dev/null
  curl -s http://localhost:5000/random > /dev/null
  curl -s http://localhost:5000/error > /dev/null 2>&1

  echo "Batch $i/100 complete"
  sleep 0.3
done

echo "Done! Check Grafana for metrics."
```

Save as `generate-traffic.sh` and run:
```bash
chmod +x generate-traffic.sh
./generate-traffic.sh
```

---

## 📊 Grafana Dashboards

After logging into Grafana:

1. Go to **Dashboards** → **Browse**
2. Find **Flask Application Metrics** dashboard
3. View request rates, error rates, and latency metrics

### Available Panels

- Requests per second (200 OK)
- Errors per second
- Total requests per minute by status code
- Average request duration
- Request duration p90
- Requests under 250ms

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Builds** multi-arch Docker image (amd64/arm64)
2. **Pushes** to GitHub Container Registry
3. **Updates** `helm-charts/python-app/values.yaml` with new image tag
4. **ArgoCD** detects the change and syncs automatically

---

## 🧹 Cleanup

Remove all resources:

```bash
kind delete cluster --name devops-demo
```
