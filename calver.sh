# shellcheck shell=bash
# ov_calver — the CalVer (YYYY.DDD.HHMM, UTC) that identifies an ov build.
#
# Single source of truth for the build-time version stamp, shared (R3) by:
#   - pkg/arch/PKGBUILD   — pkgver() (pacman package version) + build() ldflags
#   - taskfiles/Build.yml — `task build:ov` ldflags injection
#
# It is injected into the binary via `-ldflags "-X main.BuildCalVer=$(ov_calver)"`
# so `ov version` reports a FROZEN build identity, not a wall-clock readout. The
# format matches ComputeCalVerAt() in ov/version.go exactly: DDD = day-of-year
# with no leading zeros, HHMM = hour*100 + minute, all UTC.
#
#   clean tree → the last commit's UTC date (reproducible; the same value
#                `pacman -Q overthink-git` reports for the same commit).
#   dirty tree / no git → the current UTC time (so successive dev rebuilds are
#                monotonic — a freshly built binary sorts newer than the last).
ov_calver() {
	local y d h m
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
		git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
		# Committed, clean: derive from the HEAD commit's UTC timestamp.
		read -r y d h m <<<"$(TZ=UTC0 git log -1 --format=%cd --date='format-local:%Y %j %H %M')"
	else
		# Dirty or non-git: stamp the current UTC build time.
		read -r y d h m <<<"$(date -u '+%Y %j %H %M')"
	fi
	printf '%d.%d.%d\n' "$((10#$y))" "$((10#$d))" "$(((10#$h) * 100 + (10#$m)))"
}

# Direct execution (`bash calver.sh`) prints the value — convenient for the
# Taskfile to capture in a $(...) without sourcing into its own shell.
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
	ov_calver
fi
