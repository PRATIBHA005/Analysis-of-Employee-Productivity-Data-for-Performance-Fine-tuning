select * from productivity;


select *  from  employees;

---Key Tasks and Methodologies:
---1.string manipulation or string transformation

update employees
set first_name = UPPER(LEFT(first_name,1))+lower(RIGHT(first_name,len(first_name)-1)),
	last_name  = UPPER(LEFT(last_name,1))+lower(RIGHT(last_name,len(last_name)-1));

update employees
set manager_id = 'Kiran'
	where manager_id = 'kppalive';


---2.Renaming Column name for table employees
EXEC sp_rename 'employees.manager_id',  'manager', 'COLUMN';


select *  from  employees


---3.Renaming Column name for table productivity

EXEC sp_rename 'productivity.Time_Utilisation',  'time_utilisation', 'COLUMN';
EXEC sp_rename 'productivity.Case_Count',  'case_count', 'COLUMN';
EXEC sp_rename 'productivity.Productivity_per_hour',  'productivity_per_hour', 'COLUMN';


--4.Rounding columns to 2 decimals

update productivity set time_utilisation = round(time_utilisation,2);

update productivity set productivity_per_hour = round(productivity_per_hour,2);

--5.Changing date time to date

ALTER TABLE productivity ALTER COLUMN date DATE;

---6.Checking the columns

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'productivity';

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'employees';






---Key Questions for Employee Productivity Analysis:

---1.creating a new column team_average for each usecase of that day

alter table productivity add team_average float;

 
update p
set p.team_average = ta.team_average 
from productivity p 

join 
(	select date, usecase, round(avg(productivity_per_hour),2) team_average
	from productivity
	group by date, usecase) as ta

on p.usecase = ta.usecase  and p.date = ta.date
;

---2. Find the top performer for the month of May for each use case?

with top_performer as  (
	select usecase, emp_id
			,round(sum(case_count)/sum(time_utilisation),2) pro_per_hour
			,ROW_NUMBER() over(partition by usecase order by sum(case_count)/sum(time_utilisation) desc) rn
	from productivity 
	group by usecase, emp_id)

select t.usecase, t.emp_id, e.first_name, e.last_name, t.pro_per_hour 
from top_performer t
join employees e
on t.emp_id = e.emp_id
where rn =1


---3. Which manager team performing better in Postcursor_Audits_L1?

select p.usecase,  e.manager, round(sum(p.case_count)/sum(p.time_utilisation),2) pro_per_hour
from productivity p
join employees e
on p.emp_id = e.emp_id
where p.usecase = 'Postcursor_Audits_L1'
group by p.usecase, e.manager
order by 3 desc


---4. Find the top 2 performer of each manager?

select * from 

(select  e.manager, p.emp_id, e.first_name, e.last_name, round(sum(p.case_count)/sum(p.time_utilisation),2) pro_per_hour
,ROW_NUMBER() over(partition by e.manager order by sum(p.case_count)/sum(p.time_utilisation) desc) rn
from productivity p
join employees e
on p.emp_id = e.emp_id
group by e.manager, p.emp_id, e.first_name, e.last_name) a

where rn <=2


---5. Find the employees who are doing below team average?

select p.emp_id, e.first_name, e.last_name, e.manager, p.date, p.Productivity_per_hour, p.team_average
from productivity p
join employees e on p.emp_id = e.emp_id
where p.Productivity_per_hour<p.team_average
order by date, p.team_average, p.Productivity_per_hour desc;

---6. How does employee productivity vary from week to week?

select  usecase
,	round(sum(case when DATEPART(WEEK,date) = 18 then case_count end)/sum(case when DATEPART(WEEK,date) = 18 then Time_Utilisation end),2) week_18
,	round(sum(case when DATEPART(WEEK,date) = 19 then case_count end)/sum(case when DATEPART(WEEK,date) = 19 then Time_Utilisation end),2) week_19
,	round(sum(case when DATEPART(WEEK,date) = 20 then case_count end)/sum(case when DATEPART(WEEK,date) = 20 then Time_Utilisation end),2) week_20
,	round(sum(case when DATEPART(WEEK,date) = 21 then case_count end)/sum(case when DATEPART(WEEK,date) = 21 then Time_Utilisation end),2) week_21
,	round(sum(case when DATEPART(WEEK,date) = 22 then case_count end)/sum(case when DATEPART(WEEK,date) = 22 then Time_Utilisation end),2) week_22
from productivity
group by usecase;


