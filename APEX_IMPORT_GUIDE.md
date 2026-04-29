# Исправленный способ (без ORA-06502) для Oracle APEX

Ошибка `ORA-06502: character to number conversion error` при **App Builder → Import** возникала из-за несовместимости экспортного API между версиями APEX.

Ниже — стабильный путь, который работает в большинстве сред:

## Важно
Файл `apex_app_mockup.sql` теперь нужно запускать в:
- **SQL Workshop → SQL Scripts**

а не загружать через **App Builder → Import**.

---

## 1) Подготовка базы
1. Выполните `1.sql`.
2. Выполните `apex_app_mockup.sql`.

Скрипт создаст:
- таблицу ролей `app_user_roles`;
- функцию `has_role` для авторизации;
- набор представлений `v_*` для всех таблиц вашей БД;
- 2 view для диаграмм.

---

## 2) Создание приложения в APEX (Wizard)
1. **App Builder → Create → New Application**.
2. Имя: `Construction Expertise Pro`.
3. Добавьте страницы:
   - Interactive Report по view:
     - `v_clients`, `v_objects`, `v_sectors`, `v_employees`, `v_sector_heads`,
     - `v_services`, `v_pricing`, `v_contracts`, `v_contract_services`,
     - `v_payments`, `v_documents`, `v_expertise_reports`.
   - Form pages (Create/Edit):
     - таблица `clients`,
     - таблица `contracts`.
   - Chart pages:
     - `v_contract_status_chart`,
     - `v_payment_status_chart`.

---

## 3) Ролевая авторизация
1. Shared Components → Authorization Schemes.
2. Создайте 3 схемы типа **PL/SQL Function Body**:
   - `return has_role('MANAGER');`
   - `return has_role('EXPERT');`
   - `return has_role('SECTOR_HEAD');`
3. Назначьте схемы на страницы/регионы.

Пример наполнения ролей:
```sql
insert into app_user_roles(username, role_code) values ('IVANOV', 'MANAGER');
insert into app_user_roles(username, role_code) values ('PETROV', 'EXPERT');
insert into app_user_roles(username, role_code) values ('SIDOROV', 'SECTOR_HEAD');
commit;
```

---

## 4) Оформление (красивый стиль)
В приложении: **Shared Components → Themes → Universal Theme → Theme Roller / Inline CSS**

```css
.t-Header-branding { background: linear-gradient(90deg,#1e3a8a,#0ea5e9)!important; }
.t-Body-nav { background: #0f172a; }
.t-Region { border-radius: 12px; box-shadow: 0 4px 16px rgba(2,6,23,.08); }
.t-Button--hot { background:#0ea5e9!important; border-color:#0284c7!important; }
```

---

## 5) Почему это исправляет ошибку
- Мы убрали зависимость от внутреннего экспортного формата `wwv_flow_imp*`, который часто ломается между версиями APEX.
- Используется стандартный стабильный сценарий: SQL-объекты + создание UI через мастер APEX.
