# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 80 /health >/dev/null; }
exercise() {
	expect "$(http 80 /)" "static-web-server on Jerboa" "the default page"
	expect "$(curl -fsSI --max-time 10 "http://$(addr 80)/")" "content-type: text/html" "the content type"
	[ "$(http_status 80 /missing)" = 404 ]
	[ "$(http_status 80 /index.html -I)" = 200 ]
}
