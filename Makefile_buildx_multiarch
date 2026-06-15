ACCT := telosalliance
IMAGE := ubuntu-18.04
TAG   ?= latest
FULL_PROJECT_NAME := $(ACCT)/$(IMAGE)
IMAGE_EXISTS := $(shell docker buildx ls | grep $(IMAGE))
TAG_DATE := $(shell date +'%Y-%m-%d')

.PHONY: all image run

all: image

image:
ifneq ($(IMAGE_EXISTS),)
	docker buildx rm $(IMAGE)
endif
	docker buildx create --use --platform=linux/amd64,linux/arm64 --name $(IMAGE)
	docker buildx inspect --bootstrap
	docker buildx build --push --platform linux/amd64,linux/arm64 $(ARGS) -t $(FULL_PROJECT_NAME):$(TAG) -t $(FULL_PROJECT_NAME):$(TAG_DATE) .

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile

run:
	docker run $(ARGS) \
		--hostname $(FULL_PROJECT_NAME) \
		--env LINUX_USER=$(shell id -un) \
		--env LINUX_UID=$(shell id -u) \
		--env LINUX_GROUP=$(shell id -gn) \
		--env LINUX_GID=$(shell id -g) \
		--mount src=$(HOME),target=$(HOME),type=bind \
		-ti $(FULL_PROJECT_NAME):$(TAG)
