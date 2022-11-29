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
    initialize_project_for_template "python"
}

@test "cdktf is installed" {
    run run_cdktf_bundle cdktf --version

    assert_output --partial "Creating the HOME directory"
}

@test "cdktf init new projet" {
    run initialize_project

    assert_output --partial "Successfully created virtual environment!"
    assert_output --partial "Your cdktf Python project is ready!"
}
