
DOCKER=docker

PLATFORMS=linux/amd64,linux/arm64/v8

WINE_VERSION = 10.2

BUILD_ARGS := --build-arg WINE_VERSION=$(WINE_VERSION)

IMAGE_TAG := $(WINE_VERSION)-wow64
IMAGE := panard/wine:$(IMAGE_TAG)

build:
	$(DOCKER) build $(BUILD_ARGS) -t $(IMAGE) .
push:
	$(DOCKER) push $(IMAGE)
deps:
	$(DOCKER) pull debian:stable-slim
	$(DOCKER) pull debian:stable

buildx:
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) .

loadx:
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) -t $(IMAGE)x --load .
	echo $(IMAGE)x

pushx:
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) -t $(IMAGE)x --push .
