#!/bin/bash

# Start k8s-ci before run this command
# docker run --privileged -v /tmp/z:/var/lib/containers -it --rm -v $PWD:/work -w /work byjg/k8s-ci

if [ -z "$DOCKER_USERNAME" ]  || [ -z "$DOCKER_PASSWORD" ] || [ -z "$DOCKER_REGISTRY" ]
then
  echo You need to setup \$DOCKER_USERNAME, \$DOCKER_PASSWORD and \$DOCKER_REGISTRY before run this command.
  exit 1
fi

if [ -z "$TAG" ]
then
  echo You need to setup the $TAG
  exit 2
fi

buildah login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD $DOCKER_REGISTRY

podman run --rm --events-backend=file --cgroup-manager=cgroupfs --privileged docker://multiarch/qemu-user-static --reset -p yes

buildah bud --arch arm64 --os linux --iidfile /tmp/iid-arm64 --build-arg TARGETPLATFORM=linux/arm64 -f Dockerfile -t byjg/k8s-ci:latest-arm64 .
buildah bud --arch amd64 --os linux --iidfile /tmp/iid-amd64 --build-arg TARGETPLATFORM=linux/amd64 -f Dockerfile -t byjg/k8s-ci:latest-amd64 .

buildah manifest create byjg/k8s-ci:local
buildah manifest add byjg/k8s-ci:local --arch arm64 --os linux --variant v8 $(cat /tmp/iid-arm64)
buildah manifest add byjg/k8s-ci:local --arch amd64 --os linux $(cat /tmp/iid-amd64)

buildah manifest push --all --format v2s2 byjg/k8s-ci:local docker://byjg/k8s-ci:latest
buildah manifest push --all --format v2s2 byjg/k8s-ci:local docker://byjg/k8s-ci:$TAG

