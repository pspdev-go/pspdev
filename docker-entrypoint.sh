#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
	set -- .
fi

# Populate the module directory before pspgo resolves its bridge sources. A
# clean container initially has only go.mod metadata and no extracted module.
go mod download github.com/pspdev-go/pspsdk-go

exec pspgo build "$@"
