-- https://postgrespro.ru/docs/postgresql/9.6/sql-createtablespace
-- CREATE TABLESPACE регистрирует новое табличное пространство на уровне кластера баз данных.

-- https://postgrespro.ru/docs/postgresql/9.4/sql-altertable
-- REPLICA IDENTITY форма меняет информацию, записываемую в журнал упреждающей записи для идентификации изменяемых или удаляемых строк.
-- В режиме FULL записываются старые значения всех колонок в строке

-- TODO Разобраться 1 - Важно
-- применение правил ограничения длины полей
-- SELECT table_name, field_name, field_length FROM ref_insurance_api.length_constraint;

QUESTIONNAIRE_QUESTION - с нижним поддчеркиванием - означает что таблица нужна для решения связи многие ко многим

POSSIBLE ANSWER - с пробелом - означает что таблица не участвует в связи многие ко многим

## Венгерская нотация

> Подход к устранению неоднозначностей
>
> Добавляется префикс:
> p_ (parametr) - для параметров 
> l_ (local) или v_ (variable) - для переменных 
> с_ (constant) - для констант