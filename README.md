# PSP Go Docker toolchain

[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen?style=flat-square)](/LICENSE)

This repository provides a container image for building PSP applications
written with [`pspsdk-go`](https://github.com/pspdev-go/pspsdk-go). The image
contains Go, the PSP-enabled TinyGo fork, `pspgo`, and the complete PSPSDK
toolchain.

Users only need Docker. Go, TinyGo, PSPSDK, CMake, and `pspgo` do not need to
be installed on the host.

## Build a project

Run the image from the root of a Go project that depends on `pspsdk-go`:

```sh
docker run --rm --platform linux/amd64 \
  --volume "$PWD:/workspace" \
  ghcr.io/pspdev-go/pspdev:latest
```

The resulting PSP package is written to:

```text
build/pspgo/cmake/EBOOT.PBP
```

## PSP menu assets

Add an optional `pspgo.toml` to the application project to package menu
artwork and audio:

```toml
title = "My PSP Game"
icon = "assets/ICON0.PNG"
animation = "assets/ICON1.PMF"
preview = "assets/PIC0.PNG"
background = "assets/PIC1.PNG"
music = "assets/SND0.AT3"
```

All paths are relative to the project directory mounted at `/workspace`, so no
additional Docker volumes or flags are required. The files are included in
the generated `EBOOT.PBP`.

Pass a package path after the image name when the PSP application is not the
module's root package:

```sh
docker run --rm --platform linux/amd64 \
  --volume "$PWD:/workspace" \
  ghcr.io/pspdev-go/pspdev:latest ./cmd/game
```

The published image is currently `linux/amd64`, matching the official
`pspdev/pspdev` base image. Docker Desktop runs it through emulation on Apple
Silicon.

## Convenience script

After cloning this repository, the included script reduces the command to:

```sh
./build /path/to/project
```

An optional second argument selects the package:

```sh
./build /path/to/project ./cmd/game
```

Set `PSPDEV_GO_IMAGE` to use another image tag:

```sh
PSPDEV_GO_IMAGE=pspdev-go/pspdev:dev ./build /path/to/project
```

On Linux, the script runs the container with the current UID and GID so build
artifacts are not owned by root.

## Docker Compose

The same build can be run with Compose:

```sh
PROJECT_DIR=/path/to/project docker compose run --rm build
```

## Build the image locally

```sh
docker build --platform linux/amd64 -t pspdev-go/pspdev:dev .
PSPDEV_GO_IMAGE=pspdev-go/pspdev:dev ./build /path/to/project
```

The image pins:

- `pspdev/pspdev:v20260701`
- Go 1.25.9
- the `support-psp` TinyGo commit
- the latest `pspgo` main branch

Override the source references with Docker build arguments when testing an
update.
