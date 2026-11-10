# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 9090 /-/ready >/dev/null; }
up() { expect "$(http 9090 '/api/v1/query?query=up' 2>/dev/null)" '"1"]' >/dev/null 2>&1; }
exercise() {
	wait_for 60 up
	expect "$(http 9090 '/api/v1/query?query=prometheus_build_info')" "\"version\":\"${VERSION}\"" "the build info"
	expect "$(http 9090 /api/v1/targets)" '"health":"up"' "the targets"
	expect "$(http 9090 '/api/v1/query?query=sum(up)')" '"result":[{' "a query"
	expect "$(http 9090 /api/v1/status/config)" "scrape_configs" "the configuration"
	http 9090 /-/reload -X POST >/dev/null
}
write_data() {
	wait_for 60 up
	sleep 16
	date +%s > "${STATE}/time"
	expect "$(http 9090 "/api/v1/query?query=count_over_time(up%5B1m%5D)&time=$(cat "${STATE}/time")")" '"result":[{'
}
read_data() {
	expect "$(http 9090 "/api/v1/query?query=count_over_time(up%5B1m%5D)&time=$(cat "${STATE}/time")")" '"result":[{' "samples from before the new VM"
}
