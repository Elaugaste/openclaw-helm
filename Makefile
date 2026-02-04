IMAGE_NAME ?= elaugaste/openclaw
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io
DOCKER_IMAGE = $(if $(REGISTRY),$(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG),$(IMAGE_NAME):$(IMAGE_TAG))

REPO_URL = https://github.com/openclaw/openclaw.git
OPENCLAW_DOCKER_APT_PACKAGES ?= "ffmpeg build-essential git curl jq"
PLATFORM ?= linux/amd64

.PHONY: build push clean helm-lint helm-template

build:
	@echo "Building OpenClaw image for $(PLATFORM)..."
	@rm -rf /tmp/openclaw-build
	@git clone --depth 1 $(REPO_URL) /tmp/openclaw-build
	@docker build --platform $(PLATFORM) --build-arg OPENCLAW_DOCKER_APT_PACKAGES=$(OPENCLAW_DOCKER_APT_PACKAGES) -t $(DOCKER_IMAGE) /tmp/openclaw-build
	@echo "Image built: $(DOCKER_IMAGE)"

push:
	@if [ -z "$(REGISTRY)" ]; then \
		echo "REGISTRY is not set. Cannot push."; \
		exit 1; \
	fi
	docker push $(DOCKER_IMAGE)

clean:
	@rm -rf /tmp/openclaw-build

helm-lint:
	helm lint .

helm-template:
	helm template openclaw .
