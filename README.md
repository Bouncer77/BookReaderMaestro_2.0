# BookReaderMaestro_2.0

Full-stack приложение для проверки знаний пользователей после прочтения глав технической литературы


## MVP

> MVP - Минимально жизнеспособный продукт (Minimum Viable Product)

Ключевая задача приложения оденивать знания пользователей после прочтения технической книги или главы из книги.  

Поэтому MVP представляется обладает минимальным набором сущностей: 
1. Опросный лист (questionnaire)
2. Вопрос (question)
3. Вариант ответа (possible_answer)

![ERD_MVP](./DB/Diagram/ERD_MVP.svg)

## Technology stack

### Frontend

React JS

### Backend

Java 8

Spring Boot 2.0

	+ JPA
	+ MVC
	+ Security

Maven

Lombok

### Relational Database Management System

Postgres SQL 12

## Tools

Инструмент                                             | Описание
-------------------------------------------------------|--------------------------------------------------------------------------------
[IntelliJ IDEA](https://www.jetbrains.com/ru-ru/idea/) | Интегрированная среда разработки программного обеспечения для Java
[Git](https://git-scm.com/)                            | Распределённая система управления версиями
[DBeaver](https://dbeaver.com/)                        | Платформенно-независимый клиент баз данных, написан на Java, работает с любой системой управления базами данных, поддерживающей JDBC 2.0, ODBC, REST.
[Visual Paradigm](https://www.visual-paradigm.com/)    | Инструмент UML CASE, поддерживающий UML 2, SysML и нотацию моделирования бизнес-процессов из группы управления объектами.
[Postman](https://www.postman.com/)                    |  Postman предназначен для проверки запросов с клиента на сервер и получения ответа от бэкенда.
[Postman Rest](https://documenter.getpostman.com/view/5922408/RznJmGfn#ac795868-5d2e-4975-a022-3b06176850a6) | Поднимает web сервер для получение информации из бд


## Teaching material

[Как спроектировать базу данных в Visual Paradigm](https://www.visual-paradigm.com/tutorials/how-to-model-relational-database-with-erd.jsp)

[Книги по PostgresSQL](https://postgrespro.ru/education/books)

[Курсы по PostgresSQL](https://postgrespro.ru/education/courses)

[YouTube канал Postgres Pro](https://www.youtube.com/c/PostgresProfessional/playlists?view=50&sort=dd&shelf_id=3)

[Видеокурс по основам SQL](https://www.youtube.com/watch?v=8a2CSE6cg5k&list=PLaFqU3KCWw6J1NEI8hjYlvGnD4Y7Sxx4r&ab_channel=PostgresProfessional)

[Курс DEV-1 - pl/pgSQL](https://postgrespro.ru/education/courses/DEV1)

[DEV-1 Видеокурс](https://www.youtube.com/watch?v=8uHePp-qFNE&list=PLaFqU3KCWw6LNR1IZ814whJe89J1tRQ3t&ab_channel=PostgresProfessional)
