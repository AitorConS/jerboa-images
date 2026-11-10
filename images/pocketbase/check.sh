# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 8090 /api/health)" '"code":200'; }
json() { python3 -c "import json,sys;print(json.load(sys.stdin)$1)"; }
# The first start prints a link with a token for creating the first
# superuser; the test creates it with that token, as the installer page does.
superuser() {
	local installer
	installer="$(jerboa logs "${vm}" | grep -o 'pbinstall/[A-Za-z0-9._-]*' | tail -n1 | cut -d/ -f2)"
	[ -n "${installer}" ] || { echo "no installer link on the console" >&2; return 1; }
	http 8090 /api/collections/_superusers/records -H "Authorization: ${installer}" -H 'Content-Type: application/json' \
		-d '{"email":"admin@example.com","password":"jerboa-test-password","passwordConfirm":"jerboa-test-password"}' >/dev/null
}
login() {
	http 8090 /api/collections/_superusers/auth-with-password -H 'Content-Type: application/json' \
		-d '{"identity":"admin@example.com","password":"jerboa-test-password"}' | json "['token']"
}
notes() {
	local token="$1"
	http 8090 /api/collections -H "Authorization: ${token}" -H 'Content-Type: application/json' \
		-d '{"name":"notes","type":"base","fields":[{"name":"text","type":"text"}],"listRule":"","viewRule":"","createRule":""}' >/dev/null
}
exercise() {
	[ "$(http_status 8090 /api/collections)" = 401 ]
	superuser
	notes "$(login)"
	http 8090 /api/collections/notes/records -H 'Content-Type: application/json' -d '{"text":"hello from a unikernel"}' >/dev/null
	expect "$(http 8090 /api/collections/notes/records)" '"text":"hello from a unikernel"' "the record"
	[ "$(http_status 8090 /_/)" = 200 ]
}
write_data() {
	superuser
	notes "$(login)"
	http 8090 /api/collections/notes/records -H 'Content-Type: application/json' -d '{"text":"kept across VMs"}' >/dev/null
}
read_data() {
	login >/dev/null
	expect "$(http 8090 /api/collections/notes/records)" "kept across VMs" "the record from before the new VM"
}
