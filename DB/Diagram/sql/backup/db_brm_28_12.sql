PGDMP     0                    x            db_brm    12.4    12.4 >    4           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            5           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            6           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            7           1262    19589    db_brm    DATABASE     �   CREATE DATABASE db_brm WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Russian_Russia.1251' LC_CTYPE = 'Russian_Russia.1251' TABLESPACE = brm_data_tbs;
    DROP DATABASE db_brm;
                brm_db_owner    false            8           0    0    DATABASE db_brm    ACL     �   REVOKE CONNECT,TEMPORARY ON DATABASE db_brm FROM PUBLIC;
GRANT TEMPORARY ON DATABASE db_brm TO PUBLIC;
GRANT CONNECT ON DATABASE db_brm TO postgres;
                   brm_db_owner    false    2871                        2615    19677    brm_api    SCHEMA        CREATE SCHEMA brm_api;
    DROP SCHEMA brm_api;
                ref_owner_brm_api    false            �            1255    19991 2   ui_add_question_to_questionnaire(numeric, numeric)    FUNCTION     @  CREATE FUNCTION brm_api.ui_add_question_to_questionnaire(p_question_id numeric, p_questionnaire_id numeric) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        INSERT INTO questionnaire_question
            (question_id, questionnaire_id)
        VALUES(p_question_id, p_questionnaire_id);

        RETURN;
        
        EXCEPTION
            WHEN unique_violation THEN
                RAISE EXCEPTION 'Уже имееется вопрос в вопроснике!' USING ERRCODE = '020501';

    END;
$$;
 k   DROP FUNCTION brm_api.ui_add_question_to_questionnaire(p_question_id numeric, p_questionnaire_id numeric);
       brm_api          postgres    false    7            �            1255    19993 &   ui_constraint_modify(numeric, numeric)    FUNCTION       CREATE FUNCTION brm_api.ui_constraint_modify(p_constraint_id numeric, p_length numeric) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
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
$$;
 W   DROP FUNCTION brm_api.ui_constraint_modify(p_constraint_id numeric, p_length numeric);
       brm_api          postgres    false    7            �            1255    19992    ui_get_constraints()    FUNCTION     u  CREATE FUNCTION brm_api.ui_get_constraints() RETURNS TABLE(constraint_id_var numeric, name_var text, value_var numeric, description_var text)
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        RETURN QUERY select constraint_id, concat(table_name, '.',field_name), field_length, description from length_constraint;
    END;
$$;
 ,   DROP FUNCTION brm_api.ui_get_constraints();
       brm_api          postgres    false    7            �            1255    19735    ui_get_questionnaires()    FUNCTION     =  CREATE FUNCTION brm_api.ui_get_questionnaires() RETURNS TABLE(questionnaire_id_var numeric, name_var text, description_var text)
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        RETURN QUERY SELECT questionnaire_id, name, description FROM "questionnaire";
    END;
$$;
 /   DROP FUNCTION brm_api.ui_get_questionnaires();
       brm_api          postgres    false    7            �            1255    19987    ui_get_questions()    FUNCTION     (  CREATE FUNCTION brm_api.ui_get_questions() RETURNS TABLE(question_id_var numeric, question_var text, hint_var text)
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        RETURN QUERY SELECT questionnaire_id, question, hint FROM "question";
    END;
$$;
 *   DROP FUNCTION brm_api.ui_get_questions();
       brm_api          postgres    false    7            �            1255    19988 '   ui_question_create(numeric, text, text)    FUNCTION     �  CREATE FUNCTION brm_api.ui_question_create(p_question_id numeric, p_question text, p_hint text) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
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
$$;
 _   DROP FUNCTION brm_api.ui_question_create(p_question_id numeric, p_question text, p_hint text);
       brm_api          postgres    false    7            �            1255    19990    ui_question_delete(numeric)    FUNCTION     /  CREATE FUNCTION brm_api.ui_question_delete(p_question_id numeric) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        DELETE FROM "question" 
        WHERE question_id = p_question_id;

        RETURN p_question_id;
        
    END;
$$;
 A   DROP FUNCTION brm_api.ui_question_delete(p_question_id numeric);
       brm_api          postgres    false    7            �            1255    19989 '   ui_question_modify(numeric, text, text)    FUNCTION     �  CREATE FUNCTION brm_api.ui_question_modify(p_question_id numeric, p_question text, p_hint text) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        UPDATE "question" 
        SET question = p_question,
        hint = p_hint
        WHERE question_id = p_question_id;

        RETURN p_question_id;
        
    END;
$$;
 _   DROP FUNCTION brm_api.ui_question_modify(p_question_id numeric, p_question text, p_hint text);
       brm_api          postgres    false    7            �            1255    19736 ,   ui_questionnaire_create(numeric, text, text)    FUNCTION     �  CREATE FUNCTION brm_api.ui_questionnaire_create(p_questionnaire_id numeric, p_name text, p_description text) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
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
$$;
 l   DROP FUNCTION brm_api.ui_questionnaire_create(p_questionnaire_id numeric, p_name text, p_description text);
       brm_api          postgres    false    7            �            1255    19738     ui_questionnaire_delete(numeric)    FUNCTION     M  CREATE FUNCTION brm_api.ui_questionnaire_delete(p_questionnaire_id numeric) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        DELETE FROM "questionnaire" 
        WHERE questionnaire_id = p_questionnaire_id;

        RETURN p_questionnaire_id;
        
    END;
$$;
 K   DROP FUNCTION brm_api.ui_questionnaire_delete(p_questionnaire_id numeric);
       brm_api          postgres    false    7            �            1255    19737 ,   ui_questionnaire_modify(numeric, text, text)    FUNCTION     �  CREATE FUNCTION brm_api.ui_questionnaire_modify(p_questionnaire_id numeric, p_name text, p_description text) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'brm_api', 'pg_temp'
    AS $$
    BEGIN
        UPDATE "questionnaire" 
        SET name = p_name,
        description = p_description
        WHERE questionnaire_id = p_questionnaire_id;

        RETURN p_questionnaire_id;
        
    END;
$$;
 l   DROP FUNCTION brm_api.ui_questionnaire_modify(p_questionnaire_id numeric, p_name text, p_description text);
       brm_api          postgres    false    7            �            1259    19726    length_constraint    TABLE     �   CREATE TABLE brm_api.length_constraint (
    constraint_id numeric NOT NULL,
    table_name text NOT NULL,
    field_name text NOT NULL,
    field_length numeric NOT NULL,
    description text NOT NULL
);
 &   DROP TABLE brm_api.length_constraint;
       brm_api         heap    postgres    false    7            9           0    0    TABLE length_constraint    COMMENT     H   COMMENT ON TABLE brm_api.length_constraint IS 'Ограничения';
          brm_api          postgres    false    209            :           0    0 &   COLUMN length_constraint.constraint_id    COMMENT     r   COMMENT ON COLUMN brm_api.length_constraint.constraint_id IS 'Идентификатор ограничения';
          brm_api          postgres    false    209            ;           0    0 #   COLUMN length_constraint.table_name    COMMENT     e   COMMENT ON COLUMN brm_api.length_constraint.table_name IS 'Наименование таблицы';
          brm_api          postgres    false    209            <           0    0 #   COLUMN length_constraint.field_name    COMMENT     _   COMMENT ON COLUMN brm_api.length_constraint.field_name IS 'Наименование поля';
          brm_api          postgres    false    209            =           0    0 %   COLUMN length_constraint.field_length    COMMENT     �   COMMENT ON COLUMN brm_api.length_constraint.field_length IS 'Максимальная длина поля (количестве символов)';
          brm_api          postgres    false    209            >           0    0 $   COLUMN length_constraint.description    COMMENT     w   COMMENT ON COLUMN brm_api.length_constraint.description IS 'Описание ограничиваемого поля';
          brm_api          postgres    false    209            �            1259    19713    possible_answer    TABLE       CREATE TABLE brm_api.possible_answer (
    possible_answer_id numeric NOT NULL,
    question_id numeric NOT NULL,
    answer text NOT NULL,
    is_truthful boolean DEFAULT false NOT NULL,
    explanation text
);

ALTER TABLE ONLY brm_api.possible_answer REPLICA IDENTITY FULL;
 $   DROP TABLE brm_api.possible_answer;
       brm_api         heap    ref_owner_brm_api    false    7            ?           0    0    TABLE possible_answer    COMMENT     M   COMMENT ON TABLE brm_api.possible_answer IS 'Возможный ответ';
          brm_api          ref_owner_brm_api    false    208            @           0    0 )   COLUMN possible_answer.possible_answer_id    COMMENT     k   COMMENT ON COLUMN brm_api.possible_answer.possible_answer_id IS 'Идентификатор ответа';
          brm_api          ref_owner_brm_api    false    208            A           0    0 "   COLUMN possible_answer.question_id    COMMENT     f   COMMENT ON COLUMN brm_api.possible_answer.question_id IS 'Идентификатор вопроса';
          brm_api          ref_owner_brm_api    false    208            B           0    0    COLUMN possible_answer.answer    COMMENT     U   COMMENT ON COLUMN brm_api.possible_answer.answer IS 'Возможный ответ';
          brm_api          ref_owner_brm_api    false    208            C           0    0 "   COLUMN possible_answer.is_truthful    COMMENT     Z   COMMENT ON COLUMN brm_api.possible_answer.is_truthful IS 'Правдивый ответ';
          brm_api          ref_owner_brm_api    false    208            D           0    0 "   COLUMN possible_answer.explanation    COMMENT     Q   COMMENT ON COLUMN brm_api.possible_answer.explanation IS 'Объяснение';
          brm_api          ref_owner_brm_api    false    208            �            1259    19687    question    TABLE     �   CREATE TABLE brm_api.question (
    question_id numeric NOT NULL,
    question text NOT NULL,
    hint text,
    CONSTRAINT "length_constraint.question.hint" CHECK ((char_length(hint) <= 255))
);

ALTER TABLE ONLY brm_api.question REPLICA IDENTITY FULL;
    DROP TABLE brm_api.question;
       brm_api         heap    ref_owner_brm_api    false    7            E           0    0    TABLE question    COMMENT     5   COMMENT ON TABLE brm_api.question IS 'Вопрос';
          brm_api          ref_owner_brm_api    false    205            F           0    0    COLUMN question.question_id    COMMENT     _   COMMENT ON COLUMN brm_api.question.question_id IS 'Идентификатор вопроса';
          brm_api          ref_owner_brm_api    false    205            G           0    0    COLUMN question.question    COMMENT     ?   COMMENT ON COLUMN brm_api.question.question IS 'Вопрос';
          brm_api          ref_owner_brm_api    false    205            H           0    0    COLUMN question.hint    COMMENT     A   COMMENT ON COLUMN brm_api.question.hint IS 'Подсказка';
          brm_api          ref_owner_brm_api    false    205            �            1259    19694    question_id_sequence    SEQUENCE     �   CREATE SEQUENCE brm_api.question_id_sequence
    START WITH 100
    INCREMENT BY 1
    MINVALUE 100
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE brm_api.question_id_sequence;
       brm_api          postgres    false    7            �            1259    19678    questionnaire    TABLE       CREATE TABLE brm_api.questionnaire (
    questionnaire_id numeric NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT "length_constraint.questionnaire.name" CHECK ((char_length(name) <= 255))
);

ALTER TABLE ONLY brm_api.questionnaire REPLICA IDENTITY FULL;
 "   DROP TABLE brm_api.questionnaire;
       brm_api         heap    ref_owner_brm_api    false    7            I           0    0    TABLE questionnaire    COMMENT     @   COMMENT ON TABLE brm_api.questionnaire IS 'Вопросник';
          brm_api          ref_owner_brm_api    false    203            J           0    0 %   COLUMN questionnaire.questionnaire_id    COMMENT     o   COMMENT ON COLUMN brm_api.questionnaire.questionnaire_id IS 'Идентификатор вопросника';
          brm_api          ref_owner_brm_api    false    203            K           0    0    COLUMN questionnaire.name    COMMENT     Y   COMMENT ON COLUMN brm_api.questionnaire.name IS 'Название вопросника';
          brm_api          ref_owner_brm_api    false    203            L           0    0     COLUMN questionnaire.description    COMMENT     `   COMMENT ON COLUMN brm_api.questionnaire.description IS 'Описание вопросника';
          brm_api          ref_owner_brm_api    false    203            �            1259    19685    questionnaire_id_sequence    SEQUENCE     �   CREATE SEQUENCE brm_api.questionnaire_id_sequence
    START WITH 100
    INCREMENT BY 1
    MINVALUE 100
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE brm_api.questionnaire_id_sequence;
       brm_api          postgres    false    7            �            1259    19696    questionnaire_question    TABLE     �   CREATE TABLE brm_api.questionnaire_question (
    questionnaire_id numeric NOT NULL,
    question_id numeric NOT NULL
);

ALTER TABLE ONLY brm_api.questionnaire_question REPLICA IDENTITY FULL;
 +   DROP TABLE brm_api.questionnaire_question;
       brm_api         heap    ref_owner_brm_api    false    7            M           0    0    TABLE questionnaire_question    COMMENT     �   COMMENT ON TABLE brm_api.questionnaire_question IS 'Реализует связь многие ко многим между Вопросник и Вопрос';
          brm_api          ref_owner_brm_api    false    207            N           0    0 .   COLUMN questionnaire_question.questionnaire_id    COMMENT     x   COMMENT ON COLUMN brm_api.questionnaire_question.questionnaire_id IS 'Идентификатор вопросника';
          brm_api          ref_owner_brm_api    false    207            O           0    0 )   COLUMN questionnaire_question.question_id    COMMENT     m   COMMENT ON COLUMN brm_api.questionnaire_question.question_id IS 'Идентификатор вопроса';
          brm_api          ref_owner_brm_api    false    207            1          0    19726    length_constraint 
   TABLE DATA           n   COPY brm_api.length_constraint (constraint_id, table_name, field_name, field_length, description) FROM stdin;
    brm_api          postgres    false    209   [       0          0    19713    possible_answer 
   TABLE DATA           m   COPY brm_api.possible_answer (possible_answer_id, question_id, answer, is_truthful, explanation) FROM stdin;
    brm_api          ref_owner_brm_api    false    208   �[       -          0    19687    question 
   TABLE DATA           @   COPY brm_api.question (question_id, question, hint) FROM stdin;
    brm_api          ref_owner_brm_api    false    205   �[       +          0    19678    questionnaire 
   TABLE DATA           M   COPY brm_api.questionnaire (questionnaire_id, name, description) FROM stdin;
    brm_api          ref_owner_brm_api    false    203   �[       /          0    19696    questionnaire_question 
   TABLE DATA           P   COPY brm_api.questionnaire_question (questionnaire_id, question_id) FROM stdin;
    brm_api          ref_owner_brm_api    false    207   �[       P           0    0    question_id_sequence    SEQUENCE SET     F   SELECT pg_catalog.setval('brm_api.question_id_sequence', 100, false);
          brm_api          postgres    false    206            Q           0    0    questionnaire_id_sequence    SEQUENCE SET     K   SELECT pg_catalog.setval('brm_api.questionnaire_id_sequence', 100, false);
          brm_api          postgres    false    204            �
           1259    19732    length_constraint_pk    INDEX     c   CREATE UNIQUE INDEX length_constraint_pk ON brm_api.length_constraint USING btree (constraint_id);
 )   DROP INDEX brm_api.length_constraint_pk;
       brm_api    brm_index_tbs       postgres    false    209            �
           1259    19725    possible_answer_pk    INDEX     q   CREATE UNIQUE INDEX possible_answer_pk ON brm_api.possible_answer USING btree (possible_answer_id, question_id);
 '   DROP INDEX brm_api.possible_answer_pk;
       brm_api    brm_index_tbs       ref_owner_brm_api    false    208    208            �
           1259    19693    question_pk    INDEX     O   CREATE UNIQUE INDEX question_pk ON brm_api.question USING btree (question_id);
     DROP INDEX brm_api.question_pk;
       brm_api    brm_index_tbs       ref_owner_brm_api    false    205            �
           1259    19684    questionnaire_pk    INDEX     ^   CREATE UNIQUE INDEX questionnaire_pk ON brm_api.questionnaire USING btree (questionnaire_id);
 %   DROP INDEX brm_api.questionnaire_pk;
       brm_api    brm_index_tbs       ref_owner_brm_api    false    203            �
           1259    19712    questionnaire_question_pk    INDEX     }   CREATE UNIQUE INDEX questionnaire_question_pk ON brm_api.questionnaire_question USING btree (questionnaire_id, question_id);
 .   DROP INDEX brm_api.questionnaire_question_pk;
       brm_api    brm_index_tbs       ref_owner_brm_api    false    207    207            �
           2606    19720 0   possible_answer possible_answer_question_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY brm_api.possible_answer
    ADD CONSTRAINT possible_answer_question_id_fkey FOREIGN KEY (question_id) REFERENCES brm_api.question(question_id) ON DELETE CASCADE;
 [   ALTER TABLE ONLY brm_api.possible_answer DROP CONSTRAINT possible_answer_question_id_fkey;
       brm_api          ref_owner_brm_api    false    208    2726    205            �
           2606    19707 >   questionnaire_question questionnaire_question_question_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY brm_api.questionnaire_question
    ADD CONSTRAINT questionnaire_question_question_id_fkey FOREIGN KEY (question_id) REFERENCES brm_api.question(question_id) ON DELETE CASCADE;
 i   ALTER TABLE ONLY brm_api.questionnaire_question DROP CONSTRAINT questionnaire_question_question_id_fkey;
       brm_api          ref_owner_brm_api    false    2726    205    207            �
           2606    19702 C   questionnaire_question questionnaire_question_questionnaire_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY brm_api.questionnaire_question
    ADD CONSTRAINT questionnaire_question_questionnaire_id_fkey FOREIGN KEY (questionnaire_id) REFERENCES brm_api.questionnaire(questionnaire_id) ON DELETE CASCADE;
 n   ALTER TABLE ONLY brm_api.questionnaire_question DROP CONSTRAINT questionnaire_question_questionnaire_id_fkey;
       brm_api          ref_owner_brm_api    false    207    203    2725            1   c   x�3�,,M-.����K�,J��K�M�425�0���
6]�wa�ņ�.6^�{aǅ]6p�5qfd�@��*�TTpa;�T��E��f�=... �;�      0      x������ � �      -      x������ � �      +      x������ � �      /      x������ � �     