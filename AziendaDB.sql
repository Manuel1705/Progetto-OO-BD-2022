create schema azienda;

create domain azienda.role_type as varchar(9) constraint role_domain check (
   value like 'junior' or 
value like 'middle' or 
value like 'senior' or 
value like 'executive' or 
value like 'temporary'
);

create domain azienda.ssn_type as char(15) constraint ssn_domain check(value similar to '\d+');

create table azienda.employee(
    ssn azienda.ssn_type,
    first_name varchar(30) not null,
    last_name varchar(30) not null,
    phone_num varchar(10) not null,
    email varchar(50),
    address varchar(50),
    employment_date date not null,
    salary float not null,
    role azienda.role_type not null,
    laboratory_name varchar(30),
    constraint employee_pk primary key(ssn)
);

create table azienda.career_development(
old_role azienda.role_type not null,
new_role azienda.role_type not null,
role_change_date date not null,
salary_change float not null,
ssn azienda.ssn_type,
constraint cd_emp_fk foreign key(ssn) references azienda.employee(ssn)
on update cascade on delete cascade 
);

create table azienda.laboratory(
    name varchar(30),
    topic varchar(50),
    sresp azienda.ssn_type,
    constraint lab_pk primary key(name),
    constraint lsresp_fk foreign key(sresp) references azienda.employee(ssn) on update cascade on delete cascade
);

create table azienda.project(
    cup char(15),
    name varchar(30) not null,
    budget float not null,
    remaining_funds float not null,
    start_date date not null,
    end_date date not null,
    sresp azienda.ssn_type,
    sref azienda.ssn_type,
    constraint project_pk primary key(cup),
    constraint psresp_fk foreign key(sresp) references azienda.employee(ssn) on update cascade on delete cascade,
    constraint psref_fk foreign key(sref) references azienda.employee(ssn) on update cascade on delete cascade
);

create table azienda.equipment(
    id_equipment serial,
    name varchar(30) not null,
    description varchar(200),
    price float not null,
    purchase_date date not null,
    dealer varchar(30) not null,
    laboratory_name varchar(30),
    project_cup char(15),
    constraint equipment_pk primary key(id_equipment),
    constraint lab_equipment_fk foreign key(laboratory_name) references azienda.laboratory(name) on update cascade on delete set null,
    constraint project_equipment_fk foreign key(project_cup) references azienda.project(cup) on update cascade on delete set null
);

create table azienda.temporary_contract(
    ssn azienda.ssn_type,
    cup char(15),
    constraint temp_ssn_fk foreign key(ssn) references azienda.employee(ssn) on update cascade on delete cascade,
    constraint temp_cup_fk foreign key(cup) references azienda.project(cup) on update cascade on delete cascade
);

alter table azienda.employee 
add constraint emp_lab_fk foreign key(laboratory_name) references azienda.laboratory(name);

insert into azienda.employee values('123456789123451','io','sempre io','3465013137','manuelrignogna@alice.it','casa mia','2012-12-12',1,'junior',null);

create fuction check_employment_date() returns trigger as $check_employment_date_trigger$
begin
if new.role = 'junior' or new.role = 'middle' or new.role = 'senior'
    if current_date-new.employment_date<3*365 and new.role<>'junior' then
        update on azienda.employee
        set role='junior'
        where ssn=new.ssn
     elsif current_date-new.employment_date>=3*365 and current_date-new.employment_date<7*365 and new.role<>"middle" then
        update on azienda.employee
        set role='middle'
        where ssn=new.ssn
    elsif current_date-new.employment_date>=7*365 and new.role<>"senior" then
        update on azienda.employee
        set role='senior'
        where ssn=new.ssn
end if;
end;
$check_employment_date_trigger$ LANGUAGE plpgsql;

create trigger check_employment_date_trigger after insert or update of ruolo on azienda.impiegato
for each row
execute function check_employment_date();

create function check_remaining_funds() returns trigger as $check_remaining_funds_trigger$
begin
update on azienda.project
set remaining_funds=new.budget
where cup=new.cup
end;
$check_remaining_funds_trigger$ LANGUAGE plpgsql;

create trigger check_remaining_funds_trigger after insert on azienda.project
for each row
execute function check_remaining_funds();

create function check_end_date() returns trigger as $check_end_date_trigger$
begin
if new.start_date>=new.end_date
delete from azienda.PROJECT
WHERE cup=new.cup;
end;
$check_end_date_trigger$ LANGUAGE plpgsql;

create trigger check_end_date_trigger after insert on azienda.project
for each row
execute function check_end_date();

create function check_salary_temporary() returns trigger as $check_salary_temporary_trigger$
declare 
sum_salary employee.salary%type;
cup_new_emp project.cup%type;
project_budget project.budget%type;
remaining_months int;
end_date_prj project.end_date%type;
begin

select cup into cup_new_emp
from azienda.temporary_contract
where ssn=new.ssn;

select sum(emp.salary) into sum_salary
from azienda.employee emp join azienda.temporary_contract temp on emp.ssn=tmp
where temp.cup=cup_new_emp and emp.role like 'temporary';

select budget, end_date into project_budget, end_date_prj
from azienda.project 
where cup=cup_new_emp;

remaining_months:= end_date_prj-current_date;

if sum_salary*remaining_months>project_budget/2
delete from employee
where ssn=new.ssn;
end if;
end;
$check_salary_temporary_trigger$ LANGUAGE plpgsql;

create trigger check_salary_temporary_trigge after insert on azienda.employee
for each row
execute function check_salary_temporary();



create function check_price_equipment() returns trigger as $check_price_equipment_trigger$
declare 
sum_price equipment.price%type;
project_budget project.budget%type;
begin
select budget into project_budget
from azienda.project 
where cup=new.cup;

select sum(price) into sum_price
from azienda.equipment
where project_cup=new.cup;

if sum_price>project_budget/2
delete from azienda.equipment
where id_equipment=new.id_equipment;
end if;
end;
$check_price_equipment_trigger$ LANGUAGE plpgsql;

create trigger check_price_equipment_trigger after insert on azienda.equipment
fro each row
execute function check_price_equipment();

create function check_budget() returns trigger as $check_budget_trigger$
declare
sum_salary employee.salary%type;
sum_price equipment.price%type;
remaining_months int;
begin
select sum(price) into sum_price
from azienda.equipment
where project_cup=new.cup;
if new.budget/2<sum_price
update azienda.project
set budget=old.budget
where cup=new.cup;
end if;

select sum(emp.salary) into sum_salary
from azienda.employee emp join azienda.temporary_contract temp on emp.ssn=tmp
where temp.cup=cup_new_emp and emp.role like 'temporary';

remaining_months=new.end_date-current_date;
if sum_salary*remaining_months>new.budget/2
update azienda.project
set budget=old.budget
where cup=new.cup;
end if;
end;
$check_budget_trigger$ LANGUAGE plpgsql; 

create trigger check_budget_trigger after update of budget on azienda.project
for each row
execute function check_budget();



