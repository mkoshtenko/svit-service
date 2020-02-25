[![Build Status](https://travis-ci.org/mkoshtenko/svit-service.svg?branch=master)](https://travis-ci.org/mkoshtenko/svit-service)
[![codecov](https://codecov.io/gh/mkoshtenko/svit-service/branch/master/graph/badge.svg)](https://codecov.io/gh/mkoshtenko/svit-service)
[![codebeat badge](https://codebeat.co/badges/ab58552c-96ab-4216-a399-d76621c9c8d7)](https://codebeat.co/projects/github-com-mkoshtenko-svit-service-master)

## Overview
Storage for simple vertices inside table 

# Swift `5.2` or greater is required
It is in development status, however latest snapshot can be downloaded [here](https://swift.org/download/#releases)
For docker container is used [nightly-5.2-bionic](https://hub.docker.com/r/swiftlang/swift/tags)

Pull the container with the following:
`docker pull swiftlang/swift:nightly-5.2-bionic`

## Dependencies
If Vapor Toolbox is already installed skip to step 3.

1. Install [homebrew](https://brew.sh), it will be used as package manager for Vapor toolbox. 

2. Install Vapor Toolbox, it requires Swift 4.1 or higher
  ```
 brew tap vapor/tap
 brew install vapor/tap/vapor
 ```

3. Update Vapor Toolbox
  `brew upgrade vapor`

4. Updates dependencies
  `vapor update`

If you are experiencing problems with Swift Package Manager, sometimes cleaning can help.
`vapor clean`

## Run tests

### Locally on Mac OS using Xcode

Open Xcode
`vapor xcode -y`

To run unit tests, select `Run` scheme and hit `Command+U`.

### In a Docker container

```
docker build -f 'test.Dockerfile' .
```

## How to build and run
### Docker
Before start you can remove all cached data:
```
docker system prune -a
```

Create file with necessary environment variables.

Build environment example '.env':
```
SVIT_DB_PASSWORD=<db password>
SVIT_DB_USER=<db username>
SVIT_DB_PORT=54320
SVIT_DB_NAME=svit_db
```

Do not forget to replace values with the real data.

You can verify the environment with the config command, which prints resolved application config to the terminal:
```
docker-compose config
```

Run containers in the background:
```
docker-compose build
docker-compose up -d
```
After these commands the service should be accessible at configured location (e.g. `http://localhost:8080/health`).
The configuration can be changed in `web.Dockerfile`.

Using docker-compose ps, check the status of your services:
```
docker-compose ps
docker-compose stop
```

## How to run a debug build

For development purposes might be necessary to run the service from the Xcode and play with the API.
Since this will require the database service running, the following steps explain how it can be launched.

### 1. Run PostgreSQL container
Start a container with database instance:
`docker run -d --name svit_db_postgres -e POSTGRES_USER=svit_db_user -e POSTGRES_DB=svit_db -e POSTGRES_PASSWORD=password -p 54320:5432 postgres:12`

The version of the container is `12`, it is taken from https://hub.docker.com/_/postgres
This will add a user `svit_db_user`  and create the database  `svit_db`.
The database will be accessible via  `54320` public port.
These values are specified in `PSQLFactory.swift` as defaults.

Print and check the container is listed there:
`docker ps -a`

To stop the db container run:
```
docker stop svit_db_postgres
docker rm svit_db_postgres
```

To run commands inside the container:
```
# run bash
docker exec -it svit_db_postgres bash

# or run psql
docker exec -it svit_db_postgres psql -d svit_db -U svit_db_user
```

### 2. Migrations
In vapor 4 db migration do not run automatically, to do so you need to execute:
`swift run Run migrate`

Or, as an alternative way, it is also possible to run them from the xcode with `migrate -y` argument added to the scheme.

it takes configurations and migrations from `configure.swift` and will try to execute them. 

### 3. Launch  From the XCode
1. Create xcodeproj from repo with vapor cli `vapor xcode -y`
2. Choose `Run` scheme against the Mac machine
3. Hit `CMD+R`

## API usage examples
### VERTEX
- create:
`curl -H "Content-Type: application/json" -d '{"type":"test", "data":""}' -X POST http://localhost:8080/vertices`

- delete:
`curl -H "Content-Type: application/json" -X DELETE http://localhost:8080/vertices/3`

- update:
`curl -H "Content-Type: application/json" -d '{"data":"UPDATED"}' -X PATCH http://localhost:8080/vertices/1`

### RELATION
- create:
`curl -H "Content-Type: application/json" -d '{"type":"implements", "from": 1, "to": 2, "data":""}' -X POST http://localhost:8080/relations`

- delete:
`curl -H "Content-Type: application/json" -X DELETE http://localhost:8080/relations/1`

- update:
`curl -H "Content-Type: application/json" -d '{"data":"{\"aa\":100}"}' -X PATCH http://localhost:8080/relations/6`

### COUNT
- get:
`curl http://127.0.0.1:8080/count?from=1&type=implements`

## Links
Docker cheat-sheet:
https://www.saltycrane.com/blog/2017/08/docker-cheat-sheet/

Vapor repo:
https://github.com/vapor/vapor
