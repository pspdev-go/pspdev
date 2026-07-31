# syntax=docker/dockerfile:1.7

ARG GO_IMAGE=golang:1.25.9-alpine
ARG PSPDEV_IMAGE=pspdev/pspdev:v20260701

FROM --platform=linux/amd64 ${GO_IMAGE} AS go-toolchain

FROM --platform=linux/amd64 ${PSPDEV_IMAGE}

ARG TINYGO_REPOSITORY=https://github.com/pspdev-go/tinygo.git
ARG TINYGO_REF=f33c350b8f12933ee3e1c1dcbfe9a664ce183fbe
ARG PSPGO_MODULE=github.com/pspdev-go/pspgo
ARG PSPGO_REF=9a81a07b174661b0feb435dc9884db263c908339

COPY --from=go-toolchain /usr/local/go /usr/local/go

ENV PATH="/usr/local/go/bin:/opt/tinygo/build:/usr/local/pspdev/bin:${PATH}" \
    PSPDEV="/usr/local/pspdev" \
    GOTOOLCHAIN="local" \
    TINYGOROOT="/opt/tinygo" \
    HOME="/tmp/pspdev-home"

RUN apk add --no-cache \
    build-base \
    clang20-dev \
    git \
    lld20-dev \
    llvm20-dev

RUN git clone "${TINYGO_REPOSITORY}" /opt/tinygo \
    && git -C /opt/tinygo checkout --detach "${TINYGO_REF}" \
    && ln -s /usr/lib/llvm20 /opt/tinygo/llvm-build \
    && ln -s /usr/bin/ld.lld /usr/lib/llvm20/bin/ld.lld

RUN cd /opt/tinygo \
    && CGO_CFLAGS="-I/usr/lib/llvm20/include" \
       CGO_CXXFLAGS="-I/usr/lib/llvm20/include" \
       CGO_LDFLAGS="-L/usr/lib/llvm20/lib" \
       go build -buildvcs=false -o /opt/tinygo/build/tinygo . \
    && GOBIN=/usr/local/bin go install "${PSPGO_MODULE}@${PSPGO_REF}" \
    && tinygo version \
    && test -x /usr/local/bin/pspgo

COPY docker-entrypoint.sh /usr/local/bin/pspdev-build

RUN chmod 0755 /usr/local/bin/pspdev-build \
    && mkdir -p /workspace /tmp/pspdev-home /tmp/go-cache /tmp/go-mod-cache \
    && chmod 1777 /tmp/pspdev-home /tmp/go-cache /tmp/go-mod-cache

ENV GOCACHE="/tmp/go-cache" \
    GOMODCACHE="/tmp/go-mod-cache"

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/pspdev-build"]
