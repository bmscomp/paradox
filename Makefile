.PHONY: all build create verify destroy start-proxy

all: export-cert build create verify

dev: export-mitm-cert build create verify

export-cert:
	@chmod +x scripts/export-cert.sh
	@./scripts/export-cert.sh || echo "Certificate export failed (ignoring for now, using existing if any)"

proxy-setup:
	@chmod +x proxy/setup-proxy.sh
	@cd proxy && ./setup-proxy.sh

proxy-start:
	@chmod +x proxy/start-proxy.sh
	@cd proxy && ./start-proxy.sh

proxy-trust:
	@chmod +x proxy/trust-ca.sh
	@cd proxy && ./trust-ca.sh

export-mitm-cert:
	@chmod +x proxy/export-mitm-cert.sh
	@cd proxy && ./export-mitm-cert.sh

build:
	@chmod +x scripts/build.sh
	@./scripts/build.sh

create:
	@chmod +x scripts/create-cluster.sh
	@./scripts/create-cluster.sh

verify:
	@chmod +x scripts/verify.sh
	@./scripts/verify.sh

destroy:
	kind delete cluster --name paradox

start-proxy:
	@echo "Ensure you have a proxy running on port 9000!"
