#!/bin/bash

echo "============================================"
echo "  Generating traffic to Python App"
echo "============================================"
echo ""

# Check if app is accessible
if ! curl -s http://localhost:5000/health > /dev/null 2>&1; then
  echo "❌ Python app not accessible at http://localhost:5000"
  echo ""
  echo "Run this first:"
  echo "  kubectl port-forward svc/python-app-python-app 5000:80 &"
  exit 1
fi

echo "✅ Python app is accessible"
echo ""

BATCHES=${1:-50}
echo "Running $BATCHES batches of requests..."
echo ""

for i in $(seq 1 $BATCHES); do
  # Success endpoints
  curl -s http://localhost:5000/ > /dev/null
  curl -s http://localhost:5000/about > /dev/null
  curl -s http://localhost:5000/info > /dev/null
  curl -s http://localhost:5000/health > /dev/null

  # Slow endpoint (for latency metrics)
  curl -s http://localhost:5000/slow > /dev/null

  # Random status codes
  curl -s http://localhost:5000/random > /dev/null

  # Error endpoint (for error rate metrics)
  curl -s http://localhost:5000/error > /dev/null 2>&1

  printf "\rProgress: %d/%d batches" "$i" "$BATCHES"
  sleep 0.2
done

echo ""
echo ""
echo "============================================"
echo "  ✅ Traffic generation complete!"
echo "============================================"
echo ""
echo "Check Grafana for metrics:"
echo "  http://localhost:3000"
echo "  Dashboard: Flask Application Metrics"
echo ""

