# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 9093 /-/ready >/dev/null; }
iso() { python3 -c "import datetime,sys;print((datetime.datetime.now(datetime.timezone.utc)+datetime.timedelta(seconds=int(sys.argv[1]))).isoformat())" "$1"; }
exercise() {
	http 9093 /api/v2/alerts -X POST -H 'Content-Type: application/json' \
		-d '[{"labels":{"alertname":"JerboaTest","severity":"info"},"annotations":{"summary":"test"}}]' >/dev/null
	wait_for 10 sh -c "curl -fsS 'http://$(addr 9093)/api/v2/alerts' | grep -q JerboaTest"
	expect "$(http 9093 /api/v2/status)" "\"version\":\"${VERSION}\"" "the status"
	expect "$(http 9093 /api/v2/alerts/groups)" "JerboaTest" "the alert groups"
}
write_data() {
	http 9093 /api/v2/silences -X POST -H 'Content-Type: application/json' \
		-d "{\"matchers\":[{\"name\":\"alertname\",\"value\":\"Kept\",\"isRegex\":false}],\"startsAt\":\"$(iso 0)\",\"endsAt\":\"$(iso 86400)\",\"createdBy\":\"test\",\"comment\":\"jerboa-persisted\"}" >/dev/null
	expect "$(http 9093 /api/v2/silences)" "jerboa-persisted"
}
read_data() { expect "$(http 9093 /api/v2/silences)" "jerboa-persisted" "the silence from before the new VM"; }
