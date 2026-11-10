# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { [ "$(http_status 8200 '/v1/sys/health?uninitcode=200&sealedcode=200&standbycode=200')" = 200 ]; }
json() { python3 -c "import json,sys;print(json.load(sys.stdin)$1)"; }
# A new node answers init once Raft has elected it leader, which can take
# longer than one request's default timeout.
init() {
	http 8200 /v1/sys/init -X PUT -d '{"secret_shares":1,"secret_threshold":1}' --max-time 60 > "${STATE}/init.json"
	unseal
}
unseal() {
	http 8200 /v1/sys/unseal -X PUT -d "{\"key\":\"$(json "['keys'][0]" < "${STATE}/init.json")\"}" >/dev/null
	wait_for 60 sh -c "[ \"\$(curl -s -o /dev/null -w '%{http_code}' 'http://$(addr 8200)/v1/sys/health')\" = 200 ]"
}
# A new KV version 2 mount upgrades itself for a moment before taking writes.
kv_put() { wait_for 30 sh -c "curl -fsS -o /dev/null -X POST -H 'X-Vault-Token: $(json "['root_token']" < "${STATE}/init.json")' -d '$2' 'http://$(addr 8200)$1'"; }
bao() { local path="$1"; shift; http 8200 "${path}" -H "X-Vault-Token: $(json "['root_token']" < "${STATE}/init.json")" "$@"; }
exercise() {
	init
	bao /v1/sys/mounts/secret -X POST -d '{"type":"kv","options":{"version":"2"}}' >/dev/null
	kv_put /v1/secret/data/app '{"data":{"password":"s3cret"}}'
	expect "$(bao /v1/secret/data/app)" '"password":"s3cret"' "the secret"
	expect "$(http 8200 /v1/sys/health)" "\"version\":\"${VERSION}" "the version"
	http 8200 /v1/sys/seal -X PUT -H "X-Vault-Token: $(json "['root_token']" < "${STATE}/init.json")" >/dev/null
	[ "$(http_status 8200 /v1/secret/data/app -H "X-Vault-Token: $(json "['root_token']" < "${STATE}/init.json")")" = 503 ]
}
write_data() {
	init
	bao /v1/sys/mounts/secret -X POST -d '{"type":"kv","options":{"version":"2"}}' >/dev/null
	kv_put /v1/secret/data/kept '{"data":{"note":"across VMs"}}'
}
read_data() {
	expect "$(http 8200 /v1/sys/seal-status)" '"sealed":true' "a sealed vault after the new VM"
	unseal
	expect "$(bao /v1/secret/data/kept)" '"note":"across VMs"' "the secret from before the new VM"
}
