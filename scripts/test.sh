#!/usr/bin/env bash
# Boots images/<name> for the host's platform on a network, publishes its
# port and checks that it answers: an HTTP page with the expected text, or
# Redis PONG.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1"

case "$(uname -m)" in
x86_64) platform=linux/amd64 ;;
aarch64 | arm64) platform=linux/arm64 ;;
*) echo "unsupported host $(uname -m)" >&2; exit 1 ;;
esac
case " ${PLATFORMS} " in
*" ${platform} "*) ;;
*) echo "${name} is not built for ${platform}: nothing to test"; exit 0 ;;
esac
ref="$(local_ref "${platform}")"
vm="test-${name}"
host_port=18080

jerboa network inspect ci >/dev/null 2>&1 || jerboa network create ci >/dev/null
jerboa rm "${vm}" >/dev/null 2>&1 || true
jerboa run "${ref}" --name "${vm}" --network ci -p "127.0.0.1:${host_port}:${PORT}"

cleanup() {
	jerboa logs "${vm}" 2>/dev/null | tail -n 50 || true
	jerboa stop "${vm}" >/dev/null 2>&1 || true
	jerboa rm "${vm}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

check() {
	case "${CHECK}" in
	http) curl -fsS --max-time 5 "http://127.0.0.1:${host_port}/" | grep -q "${EXPECT:?}" ;;
	redis)
		exec 3<>"/dev/tcp/127.0.0.1/${host_port}" || return 1
		printf 'PING\r\n' >&3
		timeout 5 head -c 7 <&3 | grep -q '+PONG'
		local ok=$?
		exec 3>&-
		return "${ok}"
		;;
	*) echo "unknown CHECK ${CHECK}" >&2; return 1 ;;
	esac
}

for _ in $(seq 1 60); do
	if check 2>/dev/null; then
		echo "${ref} answers on port ${PORT}"
		exit 0
	fi
	sleep 1
done
echo "${ref} did not answer on port ${PORT} within 60 seconds" >&2
exit 1
