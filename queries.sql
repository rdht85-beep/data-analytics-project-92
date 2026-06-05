-- customers_count.csv
-- данный запрос выводит количество уникальных клиентов по номеру id (поле customer_id)
SELECT COUNT(DISTINCT customer_id) AS customers_count
FROM customers;


-- top_10_total_income.csv
SELECT 
	e.first_name || ' ' || e.last_name AS seller, -- соединение имя и фамилии из таблицы employees
	COUNT(s.sales_id) AS operations, -- подсчет количества сделок
	FLOOR(SUM(s.quantity * p.price)) AS income -- сумма количества товара и цены, округленная до целого в меньшую сторону
FROM sales s
INNER JOIN employees e  -- соединение с таблицей employees по id сотрудника
	ON s.sales_person_id = e.employee_id
INNER JOIN products p -- соединение с таблицей products по id продукта
	ON s.product_id = p.product_id
GROUP BY e.first_name || ' ' || e.last_name -- группировка по продавцу
ORDER BY income desc -- сортировка по полю и направление сортировки
LIMIT 10; -- установка лимита строк


-- lowest_average_income.csv
SELECT
	seller,
	average_income
FROM ( -- подзапрос для расчета среднего значения выручки по каждому продавцу, а также общее значение средней выручки по всем продацам
	SELECT
		e.first_name || ' ' || e.last_name AS seller,
		FLOOR(AVG(s.quantity * p.price)) AS average_income, -- сумма количества товара и цены, округленная до целого в меньшую сторону
		AVG(AVG(s.quantity * p.price)) OVER() AS general_avg -- оконная функция для расчета среднего значения выручки по всем продавцам 
	FROM sales s 
	INNER JOIN employees e  -- соединение с таблицей employees по id сотрудника
		ON s.sales_person_id = e.employee_id
	INNER JOIN products p -- соединение с таблицей products по id продукта
	ON s.product_id = p.product_id
	GROUP BY seller
	) AS tab
WHERE average_income < general_avg -- установка условия выборки для итоговой таблицы
ORDER BY average_income ASC; -- установка сортировки по возрастанию


-- day_of_the_week_income.csv
SELECT 
    e.first_name || ' ' || e.last_name AS seller, -- соединение имя и фамилии из таблицы employees
    TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week, --преобразование даты в день недели
    FLOOR(SUM(s.quantity * p.price)) AS income -- сумма количества товара и цены, округленная до целого в меньшую сторону
FROM sales s
INNER JOIN employees e -- соединение с таблицей employees по id сотрудника
	ON s.sales_person_id = e.employee_id
INNER JOIN products p -- соединение с таблицей products по id продукта
	ON s.product_id = p.product_id
GROUP BY -- группировка по продацу, номеру дня недели и полю с названием дня
	e.first_name || ' ' || e.last_name,
	EXTRACT(ISODOW FROM s.sale_date), --вывод номера дня недели из даты
	TO_CHAR(s.sale_date, 'Day') --преобразование даты в день недели
ORDER BY 
	EXTRACT(ISODOW FROM s.sale_date), --сортировка по номеру дня недели
	e.first_name || ' ' || e.last_name; -- сортировка по продавцу


-- age_groups.csv
SELECT
	 CASE -- определение и агрегация групп по возрастам
	 	WHEN age BETWEEN 16 AND 25 THEN '16-25'
	 	WHEN age BETWEEN 26 AND 40 THEN '26-40'
	 	WHEN age >=41 THEN '40+'
	 	ELSE 'other'
	 END AS age_category,
	 COUNT(customer_id) AS age_count -- подсчет клиентов в каждой ранее определенной группе
FROM customers
GROUP BY age_category -- группировка по возрастной категории
ORDER BY min(age); -- сортировка по возрастной группе в порядке возрастания


-- customers_by_month.csv
SELECT
	TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, -- выделение месяца из даты в формате "год-месяц"
	COUNT(DISTINCT s.customer_id) AS total_customers, -- подсчет уникальных пользователей
	FLOOR(SUM(s.quantity * p.price)) AS income -- расчет выручки с огруглением до целого числа в меньшую сторону
FROM sales s
INNER JOIN customers c -- соединение с таблицей customers по полю id
	ON s.customer_id = c.customer_id 
INNER JOIN products p -- соединение с таблицей products по полю id
	ON s.product_id = p.product_id
GROUP BY selling_month -- группировка по месяцу
ORDER BY selling_month asc; -- сортировка по месяцу в порядке возрастания


-- special_offer.csv
WITH tab AS ( -- создание временной таблицы для последующего применения в конечном запросе
    SELECT 
        s.customer_id,
        s.sale_date,
        c.first_name || ' ' || c.last_name AS customer, -- соединение имя и фамилии клиента
        e.first_name || ' ' || e.last_name AS seller, -- соединение имя и фамилии продавца
        p.price,
        ROW_NUMBER() OVER ( -- оконная функция для присвоения порядковых номеров в ракурсе каждого клиента по его id
            PARTITION BY s.customer_id 
            ORDER BY s.sale_date ASC, s.sales_id asc -- сортировка по дате продажи и индентификатору покупки
        ) AS purchase_number
    FROM sales s
    INNER JOIN customers c -- соединение с таблицей customers по id клиента
		ON s.customer_id = c.customer_id
    INNER JOIN employees e -- соединение с таблицей employees по id сотрудника
		ON s.sales_person_id = e.employee_id
    INNER JOIN products p -- соединение с таблицей products по id продукта
		ON s.product_id = p.product_id
)
SELECT -- выборка полей согласно запросу из подготовленной таблицы tab
    customer,
    sale_date,
    seller
FROM tab
WHERE -- установка условий согласно задаче
    purchase_number = 1 -- выбор самой первой покупки
    AND price = 0 -- выбор покупки с нулевой суммой
ORDER BY customer_id ASC; -- установка сортировки по id клиента по возрастанию