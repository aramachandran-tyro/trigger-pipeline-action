#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export CURL_STUB_DEBUG=/dev/tty

teardown() {
  unset BUILDKITE_API_ACCESS_TOKEN
  unset PIPELINE
  if [[ -f "$HOME/push.json" ]]; then rm "$HOME/push.json"; fi
}

@test "Prints error and fails if \$BUILDKITE_API_ACCESS_TOKEN isn't set" {
  run $PWD/entrypoint.sh

  assert_output --partial "You must set the BUILDKITE_API_ACCESS_TOKEN environment variable"
  assert_failure
}

@test "Prints error and fails if \$PIPELINE isn't set" {
  export BUILDKITE_API_ACCESS_TOKEN="123"

  run $PWD/entrypoint.sh

  assert_output --partial "You must set the PIPELINE environment variable"
  assert_failure
}

@test "Creates a build with defaults" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"a-branch","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"a-branch"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}


@test "Creates a build with push from a \$TAG" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/tags/tag1
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"tag1","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"tag1"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}


@test "Creates a build with commit from \$COMMIT" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export COMMIT="custom-commit"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"custom-commit","branch":"a-branch","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"a-branch"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}

@test "Creates a build with branch from \$BRANCH" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export BRANCH="custom-branch"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"custom-branch","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"a-branch"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}

@test "Creates a build with branch from \$MESSAGE" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export MESSAGE="A custom message"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"a-branch","message":"A custom message","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"a-branch"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}

@test "Creates a build with build env vars from \$BUILD_ENV_VARS" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export BUILD_ENV_VARS="{\"FOO\": \"bar\"}"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"a-branch","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"FOO":"bar","GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"a-branch"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/push.json"

  assert_success

  unstub curl
}

@test "Prints error and fails if \$BUILD_ENV_VARS is not valid JSON" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export BUILD_ENV_VARS="broken"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/a-branch
  export GITHUB_EVENT_PATH="tests/push.json"
  export GITHUB_ACTION="push"

  run $PWD/entrypoint.sh

  assert_output --partial "Error: BUILD_ENV_VARS provided invalid JSON: broken"

  assert_failure
}

@test "Sets DELETED_EVENT_REF on delete event" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/master
  export GITHUB_EVENT_PATH="tests/delete.json"
  export GITHUB_ACTION="delete"
  export GITHUB_EVENT_NAME="delete"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"master","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"DELETE_EVENT_REF":"a-deleted-branch","GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"master"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/delete.json"

  assert_success

  unstub curl
}

@test "Combines DELETED_EVENT_REF and BUILD_ENV_VARS correctly" {
  export BUILDKITE_API_ACCESS_TOKEN="123"
  export PIPELINE="my-org/my-pipeline"
  export BUILD_ENV_VARS="{\"FOO\": \"bar\"}"

  export GITHUB_SHA=a-sha
  export GITHUB_REF=refs/heads/master
  export GITHUB_EVENT_PATH="tests/delete.json"
  export GITHUB_ACTION="delete"
  export GITHUB_EVENT_NAME="delete"
  export GITHUB_REPOSITORY="buildkite/test-repo"

  EXPECTED_JSON='{"commit":"a-sha","branch":"master","message":"","author":{"name":"The Pusher","email":"pusher@pusher.com"},"env":{"DELETE_EVENT_REF":"a-deleted-branch","FOO":"bar","GITHUB_REPOSITORY":"buildkite/test-repo","SOURCE_REPO_SHA":"a-sha","SOURCE_REPO_REF":"master"}}'

  stub curl "--fail --silent -X POST -H \"Authorization: Bearer 123\" https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds -d '$EXPECTED_JSON' : echo '{\"web_url\": \"https://buildkite.com/build-url\"}'"

  run $PWD/entrypoint.sh

  assert_output --partial "Build created:"
  assert_output --partial "https://buildkite.com/build-url"
  assert_output --partial "Saved build JSON to:"
  assert_output --partial "/github/home/delete.json"

  assert_success

  unstub curl
}
