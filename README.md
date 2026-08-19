# SQL Practice Tasks

Учебные задачи по SQL, решённые в рамках самостоятельной подготовки.  
Репозиторий создан для отработки навыков написания сложных запросов, декомпозиции задач и работы с разными диалектами SQL.

## Цели репозитория

- Прокачать уверенное владение SQL на уровне, достаточном для позиции Junior+/Middle Data Engineer.
- Научиться разбивать сложные бизнес-задачи на читаемые этапы с помощью CTE.
- Освоить работу с подзапросами, агрегациями и оконными функциями.
- Попрактиковаться в написании самодокументируемого SQL-кода.
- Подготовиться к реальным задачам на собеседованиях и в работе с данными.

## Стек

<p align="left">
  <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/DBeaver-372923?style=for-the-badge&logo=dbeaver&logoColor=white" />
</p>

## Навигация по задачам

| Задача | SQL | Описание |
|:---|:---|:---|
| Top Couriers by September Deliveries | [`top_couriers_by_september_deliveries.sql`](sql/top_couriers_by_september_deliveries.sql) | [`описание`](descriptions/top_couriers_by_september_deliveries.md) |
| Last 100 Delivered Orders and Their Products | [`last_100_delivered_orders_with_products.sql`](sql/last_100_delivered_orders_with_products.sql) | [`описание`](descriptions/last_100_delivered_orders_with_products.md) |
| User Age with Missing Birth Date Replacement | [`user_age_with_missing_birth_date.sql`](sql/user_age_with_missing_birth_date.sql) | [`описание`](descriptions/user_age_with_missing_birth_date.md) |
| Delivery Time for Large Non-Canceled Orders | [`delivery_time_for_large_non_canceled_orders.sql`](sql/delivery_time_for_large_non_canceled_orders.sql) | [`описание`](descriptions/delivery_time_for_large_non_canceled_orders.md) |
| First Purchase Analysis | [`first_purchases_by_day.sql`](sql/first_purchases_by_day.sql) | [`описание`](descriptions/first_purchases_by_day.md) |
| Top Products in Non-Canceled Orders | [`top_products_by_non_canceled_orders.sql`](sql/top_products_by_non_canceled_orders.sql) | [`описание`](descriptions/top_products_by_non_canceled_orders.md) |
| Orders Containing Top Expensive Products | [`orders_with_top_expensive_products.sql`](sql/orders_with_top_expensive_products.sql) | [`описание`](descriptions/orders_with_top_expensive_products.md) |
| Orders Containing Top Expensive Products (Optimized) | [`orders_with_top_expensive_products_optimized.sql`](sql/orders_with_top_expensive_products_optimized.sql) | [`описание`](descriptions/orders_with_top_expensive_products.md) |
| Non-Canceled Orders with Products | [`non_canceled_orders_with_products.sql`](sql/non_canceled_orders_with_products.sql) | [`описание`](descriptions/non_canceled_orders_with_products.md) |
| Sales Sum of Non-Canceled Orders | [`total_revenue_from_non_canceled_orders.sql`](sql/total_revenue_from_non_canceled_orders.sql) | [`описание`](descriptions/total_revenue_from_non_canceled_orders.md) |
| User Order Statistics | [`user_order_value_and_size_stats.sql`](sql/user_order_value_and_size_stats.sql) | [`описание`](descriptions/user_order_value_and_size_stats.md) |
| Daily Revenue from Non-Canceled Orders | [`daily_revenue_from_non_canceled_orders.sql`](sql/daily_revenue_from_non_canceled_orders.sql) | [`описание`](descriptions/daily_revenue_from_non_canceled_orders.md) |
| Top 10 Products in Non-Canceled September Deliveries | [`top_products_in_september_deliveries.sql`](sql/top_products_in_september_deliveries.sql) | [`описание`](descriptions/top_products_in_september_deliveries.md) |
| Average Cancel Rate by Sex | [`avg_cancel_rate_by_sex.sql`](sql/avg_cancel_rate_by_sex.sql) | [`описание`](descriptions/avg_cancel_rate_by_sex.md) |

## Используемые техники

### Декомпозиция и структура запросов

- CTE (`WITH`) - пошаговое разбиение задачи на логические блоки.
- `MATERIALIZED` - управление материализацией CTE.
- Вложенные подзапросы в `SELECT` и `FROM`.
- Переход от одноразовых CTE к прямым подзапросам.
- Проектирование переиспользуемых CTE.

### Фильтрация и условия

- `EXISTS` / `NOT EXISTS` - проверка наличия строк в подзапросе.
- `IN` / `NOT IN` - сравнение со списком значений.
- `ANY` / `<> ALL` - работа с массивами и подзапросами.
- Агрегация с `FILTER` - подсчёт по условию без `CASE`.
- `HAVING` - фильтрация после группировки.

### Работа с массивами

- `UNNEST` - разворачивание массивов в строки.
- `ANY` - проверка вхождения элементов массива в список.
- Комбинация `UNNEST` + `JOIN` для связи товаров и заказов, например.

### Работа с датами и временем

- `DATE_TRUNC` - округление дат до нужной точности.
- `AGE` - вычисление возраста или разницы между датами.
- `EXTRACT` / `DATE_PART` - извлечение компонентов даты.
- `TO_CHAR` / `TO_TIMESTAMP` - форматирование и преобразование типов.
- `INTERVAL` - арифметика с датами.

### Агрегация и оконные функции

- `SUM`, `AVG`, `MIN`, `MAX`, `COUNT`.
- `ROUND` + приведение к `DECIMAL` для корректных дробей.
- Группировка по нескольким уровням (`GROUP BY` + CTE).
- Расчёт метрик на уровне заказа и пользователя.

### Проектирование и оптимизация

- Разделение расчёта цены заказа и пользовательской статистики.
- Вынос `LIMIT` и `ORDER BY` в финальный запрос.
- Использование `JOIN` для связи таблиц вместо подзапросов.
- Сравнение производительности версий с `UNNEST` и `ANY`.

## Примечания

- Задачи взяты из открытых источников и адаптированы под учебные цели.
- Некоторые решения намеренно усложнены, чтобы прокачать работу с подзапросами.
- Все задачи разобраны в отдельных файлах с подробным описанием логики и используемых методов.
- Репозиторий будет пополняться по мере прохождения новых тем.
- README находится в процессе доработки.
