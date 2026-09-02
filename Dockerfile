# syntax: multi-stage - httping isn't packaged for Alpine at all (checked
# both the stable and edge/community repos), so it's built from source here.
# The builder stage carries the compiler toolchain; the final stage doesn't.

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS builder

RUN apk add --no-cache \
    build-base \
    cmake \
    openssl-dev \
    gettext-dev \
    gettext \
    git

ARG HTTPING_VERSION=4.4.0

RUN git clone --depth 1 --branch "v${HTTPING_VERSION}" \
    https://github.com/folkertvanheusden/HTTPing.git /tmp/httping

WORKDIR /tmp/httping

# httping's get_ts() (utils.c) adds gettimeofday's second argument -
# struct timezone's tz_minuteswest field - into every timestamp it takes.
# That field is a deprecated, kernel-optional part of gettimeofday(2); on
# musl libc (this image's C library) it isn't reliably populated, so it
# reads near-garbage stack values on every call. Verified directly: an
# unpatched build reported multi-million-millisecond and negative
# round-trip times against a real host; with this term removed, the same
# request reports sane, consistent numbers (tens of milliseconds). Duration
# math never needs a timezone correction anyway - start and end timestamps
# would cancel it out even if the field were reliable - so this is a
# straightforward fix, not a loss of behavior.
RUN sed -i \
    's|return (double)ts.tv_sec + ((double)ts.tv_usec)/1000000.0 + (double)(tz.tz_minuteswest \* 60);|return (double)ts.tv_sec + ((double)ts.tv_usec)/1000000.0;|' \
    utils.c

RUN cmake -DUSE_SSL=ON -DUSE_GETTEXT=ON -B build . && \
    cmake --build build

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
LABEL MAINTAINER="Steven Wade <steven@stevenwade.co.uk>"

# libintl: httping links against libintl.so.8 at runtime (see the builder
# stage's gettext note). musl-libintl looks like the obvious musl-native
# choice but only ships the header for build-time use, not a runtime .so -
# verified directly, it did nothing and the binary still failed to load.
# This "libintl" package is the one that actually provides libintl.so.8.
RUN apk add --no-cache \
    ca-certificates \
    apache2-utils \
    curl \
    wget \
    bind-tools \
    netcat-openbsd \
    tcpdump \
    mtr \
    iperf3 \
    libintl \
    socat \
    jq \
    bash && \
    adduser -D -H -u 10001 debug

COPY --from=builder /tmp/httping/build/httping /usr/local/bin/httping

# No $HOME (adduser -H above) since the image is meant to run with a
# read-only root filesystem - bash would otherwise try and fail to write
# its history there. /tmp still needs its own writable volume at deploy
# time (an emptyDir) since readOnlyRootFilesystem covers the whole
# filesystem, /tmp included - see README.
ENV HISTFILE=/tmp/.bash_history

USER 10001
WORKDIR /tmp

CMD ["/bin/bash"]
