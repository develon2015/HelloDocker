# postgis
```
docker run -it -d --name postgis --network host -e POSTGRES_PASSWORD=password --privileged postgis/postgis

docker exec -it postgis psql -U postgres

SELECT * FROM pg_available_extensions WHERE name = 'postgis';
SELECT name, default_version,installed_version FROM pg_available_extensions WHERE name LIKE 'postgis%' or name LIKE 'address%';

create database test;
\c test
create extension postgis;
SELECT PostGIS_Full_Version();
```
