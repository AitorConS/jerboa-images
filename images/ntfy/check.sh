# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 80 /v1/health)" '"healthy":true'; }
exercise() {
	http 80 /jerboa-test -H 'Title: Unikernel' -d 'hello from a unikernel' >/dev/null
	local got
	got="$(http 80 '/jerboa-test/json?poll=1')"
	expect "${got}" '"message":"hello from a unikernel"' "the message"
	expect "${got}" '"title":"Unikernel"' "its title"
	expect "$(http 80 /jerboa-test/raw?poll=1)" "hello from a unikernel" "the raw message"
}
write_data() { http 80 /kept -d 'kept across VMs' >/dev/null; }
read_data() { expect "$(http 80 '/kept/json?poll=1')" "kept across VMs" "the message from before the new VM"; }
