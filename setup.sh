#!/bin/bash
set -e

echo "============================================"
echo "  DevOps Demo - One-Click Setup"
echo "============================================"
echo ""

command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Run: brew install kind"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Run: brew install kubectl"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed. Run: brew install helm"; exit 1; }

echo "✅ Prerequisites check passed"
echo ""

echo "=== Creating Kind cluster ==="
if kind get clusters | grep -q "devops-demo"; then
  echo "Cluster 'devops-demo' already exists, skipping creation"
else
  kind create cluster --name devops-demo
fi

echo ""
echo "=== Installing ArgoCD ==="
cd "$(dirname "$0")/helm-charts/argocd"
helm dependency update
helm upgrade --install argocd . -n argocd --create-namespace --wait --timeout 10m

echo ""
echo "=== Waiting for ArgoCD to be ready ==="
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo ""
echo "============================================"
echo "  ✅ Setup Complete!"
echo "============================================"
echo ""
echo "ArgoCD will now deploy all applications:"
echo "  • python-app (default namespace)"
echo "  • kube-prometheus-stack (monitoring namespace)"
echo "  • loki (monitoring namespace)"
echo ""
echo "-------------------------------------------"
echo "ArgoCD Admin Credentials:"
echo "  Username: admin"
echo -n "  Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
echo "-------------------------------------------"
echo ""
echo "Run the following commands to access applications:"
echo ""
echo "  kubectl port-forward svc/argocd-server 8080:80 -n argocd &"
echo "  kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &"
echo "  kubectl port-forward svc/python-app-python-app 5000:80 &"
echo ""
echo "============================================"
