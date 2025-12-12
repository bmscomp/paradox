#!/bin/bash
set -e

VENV_DIR=".proxy-venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Run 'make proxy-setup' first."
    exit 1
fi

source $VENV_DIR/bin/activate

echo "Starting mitmproxy on port 9000..."
echo "Proxy address: http://127.0.0.1:9000"
echo "Press Ctrl+C to stop."

# mitmdump is the command-line version (lighter than mitmproxy TUI)
# --ssl-insecure: Do not verify upstream server SSL/TLS certificates. 
# This helps if the user is behind another corporate proxy (like Zscaler) that intercepts traffic.
mitmdump --listen-port 9000 --set flow_detail=1 --ssl-insecure
