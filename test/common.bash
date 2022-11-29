#!/bin/bash

WORKSPACE_DIR="workspace"

init_environment() {
    echo "# Initializing the test environment" >&3

    # Create the workspace directory.
    pushd .
    mkdir ${WORKSPACE_DIR}
    cd ${WORKSPACE_DIR}
}

clean_environment() {
    echo "# Cleaning the test environment" >&3

    # Delete the workspace directory.
    popd
    rm -rf ${WORKSPACE_DIR}
}

run_cdktf_bundle() {
    # Check that the image tag is set.
    # TODO

    docker run --rm -i \
        --name cdktf \
        --user $(id -u):$(id -g) \
        --volume $(pwd):/workspace \
        ghcr.io/pcasteran/cdktf-bundle:ci-python \
        "$@"
}

initialize_project_for_template() {
    # Get the template to use.
    template=$1
    if [ -z "${template}" ]; then
        echo "No template provided." >&2
        return 1
    fi
    echo "# Initializing project with template '${template}'" >&3

    # RUN CDKTF to initialize the project.
    run_cdktf_bundle cdktf init \
      --template=${template} \
      --local \
      --project-name="test-${template}" \
      --project-description="test-${template}" \
      --no-enable-crash-reporting
}


