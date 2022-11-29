#!/usr/bin/env bats

load "../node_modules/bats-support/load"
load "../node_modules/bats-assert/load"

load "../common.bash"

setup() {
    init_environment
}

teardown() {
    clean_environment
}

initialize_project() {
    initialize_project_for_template "go"
}

@test "cdktf is installed" {
    run run_cdktf_bundle cdktf --version
    assert_output --partial "Creating the HOME directory"
}

@test "init new projet" {
    run initialize_project
    assert_output --partial "Your cdktf go project is ready!"
}

@test "add provider" {
    initialize_project

    # Install the `random` provider.
    run run_cdktf_bundle cdktf provider add random
    assert_output --partial "Found pre-built provider."
    assert_output --partial "Package installed."
}

@test "full test" {
    initialize_project

    run_cdktf_bundle cdktf provider add random local

    # Replace the `main.go` file in the initialized project.
    cp main_full_test.go ${WORKSPACE_DIR}/main.go
}
