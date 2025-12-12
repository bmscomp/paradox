#!/bin/bash
set -e

CLUSTER_NAME="paradox"
# Kind containers
CONTAINERS=$(kind get nodes --name $CLUSTER_NAME)

echo "Verifying cluster $CLUSTER_NAME..."
echo "Checking Kubernetes Node Names (should be alpha, gamma, segma)..."
kubectl get nodes --no-headers -o custom-columns=":metadata.name" | sort | tr '\n' ' '
echo ""

echo "Verifying Docker Nodes ($CONTAINERS)..."

for node in $CONTAINERS; do
    echo "------------------------------------------------"
    echo "Checking container: $node"
    
    # Check tools
    echo "Checking tools..."
    docker exec $node which curl > /dev/null && echo "  curl: OK" || echo "  curl: MISSING"
    docker exec $node which ping > /dev/null && echo "  ping: OK" || echo "  ping: MISSING"
    docker exec $node which nslookup > /dev/null && echo "  nslookup: OK" || echo "  nslookup: MISSING"
    docker exec $node which dig > /dev/null && echo "  dig: OK" || echo "  dig: MISSING"

    # Check proxy/internet
    echo "Checking internet connectivity via proxy..."
    # We expect HTTP_PROXY to be set in the container
    # We try to reach google.com
    if docker exec $node curl -I -s --max-time 5 http://google.com > /dev/null; then
        echo "  Internet (http): OK"
    else
        echo "  Internet (http): FAILED"
    fi

    # Check DNS
    echo "Checking DNS..."
    if docker exec $node nslookup google.com > /dev/null; then
         echo "  DNS: OK"
    else
         echo "  DNS: FAILED"
    fi
done
echo "------------------------------------------------"
echo "Verification complete."
