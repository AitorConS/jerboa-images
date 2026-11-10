# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { expect "$(http 2379 /health)" '"health":"true"'; }
b64() { printf '%s' "$1" | base64; }
put() { http 2379 /v3/kv/put -d "{\"key\":\"$(b64 "$1")\",\"value\":\"$(b64 "$2")\"}" >/dev/null; }
get() { http 2379 /v3/kv/range -d "{\"key\":\"$(b64 "$1")\"}"; }
exercise() {
	put greeting hello
	expect "$(get greeting)" "\"value\":\"$(b64 hello)\"" "the value"
	put greeting again
	expect "$(get greeting)" '"version":"2"' "the key's version"
	http 2379 /v3/kv/deleterange -d "{\"key\":\"$(b64 greeting)\"}" >/dev/null
	if get greeting | grep -q '"kvs"'; then echo "the deleted key is still there" >&2; return 1; fi
	expect "$(http 2379 /version)" "\"etcdserver\":\"${VERSION}\"" "the version"
	expect "$(http 2379 /v3/maintenance/status -X POST -d '{}')" '"leader"' "the member status"
}
write_data() { put kept "across VMs"; }
read_data() { expect "$(get kept)" "\"value\":\"$(b64 'across VMs')\"" "the key from before the new VM"; }
