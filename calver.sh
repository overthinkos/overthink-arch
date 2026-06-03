# shellcheck shell=bash
# ov_calver — the CalVer (YYYY.DDD.HHMM, UTC) that identifies an ov build.
#
# Single source of truth for the build-time version stamp, shared (R3) by:
#   - pkg/arch/PKGBUILD   — pkgver() (pacman package version) + build() ldflags
#   - taskfiles/Build.yml — `task build:ov` ldflags injection
#
# Injected into the binary via `-ldflags "-X main.BuildCalVer=$(ov_calver)"` so
# `ov version` reports a FROZEN, DETERMINISTIC build identity. The CalVer is
# derived ONLY from the HEAD commit's UTC date — so EVERY binary built from the
# same commit reports the IDENTICAL version: a dirty working-tree `task
# build:ov`, the clean `git+file://` makepkg clone its `pkgver()` reads, and an
# AUR build all agree. The build clock is never consulted: the wall clock
# identifies the MOMENT of a build, not its SOURCE, and that conflation is what
# makes two builds of one commit disagree (e.g. `pacman` pkgver vs `ov version`)
# and lets a stale binary falsely sort "newer" than a fresh one. The format
# matches ComputeCalVerAt() in ov/version.go exactly: DDD = day-of-year with no
# leading zeros, HHMM = hour*100 + minute, all UTC.
ov_calver() {
	local y d h m
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		echo "ov_calver: not inside a git work tree — cannot derive a deterministic CalVer (build ov from its git checkout)" >&2
		return 1
	fi
	# HEAD commit's UTC timestamp — identical for a clean tree and a dirty tree at
	# the same commit, so the stamp identifies the SOURCE, never the build moment.
	read -r y d h m <<<"$(TZ=UTC0 git log -1 --format=%cd --date='format-local:%Y %j %H %M')"
	printf '%d.%d.%d\n' "$((10#$y))" "$((10#$d))" "$(((10#$h) * 100 + (10#$m)))"
}

# Direct execution (`bash calver.sh`) prints the value — convenient for the
# Taskfile to capture in a $(...) without sourcing into its own shell.
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
	ov_calver
fi
