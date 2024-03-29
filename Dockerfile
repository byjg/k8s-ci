FROM docker.io/ubuntu:22.04

ENV HELM_VERSION=3.11.3
ENV KUSTOMIZE_VERSION=5.0.2
ENV DOCTL_VERSION=1.94.0
ENV GCLOUD_VERSION=429.0.0
ENV EKSCTL_VERSION=v0.140.0

ARG DEBIAN_FRONTEND=noninteractive
#ARG BUILDPLATFORM
ARG TARGETPLATFORM
ENV TZ=UTC

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; \
    then export PLATFORM_GOOGLE="x86_64"; export PLATFORM_AWS="x86_64";  export PLATFORM="amd64"; \
    else export PLATFORM_GOOGLE="arm";    export PLATFORM_AWS="aarch64"; export PLATFORM="arm64"; \
    fi \
 && apt update -y -qq -o=Dpkg::Use-Pty=0 \
 && apt install -y -qq -o=Dpkg::Use-Pty=0 \
          wget curl gnupg gnupg2 gnupg1 \
          unzip curl wget git python3 libffi-dev build-essential \
          python3-cffi python3-pip groff ansible bash \
          docker iptables runc podman buildah \
          jq \
 && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq \
 && echo 'cgroup_manager="cgroupfs"' >> /etc/containers/libpod.conf \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apt/archives \
 && curl -LOs https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${PLATFORM}/kubectl \
 && chmod a+x kubectl \
 && mv kubectl /usr/bin/kubectl \
 && curl -Ls https://get.helm.sh/helm-v${HELM_VERSION}-linux-${PLATFORM}.tar.gz | tar xz -C /tmp \
 && mv /tmp/linux-${PLATFORM}/helm /usr/bin/helm \
 && curl -Ls https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${PLATFORM}.tar.gz | tar xz -C /tmp \
 && mv /tmp/kustomize /usr/bin/kustomize \
 && curl -Ls https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${PLATFORM}.tar.gz | tar xz -C /tmp \
 && mv /tmp/doctl /usr/bin/doctl \
 && curl -Ls https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-${PLATFORM_GOOGLE}.tar.gz | tar xz -C /opt \
 && /opt/google-cloud-sdk/install.sh --command-completion true --path-update true -q \
 && curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_${PLATFORM}.tar.gz" | tar xz -C /tmp \
 && mv /tmp/eksctl /usr/local/bin \
 && curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${PLATFORM_AWS}.zip" -o "/tmp/awscliv2.zip" \
 && unzip -qq /tmp/awscliv2.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/*

WORKDIR /root

CMD [ "/bin/bash" ]
