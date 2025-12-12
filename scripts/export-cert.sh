#!/bin/bash
set -e

TARGET="certs/zscaler.pem"
SEARCH_TERM="Zscaler Root CA"

echo "Checking for Zscaler certificate in macOS Keychain..."
mkdir -p certs

# Try to find specific Root CA first
# -c queries by Common Name
# -p outputs PEM format
# -a finds all (we take the first one or concatenates if multiple, usually fine for CAs)
if security find-certificate -c "$SEARCH_TERM" -p > "$TARGET" 2>/dev/null && [ -s "$TARGET" ]; then
    echo "Successfully exported '$SEARCH_TERM' to $TARGET"
else
    echo "Warning: '$SEARCH_TERM' not found. Searching for any certificate with 'Zscaler'..."
    if security find-certificate -c "Zscaler" -p > "$TARGET" 2>/dev/null && [ -s "$TARGET" ]; then
         echo "Successfully exported Zscaler certificate to $TARGET"
    else
         echo "Error: No Zscaler certificate found in macOS Keychain."
         echo "Please manually export your Zscaler Root CA from Chrome/Keychain Access to $TARGET"
         # Create dummy to prevent build failure if user wants to proceed without it?
         # User explicitly asked for export, so failure is appropriate if missing.
         rm -f "$TARGET"
         exit 1
    fi
fi
