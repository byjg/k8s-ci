#!/bin/bash

# Start k8s-ci before run this command
# docker run --privileged -v /tmp/z:/var/lib/containers -it --rm -v $PWD:/work -w /work byjg/k8s-ci

TAG="1.4.0"

podman run --rm --events-backend=file --cgroup-manager=cgroupfs --privileged docker://multiarch/qemu-user-static --reset -p yes

buildah bud --arch arm64 --iidfile /tmp/iid-arm64 -f Dockerfile -t byjg/k8s-ci:latest-arm64 .
buildah bud --arch amd64 --iidfile /tmp/iid-amd64 -f Dockerfile -t byjg/k8s-ci:latest-amd64 .

buildah manifest create byjg/k8s-ci:latest
buildah manifest add byjg/k8s-ci:latest --arch arm64 --variant v8 $(cat /tmp/iid-arm64)
buildah manifest add byjg/k8s-ci:latest --arch amd64 $(cat /tmp/iid-amd64)

buildah login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD $DOCKER_REGISTRY

buildah manifest push --all byjg/k8s-ci:latest docker://byjg/k8s-ci:latest
buildah manifest push --all byjg/k8s-ci:latest docker://byjg/k8s-ci:$TAG

