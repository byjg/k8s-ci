# byjg/k8s-ci

[![Opensource ByJG](https://img.shields.io/badge/opensource-byjg-success.svg)](http://opensource.byjg.com)
[![Install MCP Server](https://img.shields.io/badge/Install-MCP_Server-8A2BE2?logo=modelcontextprotocol&logoColor=white)](https://opensource.byjg.com/docs/ai/mcpserver-byjg-docs/)
[![Build Status](https://github.com/byjg/k8s-ci/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/byjg/k8s-ci/actions/workflows/build.yml)

## Description

A small Ubuntu image for CI/CD that installs the tools a job needs when it starts.

It does not carry `kubectl`, `helm` or the cloud CLIs: it carries
[load.sh](https://shellscript.download), which installs them. You name the tools in
`CI_TOOLS`, and each job gets what it asked for, in the version it asked for. There is no
big image to pull, and none to rebuild when a tool has a new release.

```bash
docker run --rm -e CI_TOOLS="kubectl helm=3.19.0 aws-cli" byjg/k8s-ci helm version
```

## Choosing the tools: `CI_TOOLS`

`CI_TOOLS` is a list separated by spaces. Each item is the name of a script of the
[shellscript.download](https://shellscript.download) catalog:

| Item          | Installs           |
|---------------|--------------------|
| `kubectl`     | the latest version |
| `helm=3.19.0` | that version       |

Empty, which is the default, nothing is installed.

Some of the tools of the catalog:

| Tool                                  | Name in `CI_TOOLS`                |
|---------------------------------------|-----------------------------------|
| kubectl, Helm, Kustomize              | `kubectl`, `helm`, `kustomize`    |
| AWS CLI, eksctl                       | `aws-cli`, `eksctl`               |
| Google Cloud CLI (gcloud, gsutil, bq) | `gcloud`                          |
| DigitalOcean CLI                      | `doctl`                           |
| GitHub CLI                            | `gh`                              |
| jq, yq                                | `jq`, `yq`                        |
| Java, Maven, Ant                      | `java-temurin=21`, `maven`, `ant` |
| Podman, Buildah                       | `podman`, `buildah`               |

The full list is on [shellscript.download](https://shellscript.download), or
`docker run --rm byjg/k8s-ci load.sh --list`.

## How to use it

### With `docker run`

The entrypoint of the image installs what `CI_TOOLS` names, then runs your command:

```bash
docker run --rm \
  -e CI_TOOLS="kubectl kustomize" \
  -v "$PWD:/work" -w /work \
  byjg/k8s-ci kubectl apply -k overlays/production --dry-run=client
```

### In a CI system that starts the container its own way

GitHub Actions and GitLab CI replace the entrypoint of the image, so nothing is installed
when the container starts. Run `install-tools` as the first step of the job. It reads
`CI_TOOLS`, or takes the tools as arguments.

GitHub Actions:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: byjg/k8s-ci
      env:
        CI_TOOLS: "kubectl helm=3.19.0 aws-cli"
    steps:
      - uses: actions/checkout@v4
      - run: install-tools
      - run: helm upgrade --install my-app ./chart
```

GitLab CI:

```yaml
deploy:
  image: byjg/k8s-ci
  variables:
    CI_TOOLS: "kubectl helm=3.19.0"
  script:
    - install-tools
    - helm upgrade --install my-app ./chart
```

`install-tools kubectl helm=3.19.0` does the same without the variable.

### With the tools already in the image

To download nothing when a job starts, build your own image on top of this one:

```dockerfile
FROM byjg/k8s-ci
ENV CI_TOOLS="kubectl=1.34.0 helm=3.19.0 aws-cli"
RUN install-tools
```

With a version for each tool, a job that uses that image needs no network to start. A
tool without a version is the latest when the image is built, and each start checks
whether there is a newer one.

### Keeping the tools between runs

What is installed is not downloaded again. On a machine that runs many jobs, a named
volume keeps the tools from one run to the next:

```bash
docker run --rm -v k8s-ci-tools:/home/ci/.shellscript \
  -e CI_TOOLS="aws-cli gcloud" byjg/k8s-ci aws --version
```

The first run downloads both; the next ones start in about a second. Use a named volume,
not a folder of the host: Docker fills a new named volume with what the image has in that
folder, which is `load.sh` itself.

### Tools that need more than a command

Most tools are a command on the `PATH`, and work from any shell. Java, Maven and Ant
also need variables such as `JAVA_HOME`. The image sets them:

- for the command of `docker run`, whatever it is;
- for every `bash` that starts in the container, which is how a CI system runs the lines
  of a job.

A CI system that runs those lines with `sh` does not load them. GitHub Actions does so in
a container: ask it for `bash`.

```yaml
defaults:
  run:
    shell: bash
```

## What is in the image

- Ubuntu 24.04, with `bash`, `curl`, `git`, `unzip`, `python3`, `sudo` and the CA
  certificates.
- `load.sh`, from [shellscript.download](https://shellscript.download).
- `install-tools`, and the entrypoint that calls it.
- `/etc/k8s-ci/tools-env.sh`, which gives a shell what the installed tools need, and
  `BASH_ENV` pointing at it.
- A user `ci`, which the image runs as, with `sudo` without a password.

It is built for `amd64` and `arm64`.

## Users and permissions

The tools are installed by the user `ci`, in `/home/ci/.shellscript`, and are on the
`PATH` of every user of the image.

- **Run as `ci`** (the default): nothing to do.
- **Run as root**, as many CI systems do: `install-tools` hands the installation over to
  `ci`, and root uses the tools. It also works when the CI system sets another `HOME`.
- **Run as another user id** (`docker run --user 1234`): `install-tools` stops with an
  error, since that user cannot write to the home of `ci`. Use an image with the tools
  already in it.

## GitHub rate limit

`load.sh` finds the latest version of most tools without the GitHub API. `kustomize` and
`ant` still ask it, and GitHub answers 60 requests an hour to an address that does not
identify itself. On a shared runner, give the job a token, or a version for those tools:

```bash
docker run --rm -e GITHUB_TOKEN -e CI_TOOLS="kustomize" byjg/k8s-ci kustomize version
```

## Coming from an older version of this image

Up to 1.8.0 this image had every tool installed, in versions fixed when it was built. It
no longer has any:

| Before | Now |
|---|---|
| `kubectl`, `helm`, `kustomize`, `aws`, `gcloud`, `doctl`, `eksctl` in the image | name them in `CI_TOOLS` |
| `source /opt/google-cloud-sdk/path.bash.inc` before `gcloud` | not needed |
| Docker inside the image | not there: build images with the Docker of the CI system |
| `podman`, `buildah` in the image | `CI_TOOLS="podman buildah"` |
| Ansible in the image | not there: install it in an image of your own, on top of this one |
| The image ran as root | it runs as `ci`, which has `sudo` |

----
[Open source ByJG](http://opensource.byjg.com)
