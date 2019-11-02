FROM alpine:3.10

RUN apk add --no-cache curl wget git python3 libffi-dev build-base py3-cffi ansible bash docker \
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
 && chmod a+x kubectl \
 && mv kubectl /usr/bin/kubectl \
 && curl -LO https://get.helm.sh/helm-v2.15.2-linux-amd64.tar.gz \
 && tar xvf helm-v2.15.2-linux-amd64.tar.gz \
 && mv ./linux-amd64/tiller /usr/bin/tiller \
 && mv ./linux-amd64/helm /usr/bin/heml \
 && rm -rf ./linux-amd64 \
 && curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.3.0/kustomize_v3.3.0_linux_amd64.tar.gz \
 && tar xvf kustomize_v3.3.0_linux_amd64.tar.gz \
 && mv kustomize /usr/bin/kustomize \
 && curl -LO https://github.com/digitalocean/doctl/releases/download/v1.33.1/doctl-1.33.1-linux-amd64.tar.gz \
 && tar xvf doctl-1.33.1-linux-amd64.tar.gz \
 && mv doctl /usr/bin/doctl \
 && pip3 install --upgrade pip \
 && curl -LO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-269.0.0-linux-x86_64.tar.gz \
 && tar xvf google-cloud-sdk-269.0.0-linux-x86_64.tar.gz \
 && ./google-cloud-sdk/install.sh -q \
 && echo source /google-cloud-sdk/path.bash.inc > .bashrc \
 && curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
 && mv /tmp/eksctl /usr/local/bin \
 && pip install awscli boto3 boto botocore

WORKDIR /root
CMD [ "/bin/bash" ]
