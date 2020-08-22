# Alpine image with K8s and cloud tools to be used in CI/CD 

This image contains everything you need to deploy to cloud.

Components installed:

- docker
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
- Amazon Cloud (aws)
- Digital Ocean (doctl)

Note on Google Cloud: You need to run the command below before start to use `gcloud`:

```bash
source /google-cloud-sdk/path.bash.inc 
```
