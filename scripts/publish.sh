#!/usr/bin/env bash
# Publishes images/<name> at one of its versions (the newest by default) to
# jerboa/<name> on the registry, from a GitHub
# Actions job of a trusted publisher (the job's OIDC token: no stored
# credential), which also signs every push with Sigstore:
#   <version>-<arch>  one tag per platform, pushed only when its disk changed;
#   <version>         an image index of those, pushed when a platform changed
#                     or the tag does not exist yet;
#   aliases           the same index under the version's minor and major
#                     lines when it is the newest of them, and latest for the
#                     image's newest version (lib.sh, alias_tags);
#   the description and README shown on the hub.
# Builds are deterministic, so an unchanged image is not pushed or signed again.
#
# The index names its recipes by digest, not by tag: the CDN serves a tag for
# up to a minute after it changes, and a tag this script looked up before it
# existed answers 404 for a few minutes.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1" "${2:-}"

repo="${NAMESPACE}/${name}"

# The recipe the registry's tag names, or nothing when the tag does not exist.
remote_recipe() {
	curl -fsS --max-time 20 "${CDN}/tags/${repo}/$1" 2>/dev/null | jq -r '.recipe // empty' || true
}

# The disk digest of a recipe on the registry.
remote_disk() {
	curl -fsS --max-time 20 "${CDN}/recipes/${1#sha256:}.json" | jq -r '.diskDigest // empty'
}

changed=0
sources=()
for platform in ${PLATFORMS}; do
	tag="${VERSION}-$(arch_of "${platform}")"
	local_disk="$(jerboa images recipe "$(local_ref "${platform}")" | jq -r '.diskDigest')"
	recipe="$(remote_recipe "${tag}")"
	if [ -n "${recipe}" ] && [ "$(remote_disk "${recipe}")" = "${local_disk}" ]; then
		echo "${repo}:${tag} is up to date (${local_disk})"
	else
		jerboa tag "$(local_ref "${platform}")" "${repo}:${tag}"
		# jerboa push prints the recipe's digest on a line of its own.
		recipe="$(jerboa push "${repo}:${tag}" | tee /dev/stderr | grep -E '^sha256:[0-9a-f]{64}$' | tail -n1)"
		[ -n "${recipe}" ] || { echo "::error::no recipe digest in the output of jerboa push ${repo}:${tag}"; exit 1; }
		changed=1
	fi
	sources+=("${repo}@${recipe}")
done

# shellcheck disable=SC2046
for tag in "${VERSION}" $(alias_tags); do
	if [ "${changed}" = 1 ] || [ -z "$(curl -fsS --max-time 20 "${CDN}/tags/${repo}/${tag}" 2>/dev/null)" ]; then
		jerboa push --index "${repo}:${tag}" "${sources[@]}"
	else
		echo "${repo}:${tag} is up to date"
	fi
done

# The hub page belongs to the image, not a version: the newest one sets it.
[ "${VERSION}" != "${VERSIONS%% *}" ] || jerboa registry repo edit "${repo}" --description "${DESCRIPTION}" --readme "${dir}/README.md"
