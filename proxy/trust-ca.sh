#!/bin/bash
set -e

MITM_CERT="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"

if [ ! -f "$MITM_CERT" ]; then
    echo "Error: Certificate not found at $MITM_CERT"
    echo "Run 'make proxy-setup' and 'make proxy-start' first."
    exit 1
fi

echo "Adding Mitmproxy CA to macOS System Keychain..."
echo "You may be prompted for your password."

sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$MITM_CERT"

echo "Certificate trusted. You may need to restart Docker Desktop for changes to take effect."
