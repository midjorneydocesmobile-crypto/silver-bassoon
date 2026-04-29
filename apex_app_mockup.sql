-- This script is intentionally SQL-Workshop safe.
-- Run it in SQL Workshop > SQL Scripts (NOT App Builder > Import).
-- It prepares reusable views and role tables for fast APEX app generation via Create Application wizard.

set define off;

--------------------------------------------------------------------------------
-- 1) Access control (for manager / expert / sector head)
--------------------------------------------------------------------------------
create table app_user_roles (
  username      varchar2(255) not null,
  role_code     varchar2(30)  not null,
  constraint pk_app_user_roles primary key (username, role_code),
  constraint ck_app_user_roles_role check (role_code in ('MANAGER','EXPERT','SECTOR_HEAD'))
);

create or replace function has_role(p_role in varchar2) return boolean is
  l_cnt number;
begin
  select count(*)
    into l_cnt
    from app_user_roles
   where upper(username) = upper(v('APP_USER'))
     and role_code = upper(p_role);
  return l_cnt > 0;
end;
/

--------------------------------------------------------------------------------
-- 2) Reporting views (cover all DB tables)
--------------------------------------------------------------------------------
create or replace view v_clients as
select id, fio_client, phone, email, passport_data, registration_date
  from clients;

create or replace view v_objects as
select o.id,
       o.object_address,
       o.object_type,
       o.square,
       o.floors,
       o.construction_year,
       o.id_client,
       c.fio_client
  from construction_objects o
  join clients c on c.id = o.id_client;

create or replace view v_sectors as select * from sectors;

create or replace view v_employees as
select e.*, s.sector_name
  from employees e
  left join sectors s on s.id = e.id_sector;

create or replace view v_sector_heads as
select sh.*, s.sector_name
  from sector_heads sh
  left join sectors s on s.id = sh.id_sector;

create or replace view v_services as select * from services;

create or replace view v_pricing as
select p.*, s.service_name
  from pricing p
  join services s on s.id = p.id_service;

create or replace view v_contracts as
select ct.*,
       cl.fio_client,
       o.object_address,
       e.fio_employee
  from contracts ct
  join clients cl on cl.id = ct.id_client
  join construction_objects o on o.id = ct.id_object
  left join employees e on e.id = ct.id_employee;

create or replace view v_contract_services as
select cs.*, s.service_name, p.price
  from contract_services cs
  join services s on s.id = cs.id_service
  join pricing p on p.id = cs.id_pricing;

create or replace view v_payments as select * from payments;
create or replace view v_documents as select * from documents;

create or replace view v_expertise_reports as
select er.*, e.fio_employee, sh.fio_sector_head
  from expertise_reports er
  left join employees e on e.id = er.id_employee
  left join sector_heads sh on sh.id = er.id_sector_head;

--------------------------------------------------------------------------------
-- 3) Chart views
--------------------------------------------------------------------------------
create or replace view v_contract_status_chart as
select status label, count(*) value
  from contracts
 group by status;

create or replace view v_payment_status_chart as
select status label, sum(amount) value
  from payments
 group by status;

commit;
