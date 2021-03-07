#!/usr/bin/env bash

set -ueo pipefail -x

source "git/ci/bump/tasks/functions.inc.bash"

install_yasak

version=$(bosh interpolate --path "/version" "artifact-info/properties.yml")
sha1=$(   bosh interpolate --path "/sha1"    "artifact-info/properties.yml")

git clone "git" "git-bumped"

pushd "git-bumped" > /dev/null

    update-yaml-value \
        "${SPEC_FILE}" \
        "/deployment_vars/${YAML_PROP_PREFIX}_version" \
        "\"${version}\""

    update-yaml-value \
        "${SPEC_FILE}" \
        "/deployment_vars/${YAML_PROP_PREFIX}_sha1" \
        "${sha1}"

popd > /dev/null

# Write properties to the keyval output resource
echo "commit_message=Bump ${ARTIFACT_HUMAN_NAME} to version ${version}" \
    >> commit-info/keyval.properties
