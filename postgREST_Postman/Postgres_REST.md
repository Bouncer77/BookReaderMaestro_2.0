# Postgres REST

## Как через Postman посмотреть содержием базы данных?

Необходимо скачать [postgrest](https://github.com/PostgREST/postgrest/releases/tag/v7.0.1)

[Введение](https://postgrest.org/en/v4.3/tutorials/tut0.html#step-3-install-postgrest)
[Репозиторий с postgrest на GitHub](https://github.com/PostgREST/postgrest)

postgrest поднимает локально web сервер, который пропускает через себя запросы Postman - возвращая ответы в JSON формате.

[Оригинал инструкции на англ](https://documenter.getpostman.com/view/5922408/RznJmGfn#ac795868-5d2e-4975-a022-3b06176850a6)
[Ссылка на документацию к postgrest](https://postgrest.org/en/v4.3/api.html)

[Работа с хранимыми процедурами](https://postgrest.org/en/v4.3/api.html#stored-procedures)

## tutorial.conf
db-uri = "postgres://postgres:postgres@localhost/db_brm"
db-schema = "brm_api"
db-anon-role = "ref_owner_brm_api"

```bash
./postgrest tutorial.conf
```