.PHONY: all build create verify destroy start-proxy

all: export-cert build create verify

export-cert:
	@chmod +x scripts/export-cert.sh
	@./scripts/export-cert.sh || echo "Certificate export failed (ignoring for now, using existing if any)"

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
