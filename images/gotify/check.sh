# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 80 /health)" '"health":"green"'; }
token() { python3 -c 'import json,sys;print(json.load(sys.stdin)["token"])'; }
exercise() {
	local app
	app="$(http 80 /application -u admin:admin -H 'Content-Type: application/json' -d '{"name":"jerboa"}' | token)"
	http 80 "/message?token=${app}" -H 'Content-Type: application/json' -d '{"title":"Unikernel","message":"hello from a unikernel","priority":5}' >/dev/null
	expect "$(http 80 /message -u admin:admin)" '"message":"hello from a unikernel"' "the message"
	[ "$(http_status 80 /message -u admin:wrong)" = 401 ]
	expect "$(http 80 /version)" "\"version\":\"${VERSION}\"" "the version"
}
write_data() {
	local app
	app="$(http 80 /application -u admin:admin -H 'Content-Type: application/json' -d '{"name":"kept"}' | token)"
	http 80 "/message?token=${app}" -H 'Content-Type: application/json' -d '{"message":"kept across VMs"}' >/dev/null
}
read_data() { expect "$(http 80 /message -u admin:admin)" "kept across VMs" "the message from before the new VM"; }
