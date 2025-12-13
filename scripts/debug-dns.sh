#!/bin/bash
echo "debugging docker dns..."
docker run --rm busybox sh -c "
    echo '--- /etc/resolv.conf ---'
    cat /etc/resolv.conf
    echo '--- nslookup host.docker.internal ---'
    nslookup host.docker.internal
    echo '--- ping host.docker.internal ---'
    ping -c 1 host.docker.internal
"
