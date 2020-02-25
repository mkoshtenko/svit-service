# Versions can be found here: https://hub.docker.com/r/swiftlang/swift/tags
FROM swiftlang/swift:nightly-5.2-bionic

WORKDIR /root
COPY . .

ARG env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev openssl libatomic1 libicu60 libxml2 libcurl4 libz-dev libbsd0 tzdata zlib1g-dev libsqlite3-dev sqlite3 \
  && rm -r /var/lib/apt/lists/*

RUN swift package resolve
RUN swift build
RUN swift test --enable-code-coverage

RUN bash scripts/export-codecov.sh
RUN bash <(curl -s https://codecov.io/bash) -J "app" -D ".build/debug"
