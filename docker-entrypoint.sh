#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
	set -- .
fi

build_dir=build/pspgo
if [ -f pspgo.toml ]; then
	configured_build_dir=$(
		awk -F= '
			{
				key = $1
				gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
				if (key == "build_dir") {
					value = substr($0, index($0, "=") + 1)
					sub(/[[:space:]]*#.*/, "", value)
					gsub(/^[[:space:]"]+|[[:space:]"]+$/, "", value)
					print value
					exit
				}
			}
		' pspgo.toml
	)
	if [ -n "$configured_build_dir" ]; then
		build_dir=$configured_build_dir
	fi
fi

case "$build_dir" in
	/*) cmake_cache=$build_dir/cmake/CMakeCache.txt ;;
	*) cmake_cache=$PWD/$build_dir/cmake/CMakeCache.txt ;;
esac

remove_cmake_cache() {
	[ -f "$cmake_cache" ] || return 0
	resolved_cache=$(readlink -f "$cmake_cache")
	case "$resolved_cache" in
		/workspace/*/CMakeCache.txt) rm -f "$resolved_cache" ;;
	esac
}

# CMake caches absolute source and build paths. A cache created on the host
# cannot be reused in /workspace, and one left by Docker cannot be reused on
# the host.
remove_cmake_cache
trap remove_cmake_cache EXIT

# Populate the module directory before pspgo resolves its bridge sources. A
# clean container initially has only go.mod metadata and no extracted module.
go mod download github.com/pspdev-go/pspsdk-go

pspgo build "$@"
