#!/bin/bash
set -e

VENV_DIR=".proxy-venv"

echo "Setting up local proxy simulator (mitmproxy)..."

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required."
    exit 1
fi

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv $VENV_DIR
fi

source $VENV_DIR/bin/activate

echo "Installing mitmproxy..."
pip install mitmproxy

echo "Setup complete. Run 'make proxy-start' to start the proxy."
