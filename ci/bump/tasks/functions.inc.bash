
function install_yasak() {
    if [[ ! -f ${GOPATH}/bin/yasak ]] || ! yasak -h > /dev/null; then
        go get github.com/gstackio/yasak
    fi
    if [[ ! -f /usr/local/bin/update-yaml-value || ! -x /usr/local/bin/update-yaml-value ]]; then
        yasak_dir="${GOPATH}/src/github.com/gstackio/yasak"
        sed -i 's|sed -e|sed -i -e|' "${yasak_dir}/example-edit-value.sh"
        cp "${yasak_dir}/example-edit-value.sh" "/usr/local/bin/update-yaml-value"
    fi
}
