#!/bin/bash

echo "============================================"
echo "  Starting Port Forwards"
echo "============================================"
echo ""

# Kill existing port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 1

echo "Starting port-forwards..."
echo ""

# ArgoCD
kubectl port-forward svc/argocd-server 8080:80 -n argocd &
echo "✅ ArgoCD:     http://localhost:8080"

# Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &
echo "✅ Grafana:    http://localhost:3000 (admin/admin)"

# Prometheus
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &
echo "✅ Prometheus: http://localhost:9090"

# Python App
kubectl port-forward svc/python-app-python-app 5000:80 &
echo "✅ Python App: http://localhost:5000"

echo ""
echo "============================================"
echo "  All port-forwards started!"
echo "============================================"
echo ""
echo "Press Ctrl+C to stop all port-forwards"
echo ""

# Wait for interrupt
wait

