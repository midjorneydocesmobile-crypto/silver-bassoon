prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback

begin
  apex_application_install.set_application_id(9100);
  apex_application_install.set_application_name('Construction Expertise Pro');
  apex_application_install.set_schema(user);
  apex_application_install.generate_offset;
  apex_application_install.set_application_alias('CONST-EXPERTISE-PRO');
end;
/

begin
  wwv_flow_imp.import_begin(
    p_version_yyyy_mm_dd=>'2024.10.01',
    p_release=>'24.2.0',
    p_default_workspace_id=>null,
    p_default_application_id=>9100,
    p_default_id_offset=>apex_application_install.get_offset,
    p_default_owner=>user);

  wwv_flow_imp_shared.create_flow(
    p_id=>wwv_flow_imp.id(9100),
    p_name=>'Construction Expertise Pro',
    p_alias=>'CONST-EXPERTISE-PRO',
    p_page_view_logging=>'YES',
    p_flow_language=>'ru',
    p_flow_language_derived_from=>'SESSION',
    p_authentication=>'APEX',
    p_theme_id=>42,
    p_logo_type=>'T',
    p_logo_text=>'Строительная экспертиза PRO');

  -- Roles
  wwv_flow_imp_shared.create_security_scheme(
    p_id=>wwv_flow_imp.id(910000100),
    p_name=>'ROLE_MANAGER',
    p_scheme_type=>'NATIVE_FUNCTION_BODY',
    p_attribute_01=>q'[return apex_authorization.is_authorized(''MANAGER'');]');

  wwv_flow_imp_shared.create_security_scheme(
    p_id=>wwv_flow_imp.id(910000101),
    p_name=>'ROLE_EXPERT',
    p_scheme_type=>'NATIVE_FUNCTION_BODY',
    p_attribute_01=>q'[return apex_authorization.is_authorized(''EXPERT'');]');

  wwv_flow_imp_shared.create_security_scheme(
    p_id=>wwv_flow_imp.id(910000102),
    p_name=>'ROLE_HEAD',
    p_scheme_type=>'NATIVE_FUNCTION_BODY',
    p_attribute_01=>q'[return apex_authorization.is_authorized(''SECTOR_HEAD'');]');

  -- Navigation
  wwv_flow_imp_shared.create_list(p_id=>wwv_flow_imp.id(910000001), p_name=>'Desktop Navigation Menu');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000011),p_list_item_display_sequence=>10,p_list_item_link_text=>'Дашборд',p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-home');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000012),p_list_item_display_sequence=>20,p_list_item_link_text=>'Клиенты',p_list_item_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-users');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000013),p_list_item_display_sequence=>30,p_list_item_link_text=>'Объекты',p_list_item_link_target=>'f?p=&APP_ID.:12:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-building-o');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000014),p_list_item_display_sequence=>40,p_list_item_link_text=>'Сотрудники/Секторы',p_list_item_link_target=>'f?p=&APP_ID.:14:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-sitemap');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000015),p_list_item_display_sequence=>50,p_list_item_link_text=>'Услуги и цены',p_list_item_link_target=>'f?p=&APP_ID.:16:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-tags');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000016),p_list_item_display_sequence=>60,p_list_item_link_text=>'Контракты',p_list_item_link_target=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-file-text-o');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000017),p_list_item_display_sequence=>70,p_list_item_link_text=>'Платежи/Документы',p_list_item_link_target=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-credit-card');
  wwv_flow_imp_shared.create_list_item(p_id=>wwv_flow_imp.id(910000018),p_list_item_display_sequence=>80,p_list_item_link_text=>'Экспертиза',p_list_item_link_target=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::',p_list_item_icon=>'fa-clipboard-check');

  -- Dashboard page with charts
  wwv_flow_imp_page.create_page(p_id=>1,p_name=>'Дашборд',p_alias=>'DASHBOARD',p_step_title=>'Дашборд',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(
    p_id=>wwv_flow_imp.id(910100001),p_plug_name=>'KPI',p_plug_display_sequence=>10,p_query_type=>'SQL',
    p_plug_source=>q'[select (select count(*) from clients) clients_cnt,
                             (select count(*) from contracts) contracts_cnt,
                             (select count(*) from payments where status=''completed'') paid_cnt,
                             (select count(*) from documents where status=''verified'') docs_verified
                      from dual]',
    p_plug_source_type=>'NATIVE_CARDS');
  wwv_flow_imp_page.create_page_plug(
    p_id=>wwv_flow_imp.id(910100002),p_plug_name=>'Статусы контрактов',p_plug_display_sequence=>20,p_query_type=>'SQL',
    p_plug_source=>q'[select status label, count(*) value from contracts group by status]',
    p_plug_source_type=>'NATIVE_JET_CHART');
  wwv_flow_imp_page.create_page_plug(
    p_id=>wwv_flow_imp.id(910100003),p_plug_name=>'Платежи по статусам',p_plug_display_sequence=>30,p_query_type=>'SQL',
    p_plug_source=>q'[select status label, sum(amount) value from payments group by status]',
    p_plug_source_type=>'NATIVE_JET_CHART');

  -- Clients report + form (Create/Edit)
  wwv_flow_imp_page.create_page(p_id=>10,p_name=>'Клиенты',p_alias=>'CLIENTS',p_step_title=>'Клиенты',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100010),p_plug_name=>'Список клиентов',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from clients]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page(p_id=>11,p_name=>'Клиент: Create/Edit',p_alias=>'CLIENT-FORM',p_step_title=>'Клиент: Create/Edit',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100011),p_plug_name=>'Форма клиента',p_plug_display_sequence=>10,p_query_type=>'TABLE',p_query_table=>'CLIENTS',p_include_rowid_column=>false,p_plug_source_type=>'NATIVE_FORM');

  -- Construction objects
  wwv_flow_imp_page.create_page(p_id=>12,p_name=>'Объекты строительства',p_alias=>'OBJECTS',p_step_title=>'Объекты',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100012),p_plug_name=>'Реестр объектов',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select o.*, c.fio_client from construction_objects o join clients c on c.id=o.id_client]',p_plug_source_type=>'NATIVE_IR');

  -- Sectors + employees + heads
  wwv_flow_imp_page.create_page(p_id=>14,p_name=>'Секторы и сотрудники',p_alias=>'SECTORS-EMPLOYEES',p_step_title=>'Секторы и сотрудники',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100014),p_plug_name=>'Секторы',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from sectors]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100015),p_plug_name=>'Сотрудники',p_plug_display_sequence=>20,p_query_type=>'SQL',p_plug_source=>q'[select e.*, s.sector_name from employees e join sectors s on s.id=e.id_sector]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100016),p_plug_name=>'Руководители секторов',p_plug_display_sequence=>30,p_query_type=>'SQL',p_plug_source=>q'[select sh.*, s.sector_name from sector_heads sh join sectors s on s.id=sh.id_sector]',p_plug_source_type=>'NATIVE_IR');

  -- Services + pricing
  wwv_flow_imp_page.create_page(p_id=>16,p_name=>'Услуги и цены',p_alias=>'SERVICES-PRICING',p_step_title=>'Услуги и цены',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100017),p_plug_name=>'Услуги',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from services]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100018),p_plug_name=>'Цены',p_plug_display_sequence=>20,p_query_type=>'SQL',p_plug_source=>q'[select p.*, s.service_name from pricing p join services s on s.id=p.id_service]',p_plug_source_type=>'NATIVE_IR');

  -- Contracts + form + services bridge
  wwv_flow_imp_page.create_page(p_id=>20,p_name=>'Контракты',p_alias=>'CONTRACTS',p_step_title=>'Контракты',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100020),p_plug_name=>'Реестр контрактов',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from contracts]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page(p_id=>21,p_name=>'Контракт: Create/Edit',p_alias=>'CONTRACT-FORM',p_step_title=>'Контракт: Create/Edit',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100021),p_plug_name=>'Форма контракта',p_plug_display_sequence=>10,p_query_type=>'TABLE',p_query_table=>'CONTRACTS',p_include_rowid_column=>false,p_plug_source_type=>'NATIVE_FORM');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100022),p_plug_name=>'Услуги в контракте',p_plug_display_sequence=>20,p_query_type=>'SQL',p_plug_source=>q'[select cs.*, s.service_name from contract_services cs join services s on s.id=cs.id_service]',p_plug_source_type=>'NATIVE_IR');

  -- Payments + documents
  wwv_flow_imp_page.create_page(p_id=>24,p_name=>'Платежи и документы',p_alias=>'PAYMENTS-DOCUMENTS',p_step_title=>'Платежи и документы',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100024),p_plug_name=>'Платежи',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from payments]',p_plug_source_type=>'NATIVE_IR');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100025),p_plug_name=>'Документы',p_plug_display_sequence=>20,p_query_type=>'SQL',p_plug_source=>q'[select * from documents]',p_plug_source_type=>'NATIVE_IR');

  -- Expertise reports
  wwv_flow_imp_page.create_page(p_id=>30,p_name=>'Отчёты экспертизы',p_alias=>'EXPERTISE-REPORTS',p_step_title=>'Отчёты экспертизы',p_protection_level=>'C');
  wwv_flow_imp_page.create_page_plug(p_id=>wwv_flow_imp.id(910100030),p_plug_name=>'Отчёты',p_plug_display_sequence=>10,p_query_type=>'SQL',p_plug_source=>q'[select * from expertise_reports]',p_plug_source_type=>'NATIVE_IR');

  -- CSS
  wwv_flow_imp_shared.create_theme_style(
    p_id=>wwv_flow_imp.id(910000900),p_theme_id=>42,p_name=>'Custom Accent',p_is_current=>true,
    p_css=>q'[
.t-Header-branding { background: linear-gradient(90deg,#1e3a8a,#0ea5e9)!important; }
.t-Body-nav { background: #0f172a; }
.t-Region { border-radius: 12px; box-shadow: 0 4px 16px rgba(2,6,23,.08); }
.t-Button--hot { background:#0ea5e9!important; border-color:#0284c7!important; }
]');

  wwv_flow_imp.import_end;
  commit;
end;
/
