#!/usr/bin/env bash

set -eo pipefail

SUBSYS_DIR=${SUBSYS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}
BASE_DIR=${BASE_DIR:-$(cd "${SUBSYS_DIR}" && git rev-parse --show-toplevel)}

source "${BASE_DIR}/lib/hooks-api/common.inc.bash"
source "${BASE_DIR}/lib/hooks-api/bosh-releases.inc.bash"

function _config() {
    must_provide_dev_release="true"
    input_resource_index="0"
    release_name="harbor-container-registry"
}

function main() {
    _config

    local developing
    developing=$(own_spec_var "/developing" 2> /dev/null || true)

    if [[ "${developing}" == "true" ]]; then
        delete_any_existing_unused_release "${release_name}"
        create_upload_dev_release_if_necessary \
            "${input_resource_index}" "${release_name}"
    elif [[ "${must_provide_dev_release}" == "true" ]]; then
        create_upload_dev_release_only_if_missing \
            "${input_resource_index}" "${release_name}"
    fi
}

main "$@"
