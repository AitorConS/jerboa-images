#!/usr/bin/env bash
# Publishes images/<name> to jerboa/<name> on the registry, from a GitHub
# Actions job of a trusted publisher (the job's OIDC token: no stored
# credential), which also signs every push with Sigstore:
#   <version>-<arch>  one tag per platform, pushed only when its disk changed;
#   <version>, latest an image index of those, pushed when a platform changed
#                     or the tag does not exist yet;
#   the description and README shown on the hub.
# Builds are deterministic, so an unchanged image is not pushed or signed again.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1"

repo="${NAMESPACE}/${name}"

# The disk digest the registry's tag names, or nothing when the tag does not exist.
remote_disk() {
	local recipe
	recipe="$(curl -fsS --max-time 20 "${CDN}/tags/${repo}/$1" 2>/dev/null | jq -r '.recipe // empty')" || return 0
	[ -n "${recipe}" ] || return 0
	curl -fsS --max-time 20 "${CDN}/recipes/${recipe#sha256:}.json" | jq -r '.diskDigest // empty'
}

changed=0
sources=()
for platform in ${PLATFORMS}; do
	tag="${VERSION}-$(arch_of "${platform}")"
	local_disk="$(jerboa images recipe "$(local_ref "${platform}")" | jq -r '.diskDigest')"
	if [ "$(remote_disk "${tag}")" = "${local_disk}" ]; then
		echo "${repo}:${tag} is up to date (${local_disk})"
	else
		jerboa tag "$(local_ref "${platform}")" "${repo}:${tag}"
		jerboa push "${repo}:${tag}"
		changed=1
	fi
	sources+=("${repo}:${tag}")
done

for tag in "${VERSION}" latest; do
	if [ "${changed}" = 1 ] || [ -z "$(curl -fsS --max-time 20 "${CDN}/tags/${repo}/${tag}" 2>/dev/null)" ]; then
		jerboa push --index "${repo}:${tag}" "${sources[@]}"
	else
		echo "${repo}:${tag} is up to date"
	fi
done

jerboa registry repo edit "${repo}" --description "${DESCRIPTION}" --readme "${dir}/README.md"
