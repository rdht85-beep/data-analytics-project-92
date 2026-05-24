--Данный запрос выводит количество уникальных клиентов по номеру id (поле customer_id)
SELECT COUNT(DISTINCT customer_id) AS customers_count
FROM customers;
