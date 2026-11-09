# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 7700 /health)" '"available"'; }
task_done() { expect "$(http 7700 "/tasks/$1")" '"status":"succeeded"' >/dev/null 2>&1; }
add() {
	local uid
	uid="$(http 7700 /indexes/movies/documents -H 'Content-Type: application/json' -d "$1" | python3 -c 'import json,sys;print(json.load(sys.stdin)["taskUid"])')"
	wait_for 60 task_done "${uid}"
}
exercise() {
	add '[{"id":1,"title":"Jerboa in the desert"},{"id":2,"title":"Unikernels at sea"},{"id":3,"title":"The hopping rodent"}]'
	expect "$(http 7700 '/indexes/movies/search?q=desrt')" '"Jerboa in the desert"' "a typo-tolerant search"
	expect "$(http 7700 /indexes/movies/stats)" '"numberOfDocuments":3' "the index stats"
	expect "$(http 7700 /version)" "\"pkgVersion\":\"${VERSION}\"" "the version"
}
write_data() { add '[{"id":42,"title":"Kept across virtual machines"}]'; }
read_data() { expect "$(http 7700 '/indexes/movies/search?q=virtual')" '"id":42' "the document from before the new VM"; }
