#!/usr/bin/env bash

set -ueo pipefail -x

git_tag=$(< github-release/tag)
version=$(< github-release/version)

resolved_tarball=$(
    find "github-release" -name "${BOSH_RELEASE_TABALL}" -print \
        | head -n1
)
sha1=$(shasum -a 1 "${resolved_tarball}" | cut -d" " -f1)

jq --null-input \
        --arg "git_tag" "${git_tag}" \
        --arg "version" "${version}" \
        --arg "sha1"    "${sha1}" \
        '{ tag: $git_tag, version: $version, sha1: $sha1 }' \
    | spruce merge "/dev/stdin" \
    > "release-info/${OUTPUT_FILE_NAME:-properties.yml}"
