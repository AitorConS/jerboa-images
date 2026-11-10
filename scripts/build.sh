#!/usr/bin/env bash
# Builds images/<name> at one of its versions (the newest by default) for each
# of its platforms, as <name>:<version>-<arch>. The build context is base/rootfs
# with images/<name>/rootfs over it, so only those go into the image.
# BUILD_PLATFORMS builds only some of its platforms, for local work.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1" "${2:-}"

toml="$(unikernel_toml)"
context="${TMPDIR:-/tmp}/context-${name}-${VERSION}"
rm -rf "${context}"
mkdir -p "${context}"
cp -R base/rootfs/. "${context}/"
[ ! -d "${dir}/rootfs" ] || cp -R "${dir}/rootfs/." "${context}/"
for platform in ${BUILD_PLATFORMS:-${PLATFORMS}}; do
	ref="$(local_ref "${platform}")"
	echo "::group::build ${ref}"
	jerboa build "${context}" -f "${toml}" --platform "${platform}" \
		--name "${name}" --tag "${VERSION}-$(arch_of "${platform}")" --sbom "sbom-${name}-${VERSION}-$(arch_of "${platform}").cdx.json"
	jerboa images inspect "${ref}"
	echo "::endgroup::"
done
