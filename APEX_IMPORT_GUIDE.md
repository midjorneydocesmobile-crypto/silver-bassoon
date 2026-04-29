# Импорт, чтобы приложение создалось сразу

Вы правы: можно сделать так, чтобы приложение **сразу появилось** через `File Type: Application, Page or Component Export`.

## Что добавлено
- `apex_application_export.sql` — файл для импорта в **App Builder → Import** (тип: `Application, Page or Component Export`).
- `apex_app_mockup.sql` — SQL-скрипт для SQL Workshop (таблица ролей, функция авторизации, view по всем таблицам и chart view).

---

## Вариант 1 (рекомендуемый): приложение появляется сразу
1. В APEX откройте **App Builder → Import**.
2. В `File Type` выберите: **Application, Page or Component Export**.
3. Загрузите файл: `apex_application_export.sql`.
4. Нажмите **Install Application**.

После этого приложение уже будет создано (страница Главная).

5. Перейдите в **SQL Workshop → SQL Scripts** и выполните `1.sql`.
6. Выполните `apex_app_mockup.sql`.
7. В App Builder добавьте страницы мастером на основе view `v_*` (это делается быстро).

---

## Почему два файла
- `apex_application_export.sql` — именно для импорта типа **Application Export**.
- `apex_app_mockup.sql` — надежная серверная часть без зависимости от версии внутреннего формата экспорта.

Так мы избегаем ошибки `ORA-06502` и при этом получаем **сразу созданное приложение**.

---

## Если опять ошибка при Import
Попробуйте:
1. Импортировать в пустой workspace.
2. В мастере импорта сменить Application ID.
3. Проверить, что версия APEX 23+.
4. Если не помогло — создать приложение вручную через Create Application и использовать `apex_app_mockup.sql`.
