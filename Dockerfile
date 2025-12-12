FROM kindest/node:v1.31.0

# Env vars for proxy - MUST be first for apt to work
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV NO_PROXY=$NO_PROXY
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV no_proxy=$NO_PROXY

# Config Certs - MUST be before apt-get so we trust the proxy
COPY certs/zscaler.pem /usr/local/share/ca-certificates/zscaler.crt
RUN update-ca-certificates


RUN rm -f /etc/apt/apt.conf.d/*proxy*

# Ensure containerd proxy config (Kind may overwrite this but good to have)
# We might need to inject this into /etc/containerd/config.toml or systemd drop-in
# But for Kind nodes, ENVs are often sufficient for the Docker daemon *inside* (which is containerd).
# However, to be safe for image pulls inside the node:
RUN mkdir -p /etc/systemd/system/containerd.service.d && \
    echo "[Service]" > /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"HTTP_PROXY=${HTTP_PROXY}\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"HTTPS_PROXY=${HTTPS_PROXY}\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf && \
    echo "Environment=\"NO_PROXY=${NO_PROXY}\"" >> /etc/systemd/system/containerd.service.d/http-proxy.conf

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
