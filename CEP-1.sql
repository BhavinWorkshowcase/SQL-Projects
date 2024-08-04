-- Creating a database.
create database if not exists Employee;
use Employee;
select database();


-- Importing the necessary dataset.
show tables;
desc data_science_team;
select * from data_science_team;
desc emp_record_table;
select * from emp_record_table;
desc proj_table;
select * from proj_table;


-- changing data type, correcting some values and assigning primary and foreign keys.
alter table emp_record_table 
 modify emp_id	char(4) primary key,
    modify proj_id	char(4);
 
 alter table data_science_team 
 modify emp_id char(4) primary key;

alter table proj_table 
 modify column PROJECT_ID char(4) primary key;

 alter table emp_record_table
 modify column proj_id char(4);

update emp_record_table set
	proj_id = null
where emp_id = 'E260';

alter table emp_record_table 
	add foreign key fk_proj_id (proj_id) references proj_table(project_id);

alter table data_science_team
	add foreign key fk_emp_id(emp_id) references emp_record_table(emp_id);
    
    
-- Q2 ER diagram.
-- saved as PDF.

-- Q3 
select emp_id , first_name, last_name, gender , dept 
from emp_record_table
order by dept;

-- Q4
select emp_id , first_name, last_name , gender, dept , emp_rating 
from emp_record_table
where emp_rating <2 ;

select emp_id , first_name, last_name , gender, dept , emp_rating 
from emp_record_table
where emp_rating >4 ;

select emp_id , first_name, last_name , gender, dept , emp_rating 
from emp_record_table
where emp_rating between 2 and 4 ;


-- Q5
select concat(first_name,' ',last_name) as NAME
from emp_record_table
where dept = 'FINANCE';


-- Q6
SELECT 
    e.EMP_ID, e.FIRST_NAME, e.LAST_NAME,  e.ROLE, 
    COUNT(r.EMP_ID) AS number_of_reporters
FROM 
    emp_record_table e
LEFT JOIN 
    emp_record_table r ON e.EMP_ID = r.MANAGER_ID
GROUP BY 
    e.EMP_ID, e.FIRST_NAME, e.LAST_NAME, e.ROLE
HAVING 
    number_of_reporters > 0;


-- Q7
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, 
    ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY, EMP_RATING, MANAGER_ID, PROJ_ID
FROM emp_record_table
WHERE DEPT = 'Healthcare'
UNION 
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, 
    ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY, EMP_RATING, MANAGER_ID, PROJ_ID
FROM emp_record_table
WHERE DEPT = 'Finance';


-- Q8
select emp_id , first_name, last_name , role , dept, emp_rating ,
max(emp_rating) over (partition by dept) as dept_max_rating
from emp_record_table;

-- Q9
SELECT 
    ROLE,
    MIN(SALARY) AS min_salary,
    MAX(SALARY) AS max_salary
FROM 
    emp_record_table
GROUP BY 
    ROLE;
    

-- Q10
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    ROLE,
    DEPT,
    EXP,
    RANK() OVER (ORDER BY EXP DESC) AS experience_rank,
    dense_rank() over (order by exp) as exp_cont_rank
FROM 
    emp_record_table;
    
    
-- Q11
CREATE VIEW high_salary_employees AS
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, COUNTRY, SALARY
FROM 
    emp_record_table
WHERE 
    SALARY > 6000;

-- Using the view 
SELECT * FROM high_salary_employees;


-- Q12
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, EXP
FROM emp_record_table
WHERE EMP_ID IN (
        SELECT  EMP_ID
        FROM  emp_record_table
        WHERE EXP > 10);


-- Q13
DELIMITER //
CREATE PROCEDURE GetExperiencedEmployees()
BEGIN
    SELECT 
        EMP_ID, FIRST_NAME, LAST_NAME, GENDER, 
    ROLE, DEPT, EXP, COUNTRY, CONTINENT, SALARY
    FROM emp_record_table
    WHERE EXP > 3;
END //
DELIMITER ;

-- USING THE STORED PROCEDURE
CALL GetExperiencedEmployees();


-- Q14
DELIMITER //

CREATE FUNCTION GetJobProfile(exp tinyint) RETURNS VARCHAR(30)
BEGIN
    DECLARE job_profile VARCHAR(30);

    IF exp <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp > 2 AND exp <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp > 5 AND exp <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF exp > 10 AND exp <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSE SET job_profile = 'MANAGER';
    END IF;

    RETURN job_profile;
END //

DELIMITER ;

-- CALLING THE FUNCTION 
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EXP,
    GetJobProfile(EXP) AS Standard_Profile,
    CASE 
    WHEN GetJobProfile(EXP) = ROLE THEN 'MATCHING' 
    ELSE 'NOT MATCHING'
    END AS MATCHING
FROM 
    data_science_team;

SET GLOBAL log_bin_trust_function_creators = 1;


-- Q15
-- Checking execution plan before creating the index
SELECT * FROM emp_record_table WHERE first_name = 'Eric';

alter table emp_record_table
modify column First_name varchar(30);

-- Created the index
CREATE INDEX idx_emp_name ON emp_record_table(first_name);

-- Checking execution plan after creating the index
SELECT * FROM emp_record_table WHERE first_name = 'Eric';


-- Q16
SELECT emp_id, first_name, last_name, salary, emp_rating, (0.05 * salary *emp_rating) AS bonus
FROM emp_record_table ;


-- Q17
SELECT 
    CONTINENT,
    COUNTRY,
    AVG(SALARY) AS average_salary
FROM 
    emp_record_table
GROUP BY 
    CONTINENT, COUNTRY;








