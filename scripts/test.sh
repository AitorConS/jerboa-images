#!/usr/bin/env bash
# Tests images/<name> at one of its versions (the newest by default) on this
# host's platform, with images/<name>/check.sh:
#   1. boots it on a network, publishes its PORTS on 127.0.0.1 and waits for
#      ready (up to 120 seconds);
#   2. runs exercise: the image's real work, through its own protocol;
#   3. stops it, which must succeed;
#   4. when image.env sets DATA (a directory), boots it with a new volume
#      there, runs write_data, replaces the VM with a new one on the same volume and
#      runs read_data: what was written must still be there;
#   5. fails if the guest's console shows a crash: a fault signal, a kernel
#      panic, a failed fork or an unimplemented system call.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1" "${2:-}"
. scripts/checks.sh
# shellcheck disable=SC1090
. "${dir}/check.sh"

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
volume="test-${name}-data"
logs="$(mktemp)"
# check.sh may keep state between write_data and read_data here, and read the
# console of the VM under test with jerboa logs "${vm}".
STATE="$(mktemp -d)"
export STATE vm
base_port="${TEST_PORT_BASE:-18000}"

publish=()
i=0
for p in ${PORTS}; do
	guest="${p%/*}" proto=tcp
	[ "${guest}" = "${p}" ] || proto="${p#*/}"
	host_port=$((base_port + i))
	publish+=(-p "127.0.0.1:${host_port}:${guest}/${proto}")
	export "ADDR_${guest}=127.0.0.1:${host_port}"
	i=$((i + 1))
done

jerboa network inspect ci >/dev/null 2>&1 || jerboa network create ci >/dev/null

remove() {
	jerboa logs "${vm}" >> "${logs}" 2>/dev/null || true
	jerboa stop "${vm}" >/dev/null 2>&1 || true
	jerboa rm "${vm}" >/dev/null 2>&1 || true
}
cleanup() {
	status=$?
	if [ "${status}" != 0 ]; then
		echo "--- console of ${vm} ---"
		jerboa logs "${vm}" 2>/dev/null | tail -n 80 || tail -n 80 "${logs}"
	fi
	remove
	jerboa volume rm "${volume}" >/dev/null 2>&1 || true
	rm -rf "${logs}" "${STATE}"
	exit "${status}"
}
trap cleanup EXIT

boot() {
	remove
	jerboa run "${ref}" --name "${vm}" --network ci "${publish[@]}" "$@"
	local start=${SECONDS}
	until ready >/dev/null 2>&1; do
		if [ $((SECONDS - start)) -ge 120 ]; then
			echo "${ref} was not ready within 120 seconds" >&2
			ready || true
			return 1
		fi
		if ! jerboa ps | awk -v n="${vm}" '$2 == n' | grep -q running; then
			echo "${ref} stopped while starting" >&2
			return 1
		fi
		sleep 1
	done
	echo "ready after $((SECONDS - start))s"
}

echo "::group::boot and exercise ${ref}"
boot
exercise
echo "exercise passed"
echo "::endgroup::"

echo "::group::stop ${ref}"
jerboa stop "${vm}"
jerboa logs "${vm}" >> "${logs}" 2>/dev/null || true
jerboa rm "${vm}" >/dev/null
echo "::endgroup::"

if [ -n "${DATA:-}" ]; then
	echo "::group::data in ${DATA} survives a new VM"
	jerboa volume rm "${volume}" >/dev/null 2>&1 || true
	jerboa volume create "${volume}" --size "${DATA_SIZE:-1G}" >/dev/null
	boot -v "${volume}:${DATA}"
	write_data
	jerboa stop "${vm}"
	boot -v "${volume}:${DATA}"
	read_data
	echo "data survived"
	echo "::endgroup::"
fi
remove

if grep -nE 'signal (4|6|7|8|11) received|kernel panic|page fault in kernel|fork failed|popen failure|unimplemented (syscall|system call)|core dump' "${logs}"; then
	echo "the console of ${ref} shows a crash or an unsupported call" >&2
	exit 1
fi
echo "${ref} passed"
