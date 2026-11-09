# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 8025 /livez >/dev/null; }
send() {
	python3 - "$(addr 1025)" "$1" <<'PY'
import smtplib,sys
from email.message import EmailMessage
host,port=sys.argv[1].rsplit(':',1)
m=EmailMessage()
m['From']='app@example.com'; m['To']='you@example.com'; m['Subject']=sys.argv[2]
m.set_content('Sent to a unikernel.')
with smtplib.SMTP(host,int(port),timeout=10) as s: s.send_message(m)
PY
}
exercise() {
	send "Hello from Jerboa"
	wait_for 10 sh -c "curl -fsS 'http://$(addr 8025)/api/v1/messages' | grep -q 'Hello from Jerboa'"
	expect "$(http 8025 '/api/v1/search?query=subject:Hello')" '"messages_count":1' "the search"
	expect "$(http 8025 /api/v1/info)" "\"Version\":\"v${VERSION}\"" "the version"
}
write_data() { send "Kept across VMs"; wait_for 10 sh -c "curl -fsS 'http://$(addr 8025)/api/v1/messages' | grep -q 'Kept across VMs'"; }
read_data() { expect "$(http 8025 /api/v1/messages)" "Kept across VMs" "the message from before the new VM"; }
