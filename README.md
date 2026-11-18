# Oracle SQL Practice – Factory Maintenance

A small practice repository for learning Oracle SQL.
It has four related tables for a factory maintenance system and 15 exercises that go from simple `SELECT` statements to joins, grouping and small data changes.

There are **no answers** here on purpose. Write your own queries in the `solutions/` folder (`01.sql`, `02.sql`, ...) or directly in SQL Workshop.

## Tables

| Table | What it stores |
| --- | --- |
| `departments` | Factory departments and their location |
| `employees` | Staff, their job title, salary and department |
| `equipment` | Machines and vehicles, their status and department |
| `maintenance_requests` | Repair requests: one employee reports one equipment |

How they relate:

- One department has many employees (`employees.department_id` → `departments.department_id`).
- One department has many pieces of equipment (`equipment.department_id` → `departments.department_id`).
- One employee can create many maintenance requests (`maintenance_requests.employee_id` → `employees.employee_id`).
- One piece of equipment can have many maintenance requests (`maintenance_requests.equipment_id` → `equipment.equipment_id`).

The scripts also use Oracle-specific syntax: identity columns, `NVL`, `SYSDATE`, `DATE` literals and `FETCH FIRST`.

## How to run the scripts

The scripts need Oracle Database 12c or later, so the free workspace at [apex.oracle.com](https://apex.oracle.com) is enough.

1. Create a free workspace at apex.oracle.com and log in.
2. Go to **SQL Workshop → SQL Scripts → Upload**.
3. Upload and run `schema/create_tables.sql`.
4. Upload and run `schema/seed_data.sql` (this ends with `COMMIT`).
5. Check that the data is there, for example: `SELECT COUNT(*) FROM maintenance_requests;` → 14.

To run a single statement, use **SQL Workshop → SQL Commands** instead and paste one statement at a time.

If the tables already exist, open `create_tables.sql` and run the four commented `DROP TABLE` lines first (child tables first), then run both scripts again.
The same steps reset the data if you want to undo the changes you make in exercise 15.

## Checklist

- [ ] 1. Filter rows with `WHERE`
- [ ] 2. Filter text with `LIKE`
- [ ] 3. Find missing values with `IS NULL`
- [ ] 4. Sort rows with `ORDER BY` and `FETCH FIRST`
- [ ] 5. `INNER JOIN` two tables
- [ ] 6. `INNER JOIN` three tables
- [ ] 7. `LEFT JOIN` and `COUNT`
- [ ] 8. `LEFT JOIN` to find rows without a match
- [ ] 9. `GROUP BY`
- [ ] 10. `GROUP BY` with `HAVING`
- [ ] 11. Averages per group
- [ ] 12. Subquery
- [ ] 13. `CASE`
- [ ] 14. Date arithmetic and `NVL`
- [ ] 15. `INSERT`, `UPDATE` and `DELETE`

The full exercise text is in [exercises.md](exercises.md).
