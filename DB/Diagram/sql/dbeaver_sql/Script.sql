-- исполнять под пользователем postgres из созданной базы справочников                                                                                                                                                           -- Автор Косенков Иван 

-- ############################################# БЛОК НАСТРОЕК ############################################

@set brm_db_name = db_brm
@set api_schema_owner = ref_owner_brm_api
@set api_schema_name = "brm_api"
@set api_schema_name_quoted = 'brm_api'
@set brm_db_data_tbs = brm_data_tbs
@set brm_db_index_tbs = brm_index_tbs

-- ########################################## УДАЛЕНИЕ ОБЪЕКТОВ ###########################################

DROP TABLE IF EXISTS :api_schema_name.possible_answer CASCADE;
DROP TABLE IF EXISTS :api_schema_name.question CASCADE;
DROP TABLE IF EXISTS :api_schema_name.questionnaire CASCADE;
DROP TABLE IF EXISTS :api_schema_name.length_constraint CASCADE;

DROP SEQUENCE IF EXISTS :api_schema_name.question_id_sequence CASCADE;
DROP SEQUENCE IF EXISTS :api_schema_name.questionnaire_id_sequence CASCADE;

/*DROP FUNCTION IF EXISTS :api_schema_name.ui_get_questions();
DROP FUNCTION IF EXISTS :api_schema_name.ui_get_questionnaires();*/

-- ############################################# СОЗДАНИЕ СХЕМ ############################################

-- удаляем схемы
DROP SCHEMA IF EXISTS :api_schema_name;

-- удаляем роли владельцев
DROP ROLE IF EXISTS :api_schema_owner;

-- создаем владельцев схем
CREATE ROLE :api_schema_owner WITH
  NOLOGIN
  NOSUPERUSER
  NOINHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;
COMMENT ON ROLE :api_schema_owner IS 'Владелец схемы API Book Reader Maestro';

-- создаем схемы
CREATE SCHEMA :api_schema_name AUTHORIZATION :api_schema_owner;

-- ############################################ СОЗДАНИЕ ТАБЛИЦ ###########################################

-- 1. QUESTIONNAIRE
CREATE TABLE :api_schema_name.questionnaire (
    questionnaire_id numeric NOT NULL,
    name text NOT NULL,
    description text
) TABLESPACE :brm_db_data_tbs;

CREATE UNIQUE INDEX questionnaire_pk ON :api_schema_name.questionnaire(questionnaire_id) TABLESPACE :brm_db_index_tbs;

COMMENT ON TABLE :api_schema_name.questionnaire IS 'Вопросник';
COMMENT ON COLUMN :api_schema_name.questionnaire.questionnaire_id IS 'Идентификатор вопросника';
COMMENT ON COLUMN :api_schema_name.questionnaire.name IS 'Название вопросника';
COMMENT ON COLUMN :api_schema_name.questionnaire.description IS 'Описание вопросника';

ALTER TABLE :api_schema_name.questionnaire REPLICA IDENTITY FULL;
ALTER TABLE :api_schema_name.questionnaire OWNER TO :api_schema_owner;

CREATE SEQUENCE :api_schema_name.questionnaire_id_sequence
    INCREMENT BY 1
    MINVALUE 100
    MAXVALUE 9223372036854775807
    CACHE 1
    NO CYCLE;

ALTER SEQUENCE :api_schema_name.questionnaire_id_sequence OWNER TO :api_schema_owner;

-- 2. QUESTION
CREATE TABLE :api_schema_name.question (
    question_id numeric NOT NULL,
    question text NOT NULL,
    hint text
) TABLESPACE :brm_db_data_tbs;

CREATE UNIQUE INDEX question_pk ON :api_schema_name.question(question_id) TABLESPACE :brm_db_index_tbs;

COMMENT ON TABLE :api_schema_name.question IS 'Вопрос';
COMMENT ON COLUMN :api_schema_name.question.question_id IS 'Идентификатор вопроса';
COMMENT ON COLUMN :api_schema_name.question.question IS 'Вопрос';
COMMENT ON COLUMN :api_schema_name.question.hint IS 'Подсказка';

ALTER TABLE :api_schema_name.question REPLICA IDENTITY FULL;
ALTER TABLE :api_schema_name.question OWNER TO :api_schema_owner;

CREATE SEQUENCE :api_schema_name.question_id_sequence
    INCREMENT BY 1
    MINVALUE 100
    MAXVALUE 9223372036854775807
    CACHE 1
    NO CYCLE;

ALTER SEQUENCE :api_schema_name.question_id_sequence OWNER TO :api_schema_owner;

-- 3. QUESTIONNAIRE_QUESTION
CREATE TABLE :api_schema_name.questionnaire_question (
    questionnaire_id numeric NOT NULL,
    question_id numeric NOT NULL,
    FOREIGN KEY (questionnaire_id) REFERENCES :api_schema_name.questionnaire(questionnaire_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES :api_schema_name.question(question_id) ON DELETE CASCADE
) TABLESPACE :brm_db_data_tbs;

CREATE UNIQUE INDEX questionnaire_question_pk ON :api_schema_name.questionnaire_question(questionnaire_id, question_id) TABLESPACE :brm_db_index_tbs;

COMMENT ON TABLE :api_schema_name.questionnaire_question IS 'Реализует связь многие ко многим между Вопросник и Вопрос';
COMMENT ON COLUMN :api_schema_name.questionnaire_question.questionnaire_id IS 'Идентификатор вопросника';
COMMENT ON COLUMN :api_schema_name.questionnaire_question.question_id IS 'Идентификатор вопроса';

ALTER TABLE :api_schema_name.questionnaire_question REPLICA IDENTITY FULL;
ALTER TABLE :api_schema_name.questionnaire_question OWNER TO :api_schema_owner;

-- 4. POSSIBLE ANSWER
CREATE TABLE :api_schema_name.possible_answer (
    possible_answer_id numeric NOT NULL,
    question_id numeric NOT NULL,
    answer text NOT NULL,
    is_truthful boolean NOT NULL DEFAULT false,
    explanation text,
    FOREIGN KEY (question_id) REFERENCES :api_schema_name.question(question_id) ON DELETE CASCADE
) TABLESPACE :brm_db_data_tbs;

CREATE UNIQUE INDEX possible_answer_pk ON :api_schema_name.possible_answer(possible_answer_id, question_id) TABLESPACE :brm_db_index_tbs;

COMMENT ON TABLE :api_schema_name.possible_answer IS 'Возможный ответ';
COMMENT ON COLUMN :api_schema_name.possible_answer.possible_answer_id IS 'Идентификатор ответа';
COMMENT ON COLUMN :api_schema_name.possible_answer.question_id IS 'Идентификатор вопроса';
COMMENT ON COLUMN :api_schema_name.possible_answer.answer IS 'Возможный ответ';
COMMENT ON COLUMN :api_schema_name.possible_answer.is_truthful IS 'Правдивый ответ';
COMMENT ON COLUMN :api_schema_name.possible_answer.explanation IS 'Объяснение';

ALTER TABLE :api_schema_name.possible_answer REPLICA IDENTITY FULL;
ALTER TABLE :api_schema_name.possible_answer OWNER TO :api_schema_owner;

-- 5. LENGTH CONSTRAINT
CREATE TABLE :api_schema_name.length_constraint (
    constraint_id numeric NOT NULL,
    table_name text NOT NULL,
    field_name text NOT NULL,
    field_length numeric NOT NULL,
    description text NOT NULL
    ) TABLESPACE :brm_db_data_tbs;

CREATE UNIQUE INDEX length_constraint_pk ON :api_schema_name.length_constraint(constraint_id) TABLESPACE :brm_db_index_tbs;

COMMENT ON TABLE :api_schema_name.length_constraint IS 'Ограничения';
COMMENT ON COLUMN :api_schema_name.length_constraint.constraint_id IS 'Идентификатор ограничения';
COMMENT ON COLUMN :api_schema_name.length_constraint.table_name IS 'Наименование таблицы';
COMMENT ON COLUMN :api_schema_name.length_constraint.field_name IS 'Наименование поля';
COMMENT ON COLUMN :api_schema_name.length_constraint.field_length IS 'Максимальная длина поля (количестве символов)';
COMMENT ON COLUMN :api_schema_name.length_constraint.description IS 'Описание ограничиваемого поля';

ALTER TABLE :api_schema_name.length_constraint REPLICA IDENTITY FULL;
ALTER TABLE :api_schema_name.length_constraint OWNER TO :api_schema_owner;

-- ########################################### СИСТЕМНЫЕ ДАННЫЕ ###########################################

INSERT INTO :api_schema_name.length_constraint
    (constraint_id, table_name, field_name, field_length, description)
VALUES
    (1, 'questionnaire', 'name', 255, 'Имя вопросника'),
    (2, 'question', 'hint', 255, 'Подсказка к вопросу')
;

-- Применение правил ограничения длины полей
do $$
DECLARE
    l_constraint_name text;
    l_table_name text;
    l_constraint_row record;
BEGIN
    FOR l_constraint_row IN (SELECT table_name, field_name, field_length FROM :api_schema_name.length_constraint) LOOP
        l_constraint_name := concat('length_constraint.', l_constraint_row.table_name, '.', l_constraint_row.field_name);
        l_table_name := concat(:api_schema_name_quoted, '.', l_constraint_row.table_name);
        execute format('ALTER TABLE %s DROP constraint IF EXISTS "%s"', l_table_name,l_constraint_name);
        execute format('ALTER TABLE %s ADD CONSTRAINT "%s" CHECK(char_length(cast(%s as text)) <= %s);', l_table_name,l_constraint_name, l_constraint_row.field_name,l_constraint_row.field_length);
    END LOOP;
end $$;

-- ############################################# ФУНКЦИИ #############################################

/* Таблица в БД
 * 1. Вопросник (questionnaire)
 * 2. Вопрос (question)
 * 3. Вопросник-Вопрос (questionnaire_question)
 * 4. Возможный ответ (possible_answer)
 * 5. Ограничение длины (length_constraint)
 */

/* CRUD
 * 1. Create (создание) - INSERT
 * 2. Read (чтение) - SELECT
 * 3. Update (модификация) - UPDATE
 * 4. Delete (удаление) - DELETE
 */

/* 
 * Правила нумерования функций
 * <номер_таблицы>.<номер_CRUD_операции>.<номер_функции>
 */

/* Правила именования функциий
 * 
 * Префикс 1 - Назначение функции:
 * ui_ - функции, вызываемые с User Interface - Интерфейса пользователя
 * core_ - функции необходимые только для вызова в других функциях Core (Ядро базы данных)
 * 
 * Префикс 2 - CRUD операция:
 * create_ - создание
 * read_ - чтение
 * update_ - модификация
 * delete_ - удаление
 * 
 * Основа - Имя функции:
 * <имя_таблицы> - для создания/чтения/модификации/удаления одной строки в таблице
 * <имя_таблицы>+'s' - для создания/чтения/модификации/удаления одной или более строк в таблице
 * */

/* Правила описания функций:
 * 
 * -- <имя CRUD операции>
 * -- <номер функции>
 * <удалить функцию, если такая функция уже существует>
 * -- <вызов функции>
 * -- <проверка результата выполнения функции>
 * <функция>
 * */

---------------------------------------- 1. Вопросник -----------------------------------

DROP FUNCTION :api_schema_name.ui_questionnaire_create(p_name text, p_description text);

-- CREATE
-- 1.1.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_create_questionnaire(p_name text, p_description text);
-- SELECT * FROM :api_schema_name.ui_create_questionnaire('Java Core', 'Контрольные вопросы часть 1. Базовый синтаксис.');
-- SELECT * FROM :api_schema_name.questionnaire;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_create_questionnaire(p_name text, p_description text)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    DECLARE
        l_questionnaire_id numeric := nextval('questionnaire_id_sequence');
    BEGIN
        
        INSERT INTO "questionnaire" 
            (questionnaire_id, "name", description)
        VALUES(l_questionnaire_id, p_name, p_description);
    
        RETURN l_questionnaire_id;
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопросник с таким кодом!' USING ERRCODE = '010201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

DROP FUNCTION :api_schema_name.ui_get_questionnaires();

-- READ
-- 1.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_questionnaires();
-- SELECT * FROM :api_schema_name.ui_read_questionnaires();
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_questionnaires()
    RETURNS TABLE (
        questionnaire_id_var numeric,
        name_var text,
        description_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY SELECT questionnaire_id, name, description FROM "questionnaire" ORDER BY questionnaire_id DESC;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

DROP FUNCTION :api_schema_name.ui_read_questionnaire(p_questionnaire_id numeric);

-- 1.2.2
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_questionnaire_by_id(p_questionnaire_id numeric);
-- SELECT * FROM :api_schema_name.ui_read_questionnaire_by_id(101);
-- SELECT * FROM :api_schema_name.questionnaire;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_questionnaire_by_id(p_questionnaire_id numeric)
    RETURNS TABLE (
        questionnaire_id_var numeric,
        name_var text,
        description_var text)
    LANGUAGE plpgsql
AS $function$
    DECLARE 
        l_questionnaire_rec record;
    BEGIN
        RETURN QUERY SELECT questionnaire_id, "name", description FROM "questionnaire" WHERE questionnaire_id = p_questionnaire_id;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

DROP FUNCTION :api_schema_name.ui_questionnaire_modify(p_questionnaire_id numeric, p_name text, p_description text);

-- UPDATE
-- 1.3.1 
DROP FUNCTION IF EXISTS :api_schema_name.ui_update_questionnaire(p_questionnaire_id numeric, p_name text, p_description text);
-- SELECT * FROM :api_schema_name.ui_update_questionnaire(102, 'Новые вопросы', 'Описание новых вопросов');
-- SELECT * FROM :api_schema_name.questionnaire;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_update_questionnaire(p_questionnaire_id numeric, p_name text, p_description text)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    BEGIN
        UPDATE "questionnaire" 
        SET name = p_name,
        description = p_description
        WHERE questionnaire_id = p_questionnaire_id;

        RETURN p_questionnaire_id;
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- DELETE
-- 1.4.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_questionnaire_delete_by_id(p_questionnaire_id numeric);
--SELECT * FROM :api_schema_name.ui_questionnaire_delete_by_id(104);
--SELECT * FROM :api_schema_name.questionnaire;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_questionnaire_delete_by_id(p_questionnaire_id numeric)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    BEGIN
        DELETE FROM "questionnaire" 
        WHERE questionnaire_id = p_questionnaire_id;

        RETURN p_questionnaire_id;
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

---------------------------------------- 2. Вопрос -----------------------------------

-- CREATE
-- 2.1.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_question_create(p_question text, p_hint text);
-- SELECT * FROM :api_schema_name.ui_question_create('К какому типа языка программирование относиться Java?', 'байт-код подается в интерпретатор(Виртуальная машина)');
-- SELECT * FROM :api_schema_name.question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_create(p_question text, p_hint text)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    DECLARE
        l_question_id numeric := nextval('question_id_sequence');
    BEGIN
        
        INSERT INTO "question" 
            (question_id, question, hint)
        VALUES(l_question_id, p_question, p_hint);
    
        RETURN l_question_id;
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

/*Создание вопроса с вариантами ответа, как бесконечное количество параметров (см pl/pgSQL Массивы)*/
-- 2.1.2

-- READ
-- 2.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_get_questions();
-- SELECT * FROM :api_schema_name.ui_get_questions();
-- SELECT * FROM :api_schema_name.question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_get_questions()
    RETURNS TABLE (
        question_id_var numeric,
        question_var text,
        hint_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY SELECT question_id, question, hint FROM "question" ORDER BY question_id DESC;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 2.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_get_question_by_id();
-- SELECT * FROM :api_schema_name.ui_get_question_by_id(116);
-- SELECT * FROM :api_schema_name.question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_get_question_by_id(p_question_id numeric)
    RETURNS TABLE (
        question_id_var numeric,
        question_var text,
        hint_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY SELECT question_id, question, hint FROM "question" WHERE question_id = p_question_id;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- UPDATE
-- 2.3.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_update_question(p_question_id numeric, p_question text, p_hint text);
-- SELECT * FROM :api_schema_name.ui_update_question(115, 'Что такое Java виртуальная машина?', 'Переводит наш скомпилированный байт-код в машинные операции');
-- SELECT * FROM :api_schema_name.question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_update_question(p_question_id numeric, p_question text, p_hint text)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    BEGIN
        UPDATE "question" 
        SET question = p_question,
        hint = p_hint
        WHERE question_id = p_question_id;

        RETURN p_question_id;
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- DELETE
-- 2.4.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_question_delete(p_question_id numeric);
-- SELECT * FROM :api_schema_name.ui_question_delete_by_id(116);
-- SELECT * FROM :api_schema_name.question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_delete_by_id(p_question_id numeric)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    BEGIN
        DELETE FROM "question" 
        WHERE question_id = p_question_id;

        RETURN p_question_id;
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

---------------------------------------- 3. Вопросник-Вопрос -----------------------------------

-- CREATE
/* Добавление вопроса в вопросник */
-- 3.1.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_add_question_to_questionnaire(p_question_id numeric, p_questionnaire_id numeric);
-- SELECT * FROM :api_schema_name.ui_add_question_to_questionnaire(115, 101);
/*SELECT * FROM :api_schema_name.questionnaire_question;
SELECT * FROM :api_schema_name.questionnaire;
SELECT * FROM  :api_schema_name.question;*/
CREATE OR REPLACE FUNCTION :api_schema_name.ui_add_question_to_questionnaire(p_question_id numeric, p_questionnaire_id numeric)
    RETURNS void 
    LANGUAGE plpgsql
AS $function$
    BEGIN
        INSERT INTO questionnaire_question
            (question_id, questionnaire_id)
        VALUES(p_question_id, p_questionnaire_id);

        RETURN;
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопрос в вопроснике!' USING ERRCODE = '020501';

    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- READ
-- 3.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_questionnaire_questions();
-- SELECT * FROM :api_schema_name.ui_read_questionnaire_questions();
-- SELECT * FROM :api_schema_name.questionnaire_question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_questionnaire_questions()
    RETURNS TABLE (
        questionnaire_id_var numeric,
        questionnaire_name_var text,
        question_id_var numeric,
        question_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY 
        SELECT qq.questionnaire_id, qr."name", qq.question_id, qn.question 
        FROM questionnaire_question AS qq 
        
        JOIN questionnaire AS qr
        ON qq.questionnaire_id = qr.questionnaire_id
        
        JOIN question AS qn
        ON qq.question_id = qn.question_id
        
        ORDER BY qq.questionnaire_id DESC, qq.question_id DESC;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- UPDATE
-- 3.3.1

-- DELETE
-- 3.4.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_delete_questionnaire_question_by_questionnaire_id(p_questionnaire_id numeric);
-- SELECT * FROM :api_schema_name.ui_delete_questionnaire_question_by_questionnaire_id(101);
-- SELECT * FROM :api_schema_name.questionnaire_question;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_delete_questionnaire_question_by_questionnaire_id(p_questionnaire_id numeric)
    RETURNS void
    LANGUAGE plpgsql
AS $function$
    BEGIN
        
        DELETE FROM questionnaire_question
        WHERE questionnaire_id = p_questionnaire_id;
        
        RETURN;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

---------------------------------------- 4. Возможный ответ -----------------------------------

-- CREATE
-- 4.1.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_create_possible_answer(p_question_id numeric, p_answer text, p_is_truthful boolean, p_explanation text);
/*SELECT * FROM :api_schema_name.ui_create_possible_answer(115, 'Возможный ответ 1', false, 'Так 1');
SELECT * FROM :api_schema_name.ui_create_possible_answer(115, 'Возможный ответ 2', false, 'Так 2');
SELECT * FROM :api_schema_name.ui_create_possible_answer(115, 'Возможный ответ 3', true, 'Так 3 - Верный');
SELECT * FROM :api_schema_name.ui_create_possible_answer(115, 'Возможный ответ 4', false, 'Так 4');*/

/*SELECT * FROM :api_schema_name.possible_answer;
SELECT * FROM :api_schema_name.question;*/
CREATE OR REPLACE FUNCTION :api_schema_name.ui_create_possible_answer(p_question_id numeric, p_answer text, p_is_truthful boolean, p_explanation text)
    RETURNS void
    LANGUAGE plpgsql
AS $function$
    DECLARE
        l_possible_answer_id numeric;
    BEGIN
        
        SELECT (coalesce(max(possible_answer_id), 0) + 1) INTO l_possible_answer_id FROM possible_answer WHERE question_id = p_question_id;
        
        INSERT INTO possible_answer
            (possible_answer_id, question_id, answer, is_truthful, explanation)
        VALUES(l_possible_answer_id, p_question_id, p_answer, p_is_truthful, p_explanation);

        RETURN;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- READ
-- 4.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_possible_answers();
--SELECT * FROM :api_schema_name.ui_read_possible_answers();
/*SELECT * FROM :api_schema_name.possible_answer;
SELECT * FROM :api_schema_name.question;*/
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_possible_answers()
    RETURNS TABLE (
        question_id_var numeric,
        possible_answer_id_var numeric,
        answer_var text,
        is_truthful_var boolean,
        explanation_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY 
        SELECT question_id, possible_answer_id, answer, is_truthful, explanation
        FROM possible_answer
        ORDER BY question_id DESC, possible_answer_id DESC;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 4.2.2
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_possible_answer_by_question_id(p_question_id numeric);
-- SELECT * FROM :api_schema_name.ui_read_possible_answer_by_question_id(115);
/*SELECT * FROM :api_schema_name.possible_answer;
SELECT * FROM :api_schema_name.question;*/
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_possible_answer_by_question_id(p_question_id numeric)
    RETURNS TABLE (
        possible_answer_id_var numeric,
        answer_var text,
        is_truthful_var boolean,
        explanation_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY 
        SELECT possible_answer_id, answer, is_truthful, explanation
        FROM possible_answer
        WHERE question_id = p_question_id
        ORDER BY possible_answer_id DESC;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- UPDATE

-- DELETE

---------------------------------------- 5. Ограничение длины -----------------------------------

-- CREATE

-- READ
-- 5.2.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_read_length_constraints();
-- SELECT * FROM :api_schema_name.ui_read_length_constraints();
-- SELECT * FROM :api_schema_name.length_constraint;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_read_length_constraints()
    RETURNS TABLE (
        constraint_id_var numeric,
        name_var text,
        value_var numeric,
        description_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY
        SELECT constraint_id, concat(table_name, '.',field_name), field_length, description
        FROM length_constraint
        ORDER BY constraint_id;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- UPDATE
-- 5.3.1
DROP FUNCTION IF EXISTS :api_schema_name.ui_update_constraint(p_constraint_id numeric, p_length numeric);
-- SELECT * FROM :api_schema_name.ui_update_constraint(1, 120);
-- SELECT * FROM :api_schema_name.length_constraint;
CREATE OR REPLACE FUNCTION :api_schema_name.ui_update_constraint(p_constraint_id numeric, p_length numeric)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    DECLARE
        l_constraint_name text;
        l_table_name text;
        l_field_name text;
    BEGIN
        -- пытаемся применить ограничение
        SELECT table_name, field_name INTO l_table_name, l_field_name FROM length_constraint WHERE constraint_id = p_constraint_id;
        l_constraint_name := concat('length_constraint.', l_table_name, '.', l_field_name);
        
        EXECUTE format('ALTER TABLE %s DROP constraint IF EXISTS "%s"', l_table_name,l_constraint_name);
        EXECUTE format('ALTER TABLE %s ADD CONSTRAINT "%s" CHECK(char_length(cast(%s as text)) <= %s);', l_table_name, l_constraint_name, l_field_name, p_length::text);

        UPDATE "length_constraint" SET field_length = p_length WHERE constraint_id = p_constraint_id;
    
        RETURN p_constraint_id;
        
        EXCEPTION
            WHEN check_violation THEN
                RAISE EXCEPTION 'Уже имеются данные не соответствующие данному ограничению!' USING ERRCODE = '050201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- DELETE

---------------------------------------- 6. Основной функционал -----------------------------------

-- 6.1.1
/* Добавление вопроса, связывание вопроса с вопросником, добавление вариантов ответа*/
-- p_answer - верный ответ
-- p_possible_answer - неверный ответ

DROP FUNCTION IF EXISTS :api_schema_name.ui_create_question_to_questionnaire_with_possible_answers(p_questionnaire_id numeric, p_question text, p_hint text, p_answer text, p_possible_answer text);
SELECT * FROM :api_schema_name.questionnaire;
SELECT * FROM :api_schema_name.ui_create_question_to_questionnaire_with_possible_answers(105, 'Зачем нужен оператор instanceof?', null, 'Оператор instanceof возвращает true, если объект является экземпляром класса или его потомком.', 'Оператор instanceof не нужен');
CREATE OR REPLACE FUNCTION :api_schema_name.ui_create_question_to_questionnaire_with_possible_answers(p_questionnaire_id numeric, p_question text, p_hint text, p_answer text, p_possible_answer text)
    RETURNS TABLE (
        question_var text,
        possible_answer_var text)
    LANGUAGE plpgsql
AS $function$
    DECLARE 
        l_question_id numeric; 
    
    BEGIN
        /* Создание вопроса */
        -- p_question text, p_hint text 
        l_question_id := ui_question_create(p_question, p_hint);
    
        /* Добавление вопроса в вопросник */
        -- p_question_id numeric, p_questionnaire_id numeric
        PERFORM * FROM ui_add_question_to_questionnaire(l_question_id, p_questionnaire_id);

        /* Создание верного варианта ответа */
        -- p_question_id numeric, p_answer text, p_is_truthful boolean, p_explanation text
        PERFORM * FROM ui_create_possible_answer(l_question_id, p_answer, true, null);
    
        /* Создание неверного варианта ответа */
        PERFORM * FROM ui_create_possible_answer(l_question_id, p_possible_answer, false, null);
    
        RETURN QUERY
        SELECT q.question, pa.answer
        FROM question AS q
        JOIN possible_answer AS pa
        ON q.question_id = pa.question_id
        ORDER BY pa.possible_answer_id;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

SELECT q.question, pa.answer
        FROM :api_schema_name.question AS q
        JOIN :api_schema_name.possible_answer AS pa
        ON q.question_id = pa.question_id
        ORDER BY pa.possible_answer_id;

