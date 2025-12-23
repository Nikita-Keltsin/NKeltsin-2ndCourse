DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS groups CASCADE;

-- 2. Создаем таблицы (Просто и понятно)
CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'starosta', 
    group_id INT REFERENCES groups(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    student_id_number VARCHAR(50) UNIQUE NOT NULL,
    group_id INT NOT NULL REFERENCES groups(id) ON DELETE CASCADE
);

CREATE TABLE schedule (
    id SERIAL PRIMARY KEY,
    group_id INT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    subject_name VARCHAR(150) NOT NULL,
    day_of_week INT NOT NULL, -- 1=Пн, 2=Вт...
    start_time VARCHAR(5) NOT NULL, -- Просто строка "09:00", чтобы не мучиться с типами Time
    end_time VARCHAR(5) NOT NULL,
    week_type VARCHAR(20) NOT NULL, -- "numerator" / "denominator"
    teacher_name VARCHAR(100),
    classroom VARCHAR(50)
);

-- Таблица посещаемости (ШАХМАТКА)
-- Вместо даты храним номер недели (1-17), так проще строить таблицу
CREATE TABLE attendance (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    schedule_id INT NOT NULL REFERENCES schedule(id) ON DELETE CASCADE,
    week_number INT NOT NULL, -- Номер недели (1, 2, ... 17)
    status VARCHAR(20) NOT NULL, -- "present"
    UNIQUE(student_id, schedule_id, week_number) -- Чтобы не было дублей галочек
);

-- 3. Заполняем данными
INSERT INTO groups (name) VALUES 
('ИУ5-31Б'), ('ИУ5-32Б'), ('ИУ5-33Б'), ('ИУ5-34Б'), ('ИУ5-35Б');

-- Студенты (Твоя группа 32Б)
INSERT INTO students (full_name, student_id_number, group_id) VALUES
('Иванов Иван', '23У001', (SELECT id FROM groups WHERE name='ИУ5-32Б')),
('Петров Петр', '23У002', (SELECT id FROM groups WHERE name='ИУ5-32Б')),
('Сидоров Сидор', '23У003', (SELECT id FROM groups WHERE name='ИУ5-32Б'));

-- Расписание (Просто строки, без заморочек с типами)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-32Б'), 'Матан (Лек)', 1, '09:00', '10:35', 'numerator', 'Проф. Х', '305'),
((SELECT id FROM groups WHERE name='ИУ5-32Б'), 'Прога (Лаб)', 1, '10:55', '12:30', 'numerator', 'Доц. Y', 'CompClass');

-- Скрипт для заполнения таблицы студентов
-- Удаляем старых студентов, чтобы не было дублей
DELETE FROM students;

-- Студенты группы ИУ5-31Б
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Баженов Н В', '23ИУ531Б01', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Баринов Е С', '23ИУ531Б02', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Блинкова К С', '23ИУ531Б03', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Горячева С А', '23ИУ531Б04', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Есакова О А', '23ИУ531Б05', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Кельцин Н М', '23ИУ531Б06', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Клубков М Е', '23ИУ531Б07', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Кострюков А В', '23ИУ531Б08', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Куртинец Р Ю', '23ИУ531Б09', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Лобков А Ю', '23ИУ531Б10', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Луценко А И', '23ИУ531Б11', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Никоноров Д М', '23ИУ531Б12', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Паронько Д И', '23ИУ531Б13', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Попов А С', '23ИУ531Б14', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Рахманов В А', '23ИУ531Б15', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ростинин М И', '23ИУ531Б16', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Рыбин М А', '23ИУ531Б17', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Сербенюк П П', '23ИУ531Б18', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ходина А П', '23ИУ531Б19', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Цориев Н В', '23ИУ531Б20', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Чехович Ю Ф', '23ИУ531Б21', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Чичёв И С', '23ИУ531Б22', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Чоботов Л К', '23ИУ531Б23', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Шанурина Е С', '23ИУ531Б24', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ширков Н И', '23ИУ531Б25', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Щеблецов Л В', '23ИУ531Б26', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Бакич Симона', '23ИУ531Б27', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ван Чжувэнь', '23ИУ531Б28', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Лю Ханьчжо', '23ИУ531Б29', (SELECT id FROM groups WHERE name='ИУ5-31Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Хамет Виам', '23ИУ531Б30', (SELECT id FROM groups WHERE name='ИУ5-31Б'));

-- Студенты группы ИУ5-35Б
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Александров Г С', '23ИУ535Б01', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Баранов Е Ю', '23ИУ535Б02', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Бондаренко М П', '23ИУ535Б03', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Воложенкова В О', '23ИУ535Б04', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Гремина А А', '23ИУ535Б05', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Дейнеко А В', '23ИУ535Б06', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Евдокимов М С', '23ИУ535Б07', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Есипов А М', '23ИУ535Б08', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Иванов Б М', '23ИУ535Б09', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ким А А', '23ИУ535Б10', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Клокова М А', '23ИУ535Б11', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Королев М О', '23ИУ535Б12', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Корольков И А', '23ИУ535Б13', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Костылев М С', '23ИУ535Б14', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Курьянова А С', '23ИУ535Б15', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Никандров В Д', '23ИУ535Б16', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Парахневич А Л', '23ИУ535Б17', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Перфильев С М', '23ИУ535Б18', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Рябов М А', '23ИУ535Б19', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Черников А С', '23ИУ535Б20', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Шаньгин Н А', '23ИУ535Б21', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Эльсон Э К', '23ИУ535Б22', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Сарыглар начын', '23ИУ535Б23', (SELECT id FROM groups WHERE name='ИУ5-35Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Довлетов Сейран', '23ИУ535Б24', (SELECT id FROM groups WHERE name='ИУ5-35Б'));

-- Студенты группы ИУ5-34Б
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Аксенкин Никита Э', '23ИУ534Б01', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Бурматов Степан М', '23ИУ534Б02', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Буш Илья Е', '23ИУ534Б03', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Верзаков Никита В', '23ИУ534Б04', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Газаева Мариам О', '23ИУ534Б05', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Глозман Варвара А', '23ИУ534Б06', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Давыдов Кирилл И', '23ИУ534Б07', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Жеребенков Алексей Ю', '23ИУ534Б08', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Изотов Егор А', '23ИУ534Б09', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Каргин Владимир В', '23ИУ534Б10', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Кострыкина Екатерина Г', '23ИУ534Б11', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Кубанов Сергей П', '23ИУ534Б12', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Мальков Никита А', '23ИУ534Б13', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Невечеря Арсений Д', '23ИУ534Б14', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Потапов Данил С', '23ИУ534Б15', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Прощаев Алексей П', '23ИУ534Б16', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Савинский Андрей Ю', '23ИУ534Б17', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Солижонов Умиджон И', '23ИУ534Б18', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Шевчук Диана В', '23ИУ534Б19', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Шерстеникин Никита С', '23ИУ534Б20', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Ясевичус Артур Г', '23ИУ534Б21', (SELECT id FROM groups WHERE name='ИУ5-34Б'));
INSERT INTO students (full_name, student_id_number, group_id) VALUES ('Яхутль Милена А', '23ИУ534Б22', (SELECT id FROM groups WHERE name='ИУ5-34Б'));

-- Расписание для ИУ5-31Б

-- Понедельник, числитель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Теория вероятностей и мат. статистика (Сем)', 1, '11:50', '13:20', 'numerator', 'Богданова С. Г.', '201х');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Теория вероятностей и мат. статистика (Лек)', 1, '14:05', '15:35', 'numerator', 'Безверхний Н. В.', '637к');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Теория вероятностей и мат. статистика (Лек)', 1, '15:55', '17:25', 'numerator', 'Безверхний Н. В.', '637к, В4К "Конгресс‑холл"');

-- Понедельник, знаменатель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Экология (Сем)', 1, '11:50', '13:20', 'denominator', 'Корсак М. Н.', '109х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Правоведение (Сем)', 1, '11:50', '13:20', 'denominator', 'Хватова М. А.', '213х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Иностранный язык (Сем)', 1, '14:05', '15:35', 'denominator', '—', '110х, 204х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Электротехника (Лек)', 1, '15:55', '17:25', 'denominator', 'Белодедов М. В.', '324х, В1 ХимЛаб');

-- Вторник, знаменатель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Электротехника (Лаб)', 2, '10:10', '11:40', 'denominator', 'Белодедов М. В.', '541к, В4, В4К "Конгресс‑холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Электротехника (Лаб)', 2, '11:50', '13:20', 'denominator', 'Белодедов М. В.', '541к, В4, В4К "Конгресс‑холл"');

-- Среда, числитель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Элективный курс по физической культуре и спорту', 3, '13:55', '15:30', 'numerator', 'Преподаватель не указан', 'каф. ФВ');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Архитектура АСОИУ (Лек)', 3, '15:55', '17:25', 'numerator', 'Щук В. П.', '502ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Модели данных (Лек)', 3, '17:35', '19:05', 'numerator', 'Масленников К. Ю.', '502ю, А1 ГУК');

-- Четверг, числитель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Модели данных (Лаб)', 4, '12:25', '13:55', 'numerator', 'Ковалева Н. А., Силантьева Е. Ю.', '512к, В4, В4К "Конгресс‑холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Модели данных (Лаб)', 4, '14:05', '15:35', 'numerator', 'Ковалева Н. А., Силантьева Е. Ю.', '512к, В4, В4К "Конгресс‑холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Парадигмы и конструкции языков программирования (Лек)', 4, '15:55', '17:25', 'numerator', 'Гапанюк Ю. Е.', '301х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Экология (Лек)', 4, '17:35', '19:05', 'numerator', 'Корсак М. Н.', '301х, В1 ХимЛаб');

-- Пятница, числитель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Электротехника (Лек)', 5, '08:30', '10:00', 'numerator', 'Белодедов М. В.', '427ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Физика (Лек)', 5, '10:10', '11:40', 'numerator', 'Корогодина Е. В.', '—');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Парадигмы и конструкции языков программирования (Лаб)', 5, '12:25', '13:55', 'numerator', 'Нарди А. Н., Заплаткин Д. Г.', '203х, В1 ХимЛаб');

-- Суббота, числитель
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Элективный курс по физической культуре и спорту', 6, '14:05', '15:30', 'numerator', 'Преподаватель не указан', 'каф. ФВ');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-31Б'),
 'Модели данных (Лек)', 6, '15:55', '17:25', 'numerator', 'Масленников К. Ю.', '502ю, А1 ГУК');

-- РАСПИСАНИЕ ДЛЯ ИУ5‑34Б
-- считаем, что в groups уже есть запись 'ИУ5-34Б'

-- ПОНЕДЕЛЬНИК (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Теория вероятностей и мат. статистика (Сем)', 1, '08:30', '10:00', 'numerator', 'Чигирёва О. Ю.', '513х, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Правоведение (Лек)', 1, '10:10', '11:40', 'numerator', 'Богданова С. Г.', '513х, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Теория вероятностей и мат. статистика (Лек)', 1, '12:25', '13:55', 'numerator', 'Безверхний Н. В.', '637к, В4, В4К "Конгресс-холл"');

-- ВТОРНИК (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Модели данных (Лаб)', 2, '10:10', '11:40', 'numerator', 'Силантьева Е. Ю., Ковалева Н. А.', '606к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Модели данных (Лаб)', 2, '11:50', '13:20', 'numerator', 'Силантьева Е. Ю., Ковалева Н. А.', '513к, В4, В4К "Конгресс-холл"');

-- СРЕДА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Элективный курс по физической культуре и спорту', 3, '13:55', '15:30', 'numerator', 'Преподаватель не указан', 'каф. ФВ');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Архитектура АСОИУ (Лек)', 3, '15:55', '17:25', 'numerator', 'Щук В. П.', '502ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Модели данных (Лек)', 3, '17:35', '19:05', 'numerator', 'Масленников К. Ю.', '502ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Иностранный язык (Сем)', 3, '19:15', '20:45', 'numerator', 'Преподаватель не указан', '211х, 204х, В1 ХимЛаб');

-- ЧЕТВЕРГ (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Парадигмы и конструкции языков программирования (Лаб)', 4, '14:05', '15:35', 'numerator', 'Нарди А. Н., Заплаткин Д. Г.', '513к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Парадигмы и конструкции языков программирования (Лек)', 4, '15:55', '17:25', 'numerator', 'Гапанюк Ю. Е.', '301х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Экология (Лек)', 4, '17:35', '19:05', 'numerator', 'Корсак М. Н.', '301х, В1 ХимЛаб');

-- ПЯТНИЦА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Теория вероятностей и мат. статистика (Сем)', 5, '08:30', '10:00', 'numerator', 'Чигирёва О. Ю.', '513х, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Правоведение (Лек)', 5, '10:10', '11:40', 'numerator', 'Богданова С. Г.', '513х, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Теория вероятностей и мат. статистика (Лек)', 5, '12:25', '13:55', 'numerator', 'Безверхний Н. В.', '637к, В4, В4К "Конгресс-холл"');

-- СУББОТА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Физика (Лек)', 6, '10:10', '11:40', 'numerator', 'Корогодина Е. В.', '323, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Физика (Лаб)', 6, '12:25', '13:55', 'numerator', 'Грищенко И. В., Лобойко Д. А.', 'каф. ФН4');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Физика (Лаб)', 6, '14:05', '15:35', 'numerator', 'Грищенко И. В., Лобойко Д. А.', 'каф. ФН4');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Физика (Сем)', 6, '11:50', '13:20', 'denominator', 'Корогодина Е. В.', '384, А1 ГУК'); -- если нужно отделить знаменатель

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-34Б'),
 'Элективный курс по физической культуре и спорту', 6, '16:20', '17:50', 'denominator', 'Преподаватель не указан', 'каф. ФВ');

-- РАСПИСАНИЕ ДЛЯ ИУ5‑35Б
-- считаем, что в groups уже есть запись 'ИУ5-35Б'

-- ПОНЕДЕЛЬНИК (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Теория вероятностей и мат. статистика (Лек)', 1, '11:50', '13:20', 'numerator', 'Безверхний Н. В.', '637к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Экология (Сем)', 1, '11:50', '13:20', 'numerator', 'Федосеева Т. А.', '103х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Теория вероятностей и мат. статистика (Сем)', 1, '14:05', '15:35', 'numerator', 'Павловский Я. Ю.', '109х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Электротехника (Лек)', 1, '15:55', '17:25', 'numerator', 'Белодедов М. В.', '324х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Электротехника (Сем)', 1, '17:35', '19:05', 'numerator', 'Белодедов М. В.', '321х, В1 ХимЛаб');

-- ВТОРНИК (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Модели данных (Лаб)', 2, '15:55', '17:25', 'numerator', 'Ковалева Н. А., Силантьева Е. Ю.', '401к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Модели данных (Лаб)', 2, '17:35', '19:05', 'numerator', 'Ковалева Н. А., Силантьева Е. Ю.', '401к, В4, В4К "Конгресс-холл"');

-- СРЕДА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Элективный курс по физической культуре и спорту', 3, '13:55', '15:30', 'numerator', 'Преподаватель не указан', 'каф. ФВ');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Архитектура АСОИУ (Лек)', 3, '15:55', '17:25', 'numerator', 'Щук В. П.', '502ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Модели данных (Лек)', 3, '17:35', '19:05', 'numerator', 'Масленников К. Ю.', '502ю, А1 ГУК');

-- ЧЕТВЕРГ (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Элективный курс по физической культуре и спорту', 4, '13:55', '15:30', 'numerator', 'Преподаватель не указан', 'каф. ФВ');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Парадигмы и конструкции языков программирования (Лек)', 4, '15:55', '17:25', 'numerator', 'Гапанюк Ю. Е.', '301х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Экология (Лек)', 4, '17:35', '19:05', 'numerator', 'Корсак М. Н.', '301х, В1 ХимЛаб');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Парадигмы и конструкции языков программирования (Лаб)', 4, '19:15', '20:45', 'numerator', 'Нарди А. Н., Заплаткин Д. Г.', '513к, В4, В4К "Конгресс-холл"');

-- ПЯТНИЦА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Правоведение (Лек)', 5, '10:10', '11:40', 'numerator', 'Богданова С. Г.', '513х, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Теория вероятностей и мат. статистика (Лек)', 5, '12:25', '13:55', 'numerator', 'Безверхний Н. В.', '637к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Электротехника (Лаб)', 5, '14:05', '15:35', 'numerator', 'Белодедов М. В.', '541к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Электротехника (Лаб)', 5, '15:55', '17:25', 'numerator', 'Белодедов М. В.', '541к, В4, В4К "Конгресс-холл"');

-- СУББОТА (ЧИСЛИТЕЛЬ)
INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Иностранный язык (Сем)', 6, '08:30', '10:00', 'numerator', 'Преподаватель не указан', '523к, 514к, В4, В4К "Конгресс-холл"');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Физика (Лек)', 6, '10:10', '11:40', 'numerator', 'Корогодина Е. В.', '323, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Правоведение (Сем)', 6, '12:25', '13:55', 'numerator', 'Донсков А. В.', '427ю, А1 ГУК');

INSERT INTO schedule (group_id, subject_name, day_of_week, start_time, end_time, week_type, teacher_name, classroom) VALUES
((SELECT id FROM groups WHERE name='ИУ5-35Б'),
 'Физика (Сем)', 6, '14:05', '15:35', 'numerator', 'Корогодина Е. В.', '384, А1 ГУК');
