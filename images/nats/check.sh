# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 8222 /healthz)" '"status":"ok"'; }
exercise() {
	local out
	out="$(tcp 4222 'CONNECT {"verbose":false}\r\nSUB greetings 1\r\nPUB greetings 5\r\nhello\r\nPING\r\n' 2)"
	expect "${out}" $'MSG greetings 1 5\r\nhello' "the delivered message"
	expect "${out}" "PONG"
	expect "$(http 8222 /varz)" "\"version\": \"${VERSION}\"" "the server version"
	expect "$(http 8222 /jsz)" '"config"' "JetStream"
}
write_data() {
	local stream='{"name":"KEPT","subjects":["kept.>"],"storage":"file"}'
	tcp 4222 "CONNECT {\"verbose\":false}\r\nSUB _INBOX.t 1\r\nPUB \$JS.API.STREAM.CREATE.KEPT _INBOX.t ${#stream}\r\n${stream}\r\nPING\r\n" 2 >/dev/null
	wait_for 10 sh -c "curl -fsS 'http://$(addr 8222)/jsz?streams=true' | grep -q '\"name\": \"KEPT\"'"
	expect "$(tcp 4222 'CONNECT {"verbose":false}\r\nSUB _INBOX.a 1\r\nPUB kept.one _INBOX.a 6\r\nstored\r\nPING\r\n' 2)" '"stream":"KEPT"' "the stored message's acknowledgement"
	wait_for 10 sh -c "curl -fsS 'http://$(addr 8222)/jsz?streams=true' | grep -q '\"messages\": 1'"
}
read_data() {
	expect "$(http 8222 '/jsz?streams=true')" '"name": "KEPT"' "the stream from before the new VM"
	expect "$(http 8222 '/jsz?streams=true')" '"messages": 1' "its message"
}
