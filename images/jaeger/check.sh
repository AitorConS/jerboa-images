# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 13133 /status >/dev/null; }
traced() { expect "$(http 16686 /api/v3/services)" "jerboa-test" >/dev/null 2>&1; }
exercise() {
	local now trace
	now="$(date +%s)000000000"
	trace="$(python3 -c 'import secrets;print(secrets.token_hex(16))')"
	http 4318 /v1/traces -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"jerboa-test"}}]},"scopeSpans":[{"spans":[{"traceId":"'"${trace}"'","spanId":"0102030405060708","name":"unikernel-span","kind":1,"startTimeUnixNano":"'"${now}"'","endTimeUnixNano":"'"${now}"'"}]}]}]}' >/dev/null
	wait_for 30 traced
	expect "$(http 16686 "/api/v3/traces/${trace}")" "unikernel-span" "the trace"
	expect "$(http 16686 /)" "<title>Jaeger" "the UI"
}
