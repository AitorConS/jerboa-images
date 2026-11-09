# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 8686 /health >/dev/null; }
exercise() {
	http 8080 / -d 'hello from a unikernel' >/dev/null
	wait_for 20 sh -c 'jerboa logs "${vm}" | grep -q "hello from a unikernel"'
	expect "$(http 8686 /health)" '"ok":true' "the health"
}
