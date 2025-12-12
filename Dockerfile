FROM kindest/node:v1.31.0

# Env vars for proxy - MUST be first for apt to work
ENV HTTP_PROXY=http://host.docker.internal:9000
ENV HTTPS_PROXY=http://host.docker.internal:9000
ENV NO_PROXY=localhost,127.0.0.1,::1,10.96.0.0/12,192.168.0.0/16,10.244.0.0/16,paradox-control-plane,paradox-worker,paradox-worker2,.svc,.cluster.local,host.docker.internal

# Config Certs - MUST be before apt-get so we trust the proxy
COPY certs/zscaler.pem /usr/local/share/ca-certificates/zscaler.crt
RUN update-ca-certificates

# DNS Config
COPY config/resolv.conf /etc/resolv.conf

# Ensure containerd proxy config (Kind may overwrite this but good to have)
# We might need to inject this into /etc/containerd/config.toml or systemd drop-in
# But for Kind nodes, ENVs are often sufficient for the Docker daemon *inside* (which is containerd).
# However, to be safe for image pulls inside the node:
RUN mkdir -p /etc/systemd/system/containerd.service.d && \
    echo "[Service]" > /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"HTTP_PROXY=http://host.docker.internal:9000\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"HTTPS_PROXY=http://host.docker.internal:9000\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"NO_PROXY=localhost,127.0.0.1,::1,10.96.0.0/12,10.244.0.0/16,host.docker.internal\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf

# Restart containerd to apply changes (ignored if systemd not running during build)
RUN systemctl restart containerd || echo "Systemd not active, skipping restart"

# Install tools - Done LAST as requested
RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    dnsutils \
    vim \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*
