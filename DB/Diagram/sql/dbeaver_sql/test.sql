@set api_schema_name = "brm_api"

-- GET
SELECT * FROM :api_schema_name.ui_get_questionnaires();
SELECT * FROM :api_schema_name.ui_get_constraints();
SELECT * FROM :api_schema_name.ui_get_questions();

SELECT * FROM :api_schema_name.ui_get_questionnaire(102);


TRUNCATE :api_schema_name.question CASCADE;
TRUNCATE :api_schema_name.questionnaire CASCADE;

SELECT * FROM :api_schema_name.question;
SELECT * FROM :api_schema_name.questionnaire;
SELECT * FROM :api_schema_name.questionnaire_question;
SELECT * FROM :api_schema_name.possible_answer;
SELECT * FROM :api_schema_name.length_constraint;

-- Заполняем 'Java Core'
-- (p_name text, p_description text);
SELECT * FROM :api_schema_name.ui_create_questionnaire('Java Core', 'Контрольные вопросы часть 1. Базовый синтаксис.');

-- Добавлять вопрос сразу в вопросник + обязательно правильный ответ

-- (p_question text, p_hint text)
SELECT * FROM :api_schema_name.ui_question_create('1. Что такое виртуальная машина?', null);
SELECT * FROM :api_schema_name.ui_question_create('2. К какому типа языка программирование относиться Java?', null);
SELECT * FROM :api_schema_name.ui_question_create('3. Из каких компонентов состоит Java?', null);
SELECT * FROM :api_schema_name.ui_question_create('4. Для чего используется JDK?', null);
SELECT * FROM :api_schema_name.ui_question_create('5. Для чего используется JRE?', null);
SELECT * FROM :api_schema_name.ui_question_create('6. Для чего используется VM?', null);
SELECT * FROM :api_schema_name.ui_question_create('7. Расскажите про базовые типы.', null);
SELECT * FROM :api_schema_name.ui_question_create('8. Что такое примитивные типы?', null);
SELECT * FROM :api_schema_name.ui_question_create('9. Что такое классы обертки?', null);
SELECT * FROM :api_schema_name.ui_question_create('10. Что такое автобоксинг и анбоксинг?', null);

-- добавлять один или более вариантов ответа за раз

-- (p_question_id numeric, p_questionnaire_id numeric)
SELECT * FROM :api_schema_name.ui_add_question_to_questionnaire();



/* Create
1. Create (создание) - INSERT
2. Read (чтение) - SELECT
3. Update (модификация) - UPDATE
4. Delete (удаление) - DELETE
*/

-- CREATE

-- 1.2
-- p_name text, p_description text
SELECT * FROM :api_schema_name.ui_create_questionnaire('Контрольные вопросы часть 1. Базовый синтаксис.',
'Взято с GitHub: https://github.com/lexa-vic/Java/blob/master/JavaLessons/%D0%92%D0%BE%D0%BF%D1%80%D0%BE%D1%81%D1%8B.txt');

-- 2.2
-- p_question text, p_hint text
SELECT * FROM :api_schema_name.ui_question_create('Что такое виртуальная машина?', 'Переводит наш скомпилированный байт-код в машинные операции');

-- 1.3
-- p_questionnaire_id numeric, p_name text, p_description text
SELECT * FROM :api_schema_name.ui_questionnaire_modify()


-- DELETE
SELECT * FROM :api_schema_name.ui_question_delete(114);

-- UPDATE
-- p_question_id numeric, p_question text, p_hint text
SELECT * FROM :api_schema_name.ui_question_modify(100, 'Кто учился в МИФИ?', null);