# terraform-cdk-bundle

A minimal bundle containing the tools required to use [CDK for Terraform](https://github.com/hashicorp/terraform-cdk)
with your favorite programming language.

The tools are packaged and distributed as a Docker image, available in many flavors:
- language: `python` and `go`
- operating system: `linux` and `darwin`
- platform: `amd64` and `arm64`.

## How to use

The easiest way to use the tool bundle is to configure an alias referencing the image you want to use:
```bash
# Python
alias cdktf_bundle='docker run --rm -it \
  --name cdktf \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/workspace \
  ghcr.io/pcasteran/cdktf-bundle:latest-python-linux'

# Go
alias cdktf_bundle='docker run --rm -it \
  --name cdktf \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/workspace \
  ghcr.io/pcasteran/cdktf-bundle:latest-go-linux'
```

Then, you just have to prepend `cdktf_bundle` to all the commands that you want to run, for example:
```bash
# Python
cdktf_bundle cdktf init --template=python --local --project-name=test --project-description=test --no-enable-crash-reporting
cdktf_bundle cdktf provider add google

cdktf_bundle pipenv run ./main.py
cdktf_bundle cdktf deploy

# Go
cdktf_bundle cdktf init --template=go --local --project-name=test --project-description=test --no-enable-crash-reporting
cdktf_bundle cdktf provider add google
cdktf_bundle go mod download

cdktf_bundle go run main.go
cdktf_bundle cdktf deploy
```

Run from the directory containing the CDKTF configuration.
Directory mounted as a volume so the configuration is available from inside the container.
CDKTF produces the run artifacts inside the `cdktf.out` directory.
Persist the various caches (downloaded Terraform providers, Python virtual environments) inside the `.home` folder that will be automatically created inside the current directory (and marked as git ignored).
Docker container is run as the current user (`--user` option) to avoid access rights issues on the created files.

## How to build










## Python

Build the image:

```bash
CDKTF_VERSION="0.13.3"
DOCKER_BUILDKIT=1 docker build \
  --build-arg "BASE=python" \
  --build-arg "CDKTF_VERSION=${CDKTF_VERSION}" \
  --tag cdktf-bundle:${CDKTF_VERSION}-python \
  --tag cdktf-bundle:latest-python \
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
  ghcr.io/pcasteran/cdktf-bundle:ci-python'

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
  --tag cdktf-bundle:${CDKTF_VERSION}-go \
  --tag cdktf-bundle:latest-go \
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
  ghcr.io/pcasteran/cdktf-bundle:ci-go'

cdktf_bundle cdktf init --template=go --local --project-name=test --project-description=test --no-enable-crash-reporting

cdktf_bundle cdktf provider add google

go build
cdktf_bundle cdktf deploy
cdktf_bundle cdktf destroy
```

## TODO

Ignore the following warnings:

```bash
Could not run version check - A system error occurred: uv_os_get_passwd returned ENOENT (no such file or directory)
```
