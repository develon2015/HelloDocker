# alpine/psql
DockerHub: https://hub.docker.com/r/alpine/psql
```
alias pg='sudo docker run -it --rm --network="host" alpine/psql'

psql -h localhost -U postgres
psql postgres://psqladmin:Eha72NtzKe01@postgresql.example:5432/psql?sslmode=require
```
