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
    initialize_project_for_template "go"
}

@test "cdktf is installed" {
    run cdktf_bundle cdktf --version
    assert_output --partial "Creating the HOME directory"
}

@test "init new projet" {
    run initialize_project
    assert_output --partial "Your cdktf go project is ready!"
}

@test "add provider" {
    initialize_project

    # Install the `random` provider.
    run cdktf_bundle cdktf provider add random
    assert_output --partial "Found pre-built provider."
    assert_output --partial "Package installed."
}

@test "full test" {
    initialize_project

    cdktf_bundle cdktf provider add random local
    go mod download

    # Replace the `main.go` file in the initialized project.
    cp ../main_full_test.go ./main.go

    # Deploy the configuration.
    assert_file_not_exist "foo.txt"
    run cdktf_bundle cdktf deploy --auto-approve
    assert_output --partial "Apply complete! Resources: 2 added, 0 changed, 0 destroyed."
    assert_file_not_exist "foo.txt"

    # Check the output.
    run cdktf_bundle cdktf output dev
    assert_output --partial "file_name = /workspace/foo.txt"
}
