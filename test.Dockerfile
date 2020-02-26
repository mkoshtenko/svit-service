# Versions can be found here: https://hub.docker.com/r/swiftlang/swift/tags
FROM swift:5.1.1

ARG env

RUN apt-get -q update && apt-get -q install -y \
    libssl-dev \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

WORKDIR /root
COPY . .

RUN swift package resolve
RUN swift build
RUN swift test --enable-code-coverage

RUN bash scripts/export-codecov.sh
RUN bash <(curl -s https://codecov.io/bash) -J "app" -D ".build/debug"
