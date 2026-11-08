# Shared by the scripts: reads images/<name>/image.env.
set -euo pipefail

NAMESPACE="${NAMESPACE:-jerboa}"
REGISTRY="${REGISTRY:-registry.jerboa.dev}"
CDN="${CDN:-https://cdn.registry.jerboa.dev}"

load_image() {
	name="$1"
	dir="images/${name}"
	[ -f "${dir}/image.env" ] || { echo "no image ${name}" >&2; exit 1; }
	# shellcheck disable=SC1090,SC1091
	. "${dir}/image.env"
	: "${VERSION:?}" "${PLATFORMS:?}" "${DESCRIPTION:?}" "${PORT:?}" "${CHECK:?}"
}

arch_of() { echo "${1#linux/}"; }

# The local name of the image built for a platform.
local_ref() { echo "${name}:${VERSION}-$(arch_of "$1")"; }
