ARG BASE="python"
ARG PYTHON_BASE_VERSION="3.11-alpine3.18"
ARG GO_BASE_VERSION="1.21-alpine3.18"

ARG PIPENV_VERSION="2023.9.8"

ARG TERRAFORM_VERSION="1.5.7"
ARG CDKTF_VERSION="0.18.0"

##

FROM python:${PYTHON_BASE_VERSION} AS python_base

ARG PIPENV_VERSION

# Install Pipenv and Poetry.
RUN pip install --no-cache-dir pipenv==${PIPENV_VERSION} && \
    apk add --no-cache poetry

##

FROM golang:${GO_BASE_VERSION} AS go_base

##

# hadolint ignore=DL3006
FROM ${BASE}_base

ARG TARGETOS
ARG TARGETARCH

ARG TERRAFORM_VERSION
ARG CDKTF_VERSION

# Install node and npm.
RUN apk add --no-cache \
    nodejs \
    npm

# Install Terraform.
WORKDIR /tmp
RUN wget -qO terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip && \
    unzip terraform.zip && \
    rm terraform.zip && \
    mv terraform /usr/local/bin/

# Install CDK for Terraform.
ENV CHECKPOINT_DISABLE=1
ENV DISABLE_VERSION_CHECK=1
RUN npm install --global cdktf-cli@${CDKTF_VERSION}

# Create the workspace directory.
# Configure the HOME directory to be in the workspace directory for all users.
ENV WORKSPACE_DIR="/workspace"
ENV HOME=${WORKSPACE_DIR}/.home
RUN mkdir -p ${WORKSPACE_DIR} && chmod 777 ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}
VOLUME ["${WORKSPACE_DIR}"]

# Create a new user that will be used by default if not overriden with `docker run --user ...`.
RUN addgroup --gid 1001 --system cdktf && \
    adduser  --uid 1001 --ingroup cdktf --shell /bin/false --disabled-password --no-create-home --system cdktf
USER cdktf

# Set the container entrypoint and its default arguments.
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh"]
