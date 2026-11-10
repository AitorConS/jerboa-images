# Tests for scripts/test.sh (helpers in scripts/checks.sh).
# shellcheck shell=bash
ready() { http 9333 /cluster/status >/dev/null && http 8888 / -H 'Accept: application/json' >/dev/null; }
# The master assigns file ids once a volume server has registered.
assignable() { wait_for 60 sh -c "curl -fsS -o /dev/null 'http://$(addr 9333)/dir/assign'"; }
exercise() {
	local fid
	assignable
	fid="$(http 9333 /dir/assign | python3 -c 'import json,sys;print(json.load(sys.stdin)["fid"])')"
	printf 'stored by a volume server' > "${STATE}/blob"
	http 8080 "/${fid}" -F "file=@${STATE}/blob" >/dev/null
	expect "$(http 8080 "/${fid}")" "stored by a volume server" "the blob"
	printf 'stored through the filer' > "${STATE}/file"
	http 8888 /docs/hello.txt -F "file=@${STATE}/file" >/dev/null
	expect "$(http 8888 /docs/hello.txt)" "stored through the filer" "the file"
	# The S3 gateway lists buckets, or refuses an anonymous caller.
	case "$(http_status 8333 /)" in 200 | 403) ;; *) echo "the S3 gateway does not answer" >&2; return 1 ;; esac
	expect "$(http 9333 /cluster/status)" '"IsLeader":true' "the master"
}
write_data() {
	assignable
	printf 'kept across VMs' > "${STATE}/kept"
	http 8888 /kept/note.txt -F "file=@${STATE}/kept" >/dev/null
}
read_data() { wait_for 60 sh -c "curl -fsS 'http://$(addr 8888)/kept/note.txt' | grep -q 'kept across VMs'"; }
