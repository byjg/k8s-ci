# byjg/k8s-ci

[![Opensource ByJG](https://img.shields.io/badge/opensource-byjg-success.svg)](http://opensource.byjg.com)
[![Build Status](https://github.com/byjg/k8s-ci/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/byjg/k8s-ci/actions/workflows/build.yml)

## Description

A comprehensive ubuntu image with K8s and cloud tools to be used in CI/CD

This image contains everything you need to deploy to cloud.

Components installed:

- docker
- buildah
- podman
- ansible
- python 3
- kubectl
- helm
- kustomize
- ansible
- eksctl
- aws_iam_authenticator

Cloud Providers CLI Installed:

- Google Cloud (gcloud)
- Amazon Cloud (aws-cli v2)
- Digital Ocean (doctl)

Note on Google Cloud: You need to run the command below before start to use `gcloud`:

```bash
source /opt/google-cloud-sdk/path.bash.inc 
```

## Tags

Since tag 1.4.0 the image is compatible with platforms `amd64` and `aarch64` .

----
[Open source ByJG](http://opensource.byjg.com)
