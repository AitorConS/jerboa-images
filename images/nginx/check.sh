# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 80 / >/dev/null; }
exercise() {
	expect "$(http 80 /)" "Welcome to nginx on Jerboa" "the default page"
	expect "$(curl -fsSI --max-time 10 "http://$(addr 80)/")" "Server: nginx/${VERSION}" "the Server header"
	[ "$(http_status 80 /missing)" = 404 ]
	expect "$(curl -fsSI --max-time 10 "http://$(addr 80)/index.html")" "Content-Type: text/html" "the content type"
}
