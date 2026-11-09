# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(tcp 11211 'version\r\n')" "VERSION ${VERSION}"; }
exercise() {
	expect "$(tcp 11211 'set greeting 0 0 5\r\nhello\r\nget greeting\r\n')" $'STORED\r\nVALUE greeting 0 5\r\nhello\r\nEND'
	expect "$(tcp 11211 'set n 0 0 1\r\n1\r\nincr n 41\r\n')" $'STORED\r\n42'
	expect "$(tcp 11211 'add greeting 0 0 1\r\nx\r\n')" "NOT_STORED"
	expect "$(tcp 11211 'delete greeting\r\nget greeting\r\n')" $'DELETED\r\nEND'
	expect "$(tcp 11211 'stats\r\n')" "STAT version ${VERSION}"
}
