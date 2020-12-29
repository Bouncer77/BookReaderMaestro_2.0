@set api_schema_name = "brm_api"

-- GET
SELECT * FROM :api_schema_name.ui_get_constraints();
SELECT * FROM :api_schema_name.ui_get_questionnaires();
SELECT * FROM :api_schema_name.ui_get_questions();
SELECT * FROM :api_schema_name.ui_get_questions_order_by_desc();

-- CREATE
-- p_question text, p_hint text
SELECT * FROM :api_schema_name.ui_question_create('Где отмечать НГ?', 'У бабушки - там весело');
SELECT * FROM :api_schema_name.ui_question_create_2('Где отмечать НГ?');

-- DELETE
SELECT * FROM :api_schema_name.ui_question_delete(101);

-- UPDATE
-- p_question_id numeric, p_question text, p_hint text
SELECT * FROM :api_schema_name.ui_question_modify(100, 'Кто учился в МИФИ?', null);