-- 00_drop_all.sql
-- Drops every object this project creates, so the scripts can be re-run from scratch.
--
-- Why the long blocks: DROP TABLE fails with ORA-00942 ("table or view does not
-- exist") on a first run. The block ignores only that error and re-raises
-- anything else, so a real problem is never hidden.
--
-- Order matters: child objects first. A table cannot be dropped while another
-- table's foreign key still points to it, and views depend on tables.

-- Views.
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW v_po_summary';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW v_low_stock';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Package. A missing package raises ORA-04043, not ORA-00942, so both codes
-- are accepted and any other error is still raised.
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE inventory_pkg';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 AND SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

-- Tables, from the most dependent one back to the parent tables.
-- Dropping a table also drops its triggers.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE stock_movements PURGE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE purchase_order_lines PURGE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE purchase_orders PURGE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE items PURGE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE suppliers PURGE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
