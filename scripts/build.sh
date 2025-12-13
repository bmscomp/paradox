#!/bin/bash
set -e

IMAGE_NAME="paradox-node:v1.34.0"

echo "Building custom Kind node image: $IMAGE_NAME"
# Check for cert exists
if [ ! -f certs/zscaler.pem ]; then
    echo "Warning: certs/zscaler.pem not found! Creating dummy."
    touch certs/zscaler.pem
fi

# Prepare DNS from host and append Google DNS
mkdir -p config
cat /etc/resolv.conf > config/resolv.conf
echo "nameserver 8.8.8.8" >> config/resolv.conf
echo "nameserver 8.8.4.4" >> config/resolv.conf

# Load proxy config for build args only
PROXY_ARGS=""
if [ -f config/proxy.env ]; then
    # Read file line by line to extract values without exporting to host shell
    # We strip 'export ' if present, though user file doesn't have it.
    # We assume simple KEY=VALUE format.
    
    # Source in a subshell to get values, then print them? 
    # Or just parse them. simpler to source in current shell but use different variable names?
    # No, the user provided file has standard names HTTP_PROXY=...
    
    # We will use 'set -a; source config/proxy.env; set +a' inside the build command? 
    # No, that's messy.
    
    # Safest: Read the file and pass generic args, but we need to NOT set HTTP_PROXY in the shell.
    # We can do: eval $(cat config/proxy.env | sed 's/^/BUILD_/')
    # Then use BUILD_HTTP_PROXY.
    
    eval $(cat config/proxy.env | sed 's/^/BUILD_/')
fi

docker build \
  --build-arg HTTP_PROXY="${BUILD_HTTP_PROXY}" \
  --build-arg HTTPS_PROXY="${BUILD_HTTPS_PROXY}" \
  --build-arg NO_PROXY="${BUILD_NO_PROXY}" \
  --build-arg http_proxy="${BUILD_HTTP_PROXY}" \
  --build-arg https_proxy="${BUILD_HTTPS_PROXY}" \
  --build-arg no_proxy="${BUILD_NO_PROXY}" \
  -t $IMAGE_NAME .
echo "Build complete."
