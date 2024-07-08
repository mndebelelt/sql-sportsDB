#create database companyHR;
#USE companyHR;

###########################################################
-- Chapter 3: Defining Tables 

create table co_employees (
id int primary key auto_increment,
em_name varchar(255) not null,
gender char(1) not null,
contact_number varchar(255),
age int not null,
date_created timestamp default now() not null
);


CREATE TABLE mentorships (
mentor_id INT NOT NULL,
mentee_id INT NOT NULL,
status VARCHAR(255) NOT NULL,
project VARCHAR(255) NOT NULL,

PRIMARY KEY (mentor_id, mentee_id, project),
CONSTRAINT fk1 FOREIGN KEY(mentor_id) REFERENCES
co_employees(id) ON DELETE CASCADE ON UPDATE RESTRICT,
CONSTRAINT fk2 FOREIGN KEY(mentee_id) REFERENCES
co_employees(id) ON DELETE CASCADE ON UPDATE RESTRICT,
CONSTRAINT mm_constraint UNIQUE(mentor_id, mentee_id)
);

-- rename co_employees to employees
rename table co_employees to employees;

-- remove age.. add salary and years_in_company from table
alter table employees
	drop column age,
    add column salary float not null after contact_number,
    add column years_in_company int not null after salary;

ALTER TABLE mentorships
DROP FOREIGN KEY fk2;

ALTER TABLE mentorships
ADD CONSTRAINT fk2 FOREIGN KEY(mentee_id) REFERENCES
employees(id) ON DELETE CASCADE ON UPDATE CASCADE,
DROP INDEX mm_constraint;

#############################################################
-- Chapter 4: Inserting, Updating and Deleting Data

INSERT INTO employees (em_name, gender, contact_number, salary,
years_in_company) VALUES
('James Lee', 'M', '516-514-6568', 3500, 11),
('Peter Pasternak', 'M', '845-644-7919', 6010, 10),
('Clara Couto', 'F', '845-641-5236', 3900, 8),
('Walker Welch', 'M', NULL, 2500, 4),
('Li Xiao Ting', 'F', '646-218-7733', 5600, 4),
('Joyce Jones', 'F', '523-172-2191', 8000, 3),
('Jason Cerrone', 'M', '725-441-7172', 7980, 2),
('Prudence Phelps', 'F', '546-312-5112', 11000, 2),
('Larry Zucker', 'M', '817-267-9799', 3500, 1),
('Serena Parker', 'F', '621-211-7342', 12000, 1);


INSERT INTO mentorships VALUES
(1, 2, 'Ongoing', 'SQF Limited'),
(1, 3, 'Past', 'Wayne Fibre'),
(2, 3, 'Ongoing', 'SQF Limited'),
(3, 4, 'Ongoing', 'SQF Limited'),
(6, 5, 'Past', 'Flynn Tech');


update employees 
set contact_number = '516-514-1729'
where id = 1;

delete from employees
where id = 5;


UPDATE employees
SET id = 11
WHERE id = 4;

SELECT * FROM employees;
SELECT * FROM mentorships;

###################################################################################
-- Chapter 5: Selecting Data Part 1

-- select em_name and gender, limit to max 3 outputs
select em_name as 'Employee Name', gender as 'Gender' 
from employees limit 3;

-- check the distinct values for gender
select distinct(gender) from employees;

-- select employees whose names end with 'er'
SELECT * FROM employees WHERE em_name LIKE '%er';

-- select all female employees who have worked more than 5 years inn the company or have salaries above 5000
select * from employees
where (years_in_company > 5 OR salary > 5000) 
AND gender = 'F';

-- select names of all employees that are mentors of the 'SQF Limited' project
select em_name from employees where id in
(select mentor_id from mentorships where project = 'SQF Limited');

-- sort the rows of the employees using gender, followed by the employee's name
select * from employees order by gender, em_name;

###############################################################################
-- Chapter 7: Selecting Data Part 2


-- count the number of genders we have in the employees table
select count(gender) from employees;

-- count the number of distinct genders we have in the employees table
select count(distinct gender) from employees;

-- calculate the average salary rounded to 2 
select round(avg(salary),2) from employees;

-- find maximum of salary of males vs females 
select gender, max(salary) from employees
group by gender;

-- find max of males vs females but only show if max>10000
SELECT gender, MAX(salary) FROM employees GROUP BY gender HAVING
MAX(salary) > 10000;


###############################################################################
-- Chapter 7: Selecting Data Part 3

select id, mentor_id, em_name as 'Mentor', project as 'Project Name'
from 
mentorships
join 
employees
on 
employees.id = mentorships.mentor_id;

#################################################################################
-- Chapter 8: Views 

/*What is a view?
Simply stated, an SQL view is a virtual table.
In contrast to actual tables, views do not contain data. Instead, they contain
SELECT statements. The data to display is retrieved using those SELECT
statements.
One advantage of using views is that it allows programmers to simplify their
code. They can write relatively complex SELECT statements to join multiple
tables into a single virtual table. Once that is done, they can access that
virtual table like a normal table and perform simple searches on it.
*/

CREATE VIEW myView AS
SELECT employees.id, mentorships.mentor_id, employees.em_name AS
'Mentor', mentorships.project AS 'Project Name'
FROM
mentorships
JOIN
employees
ON
employees.id = mentorships.mentor_id;

SELECT * FROM myView;

###############################################################################
-- Chapter 9: Triggers 
create table ex_employees (
em_id int primary key,
em_name varchar(255) not null,
gender char(1) not null,
date_left timestamp default now() 
);

DELIMITER $$
CREATE TRIGGER update_ex_employees BEFORE DELETE ON employees FOR
EACH ROW
BEGIN
INSERT INTO ex_employees (em_id, em_name, gender) VALUES
(OLD.id, OLD.em_name, OLD.gender);
END $$
DELIMITER ;

DELETE FROM employees WHERE id = 10;

SELECT * FROM employees;
SELECT * FROM ex_employees;

DROP TRIGGER IF EXISTS update_ex_employees;

#######################################################################################
-- Chapter 10: Variables and Stored Routines 

SET @em_id = 1;

select * from mentorships where mentor_id = @em_id;
select * from mentorships where mentee_id = @em_id;
SELECT * FROM employees WHERE id = @em_id;

SET @result = SQRT(9);
SELECT @result;

-- Stored procedures 
DELIMITER $$
CREATE PROCEDURE select_info()
BEGIN
SELECT * FROM employees;
SELECT * FROM mentorships;
END $$
DELIMITER ;

CALL select_info();

-- Stored procedure to select records of a particular employee
DELIMITER $$
CREATE PROCEDURE employee_info(IN p_em_id INT)
BEGIN
SELECT * FROM mentorships WHERE mentor_id = p_em_id;
SELECT * FROM mentorships WHERE mentee_id = p_em_id;
SELECT * FROM employees WHERE id = p_em_id;
END $$
DELIMITER ;

call employee_info(1)
