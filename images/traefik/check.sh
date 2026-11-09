# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http 8080 /ping)" = OK ]; }
exercise() {
	expect "$(http 8080 /api/version)" "\"Version\":\"${VERSION}\"" "the version"
	expect "$(http 8080 /api/entrypoints)" "\"name\":\"web\"" "the entry points"
	expect "$(http 8080 /api/http/routers)" "api@internal" "the routers"
	[ "$(http_status 8080 /dashboard/)" = 200 ]
	# No routes are configured yet: the web entry point answers 404.
	[ "$(http_status 80 /)" = 404 ]
}
