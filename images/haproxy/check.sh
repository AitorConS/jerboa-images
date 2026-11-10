# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 8404 /stats >/dev/null; }
exercise() {
	expect "$(http 80 /)" "HAProxy on Jerboa" "the default response"
	[ "$(http_status 80 /anything-else)" = 503 ]
	expect "$(http 8404 /stats)" "HAProxy version ${VERSION}" "the stats page"
	expect "$(http 8404 /metrics)" "haproxy_process_build_info{version=\"${VERSION}" "the metrics"
}
