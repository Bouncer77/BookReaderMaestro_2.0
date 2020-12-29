-- исполнять под пользователем postgres из базы postgres

-- ######################## блок настроек ########################

@set brm_db_name = db_brm
@set brm_db_name_quoted = 'db_brm'

@set brm_db_owner = brm_db_owner

@set brm_db_data_tbs = brm_data_tbs
@set brm_db_index_tbs = brm_index_tbs

-- папки должны быть заранее созданы
-- mkdir /var/lib/pgsql/12/data/brm_data_tbs
-- mkdir /var/lib/pgsql/12/data/brm_index_tbs
-- chown postgres:postgres /var/lib/pgsql/12/data/brm_data_tbs
-- chown postgres:postgres /var/lib/pgsql/12/data/brm_index_tbs
-- chmod go-rwx /var/lib/pgsql/12/data/brm_data_tbs
-- chmod go-rwx /var/lib/pgsql/12/data/brm_index_tbs

@set brm_db_data_tbs_loc = 'C:/Apps/PostgresSQL/data/brm_data_tbs'
@set brm_db_index_tbs_loc = 'C:/Apps/PostgresSQL/data/brm_index_tbs'

-- ###############################################################

-- отключаем все пользовательские сессии
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = :brm_db_name_quoted;
-- отключаем возможность новых подключений для пользователя postgres
DO $$
    BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = :brm_db_name_quoted) THEN
        REVOKE CONNECT ON DATABASE :brm_db_name FROM postgres;
    END IF;
END $$;

-- удаляем базу
DROP DATABASE IF EXISTS :brm_db_name;

-- удаляем табличные пространства
DROP TABLESPACE IF EXISTS :brm_db_data_tbs;
DROP TABLESPACE IF EXISTS :brm_db_index_tbs;

DROP ROLE IF EXISTS :brm_db_owner;

-- создаем владельца базы
CREATE ROLE :brm_db_owner WITH
  NOLOGIN
  NOSUPERUSER
  NOINHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  VALID UNTIL 'infinity';
COMMENT ON ROLE :brm_db_owner IS 'Владелец базы данных Book Reader Maestro';

-- создаем табличные пространства
CREATE TABLESPACE :brm_db_data_tbs OWNER :brm_db_owner LOCATION :brm_db_data_tbs_loc;
COMMENT ON TABLESPACE :brm_db_data_tbs IS 'Табличное пространство данных базы Book Reader Maestro';
CREATE TABLESPACE :brm_db_index_tbs OWNER :brm_db_owner LOCATION :brm_db_index_tbs_loc;
COMMENT ON TABLESPACE :brm_db_index_tbs IS 'Табличное пространство индексов базы Book Reader Maestro';

-- создаем базу
CREATE DATABASE :brm_db_name
    WITH
    OWNER = :brm_db_owner
    ENCODING = 'UTF8'
    TABLESPACE = :brm_db_data_tbs
    CONNECTION LIMIT = -1;
COMMENT ON DATABASE :brm_db_name IS 'База данных Book Reader Maestro';

-- запрещаем подключение PUBLIC
REVOKE CONNECT ON DATABASE :brm_db_name FROM PUBLIC;

-- назначаем привилегии
GRANT CONNECT ON DATABASE :brm_db_name TO postgres;