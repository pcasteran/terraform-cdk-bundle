# terraform-cdk-bundle

A minimal bundle containing the tools required to use [CDK for Terraform](https://github.com/hashicorp/terraform-cdk)
with your favorite programming language.

The main advantage of such a bundle is that, to be able to develop and deploy ***CDKTF*** code, there is no need to
install a programming language toolchain, Node.js or even Terraform. This makes it great for clean dev and CI
environments in which a versioned set of tools translates into reproducible builds.

The tools are packaged and distributed as a Docker image, available in many flavors:

- language: `python` and `go`
- operating system: `linux` and `darwin`
- platform: `amd64` and `arm64`.

## How to use

The easiest way to use the bundle is to configure an alias referencing the required image:

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
cdktf_bundle cdktf init --template=python --local \
  --project-name=test --project-description=test \
  --no-enable-crash-reporting

cdktf_bundle cdktf provider add google

cdktf_bundle pipenv run ./main.py
cdktf_bundle cdktf deploy

# Go
cdktf_bundle cdktf init --template=go --local \
  --project-name=test --project-description=test \
  --no-enable-crash-reporting

cdktf_bundle cdktf provider add google
cdktf_bundle go mod download

cdktf_bundle go run main.go
cdktf_bundle cdktf deploy
```

If using version `0.13.3`, just ignore the following warning:

```bash
Could not run version check - A system error occurred: uv_os_get_passwd returned ENOENT (no such file or directory)
```

As usual when using the [CDKTF CLI](https://developer.hashicorp.com/terraform/cdktf/cli-reference/commands), all the
commands must be executed from the directory containing the ***CDKTF*** configuration. This directory is mounted as a
read-write volume in the run container (`--volume` option), this allows to:

- access the ***CDKTF*** configuration files from inside the container
- write the run artifacts inside the `cdktf.out` directory
- persist the different caches (downloaded Terraform providers, Python virtual environments, ...) inside the `.home`
  folder that will be automatically created (and marked as gitignored)

The Docker container is run as the current user (`--user` option), so all the files created during the execution will
have the correct owner.

## How to build

If you need to build the image, it is advised (but not mandatory) to
use [`docker buildx`](https://docs.docker.com/engine/reference/commandline/buildx_build/) which supports
the new [BuildKit](https://docs.docker.com/build/buildkit/) build backend.

Some build arguments are available to customize the image content, they can be found in the [Dockerfile](Dockerfile).
Here are the most important ones:

- `BASE`: name of the base layer to use, this layer contains the chosen programing language toolchain (`python` or `go`)
- `CDKTF_VERSION`: the version of the [cdktf-cli](https://www.npmjs.com/package/cdktf-cli) package to install
- `TERRAFORM_VERSION`: the version of [Terraform](https://developer.hashicorp.com/terraform/downloads) to install

For example:

```bash
docker buildx build \
  --build-arg "BASE=python" \
  --build-arg "CDKTF_VERSION=0.13.3" \
  --tag cdktf-bundle:my-python \
  .
```

## Miscellaneous

### Using Poetry with the Python image

When creating a new ***CDKTF*** project (`cdktf init`), you can choose between
two [built-in templates](https://github.com/hashicorp/terraform-cdk/tree/main/packages/cdktf-cli/templates) for Python
projects: `python` (which uses Pipenv as the dependency manager) and `python-pip`.

If you want to use Poetry as the dependency manager, it is possible using a community maintained
[template](https://developer.hashicorp.com/terraform/cdktf/create-and-deploy/remote-templates#use-remote-templates).
To allow that, Poetry is installed in the Python flavor Docker images.

```bash
# Python
cdktf_bundle cdktf init --local \
  --template="https://github.com/johnfraney/cdktf-remote-template-python-poetry/archive/refs/heads/main.zip" \
  --project-name=test --project-description=test \
  --no-enable-crash-reporting
```

There is however one small issue regarding the installation of providers. Currently, ***CDKTF*** only allows to install
Python packages using `pipenv` or `pip` commands (
see [`PythonPackageManager`](https://github.com/hashicorp/terraform-cdk/blob/c2ce3cb0ff63b14bb372ca03af62aae715f264f8/packages/%40cdktf/cli-core/src/lib/dependencies/package-manager.ts#L222))
.

As there is no support for Poetry, it is not possible to install a provider using the `cdktf provider add` command, for
example: `cdktf_bundle cdktf provider add google`. Instead, the provider must be installed directly using Poetry, for
example: `cdktf_bundle poetry add cdktf-cdktf-provider-google` (notice the full
PyPI [package](https://pypi.org/project/cdktf-cdktf-provider-google/) name).

### Using Google Cloud credentials

When accessing the GCP API, Terraform authenticates using
the [Application default credentials](https://cloud.google.com/docs/authentication/application-default-credentials) mechanism.

To allow using these credentials from inside the `cdktf` container, you just need to modify the alias as follows:

```bash
alias cdktf_bundle='docker run --rm -it \
  --name cdktf \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/workspace \
  --volume "${HOME}/.config/gcloud/application_default_credentials.json":/gcp/adc.json:ro \
  --env GOOGLE_APPLICATION_CREDENTIALS=/gcp/adc.json \
  ghcr.io/pcasteran/cdktf-bundle:latest-python-linux'
```

The new volume declaration mounts the JSON file containing your credentials, in read-only mode, inside the
container. Then, the standard `GOOGLE_APPLICATION_CREDENTIALS` environment variable is set to point to this file.
