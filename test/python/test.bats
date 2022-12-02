#!/usr/bin/env bats

load "../node_modules/bats-support/load"
load "../node_modules/bats-assert/load"
load "../node_modules/bats-file/load"

load "../common.bash"

setup() {
    init_environment
}

teardown() {
    clean_environment
}

initialize_project() {
    initialize_project_for_template "python"
}

@test "cdktf is installed" {
    run cdktf_bundle cdktf --version
    assert_success
    assert_output --partial "Creating the HOME directory"
}

@test "init new projet" {
    run initialize_project
    assert_success
    assert_output --partial "Successfully created virtual environment!"
    assert_output --partial "Your cdktf Python project is ready!"
}

@test "add provider" {
    initialize_project

    # Install the `random` provider.
    run cdktf_bundle cdktf provider add random
    assert_success
    assert_output --partial "Found pre-built provider."
    assert_output --partial "Package installed."
}

@test "full test" {
    initialize_project

    # Add the providers.
    cdktf_bundle cdktf provider add random local

    # Replace the `main.py` file in the initialized project.
    cp ../main_full_test.py ./main.py

    # Deploy the configuration.
    assert_file_not_exist "foo.txt"
    run cdktf_bundle cdktf deploy --auto-approve
    assert_success
    assert_output --partial "Apply complete! Resources: 2 added, 0 changed, 0 destroyed."
    assert_file_exist "foo.txt"

    # Check the output.
    run cdktf_bundle cdktf output test
    assert_success
    assert_output --partial "file_name = /workspace/foo.txt"
}

@test "poetry" {
    # Initialize the project using the Poetry remote template.
    initialize_project_for_template "https://github.com/pcasteran/cdktf-remote-template-python-poetry/archive/refs/heads/update_template.zip"

    # Check the initial state.
    assert_file_not_exist "Pipfile"
    assert_file_not_exist "Pipfile.lock"
    assert_file_exist "pyproject.toml"
    assert_file_exist "poetry.lock"
    assert_file_contains "poetry.lock" '^name = "cdktf"$'

    # Install the `random` provider.
    run cdktf_bundle poetry add cdktf-cdktf-provider-random==3.0.11
    assert_success
    assert_file_contains "pyproject.toml" '^cdktf-cdktf-provider-random = ".*"'
    assert_file_contains "poetry.lock" '^name = "cdktf-cdktf-provider-random"$'
}
