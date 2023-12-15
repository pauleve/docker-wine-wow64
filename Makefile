
DOCKER=docker

PLATFORMS=linux/amd64,linux/arm64/v8

WINE_VERSION = 9.0-rc1

BUILD_ARGS := --build-arg WINE_VERSION=$(WINE_VERSION)

IMAGE_TAG := $(WINE_VERSION)-wow64
IMAGE := panard/wine:$(IMAGE_TAG)

build:
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) .

load: build
	$(DOCKER) buildx build --platform $(PLATFORMS) $(BUILD_ARGS) -t $(IMAGE) --load .
	echo $(IMAGE)
