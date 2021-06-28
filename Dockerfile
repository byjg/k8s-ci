FROM docker.io/ubuntu:impish

ENV HELM_VERSION=3.6.1
ENV KUSTOMIZE_VERSION=4.1.3
ENV DOCTL_VERSION=1.61.0
ENV GCLOUD_VERSION=346.0.0
ENV AWS_IAM_AUTHENTICATOR="1.19.6/2021-01-05"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto

RUN apt update -y -qq \
 && apt install -y -qq wget curl gnupg gnupg2 gnupg1 \
          unzip curl wget git python3 libffi-dev build-essential \
          python3-cffi python3-pip groff ansible bash \
          docker iptables runc podman buildah \
 && echo 'cgroup_manager="cgroupfs"' >> /etc/containers/libpod.conf \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apt/archives \
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
 && chmod a+x kubectl \
 && mv kubectl /usr/bin/kubectl \
 && curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 && tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 && mv ./linux-amd64/helm /usr/bin/heml \
 && rm -rf ./linux-amd64 \
 && curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
 && tar xvf kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
 && mv kustomize /usr/bin/kustomize \
 && curl -LO https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz \
 && tar xvf doctl-${DOCTL_VERSION}-linux-amd64.tar.gz \
 && mv doctl /usr/bin/doctl \
 && curl -LO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
 && tar xvf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
 && ./google-cloud-sdk/install.sh -q \
 && echo source /google-cloud-sdk/path.bash.inc > .bashrc \
 && curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
 && mv /tmp/eksctl /usr/local/bin \
 && curl --silent -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR}/bin/linux/amd64/aws-iam-authenticator \
 && chmod a+x /usr/local/bin/aws-iam-authenticator \
 && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf aws*

WORKDIR /root
CMD [ "/bin/bash" ]
