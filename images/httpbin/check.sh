# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http_status 8080 /status/200)" = 200 ]; }
exercise() {
	expect "$(http 8080 '/get?name=jerboa')" '"jerboa"' "the echoed query"
	expect "$(http 8080 /post -d 'payload=unikernel')" '"unikernel"' "the echoed form"
	[ "$(http_status 8080 /status/418)" = 418 ]
	expect "$(http 8080 /headers -H 'X-Jerboa: yes')" '"X-Jerboa"' "the echoed headers"
	expect "$(http 8080 /base64/amVyYm9h)" "jerboa" "the decoded text"
	[ "$(http_status 8080 /redirect/2 -L)" = 200 ]
}
