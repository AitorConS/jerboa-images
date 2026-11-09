# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 6333 /readyz >/dev/null; }
points() {
	http 6333 /collections/cities/points?wait=true -X PUT -H 'Content-Type: application/json' -d "$1" >/dev/null
}
exercise() {
	http 6333 /collections/cities -X PUT -H 'Content-Type: application/json' -d '{"vectors":{"size":4,"distance":"Dot"}}' >/dev/null
	points '{"points":[{"id":1,"vector":[0.05,0.61,0.76,0.74],"payload":{"city":"Berlin"}},{"id":2,"vector":[0.19,0.81,0.75,0.11],"payload":{"city":"London"}},{"id":3,"vector":[0.36,0.55,0.47,0.94],"payload":{"city":"Moscow"}}]}'
	expect "$(http 6333 /collections/cities/points/query -H 'Content-Type: application/json' -d '{"query":[0.2,0.1,0.9,0.7],"limit":1,"with_payload":true}')" '"city":"Berlin"' "the nearest point by dot product"
	expect "$(http 6333 /collections/cities)" '"points_count":3' "the collection"
	expect "$(http 6333 /)" "\"version\":\"${VERSION}\"" "the version"
}
write_data() {
	http 6333 /collections/kept -X PUT -H 'Content-Type: application/json' -d '{"vectors":{"size":2,"distance":"Cosine"}}' >/dev/null
	http 6333 /collections/kept/points?wait=true -X PUT -H 'Content-Type: application/json' -d '{"points":[{"id":7,"vector":[1,0],"payload":{"note":"across VMs"}}]}' >/dev/null
}
read_data() { expect "$(http 6333 /collections/kept/points/7)" '"note":"across VMs"' "the point from before the new VM"; }
