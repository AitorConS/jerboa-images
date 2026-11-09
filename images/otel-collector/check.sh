# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 13133 / >/dev/null; }
exercise() {
	local now
	now="$(date +%s)000000000"
	http 4318 /v1/traces -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"jerboa-test"}}]},"scopeSpans":[{"spans":[{"traceId":"0102030405060708090a0b0c0d0e0f10","spanId":"0102030405060708","name":"unikernel-span","kind":1,"startTimeUnixNano":"'"${now}"'","endTimeUnixNano":"'"${now}"'"}]}]}]}' >/dev/null
	http 4318 /v1/logs -H 'Content-Type: application/json' -d '{"resourceLogs":[{"scopeLogs":[{"logRecords":[{"timeUnixNano":"'"${now}"'","body":{"stringValue":"unikernel-log-line"}}]}]}]}' >/dev/null
	http 4318 /v1/metrics -H 'Content-Type: application/json' -d '{"resourceMetrics":[{"scopeMetrics":[{"metrics":[{"name":"unikernel_metric","gauge":{"dataPoints":[{"asDouble":1,"timeUnixNano":"'"${now}"'"}]}}]}]}]}' >/dev/null
	wait_for 20 sh -c 'jerboa logs "${vm}" | grep -q unikernel-span'
	wait_for 20 sh -c 'jerboa logs "${vm}" | grep -q unikernel-log-line'
	wait_for 20 sh -c 'jerboa logs "${vm}" | grep -q unikernel_metric'
}
