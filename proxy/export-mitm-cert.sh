#!/bin/bash
set -e

TARGET="../certs/zscaler.pem"
MITM_CERT="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"

echo "Checking for Mitmproxy CA certificate..."

if [ -f "$MITM_CERT" ]; then
    mkdir -p ../certs
    cp "$MITM_CERT" "$TARGET"
    echo "Successfully exported Mitmproxy CA cert to $TARGET"
    echo "The build will now trust the local proxy simulator."
else
    echo "Error: Mitmproxy CA certificate not found at $MITM_CERT"
    echo "Have you run 'make proxy-setup' and started the proxy at least once?"
    exit 1
fi
