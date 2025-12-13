#!/bin/bash
set -e

CLUSTER_NAME="paradox"
# Kind containers
CONTAINERS=$(kind get nodes --name $CLUSTER_NAME)

echo "Verifying cluster $CLUSTER_NAME..."
echo "Checking Kubernetes Node Names (should be alpha, gamma, segma)..."
kubectl get nodes --no-headers -o custom-columns=":metadata.name" | sort | tr '\n' ' '
echo ""

echo "Verifying Docker Nodes..."
for node in alpha gamma segma; do
    echo "--- Node Container: $node ---"
    if docker ps | grep -q "\b$node\b"; then
        echo "Container '$node' is running."
        echo "Testing internet connectivity via proxy..."
        docker exec $node curl -I -s --max-time 5 https://google.com > /dev/null && echo "  [OK] Internet" || echo "  [FAIL] Internet"
        
        echo "Testing DNS..."
        docker exec $node nslookup google.com > /dev/null && echo "  [OK] DNS" || echo "  [FAIL] DNS"
    else
        echo "Container '$node' NOT found."
    fi
done
echo "------------------------------------------------"
echo "Verification complete."
