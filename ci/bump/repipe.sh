#!/usr/bin/env bash

set -eo pipefail -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

pushd "${SCRIPT_DIR}" > /dev/null
(
    team_name="$(   bosh interpolate --path "/team_name"     "settings.yml")"
    pipeline_name=$(bosh interpolate --path "/pipeline_name" "settings.yml")

    set -x
    fly --target="${team_name}" \
        set-pipeline --pipeline="${pipeline_name}" \
        --config="pipeline.yml" \
        --load-vars-from="settings.yml"
)
popd > /dev/null
