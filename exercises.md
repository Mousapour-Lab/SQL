# Exercises

15 exercises, from easy to medium. There are no answers in this repository.
Write each query in SQL Workshop (or save it as `solutions/01.sql`, `solutions/02.sql`, ...).

The tables are described in [README.md](README.md).

---

## 1. Filter rows with WHERE

List the equipment that has the status `NEEDS_REPAIR`. Show the id, name and type.

*Hint: use `WHERE` and put the text value in single quotes.*

## 2. Filter text with LIKE

List the employees whose job title contains the word `Operator`. Show the first name, last name and job title.

*Hint: `LIKE '%Operator%'`.*

## 3. Find missing values

List the employees who have no salary recorded. Show the id, last name and salary.

*Hint: test the column with `IS NULL`.*

## 4. Sort rows with ORDER BY

Show the three best paid employees (last name and salary). Employees with no salary must come last.

*Hint: `ORDER BY salary DESC NULLS LAST` and `FETCH FIRST 3 ROWS ONLY`.*

## 5. INNER JOIN two tables

Show every maintenance request with the name of its equipment. Columns: request id, request date, status, equipment name.

*Hint: join `maintenance_requests` to `equipment` on the equipment id.*

## 6. INNER JOIN three tables

Same as exercise 5, but also show the full name of the employee who created the request.

*Hint: join a third table and put `first_name` and `last_name` together with `||`.*

## 7. LEFT JOIN and COUNT

Show every department with the number of employees in it, including departments with nobody in them.

*Hint: `LEFT JOIN` starting from `departments`, then count the employee id.*

## 8. LEFT JOIN to find rows without a match

Which equipment has never had a maintenance request? Show the equipment id and name.

*Hint: `LEFT JOIN` to the requests, then keep the rows where the request id `IS NULL`.*

## 9. GROUP BY

Show how many maintenance requests there are for each status. Put the biggest number first.

*Hint: `GROUP BY status` with `COUNT(*)`.*

## 10. GROUP BY with HAVING

Show the employees who created more than one request: employee id, last name and number of requests.

*Hint: filter the groups with `HAVING COUNT(*) > 1`.*

## 11. Averages per group

Show the average salary for each department, rounded to a whole number, highest average first. Ignore employees whose salary is empty.

*Hint: `ROUND(AVG(salary))` with `GROUP BY department_id`.*

## 12. Subquery

Show the employees who earn more than the average salary of the whole company. Show the last name and salary.

*Hint: put a `SELECT AVG(...)` inside the `WHERE` clause.*

## 13. CASE

For every employee show the last name, the salary and a salary band:

- `HIGH` for 4000 or more
- `MEDIUM` for 3000 to 3999
- `LOW` for less than 3000
- `NOT SET` when there is no salary

*Hint: `CASE WHEN ... THEN ... END`, and check `salary IS NULL` first.*

## 14. Date arithmetic and NVL

For every request show the request id, the request date, the close date and how many days it stayed open. Requests that are still open should show `0`.

*Hint: subtract the two dates, then wrap the result with `NVL`.*

## 15. INSERT, UPDATE and DELETE

Do these three steps one at a time and check the result with a `SELECT` after each step:

1. Insert two new requests for equipment id `11` (Test Bench), from employees `10` and `11`. Use today's date, status `OPEN` and a short description.
2. Update one of the two new requests: set its status to `CLOSED` and set the close date to today.
3. Delete the other new request.

*Hint: `INSERT INTO ... VALUES`, `UPDATE ... SET ... WHERE request_id = ...`, `DELETE FROM ... WHERE request_id = ...`; do not leave out the `WHERE`. See the note in the README to undo these changes.*

---

When all 15 boxes in the README checklist are ticked, you have used most of the SQL an entry-level Oracle job asks for.
