# Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.2 AS builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

RUN apt-get -q update && apt-get -q install -y \
    libsqlite3-dev \
    libssl-dev \
    sqlite3 \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

# RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .

RUN swift build --enable-test-discovery -c release -Xswiftc -g


# Production image
FROM ubuntu:18.04
ARG env
# DEBIAN_FRONTEND=noninteractive for automatic UTC configuration in tzdata
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libatomic1 \
    libbsd0 \
#    libcurl4 \
    libicu60 \
    libxml2 \
    libz-dev \
    tzdata \
    && rm -r /var/lib/apt/lists/*

WORKDIR /run

COPY --from=builder /build/.build/release /run
COPY --from=builder /usr/lib/swift/ /usr/lib/swift/

ENTRYPOINT ["./Run"]
# TODO: pass port number via environment
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port 80", "--auto-migrate"]
