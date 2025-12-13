#!/bin/bash
IMAGE_NAME="paradox-node:v1.34.0"
echo "debugging docker dns using $IMAGE_NAME..."
# We use --entrypoint sh because kindest/node has a complex entrypoint
docker run --rm --entrypoint sh $IMAGE_NAME -c "
    echo '--- /etc/resolv.conf ---'
    cat /etc/resolv.conf
    
    echo '--- Environment Variables ---'
    env | grep_PROXY || true
    
    echo '--- nslookup host.docker.internal ---'
    nslookup host.docker.internal || echo 'nslookup failed'
    
    echo '--- ping host.docker.internal ---'
    ping -c 1 host.docker.internal || echo 'ping failed'

    echo '--- curl https://google.com ---'
    curl -I -s --max-time 5 https://google.com && echo '[OK] Internet Access' || echo '[FAIL] Internet Access'
"
