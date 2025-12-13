#!/bin/bash
IMAGE_NAME="paradox-node:v1.34.0"
echo "debugging docker dns using $IMAGE_NAME..."
# We use --entrypoint sh because kindest/node has a complex entrypoint
# We ADD --add-host because your machine's DNS cannot resolve host.docker.internal
docker run --rm --add-host host.docker.internal=host-gateway --entrypoint sh $IMAGE_NAME -c "
    echo '--- /etc/resolv.conf ---'
    cat /etc/resolv.conf
    
    echo '--- Environment Variables ---'
    env | grep -i proxy || true
    
    echo '--- nslookup host.docker.internal ---'
    nslookup host.docker.internal || echo 'nslookup failed'
    
    echo '--- ping host.docker.internal ---'
    ping -c 1 host.docker.internal || echo 'ping failed'

    echo '--- Proxy Reachability (Port 9000) ---'
    # Check if we can connect to the proxy port
    (echo > /dev/tcp/host.docker.internal/9000) >/dev/null 2>&1 && echo "TCP Connection to Proxy OK" || echo "TCP Connection to Proxy FAILED"

    echo '--- curl https://google.com ---'
    curl -v --max-time 5 https://google.com 2>&1
"
