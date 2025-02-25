--Overview 

SELECT * FROM customers 
SELECT * FROM sales 
SELECT * FROM departments 
SELECT * FROM employees
SELECT * FROM regions 

--1.Retrieve a list of employee_id, first_name, hire_date, 
-- and department of all employees ordered by the hire date 

SELECT employee_id, first_name, hire_date, department,
ROW_NUMBER() OVER(ORDER BY hire_date) AS ROW_N 
FROM employees 

-- 2. Retrieve the employee_id, first_name, 
-- hire_date of employees for different departments 

SELECT employee_id, first_name, hire_date, department,
ROW_NUMBER() OVER(PARTITION BY department ORDER BY hire_date) 

-- 3. Let's use the RANK() function 
-- Same values get the same rank in the rank function, Unlike the row_number function.

SELECT employee_id, first_name, hire_date, department, 
Rank() over(PARTITION by department order by hire_date) as rank_ 
from employees 

-- 4. Retrieve the employee_id, first_name, salary
-- hire_date of employees for different departments order by salaries. 

SELECT employee_id, first_name, hire_date, department, salary,
ROW_NUMBER() OVER(PARTITION BY department ORDER BY SALARY DESC) AS ROW_N 
FROM employees 

--And rank.

SELECT employee_id, first_name, hire_date, department, salary,
Rank() OVER(PARTITION BY department ORDER BY SALARY DESC) AS ROW_N 
FROM employees 

--5. Difference of rank, row_number and dense_rank

SELECT employee_id, first_name, hire_date, department, salary,
ROW_NUMBER() over(order by department) as row_nmber,
Rank() OVER( ORDER BY department) AS Rnk,
DENSE_RANK() OVER( ORDER BY department) AS dense_Rnk
from employees

-- 6. Retrieve the hire_date. Return details of
-- employees hired on or before 31st Dec, 2005 and are in
-- First Aid, Movies and Computers departments 

SELECT first_name, email, department, salary, hire_date,
RANK() OVER(PARTITION BY department
			ORDER BY salary DESC) as rnk
FROM employees
WHERE hire_date <= '2005-12-31' AND department in ('First Aid', 'Movies', 'Computers')

--7. How many employees are in each department? 

SELECT department, COUNT(*) AS COUNT_ FROM employees 
GROUP BY department ORDER BY 2 DESC


-- 8. Return the fifth ranked salary for each department 

SELECT department, salary from 
(SELECT first_name, email, department, salary, hire_date,
RANK() OVER(PARTITION BY department
			ORDER BY salary DESC) as rnk
FROM employees) as s
WHERE rnk=5 
order by 2 desc 

--9. Create a common table expression to retrieve the customer_id, 
-- and how many times the customer has purchased from the mall 

WITH purchase_count as (
SELECT Customer_ID, count(*) as purchases
from sales
GROUP by Customer_ID order by 2 desc) 
SELECT * FROM purchase_count

--10. Differences of row_number, rank, dense_rank on cte(purchase_count)

SELECT customer_id, purchases,
ROW_NUMBER() OVER (ORDER BY purchases DESC) AS Row_N,
RANK() OVER (ORDER BY purchase DESC) AS Rank_N,
DENSE_RANK() OVER (ORDER BY purchases DESC) AS Dense_Rank_N
FROM purchase_count
ORDER BY purchases DESC

-- 11. Group the employees table into five groups
-- based on the order of their salaries 

SELECT first_name, department, salary,
NTILE(5) OVER(order by salary desc) as ntiles
from employees

-- 12. Group the employees table into five groups for 
-- each department based on the order of their salaries

SELECT first_name, email, department, salary,
NTILE(5) OVER(PARTITION BY department
			  ORDER BY salary DESC)
FROM employees 

--13. Group the employees table each department based on the order of their salaries,
-- hire_date and first_name(alphabetically). 

SELECT first_name, NTILE(3) over(order by first_name) as name_group,
	hire_date, NTILE(5) over(order by hire_date desc) as hire_date_group,
    salary, NTILE(5) over(PARTITION by department 
                          order by salary desc) as salary_group
                          from employees

--14. Create a CTE that returns details of an employee
-- and group the employees into five groups
-- based on the order of their salaries 

WITH cte1 as ( SELECT first_name, department, salary, 
  NTILE(5) OVER(ORDER BY salary desc) AS ntiles 
  from employees)
SELECT * from cte1 

-- 15. Find the average salary for each group of employees

WITH cte1 as ( SELECT first_name, department, salary, 
  NTILE(5) OVER(ORDER BY salary desc) AS ntiles 
  from employees)
SELECT ntiles, round(avg(salary)) as avg_salary 
from cte1 
GROUP by ntiles 
order by 2 desc

-- 16. This returns how many employees are in each department

SELECT department, count(*) as numbers_of_personel 
FROM employees 
GROUP by department order by 1

-- 17. Retrieve the first names, department and 
-- number of employees working in that department

SELECT first_name, department, 
COUNT(*) over(PARTITION by department 
             order by department) as dept_count
from employees 

--18. Total Salary for all employees 

SELECT first_name, department, hire_date,
sum(salary) over(order by hire_date) as total_salary FROM employees

--19. Total Salary for all employees each departments

SELECT first_name, department, hire_date, salary,
	sum(salary) over(PARTITION by department) as sum_salary 
    from employees
    
-- 20. Total Salary for each department and
-- order by the hire date. Call the new column running_total

SELECT first_name, department, hire_date, salary,
	sum(salary) over(PARTITION by department 
                    order by hire_date) as running_total
    from employees 

--21.Retrieve the different region ids

SELECT DISTINCT region_id
FROM employees

-- 22. Retrieve the first names, department and 
-- number of employees working in that department and region

SELECT first_name, department, 
	COUNT(*) over(PARTITION by department) as count_dept, region_id,
    COUNT(*) over(PARTITION by  region_id) as count_region
    FROM employees

-- 23. Retrieve the first names, department and 
-- number of employees working in that department and in region 2

SELECT first_name, department, 
COUNT(*) OVER(PARTITION by department) AS dept_count
FROM employees
WHERE region_id = 2

-- 24. Create a common table expression to retrieve the customer_id, 
-- ship_mode, and how many times the customer has purchased from the mall

WITH purchase_count as ( 
  SELECT customer_id, ship_mode,
  COUNT(sales)  as purchase
  FROM sales 
  GROUP by customer_id
  order by purchase desc
)
SELECT * FROM purchase_count

-- 25. Calculate the cumulative sum of customers purchase
-- for the different ship mode

SELECT customer_id, ship_mode, purchase, 
sum(purchases) OVER(PARTITION by ship_mode
				   ORDER BY customer_id ASC) AS sum_of_sales
FROM purchase_count


-- 26. Calculate the running total of salary
-- Retrieve the first_name, hire_date, salary
-- of all employees ordered by the hire date 

SELECT first_name, hire_date, salary,
sum(salary) over(order by hire_date 
                 range UNBOUNDED PRECEDING) as run_sum
from employees 

-- 27. Add the current row and previous row

SELECT first_name, hire_date, salary,
sum(salary) over(order by hire_date 
                 rows BETWEEN 1 PRECEDING and CURRENT row) as run_total
from employees 

-- 28. Total of 1 and 2 preceding.
SELECT first_name, hire_date, salary,
sum(salary) over(order by hire_date 
                 rows BETWEEN 2 PRECEDING and 1 PRECEDING) as run_total
from employees 


--Simple Moving Average (SMA)

-- 29.Find the running average

SELECT first_name, hire_date, salary,
round(avg(salary) over(order by hire_date 
                 range UNBOUNDED PRECEDING)) as run_total
from employees 

--31. 4 Units Simple Moving Average

SELECT first_name, hire_date, salary,
avg(salary) OVER(ORDER BY hire_date 
				 ROWS BETWEEN
				 3 PRECEDING AND CURRENT ROW) AS running_total
FROM employees 

-- 32. Review of the FIRST_VALUE() function

SELECT department, division,
FIRST_VALUE(department) OVER(ORDER BY department ASC) first_department
FROM departments

-- 32. Review of the FIRST_VALUE() function

SELECT department, division,
FIRST_VALUE(department) OVER(ORDER BY department ASC) first_department,
last_VALUE(department) OVER(ORDER BY department 
                           RANGE UNBOUNDED PRECEDING) last_department
FROM departments

--33.Create a common table expression to retrieve the customer_id, 
-- ship_mode, and how many times the customer has purchased from the mall
-- And find maximum and following maximum purchases each customers.

WITH purchase_count AS (
SELECT customer_id, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id
ORDER BY purchase DESC
)
SELECT customer_id, purchase, 
MAX(purchase) OVER(ORDER BY customer_id ASC) AS max_of_sales,
MAX(purchase) OVER(ORDER BY customer_id ASC
				  ROWS BETWEEN
				  CURRENT ROW AND 1 FOLLOWING) AS next_max_of_sales
FROM purchase_count

--34. Find the sum of the quantity for different ship modes 

SELECT ship_mode, sum(quantity) 
from sales GROUP by ship_mode

--35. Find the sum of the quantity for different categories

SELECT category, sum(quantity) from sales GROUP by category

--36. Find the sum of the quantity for different subcategories

SELECT sub_category, sum(quantity) from sales GROUP by sub_category

--37. Use the GROUPING SETS clause

SELECT ship_mode, category, sub_category, sum(quantity) 
from sales 
GROUP by GROUPING sets (ship_mode, category, sub_category, ())

--38. Use the ROLLUP clause

SELECT ship_mode, category, sub_category, sum(quantity) 
from sales 
GROUP by ROLLUP (ship_mode, category, sub_category)

--39. Use the CUBE clause

SELECT ship_mode, category, sub_category, sum(quantity) 
from sales 
GROUP by cube (ship_mode, category, sub_category, ())





































