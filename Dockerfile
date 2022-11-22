ARG BASE="python"
ARG PYTHON_BASE_VERSION="3.10-slim"
ARG GO_BASE_VERSION="1.19-alpine3.16"

ARG PIPENV_VERSION="2022.11.11"
ARG PIPENV_POETRY_MIGRATE_VERSION="0.2.1"

ARG NODE_VERSION="18.9.1-r0"
ARG NPM_VERSION="8.10.0-r0"

ARG TERRAFORM_VERSION="1.3.5"
ARG CDKTF_VERSION="0.13.3"

FROM python:${PYTHON_BASE_VERSION}

RUN pip install --no-cache-dir black


#ARG BASE="python"
#ARG PYTHON_BASE_VERSION="3.10-alpine3.16"
#ARG GO_BASE_VERSION="1.19-alpine3.16"
#
#ARG PIPENV_VERSION="2022.11.11"
#ARG PIPENV_POETRY_MIGRATE_VERSION="0.2.1"
#
#ARG NODE_VERSION="18.9.1-r0"
#ARG NPM_VERSION="8.10.0-r0"
#
#ARG TERRAFORM_VERSION="1.3.5"
#ARG CDKTF_VERSION="0.13.3"
#
###
#
#FROM hashicorp/terraform:${TERRAFORM_VERSION} AS terraform
#
###
#
#FROM python:${PYTHON_BASE_VERSION} AS python_base
#
#ARG PIPENV_VERSION
#ARG PIPENV_POETRY_MIGRATE_VERSION
#
## Install Pipenv.
#RUN pip install --no-cache-dir \
#    pipenv==${PIPENV_VERSION} \
#    pipenv-poetry-migrate==${PIPENV_POETRY_MIGRATE_VERSION}
#
###
#
#FROM golang:${GO_BASE_VERSION} AS go_base
#
###
#
## hadolint ignore=DL3006
#FROM ${BASE}_base
#
#ARG NODE_VERSION
#ARG NPM_VERSION
#ARG CDKTF_VERSION
#
## Install node and npm.
#RUN apk add --no-cache \
#    nodejs-current=${NODE_VERSION} \
#    npm=${NPM_VERSION}
#
## Install Terraform (copy it from the official Docker image).
#COPY --from=terraform /bin/terraform /bin/terraform
#
## Install CDK for Terraform.
#ENV CHECKPOINT_DISABLE=1
#ENV DISABLE_VERSION_CHECK=1
#RUN npm install --global cdktf-cli@${CDKTF_VERSION}
#
## Create the workspace directory.
## Configure the HOME directory to be in the workspace directory for all users.
#ENV WORKSPACE_DIR="/workspace"
#ENV HOME=${WORKSPACE_DIR}/.home
#WORKDIR ${WORKSPACE_DIR}
#VOLUME ["${WORKSPACE_DIR}"]
#
## Create a new user that will be used by default if not overriden with `docker run --user ...`.
#RUN addgroup --gid 1001 --system cdktf && \
#    adduser  --uid 1001 --ingroup cdktf --shell /bin/false --disabled-password --no-create-home --system cdktf
#USER cdktf
#
## Specify the container entrypoint and its default arguments.
#COPY docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["/bin/sh"]
