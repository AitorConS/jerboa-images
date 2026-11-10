# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 9091 /-/ready >/dev/null; }
exercise() {
	printf 'jerboa_job_duration_seconds 42\n' | http 9091 /metrics/job/backup/instance/db1 --data-binary @- >/dev/null
	expect "$(http 9091 /metrics)" 'jerboa_job_duration_seconds{instance="db1",job="backup"} 42' "the pushed metric"
	expect "$(http 9091 /api/v1/metrics)" '"backup"' "the API"
	http 9091 /metrics/job/backup/instance/db1 -X DELETE >/dev/null
	if http 9091 /metrics | grep -q jerboa_job_duration_seconds; then echo "the deleted metric is still there" >&2; return 1; fi
	expect "$(http 9091 /api/v1/status)" "\"version\":\"${VERSION}\"" "the status"
}
write_data() {
	printf 'jerboa_kept 7\n' | http 9091 /metrics/job/kept --data-binary @- >/dev/null
	sleep 7
}
read_data() { expect "$(http 9091 /metrics)" 'jerboa_kept{instance="",job="kept"} 7' "the metric from before the new VM"; }
