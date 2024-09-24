# postgresql

## 简单运行
```
docker run -it -d --name postgres --network host -e POSTGRES_PASSWORD=password postgres

psql -U postgres -p 5432 -h 127.0.0.1
psql -U postgres -p 5432 -h 127.0.0.1 -W # 目前不需要密码
```

## Docker Compose
```
services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - pgdata:/var/lib/postgresql/data 
 
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
 
volumes:
  pgdata:
```

## 环境变量
- `POSTGRES_USER` 指定具有超级用户权限的用户和同名的数据库。

  当此项为空时，使用 `Postgres` 作为默认用户

- `PGDATA` 定义数据库文件的另一个默认位置或子目录
- `POSTGRES_HOST_AUTH_METHOD` 控制主机连接所有数据库、用户和地址的认证方法。

  比如 `POSTGRES_HOST_AUTH_METHOD=trust` 可以允许所有无密码连接（不建议使用这种方法）

  这个可选变量可用于控制所有数据库、所有用户和所有地址的主机连接的认证方式。 如果未指定，则使用 `scram-sha-256` 密码验证（在 14+ 中；在旧版本中使用 md5）。 在未初始化的数据库中，将通过此近似行填充 pg_hba.conf：

  ```
  echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> pg_hba.conf
  ```

## 参考
https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/
https://github.com/docker-library/docs/blob/master/postgres/README.md
