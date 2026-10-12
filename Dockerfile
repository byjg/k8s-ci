FROM docker.io/ubuntu:24.04

# A small image that installs the tools a job needs when it starts, with load.sh
# (https://shellscript.download). CI_TOOLS names them:
#   docker run -e CI_TOOLS="kubectl helm=3.19.0 aws-cli" byjg/k8s-ci helm version
# Empty, nothing is installed. See README.md.
ENV CI_TOOLS=""

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# load.sh installs for a regular user, never for root: 'ci' is that user. It has sudo,
# for the tools that come from the packages of the system (podman, buildah).
RUN apt-get update -y -qq -o=Dpkg::Use-Pty=0 \
 && apt-get install -y -qq -o=Dpkg::Use-Pty=0 --no-install-recommends \
          ca-certificates curl unzip git python3 sudo \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives \
 && useradd --create-home --shell /bin/bash ci \
 && echo 'ci ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ci \
 && chmod 755 /home/ci

COPY bin/install-tools bin/entrypoint /usr/local/bin/
COPY bin/tools-env.sh /etc/k8s-ci/tools-env.sh

# What 'ci' installs is used by every user of the image, root included. Some tools also
# need something in the shell (JAVA_HOME): every bash loads it.
ENV PATH="/home/ci/.shellscript/bin:${PATH}" \
    BASH_ENV="/etc/k8s-ci/tools-env.sh"

USER ci
WORKDIR /home/ci

RUN /bin/bash -c "$(curl -fsSL https://shellscript.download/install/loader)" \
 && rm -rf /tmp/*

ENTRYPOINT [ "entrypoint" ]
CMD [ "/bin/bash" ]
