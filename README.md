## Overview
Storage for simple vertices inside table 

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
Using docker-compose ps, check the status of your services:
```
docker-compose ps
```

## How to run a debug build
### 1. Run PostgreSQL container
Start a container with database instance:
`docker run -d --name svit_db_postgres -e POSTGRES_USER=svit_db_user -e POSTGRES_DB=svit_db -e POSTGRES_PASSWORD=password -p 54320:5432 postgres:12`

The version of the container is `12`, it is taken from https://hub.docker.com/_/postgres
This will add a user `svit_db_user`  and create the database  `svit_db`.
The database will be accessible via  `54320` public port.
These values are specified in `configure.swift`.

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

### 3. Migrations
In vapor 4 db migration do not run automatically, to do so you have to execute:
`swift run Run migrate`

it takes configurations and migrations from `configure.swift` and will try to execute them. 

### 2. Launch  From the XCode
1. Choose `Run` target against the Mac machine
2. Hit `CMD+R`

## API usage examples
### Vertex
- list:
`curl http://localhost:8080/vertices`   // will be removed.

- create:
`curl -H "Content-Type: application/json" -d '{"data":"{\"a\":1,\"b\":[]}"}' -X POST http://localhost:8080/vertices`

- delete:
`curl -H "Content-Type: application/json" -X DELETE http://localhost:8080/vertices/3`

- update:
`curl -H "Content-Type: application/json" -d '{"data":"{\"a\":\"UPDATED\"}"}' -X PATCH http://localhost:8080/vertices/1`

### RELATION

- list:
`curl http://localhost:8080/relations`   // will be removed.

- create:
`curl -H "Content-Type: application/json" -d '{"type":"implements", "from": 1, "to": 2, "data":"{\"aa\":11}"}' -X POST http://localhost:8080/relations`

- delete:
`curl -H "Content-Type: application/json" -X DELETE http://localhost:8080/relations/1`

- update:
`curl -H "Content-Type: application/json" -d '{"data":"{\"aa\":100}"}' -X PATCH http://localhost:8080/relations/6`


## Links
Docker cheat-sheet:
https://www.saltycrane.com/blog/2017/08/docker-cheat-sheet/

Vapor repo:
https://github.com/vapor/vapor
