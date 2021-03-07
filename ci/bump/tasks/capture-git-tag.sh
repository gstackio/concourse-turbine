#!/usr/bin/env bash

set -ueo pipefail -x

git_tag=$(git -C "git" describe --tags)

jq --null-input \
        --arg "git_tag" "${git_tag}" \
        '{ tag: $git_tag }' \
    | spruce merge "/dev/stdin" \
    > "git-info/${OUTPUT_FILE_NAME:-properties.yml}"
