#!/bin/bash
set -e

CLUSTER_NAME="paradox"
IMAGE_NAME="paradox-node:v1.34.0"

# Destroy if exists
if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
    echo "Cluster $CLUSTER_NAME already exists. Deleting..."
    kind delete cluster --name $CLUSTER_NAME
fi

echo "Creating cluster $CLUSTER_NAME using image $IMAGE_NAME..."
kind create cluster --config kind-config.yaml --image $IMAGE_NAME --name $CLUSTER_NAME

echo "Injecting host.docker.internal into /etc/hosts for all nodes..."
# Get the Kind network gateway (usually the host IP from the container's perspective)
GATEWAY_IP=$(docker network inspect kind -f '{{(index .IPAM.Config 0).Gateway}}')

# Iterate over actual Kind nodes (containers)
NODES=$(kind get nodes --name $CLUSTER_NAME)
for node in $NODES; do
    if docker ps | grep -q "\b$node\b"; then
        # Check if already exists to avoid duplication
        docker exec $node sh -c "grep -q 'host.docker.internal' /etc/hosts || echo '$GATEWAY_IP host.docker.internal' >> /etc/hosts"
        echo "Injected $GATEWAY_IP -> host.docker.internal on $node"
    fi
done

echo "Cluster '$CLUSTER_NAME' created."
echo "Cluster created."
echo "Nodes:"
kubectl get nodes
