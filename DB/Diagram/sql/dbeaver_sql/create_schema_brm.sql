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

DROP FUNCTION IF EXISTS :api_schema_name.ui_get_questions();
DROP FUNCTION IF EXISTS :api_schema_name.ui_get_questionnaires();

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

---------------------------------------- 1. Вопросник -----------------------------------

-- 1.1 GET
CREATE OR REPLACE FUNCTION :api_schema_name.ui_get_questionnaires()
    RETURNS TABLE (
        questionnaire_id_var numeric,
        name_var text,
        description_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY SELECT questionnaire_id, name, description FROM "questionnaire";
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 1.2 CREATE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_questionnaire_create(p_questionnaire_id numeric, p_name text, p_description text)
    RETURNS numeric 
    LANGUAGE plpgsql
AS $function$
    DECLARE
        l_questionnaire_id numeric := nextval('questionnaire_id_sequence');
    BEGIN
        
        INSERT INTO "questionnaire" 
            (questionnaire_id, "name", description)
        VALUES(l_questionnaire_id, p_name, p_description);
    
        RETURN l_dictionary_id;
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопросник с таким кодом!' USING ERRCODE = '010201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 1.3 UPDATE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_questionnaire_modify(p_questionnaire_id numeric, p_name text, p_description text)
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

-- 1.4 DELETE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_questionnaire_delete(p_questionnaire_id numeric)
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

-- 2.1 GET
CREATE OR REPLACE FUNCTION :api_schema_name.ui_get_questions()
    RETURNS TABLE (
        question_id_var numeric,
        question_var text,
        hint_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY SELECT questionnaire_id, question, hint FROM "question";
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 2.2 CREATE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_create(p_question_id numeric, p_question text, p_hint text)
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
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопрос с таким кодом!' USING ERRCODE = '020201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_create_2(p_question_id numeric, p_question text, p_hint text)
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
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопрос с таким кодом!' USING ERRCODE = '020201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 2.3 UPDATE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_modify(p_question_id numeric, p_question text, p_hint text)
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

-- 2.4 DELETE
CREATE OR REPLACE FUNCTION :api_schema_name.ui_question_delete(p_question_id numeric)
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

-- 2.5 Добавление вопроса в опросник
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


---------------------------------------- 3. Вопросник-Вопрос -----------------------------------

---------------------------------------- 4. Возможный ответ -----------------------------------

---------------------------------------- 5. Ограничение длины -----------------------------------

-- 5.1
CREATE OR REPLACE FUNCTION :api_schema_name.ui_get_constraints()
    RETURNS TABLE (
        constraint_id_var numeric,
        name_var text,
        value_var numeric,
        description_var text)
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN QUERY select constraint_id, concat(table_name, '.',field_name), field_length, description from length_constraint;
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

-- 5.2
CREATE OR REPLACE FUNCTION :api_schema_name.ui_constraint_modify(p_constraint_id numeric, p_length numeric)
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
        
        execute format('ALTER TABLE %s DROP constraint IF EXISTS "%s"', l_table_name,l_constraint_name);
        execute format('ALTER TABLE %s ADD CONSTRAINT "%s" CHECK(char_length(cast(%s as text)) <= %s);', l_table_name, l_constraint_name, l_field_name, p_length::text);

        UPDATE "length_constraint" SET field_length = p_length WHERE constraint_id = p_constraint_id;
    
        RETURN p_constraint_id;
        
        EXCEPTION
            WHEN check_violation THEN
                RAISE EXCEPTION 'Уже имеются данные не соответствующие данному ограничению!' USING ERRCODE = '050201';
        
    END;
$function$
    SET search_path = :api_schema_name, pg_temp;

