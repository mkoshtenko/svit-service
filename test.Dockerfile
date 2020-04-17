# Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.2

ARG env

RUN apt-get -q update && apt-get -q install -y \
    libssl-dev \
    zlib1g-dev \
    sqlite3 libsqlite3-dev \
    && rm -r /var/lib/apt/lists/*

WORKDIR /root
COPY . .

RUN swift package resolve
RUN swift test --enable-code-coverage

RUN bash scripts/export-codecov.sh

# RUN bash <(curl -s https://codecov.io/bash) -v -J "app" -D ".build/debug" -t "0ae921f5-d10f-48b8-afcc-3bd80159eaa6" || echo 'Could not submit codecov report'
