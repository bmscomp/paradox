# Paradox Kind Cluster

This project sets up a `kind` Kubernetes cluster named `paradox` with a custom node image containing network tools and configured for a local proxy.

## Prerequisites

- Docker
- Kind
- Local proxy running on port 9000
- `certs/zscaler.pem` (if required for SSL interception, place it here before build)

## Structure

- `Dockerfile`: Custom image definition.
- `kind-config.yaml`: Cluster configuration (1 controller, 2 workers).
- `scripts/`: Helper scripts.
- `Makefile`: Command shortcuts.

## Usage

1. **Configure Proxy**:
   Update `config/proxy.env` with your local proxy settings if they differ from defaults.

2. **Build the image** (automatically attempts to export Zscaler cert):
   ```bash
   make build
   ```
   *Note: If the script cannot find "Zscaler" in your Keychain, it will warn you. Please verify `certs/zscaler.pem` contains the correct certificate.*

2. **Create the cluster**:
   ```bash
   make create
   ```

3. **Verify setup**:
   ```bash
   make verify
   ```

4. **All in one**:
   ```bash
   make all
   ```

## Note on Node Names

The cluster nodes are configured to be named explicitly:
- Controller: `alpha`
- Workers: `gamma`, `segma`
(Note: Docker containers will still follow Kind's naming convention like `paradox-control-plane` but the internal Kubernetes node objects will match these names).

## Proxy Configuration

The nodes are configured to use `http://host.docker.internal:9000` as the proxy. Ensure your local machine has a proxy listener on port 9000.
