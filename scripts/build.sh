#!/bin/bash
set -e

IMAGE_NAME="paradox-node:v1.31.0"

echo "Building custom Kind node image: $IMAGE_NAME"
# Check for cert exists
if [ ! -f certs/zscaler.pem ]; then
    echo "Warning: certs/zscaler.pem not found! Creating dummy."
    touch certs/zscaler.pem
fi

# Copy host resolv.conf
mkdir -p config
cp /etc/resolv.conf config/resolv.conf

docker build -t $IMAGE_NAME .
echo "Build complete."
