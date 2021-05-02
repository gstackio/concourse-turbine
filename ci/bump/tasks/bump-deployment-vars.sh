#!/usr/bin/env bash

set -ueo pipefail -x

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

echo "Bump ${ARTIFACT_HUMAN_NAME} to version ${version}" > commit-info/commit-message
