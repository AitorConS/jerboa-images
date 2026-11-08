#!/usr/bin/env bash
# Builds images/<name> for each of its platforms, as <name>:<version>-<arch>.
# The build context is images/<name>/rootfs, so only it goes into the image.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1"

mkdir -p "${dir}/rootfs"
for platform in ${PLATFORMS}; do
	ref="$(local_ref "${platform}")"
	echo "::group::build ${ref}"
	jerboa build "${dir}/rootfs" -f "${dir}/unikernel.toml" --platform "${platform}" \
		--name "${name}" --tag "${VERSION}-$(arch_of "${platform}")" --sbom "sbom-${name}-$(arch_of "${platform}").cdx.json"
	jerboa images inspect "${ref}"
	echo "::endgroup::"
done
