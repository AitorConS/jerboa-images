# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 8428 /health >/dev/null; }
exercise() {
	http 8428 /api/v1/import/prometheus -d 'jerboa_temperature{room="lab"} 21.5' >/dev/null
	http 8428 /internal/force_flush >/dev/null
	wait_for 30 sh -c "curl -fsS 'http://$(addr 8428)/api/v1/export?match[]=jerboa_temperature' | grep -q 21.5"
	expect "$(http 8428 /metrics)" "vm_app_version{version=\"victoria-metrics-" "the version"
	expect "$(http 8428 /metrics)" "-v${VERSION}" "the version number"
}
write_data() {
	http 8428 /api/v1/import/prometheus -d 'jerboa_kept 7' >/dev/null
	http 8428 /internal/force_flush >/dev/null
	wait_for 30 sh -c "curl -fsS 'http://$(addr 8428)/api/v1/export?match[]=jerboa_kept' | grep -q jerboa_kept"
}
read_data() { expect "$(http 8428 '/api/v1/export?match[]=jerboa_kept')" '"values":[7]' "the sample from before the new VM"; }
