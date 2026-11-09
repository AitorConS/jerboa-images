# Shared by the scripts: reads images/<name>/image.env.
set -euo pipefail

NAMESPACE="${NAMESPACE:-jerboa}"
REGISTRY="${REGISTRY:-registry.jerboa.dev}"
CDN="${CDN:-https://cdn.registry.jerboa.dev}"

# load_image <name> [version]: reads images/<name>/image.env and selects one
# of its VERSIONS (the first, the newest, when none is given). Sets name,
# dir, VERSION and the variables of image.env.
load_image() {
	name="$1"
	dir="images/${name}"
	[ -f "${dir}/image.env" ] || { echo "no image ${name}" >&2; exit 1; }
	# shellcheck disable=SC1090,SC1091
	. "${dir}/image.env"
	: "${VERSIONS:?}" "${PLATFORMS:?}" "${DESCRIPTION:?}" "${PORTS:?}"
	VERSION="${2:-${VERSIONS%% *}}"
	case " ${VERSIONS} " in
	*" ${VERSION} "*) ;;
	*) echo "${name} has no version ${VERSION} (VERSIONS=${VERSIONS})" >&2; exit 1 ;;
	esac
}

arch_of() { echo "${1#linux/}"; }

# The local name of the image built for a platform.
local_ref() { echo "${name}:${VERSION}-$(arch_of "$1")"; }

# The unikernel.toml of the selected version: unikernel.<major.minor>.toml or
# unikernel.<major>.toml when the image has one for that line, otherwise
# unikernel.toml. @VERSION@ in it is replaced by the version.
unikernel_toml() {
	local minor="${VERSION%.*}" major="${VERSION%%.*}" src="${dir}/unikernel.toml" out
	if [ -f "${dir}/unikernel.${minor}.toml" ]; then
		src="${dir}/unikernel.${minor}.toml"
	elif [ -f "${dir}/unikernel.${major}.toml" ]; then
		src="${dir}/unikernel.${major}.toml"
	fi
	out="${TMPDIR:-/tmp}/unikernel-${name}-${VERSION}.toml"
	sed "s/@VERSION@/${VERSION}/g" "${src}" > "${out}"
	echo "${out}"
}

# The tags that name the selected version besides <version> itself: its
# minor line and its major line when it is the newest of them in VERSIONS
# (VERSIONS lists the newest first), and latest for the first version.
alias_tags() {
	local v minor major seen_minor=" " seen_major=" " tags=()
	for v in ${VERSIONS}; do
		minor="${v%.*}" major="${v%%.*}"
		if [ "${v}" = "${VERSION}" ]; then
			[ "${v}" != "${VERSIONS%% *}" ] || tags+=(latest)
			case "${seen_minor}" in *" ${minor} "*) ;; *) [ "${minor}" = "${v}" ] || tags+=("${minor}") ;; esac
			case "${seen_major}" in *" ${major} "*) ;; *) [ "${major}" = 0 ] || [ "${major}" = "${minor}" ] || tags+=("${major}") ;; esac
		fi
		seen_minor+="${minor} " seen_major+="${major} "
	done
	echo "${tags[@]}"
}
