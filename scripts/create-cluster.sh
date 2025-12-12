#!/bin/bash
set -e

CLUSTER_NAME="paradox"
IMAGE_NAME="paradox-node:v1.31.0"

# Destroy if exists
if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
    echo "Cluster $CLUSTER_NAME already exists. Deleting..."
    kind delete cluster --name $CLUSTER_NAME
fi

echo "Creating cluster $CLUSTER_NAME using image $IMAGE_NAME..."
kind create cluster --config kind-config.yaml --image $IMAGE_NAME --name $CLUSTER_NAME

echo "Cluster created."
echo "Nodes:"
kubectl get nodes
