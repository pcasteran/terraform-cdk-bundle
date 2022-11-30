# Tests

Suite of automated tests verifying that a Docker image is functional.

The **[bats](https://www.npmjs.com/package/bats)** framework is used to define the tests, with the actions to execute and the expecting behavior.

The tests are automatically launched  by a CI workflow following the build of a Docker image.

The image tag to be tested is specified using the `DOCKER_IMAGE` environment variable.

For an introduction on how to set up testing with **bats** see [this](https://stefanzweifel.io/posts/2020/12/22/getting-started-with-bash-testing-with-bats) post.
