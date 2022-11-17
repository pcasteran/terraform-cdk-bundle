# terraform-cdk-bundle

A minimal bundle containing the tools required to use CDK for Terraform

## Python

Build the image:

```bash
CDKTF_VERSION="0.13.3"
DOCKER_BUILDKIT=1 docker build \
  --build-arg "BASE=python" \
  --build-arg "CDKTF_VERSION=${CDKTF_VERSION}" \
  --tag cdktf-bundle:0.13.3-python \
  .
```

Use it:

```bash
alias cdktf_bundle='docker run --rm -it \
  --name cdktf \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/workspace \
  --volume "${HOME}/.config/gcloud/application_default_credentials.json":/gcp/adc.json:ro \
  --env GOOGLE_APPLICATION_CREDENTIALS=/gcp/adc.json \
  cdktf-bundle:0.13.3-python'

cdktf_bundle cdktf init --template=python --local --project-name=test --project-description=test --no-enable-crash-reporting

cdktf_bundle cdktf provider add google

cdktf_bundle pipenv run ./main.py
cdktf_bundle cdktf deploy
cdktf_bundle cdktf destroy
```

### Misc

Unfortunately uses Pipenv and not Poetry (TODO: links).

The package [pipenv-poetry-migrate](https://github.com/yhino/pipenv-poetry-migrate) is installed in the Docker image to
convert for Poetry.
First initialize the Poetry project:

```bash
poetry init
```

Execute the following commands everytime you want to synchronize the Poetry project with the Pipenv file:

```bash
cdktf_bundle pipenv-poetry-migrate -f Pipfile -t pyproject.toml
poetry update
```

## Go

Build the image:

```bash
CDKTF_VERSION="0.13.3"
DOCKER_BUILDKIT=1 docker build \
  --build-arg "BASE=go" \
  --build-arg "CDKTF_VERSION=${CDKTF_VERSION}" \
  --tag cdktf-bundle:0.13.3-python \
  .
```

Use it:

```bash
alias cdktf_bundle_go='docker run --rm -it \
  --name cdktf \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/workspace \
  --volume "${HOME}/.config/gcloud/application_default_credentials.json":/gcp/adc.json:ro \
  --env GOOGLE_APPLICATION_CREDENTIALS=/gcp/adc.json \
  cdktf-bundle:0.13.3-go'

cdktf_bundle_go cdktf init --template=go --local --project-name=test --project-description=test --no-enable-crash-reporting

cdktf_bundle_go cdktf provider add google

go build
cdktf_bundle_go cdktf deploy
cdktf_bundle_go cdktf destroy
```

## TODO

Ignore the following warnings:

```bash
Could not run version check - A system error occurred: uv_os_get_passwd returned ENOENT (no such file or directory)
```
