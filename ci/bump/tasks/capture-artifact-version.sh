#!/usr/bin/env bash

set -ueo pipefail -x

version=$(< artifact/version)
sha1=$(   < artifact/sha1)

jq --null-input \
        --arg "version" "${version}" \
        --arg "sha1"    "${sha1}" \
        '{ version: $version, sha1: $sha1 }' \
    | spruce merge "/dev/stdin" \
    > "artifact-info/${OUTPUT_FILE_NAME:-properties.yml}"
