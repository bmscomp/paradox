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

# Load proxy config
if [ -f config/proxy.env ]; then
    export $(cat config/proxy.env | xargs)
fi

docker build \
  --build-arg HTTP_PROXY="${HTTP_PROXY}" \
  --build-arg HTTPS_PROXY="${HTTPS_PROXY}" \
  --build-arg NO_PROXY="${NO_PROXY}" \
  --build-arg http_proxy="${HTTP_PROXY}" \
  --build-arg https_proxy="${HTTPS_PROXY}" \
  --build-arg no_proxy="${NO_PROXY}" \
  -t $IMAGE_NAME .
echo "Build complete."
