#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
    echo "Initializing the test environment"
    pushd .
    mkdir workspace
    cd workspace
}

teardown() {
    echo "Cleaning the test environment"

    # Delete the `workspace` directory inside the current directory.
    popd
    rm -rf workspace
}

cdktf_bundle() {
  docker run --rm -i \
    --name cdktf \
    --user $(id -u):$(id -g) \
    --volume $(pwd):/workspace \
    ghcr.io/pcasteran/cdktf-bundle:ci-python \
    "$@"
}

initialize_project() {
    cdktf_bundle cdktf init \
      --template=python \
      --local \
      --project-name=test \
      --project-description=test \
      --no-enable-crash-reporting
}

@test "cdktf is installed" {
    run cdktf_bundle cdktf --version

    assert_output --partial "Creating the HOME directory"
}

@test "cdktf init new projet" {
    run initialize_project

    assert_output --partial "Successfully created virtual environment!"
    assert_output --partial "Your cdktf Python project is ready!"
}
