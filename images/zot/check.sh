# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http_status 5000 /v2/)" = 200 ]; }
exercise() {
	oci_push 5000 jerboa/test v1
	oci_pull 5000 jerboa/test v1
	expect "$(http 5000 /v2/jerboa/test/tags/list)" '"v1"' "the tag list"
	expect "$(http 5000 /v2/_catalog)" '"jerboa/test"' "the catalog"
	[ "$(http_status 5000 /v2/jerboa/test/manifests/missing)" = 404 ]
}
write_data() { oci_push 5000 jerboa/kept v1; }
read_data() { oci_pull 5000 jerboa/kept v1; }
