
create schema azienda;
create domain azienda.role_type as varchar(9) constraint role_domain check (value like 'junior' or 
value like 'middle' or 
value like 'senior' or 
value like 'executive' or 
value like 'temporary');
create domain azienda.ssn_type as varchar(15) constraint ssn_domain check(value similar to '^\d+$');
create table azienda.employee(
    ssn azienda.ssn_type,
    first_name varchar(30),
    last_name varchar(30),
    phone_num varchar(10),
    email varchar(50),
    address varchar(50),
    employment_date date,
    salary float,
    role azienda.role_type,
    laboratory_name varchar(30),
    constraint employee_pk primary key(ssn)
);

create table azienda.career_development(
old_role azienda.role_type,
new_role azienda.role_type,
role_change_date date,
salary_change float,
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
    name varchar(30),
    budget float,
    remaining_funds float,
    start_date date,
    end_date date,
    sresp azienda.ssn_type,
    sref azienda.ssn_type,
    constraint project_pk primary key(cup),
    constraint psresp_fk foreign key(sresp) references azienda.employee(ssn) on update cascade on delete cascade,
    constraint psref_fk foreign key(sref) references azienda.employee(ssn) on update cascade on delete cascade
);

create table azienda.equipment(
    id_equipment serial,
    name varchar(30),
    description varchar(200),
    price float,
    purchase_date date,
    dealer varchar(30),
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


