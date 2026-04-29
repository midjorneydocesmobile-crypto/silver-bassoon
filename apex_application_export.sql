prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback

begin
  apex_application_install.set_application_id(9100);
  apex_application_install.set_application_alias('CONST-EXPERTISE-PRO');
  apex_application_install.set_application_name('Construction Expertise Pro');
  apex_application_install.generate_offset;
end;
/

begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.10.01'
,p_release=>'24.2.0'
,p_default_workspace_id=>null
,p_default_application_id=>9100
,p_default_id_offset=>apex_application_install.get_offset
,p_default_owner=>user);

wwv_flow_imp_shared.create_flow(
 p_id=>wwv_flow_imp.id(9100)
,p_name=>'Construction Expertise Pro'
,p_alias=>'CONST-EXPERTISE-PRO'
,p_page_view_logging=>'YES'
,p_flow_language=>'ru'
,p_flow_language_derived_from=>'SESSION'
,p_authentication=>'APEX'
,p_home_link=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_theme_id=>42
,p_logo_type=>'T'
,p_logo_text=>'Construction Expertise Pro');

wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Главная'
,p_alias=>'HOME'
,p_step_title=>'Главная'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C');

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(910001)
,p_plug_name=>'Добро пожаловать'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>null
,p_plug_display_sequence=>10
,p_plug_source=>q'[<h2>Приложение установлено</h2><p>Далее запустите <code>apex_app_mockup.sql</code> в SQL Workshop и добавьте страницы мастером.</p>]'
,p_plug_source_type=>'NATIVE_STATIC');

wwv_flow_imp.import_end;
commit;
end;
/
