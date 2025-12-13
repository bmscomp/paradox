#!/bin/bash
set -e

CLUSTER_NAME="paradox"
IMAGE_NAME="paradox-node:v1.31.0"

# Destroy if exists
if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
    echo "Cluster $CLUSTER_NAME already exists. Deleting..."
    kind delete cluster --name $CLUSTER_NAME
fi

echo "Creating Kind cluster '$CLUSTER_NAME'..."
kind create cluster --config kind-config.yaml --image $IMAGE_NAME

echo "Renaming Docker containers to alpha, gamma, segma..."
# We assume standard Kind naming order: control-plane, worker, worker2 (based on config order)
# Note: Kind creates workers in parallel, so 'worker' and 'worker2' might map to gamma/segma somewhat non-deterministically
# IF the config order doesn't strictly bind them.
# However, usually the first worker defined is 'worker', second is 'worker2'.
# We defined 'gamma' then 'segma' in config.

# Handle potential existence of previous names to avoid conflict if script re-runs partially?
# The 'kind delete' above handles cleanup.

if docker ps -a | grep -q "${CLUSTER_NAME}-control-plane"; then
    docker rename "${CLUSTER_NAME}-control-plane" alpha
    echo "Renamed ${CLUSTER_NAME}-control-plane -> alpha"
fi

if docker ps -a | grep -q "${CLUSTER_NAME}-worker"; then
    # With 2 workers, one is -worker, one is -worker2.
    # We map -worker -> gamma
    if docker ps -a | grep -q "${CLUSTER_NAME}-worker$"; then # exact match end of line/name
        docker rename "${CLUSTER_NAME}-worker" gamma
        echo "Renamed ${CLUSTER_NAME}-worker -> gamma"
    fi
    # We map -worker2 -> segma
    if docker ps -a | grep -q "${CLUSTER_NAME}-worker2"; then
        docker rename "${CLUSTER_NAME}-worker2" segma
        echo "Renamed ${CLUSTER_NAME}-worker2 -> segma"
    fi
fi

# Kind likely still thinks they are named 'paradox-*' for its internal state,
# but for our usage 'docker exec alpha' will now work.

echo "Cluster '$CLUSTER_NAME' created and containers renamed."
echo "Nodes:"
kubectl get nodes
