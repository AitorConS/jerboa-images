# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(resp 6379 PING)" "+PONG"; }
exercise() {
	expect "$(resp 6379 'SET greeting hello' 'GET greeting')" $'+OK\r\n$5\r\nhello'
	expect "$(resp 6379 'INCR counter' 'INCRBY counter 41')" ':42'
	expect "$(resp 6379 'RPUSH list a b c' 'LRANGE list 0 -1')" $'*3\r\n$1\r\na\r\n$1\r\nb\r\n$1\r\nc'
	expect "$(resp 6379 'HSET user name jerboa' 'HGET user name')" $'$6\r\njerboa'
	expect "$(resp 6379 'SET temp x EX 100' 'TTL temp')" ':100'
	expect "$(resp 6379 'DEL greeting' 'EXISTS greeting')" ':0'
	expect "$(resp 6379 'INFO server')" "valkey_version:${VERSION}"
}
