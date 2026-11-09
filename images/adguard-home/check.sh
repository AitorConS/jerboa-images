# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http_status 3000 /)" != 000 ]; }
configure() {
	http 3000 /control/install/configure -H 'Content-Type: application/json' \
		-d '{"web":{"ip":"0.0.0.0","port":3000},"dns":{"ip":"0.0.0.0","port":53},"username":"admin","password":"jerboa-test-password"}' >/dev/null
	wait_for 30 sh -c "curl -fsS -o /dev/null 'http://$(addr 3000)/login.html'"
}
login() {
	curl -fsS --max-time 10 -c "${STATE}/cookies" "http://$(addr 3000)/control/login" -H 'Content-Type: application/json' \
		-d '{"name":"admin","password":"jerboa-test-password"}' >/dev/null
}
control() { local path="$1"; shift; curl -fsS --max-time 10 -b "${STATE}/cookies" "http://$(addr 3000)/control/${path}" "$@"; }
exercise() {
	expect "$(http 3000 /control/install/get_addresses)" '"interfaces"' "the installer"
	configure
	login
	expect "$(control status)" "\"version\":\"v${VERSION}\"" "the status"
	control filtering/set_rules -H 'Content-Type: application/json' -d '{"rules":["||blocked.jerboa.test^"]}' >/dev/null
	expect "$(dns_query 53 blocked.jerboa.test)" "00000000" "a blocked name answered with 0.0.0.0"
	expect "$(control 'querylog?limit=10')" "blocked.jerboa.test" "the query log"
}
write_data() { configure; }
read_data() {
	login
	expect "$(control status)" '"running":true' "a configured server after the new VM"
}
