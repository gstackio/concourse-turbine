#!/usr/bin/env bash

set -ueo pipefail -x

git_tag=$(bosh interpolate --path "/tag" "git-info/properties.yml")

git clone "git" "git-bumped"

pushd "git-bumped" > /dev/null

    update-yaml-value \
        "${SPEC_FILE}" \
        "/input_resources/name=${INPUT_RESOURCE_NAME}/version" \
        "${git_tag}"

popd > /dev/null

# Write properties to the keyval output resource
echo "commit_message=Bump ${ARTIFACT_HUMAN_NAME} to ${git_tag}" \
    >> commit-info/keyval.properties
