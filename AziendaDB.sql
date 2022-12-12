create schema azienda authorization postgres;

create domain role_type as varchar(9) constraint role_name check role_type like "junior" or 
role_type like "middle" or 
role_type like "senior" or 
role_type like "executive" or 
role_type like "temporary";

create table employee{
    ssn ssn_type,
    first_name varchar(30),
    last_name varchar(30),
    phone_num varchar(10),
    email varchar(50),
    address varchar(50),
    employment_date date,
    salary float,
    role role_type,
    laboratory_name varchar(30),
    constraint employee_pk primary key(ssn)
};

create table career_development{
old_role role_type,
new_role role_type,
role_change_date date,
salary_change float,
ssn ssn_type,
constraint cd_emp_fk foreign key(ssn) references employee(ssn)
on update cascade on delete cascade 
};

create table laboratory{
    name varchar(30),
    topic varchar(50),
    sresp ssn_type,
    constraint lab_pk primary key(name),
    constraint lsresp_fk foreign key(sresp) references employee(ssn) on update cascade on delete cascade
};

create table project{
    cup char(15),
    name varchar(30),
    budget float,
    remaining_funds float,
    start_date date,
    end_date date,
    sresp ssn_type,
    sref ssn_type,
    constraint project_pk primary key(cup),
    constraint psresp_fk foreign key(sresp) references employee(ssn) on update cascade on delete cascade,
    constraint psref_fk foreign key(sref) references employee(ssn) on update cascade on delete cascade
};

create table equipment{
    id_equipment serial,
    name varchar(30),
    description varchar(200),
    price float,
    purchase_date date,
    dealer varchar(30),
    laboratory_name varchar(30),
    project_cup char(15),
    constraint equipment_pk primary key(id_equipment),
    constraint lab_equipment_fk foreign key(laboratory_name) references laboratory(name) on update cascade on set null,
    constraint project_equipment_fk foreign key(project_cup) references project(cup) on update cascade on delete set null
};

create table temporary_contract(
    ssn ssn_type,
    cup char(15),
    constraint temp_ssn_fk foreign key(ssn) references employee(ssn) on update cascade on delete cascade,
    constraint temp_cup_fk foreign key(cup) references project(project_cup) on update cascade on delete cascade
);

alter table employee 
add constraint emp_lab_fk foreign key(laboratory_name) references laboratory(name);


