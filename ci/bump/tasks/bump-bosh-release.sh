#!/usr/bin/env bash

set -ueo pipefail -x

function main() {
    install_yasak

    local version sha1
    version=$(< bosh-io-release/version)
    sha1=$(< bosh-io-release/sha1)

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

        make_commit
    popd > /dev/null
}

function make_commit() {
    git config --global "color.ui" "always"
    git status
    git diff | cat

    git config --global "user.name" "${GIT_COMMIT_NAME}"
    git config --global "user.email" "${GIT_COMMIT_EMAIL}"

    if [[ -z "$(git status --porcelain)" ]]; then
        echo "INFO: nothing to commit. Skipping."
    else
        git add .
        git commit -m "Bump ${RELEASE_HUMAN_NAME} to version ${version}"
    fi
}

function install_yasak() {
    go get github.com/gstackio/yasak
    sed -i 's|sed -e|sed -i -e|' "yasak/example-edit-value.sh"
    cp "yasak/example-edit-value.sh" "/usr/local/bin/update-yaml-value"
}

main "$@"
