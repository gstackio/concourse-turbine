#!/usr/bin/env bash

set -eo pipefail

BASE_DIR=${BASE_DIR:-$(git rev-parse --show-toplevel)}
SUBSYS_DIR=${SUBSYS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}

source "${BASE_DIR}/lib/hooks-api/common.inc.bash"
source "${BASE_DIR}/lib/hooks-api/bosh-releases.inc.bash"

function _config() {
    input_resource_index="0"
    rename_stemcell_feature="pin-rename-stemcell"
}

function main() {
    _config

    local rsc_name  rsc_dir
    rsc_name=$(spec_var "/input_resources/${input_resource_index}/name")
    rsc_dir="${BASE_DIR}/.cache/resources/${rsc_name}"

    refresh_dependent_ops_file "${rsc_dir}/cluster/concourse.yml" \
        "/instance_groups/name=db" \
        "${SUBSYS_DIR}/features/reorder-instance-groups.yml"

    refresh_stemcell_alias "${rsc_dir}/cluster/concourse.yml" \
        "/stemcells/0/alias" \
        "${SUBSYS_DIR}/features/${rename_stemcell_feature}.yml"
}

function refresh_dependent_ops_file() {
    local src_yaml_file=$1; shift
    local yaml_path=$1; shift
    local dest_ops_file=$1; shift

    sed_in_place -ne '1,/~~~START_OF_GENERATED_FOOTER~~~/p' "${dest_ops_file}"

    bosh interpolate "${src_yaml_file}" --path "${yaml_path}" \
        | sed -e 's/^/    /' \
        >> "${dest_ops_file}"
}

function refresh_stemcell_alias() {
    local src_yaml_file=$1; shift
    local yaml_path=$1; shift
    local dest_ops_file=$1; shift

    local stemcell_alias
    stemcell_alias=$(bosh interpolate "${src_yaml_file}" --path "${yaml_path}")

    sed_in_place -E -e "s|^(- path: /stemcells/alias=)[[:alnum:]]+([[:space:]].*)$|\\1${stemcell_alias}\\2|" \
        "${dest_ops_file}"
}

function sed_in_place() {
    local operating_system
    operating_system="$(uname -s)"

    local sed_in_place_args=("-i")
    if [[ "${operating_system}" == "Darwin" ]]; then
        sed_in_place_args+=("")
    fi

    sed "${sed_in_place_args[@]}" "$@"
}

main "$@"
