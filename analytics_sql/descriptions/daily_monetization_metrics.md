# Daily Monetization Metrics

SQL-отчёт по дневным метрикам монетизации: ARPU, ARPPU, AOV.

**SQL-файл:** [daily_monetization_metrics.sql](analytics_sql/advanced_sql/daily_monetization_metrics.sql)

## Метрики

| Метрика | Формула | Описание |
|---------|---------|----------|
| **ARPU** | `daily_revenue / total_users` | Средняя выручка на всех пользователей, совершавших действия (create / cancel) |
| **ARPPU** | `daily_revenue / count_active_users` | Средняя выручка на платящего (пользователя с неотменённым заказом) |
| **AOV** | `daily_revenue / total_orders` | Средний чек неотменённого заказа |

## Логика CTE

| Блок | Назначение |
|------|------------|
| `not_canceled_orders` | Заказы, по которым **не было** действия `cancel_order`. Источник: `user_actions` (доступны action: `create_order`, `cancel_order`) |
| `active_users` | Уникальные пользователи с неотменёнными заказами по дням |
| `all_users` | Все пользователи, совершавшие любые действия по дням |
| `daily_stats` | Выручка и количество заказов по дням. `UNNEST(product_ids)` разворачивает массив товаров, `DISTINCT order_id` обязателен — иначе AOV искажается из-за дублей строк на один заказ |

## Ключевые решения

- **Исключение отмен:** `NOT EXISTS` вместо `LEFT JOIN / IS NULL`. Надёжно при `NULL`-значениях.
- **Защита от деления на ноль:** `NULLIF(..., 0)` во всех метриках.
- **NULL-выручка:** `COALESCE(SUM(price), 0)` в `daily_stats`. При `FULL JOIN` дни без заказов получают `0.00` вместо `NULL`.
- **AOV корректен:** `COUNT(DISTINCT order_id)` компенсирует размножение строк `UNNEST`.

## Зависимости

- `user_actions` — лог действий (`order_id`, `user_id`, `action`, `time`)
- `orders` — заказы (`order_id`, `product_ids[]`)
- `products` — справочник товаров (`product_id`, `price`)

## Диалект

ClickHouse / аналитический SQL. Используется `UNNEST` (разворачивание массива), `FULL JOIN`, `USING`.

## Пример вызода

```sql
-- Запустить как есть или обернуть в VIEW
SELECT * FROM daily_monetization_metrics
WHERE report_date BETWEEN '2024-01-01' AND '2024-01-31';
