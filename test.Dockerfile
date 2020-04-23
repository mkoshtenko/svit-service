# Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.2

ARG env

RUN apt-get -q update && apt-get -q install -y \
    libsqlite3-dev \
    libssl-dev \
    sqlite3 \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

COPY . .

RUN swift package resolve && swift test --enable-code-coverage
RUN bash scripts/export-codecov.sh
