#!/usr/bin/env bash
# Scans the SBOMs scripts/build.sh wrote for images/<name> with grype, which
# matches each component against the vulnerability databases it aggregates
# (NVD, GitHub, distributions). Jerboa's packages are built from upstream
# sources, so components carry generic package URLs: grype matches them by
# CPEs derived from their name and version (--add-cpes-if-none). Components
# without a version (the SBOM's own subject, the image's program) match every
# vulnerability of their name, so their matches are left out.
#
# Writes scan-<name>-<arch>.json and a report on the job's summary, and sets
# the step outputs found (critical and high vulnerabilities, all platforms)
# and report (a Markdown file listing them).
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/lib.sh
load_image "$1"

report="scan-${name}.md"
{
	echo "### Vulnerabilities in ${NAMESPACE}/${name} ${VERSION}"
	echo
} > "${report}"
found=0
for platform in ${PLATFORMS}; do
	arch="$(arch_of "${platform}")"
	sbom="sbom-${name}-${arch}.cdx.json"
	out="scan-${name}-${arch}.json"
	grype "sbom:${sbom}" --add-cpes-if-none --by-cve -o json --file "${out}"
	rows="$(jq -r '.matches[] | select(.artifact.version != "")
		| select(.vulnerability.severity == "Critical" or .vulnerability.severity == "High")
		| "| \(.artifact.name) \(.artifact.version) | [\(.vulnerability.id)](\(.vulnerability.dataSource)) | \(.vulnerability.severity) | \(.vulnerability.fix.versions | join(", ") | if . == "" then "-" else . end) |"' "${out}" | sort -u)"
	n=0
	[ -z "${rows}" ] || n="$(printf '%s\n' "${rows}" | wc -l | tr -d ' ')"
	all="$(jq '[.matches[] | select(.artifact.version != "") | .vulnerability.id] | unique | length' "${out}")"
	{
		echo "**${platform}**: ${n} critical or high, ${all} in all."
		echo
		if [ "${n}" != 0 ]; then
			echo "| Component | Vulnerability | Severity | Fixed in |"
			echo "|---|---|---|---|"
			printf '%s\n' "${rows}"
			echo
		fi
	} >> "${report}"
	found=$((found + n))
done

cat "${report}"
[ -z "${GITHUB_STEP_SUMMARY:-}" ] || cat "${report}" >> "${GITHUB_STEP_SUMMARY}"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
	echo "found=${found}" >> "${GITHUB_OUTPUT}"
	echo "report=${report}" >> "${GITHUB_OUTPUT}"
fi
