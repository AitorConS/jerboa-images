# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http 8181 /ready)" = OK ]; }
exercise() {
	# 192.0.2.10 in the answer: c000020a.
	expect "$(dns_query 53 example.jerboa.test)" "c000020a" "the A record from the hosts plugin"
	expect "$(http 8080 /health)" "OK" "the health"
	expect "$(http 9153 /metrics)" "coredns_build_info{" "the metrics"
	expect "$(http 9153 /metrics)" "version=\"${VERSION}\"" "the version"
}
