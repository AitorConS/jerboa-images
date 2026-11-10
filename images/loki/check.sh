# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http 3100 /ready)" = ready ]; }
push() {
	http 3100 /loki/api/v1/push -H 'Content-Type: application/json' \
		-d "{\"streams\":[{\"stream\":{\"job\":\"jerboa\"},\"values\":[[\"$(date +%s)000000000\",\"$1\"]]}]}" >/dev/null
}
found() { curl -fsS -G "http://$(addr 3100)/loki/api/v1/query_range" --data-urlencode 'query={job="jerboa"}' --data-urlencode "start=$(( $(date +%s) - 3600 ))000000000" | grep -q "$1"; }
exercise() {
	push "hello from a unikernel"
	wait_for 30 found "hello from a unikernel"
	expect "$(http 3100 /loki/api/v1/labels)" '"job"' "the labels"
	expect "$(http 3100 /loki/api/v1/status/buildinfo)" "\"version\":\"${VERSION}\"" "the build info"
}
write_data() { push "kept across VMs"; wait_for 30 found "kept across VMs"; }
read_data() { wait_for 30 found "kept across VMs"; }
