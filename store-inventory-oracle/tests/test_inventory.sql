-- tests/test_inventory.sql
-- Eight small checks for the package, the triggers and the views.
-- Each block prints PASS or FAIL. Every block ends with ROLLBACK, so the sample
-- data is exactly the same after a test run as before it.
--
-- How to run: SQL Workshop -> SQL Commands, one block at a time (the DBMS output
-- is shown for you). In SQL*Plus or SQLcl, run  SET SERVEROUTPUT ON  first.
--
-- The tests use the ids from 02_seed_data.sql: item 1 (22 in stock), item 6
-- (24), item 11 (45), item 15 (0), and purchase order 3 (status ORDERED).

-- Test 1: get_stock reads the seeded quantity.
DECLARE
    v_stock NUMBER;
BEGIN
    v_stock := inventory_pkg.get_stock(1);

    IF v_stock = 22 THEN
        DBMS_OUTPUT.PUT_LINE('PASS 1: get_stock(1) = ' || v_stock);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 1: expected 22, got ' || NVL(TO_CHAR(v_stock), 'NULL'));
    END IF;
END;
/

-- Test 2: issue_stock lowers the stock by exactly the issued quantity.
DECLARE
    v_before NUMBER;
    v_after  NUMBER;
BEGIN
    v_before := inventory_pkg.get_stock(6);
    inventory_pkg.issue_stock(6, 4, 'Test issue');
    v_after := inventory_pkg.get_stock(6);

    IF v_after = v_before - 4 THEN
        DBMS_OUTPUT.PUT_LINE('PASS 2: stock went from ' || v_before || ' to ' || v_after);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 2: expected ' || (v_before - 4) || ', got ' || v_after);
    END IF;

    ROLLBACK;
END;
/

-- Test 3: issuing more than we have raises our own exception, by name.
DECLARE
    v_caught BOOLEAN := FALSE;
BEGIN
    BEGIN
        -- Item 15 is out of stock, so even one unit is too many.
        inventory_pkg.issue_stock(15, 1, 'Test issue');
    EXCEPTION
        WHEN inventory_pkg.e_insufficient_stock THEN
            v_caught := TRUE;
    END;

    IF v_caught THEN
        DBMS_OUTPUT.PUT_LINE('PASS 3: not enough stock was raised as e_insufficient_stock');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 3: no exception was raised');
    END IF;

    ROLLBACK;
END;
/

-- Test 4: receiving a PO sets it to RECEIVED, adds stock, and cannot be repeated.
DECLARE
    v_status   purchase_orders.status%TYPE;
    v_before   NUMBER;
    v_after    NUMBER;
    v_expected NUMBER;
    v_again    BOOLEAN := FALSE;
    e_cannot_receive EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cannot_receive, -20002);
BEGIN
    -- The expected quantity is read from the PO line, not hard-coded.
    SELECT quantity
      INTO v_expected
      FROM purchase_order_lines
     WHERE po_id = 3
       AND item_id = 11;

    v_before := inventory_pkg.get_stock(11);
    inventory_pkg.receive_po(3);

    SELECT status INTO v_status FROM purchase_orders WHERE po_id = 3;
    v_after := inventory_pkg.get_stock(11);

    IF v_status = 'RECEIVED' AND v_after = v_before + v_expected THEN
        DBMS_OUTPUT.PUT_LINE('PASS 4a: PO 3 received, item 11 stock ' ||
                             v_before || ' -> ' || v_after);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 4a: status ' || v_status || ', stock ' ||
                             v_before || ' -> ' || v_after);
    END IF;

    -- The PO is RECEIVED now, so a second receive must be refused.
    BEGIN
        inventory_pkg.receive_po(3);
    EXCEPTION
        WHEN e_cannot_receive THEN
            v_again := TRUE;
    END;

    IF v_again THEN
        DBMS_OUTPUT.PUT_LINE('PASS 4b: receiving PO 3 a second time was rejected');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 4b: the second receive did not raise ORA-20002');
    END IF;

    ROLLBACK;
END;
/

-- Test 5: an IN movement written directly in SQL still updates stock and updated_at.
DECLARE
    v_before_qty NUMBER;
    v_after_qty  NUMBER;
    v_updated    DATE;
BEGIN
    v_before_qty := inventory_pkg.get_stock(6);

    INSERT INTO stock_movements (item_id, movement_type, quantity, reason)
    VALUES (6, 'IN', 5, 'Test trigger');

    SELECT quantity_on_hand, updated_at
      INTO v_after_qty, v_updated
      FROM items
     WHERE item_id = 6;

    IF v_after_qty = v_before_qty + 5 AND TRUNC(v_updated) = TRUNC(SYSDATE) THEN
        DBMS_OUTPUT.PUT_LINE('PASS 5: movement moved stock ' || v_before_qty ||
                             ' -> ' || v_after_qty || ' and updated_at was set');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 5: stock ' || v_before_qty || ' -> ' || v_after_qty ||
                             ', updated_at ' || NVL(TO_CHAR(v_updated, 'YYYY-MM-DD'), 'NULL'));
    END IF;

    ROLLBACK;
END;
/

-- Test 6: even without the package, the CHECK constraint blocks negative stock.
DECLARE
    v_caught BOOLEAN := FALSE;
    e_check_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_check_violation, -2290);
BEGIN
    BEGIN
        -- Item 15 has nothing in stock, so this UPDATE inside the trigger
        -- would push quantity_on_hand to -1.
        INSERT INTO stock_movements (item_id, movement_type, quantity, reason)
        VALUES (15, 'OUT', 1, 'Test negative stock');
    EXCEPTION
        WHEN e_check_violation THEN
            v_caught := TRUE;
    END;

    IF v_caught THEN
        DBMS_OUTPUT.PUT_LINE('PASS 6: the CHECK constraint refused negative stock (ORA-02290)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 6: the insert was accepted and the stock went negative');
    END IF;

    ROLLBACK;
END;
/

-- Test 7: both views return the expected rows, and items without a supplier
-- still appear in the low stock report.
DECLARE
    v_low  NUMBER;
    v_sum  NUMBER;
    v_gone NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_low FROM v_low_stock;
    SELECT COUNT(*) INTO v_sum FROM v_po_summary;
    SELECT COUNT(*) INTO v_gone
      FROM v_low_stock
     WHERE item_id = 15
       AND supplier_name = 'No supplier';

    IF v_low = 7 AND v_sum = 5 AND v_gone = 1 THEN
        DBMS_OUTPUT.PUT_LINE('PASS 7: v_low_stock has ' || v_low ||
                             ' rows, v_po_summary has ' || v_sum || ' rows');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 7: v_low_stock ' || v_low || ' rows, v_po_summary ' ||
                             v_sum || ' rows, item 15 with ''No supplier'' = ' || v_gone);
    END IF;
END;
/

-- Test 8: get_stock on an unknown id returns NULL instead of failing.
DECLARE
    v_stock NUMBER;
BEGIN
    v_stock := inventory_pkg.get_stock(9999);

    IF v_stock IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('PASS 8: get_stock(9999) returned NULL');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL 8: expected NULL, got ' || v_stock);
    END IF;
END;
/
