# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 9115 /-/healthy >/dev/null; }
exercise() {
	expect "$(http 9115 '/probe?target=127.0.0.1:9115&module=tcp_connect')" "probe_success 1" "a TCP probe"
	expect "$(http 9115 '/probe?target=http://127.0.0.1:9115/-/healthy&module=http_2xx')" "probe_success 1" "an HTTP probe"
	expect "$(http 9115 '/probe?target=127.0.0.1:1&module=tcp_connect')" "probe_success 0" "a failing probe"
	expect "$(http 9115 /metrics)" "blackbox_exporter_build_info{" "the metrics"
}
