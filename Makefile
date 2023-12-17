
DOCKER=docker

PLATFORMS=linux/amd64,linux/arm64/v8

WINE_VERSION = 9.0-rc2

BUILD_ARGS := --build-arg WINE_VERSION=$(WINE_VERSION)

IMAGE_TAG := $(WINE_VERSION)-wow64
IMAGE := panard/wine:$(IMAGE_TAG)

build:
	$(DOCKER) build $(BUILD_ARGS) -t $(IMAGE) .
push:
	$(DOCKER) push $(IMAGE)

buildx:
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) .

loadx: buildx
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) -t $(IMAGE) --load .
	echo $(IMAGE)

pushx: buildx
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) -t $(IMAGE) --push .
