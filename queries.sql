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
GROUP BY seller -- группировка по полю
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
	FROM sales s -- комментарии по соединениям см. в предыдущем задании
	INNER JOIN employees e  
		ON s.sales_person_id = e.employee_id
	INNER JOIN products p 
	ON s.product_id = p.product_id
	GROUP BY seller
	) AS tab
WHERE average_income < general_avg -- установка условия выборки для итоговой таблицы
ORDER BY average_income ASC; -- установка сортировки по возрастанию


-- day_of_the_week_income.csv
SELECT 
    e.first_name || ' ' || e.last_name AS seller, -- соединение имя и фамилии из таблицы employees
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, --преобразование даты в день недели
    FLOOR(SUM(s.quantity * p.price)) AS income -- сумма количества товара и цены, округленная до целого в меньшую сторону
FROM sales s
INNER JOIN employees e -- комментарии по соединениям см. в предыдущем задании
	ON s.sales_person_id = e.employee_id
INNER JOIN products p 
	ON s.product_id = p.product_id
GROUP BY 
	seller,
	EXTRACT(ISODOW FROM s.sale_date), --вывод номера дня недели из даты
	TO_CHAR(s.sale_date, 'Day') --преобразование даты в день недели
ORDER BY 
	EXTRACT(ISODOW FROM s.sale_date), --сортировка по номеру дня недели и продавцу
	seller;