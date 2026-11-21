-- 01_inventory_pkg.sql
-- The package is the small API that the rest of the application calls.
-- The spec says WHAT is available; the body says HOW it works.
-- Nothing in this package commits: the caller decides when the transaction ends.

CREATE OR REPLACE PACKAGE inventory_pkg AS

    -- Raised when an OUT movement would take the stock below zero.
    -- The error number is what makes it catchable by name in other code.
    e_insufficient_stock EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insufficient_stock, -20001);

    -- Mark a purchase order as received and add one IN movement per line.
    PROCEDURE receive_po (p_po_id IN purchase_orders.po_id%TYPE);

    -- Take stock out of an item and record the movement.
    PROCEDURE issue_stock (p_item_id IN items.item_id%TYPE,
                           p_qty     IN NUMBER,
                           p_reason  IN VARCHAR2 DEFAULT NULL);

    -- Current quantity on hand, or NULL when the item does not exist.
    FUNCTION get_stock (p_item_id IN items.item_id%TYPE) RETURN NUMBER;

    -- TODO(owner): add a function that returns the total value of the stock
    -- (SUM of quantity_on_hand * unit_price) and implement it in the body.

    -- TODO(owner): add a procedure that cancels a purchase order
    -- (status 'CANCELLED', only when the PO is not received yet).

END inventory_pkg;
/

CREATE OR REPLACE PACKAGE BODY inventory_pkg AS

    PROCEDURE receive_po (p_po_id IN purchase_orders.po_id%TYPE) IS
        v_status purchase_orders.status%TYPE;
    BEGIN
        -- Lock the PO row first: two users cannot receive the same PO together.
        SELECT status
          INTO v_status
          FROM purchase_orders
         WHERE po_id = p_po_id
           FOR UPDATE;

        -- Only an ORDERED PO can be received. The same check stops a second
        -- receive, a cancelled PO and a draft that was never sent.
        IF v_status <> 'ORDERED' THEN
            RAISE_APPLICATION_ERROR(-20002,
                'PO ' || p_po_id || ' cannot be received, its status is ' || v_status);
        END IF;

        -- One IN movement per line. The trigger on stock_movements does the
        -- quantity_on_hand update, so stock is never changed in two places.
        INSERT INTO stock_movements (item_id, movement_type, quantity, movement_date, reason, po_id)
        SELECT l.item_id, 'IN', l.quantity, SYSDATE, 'Received PO ' || p_po_id, p_po_id
          FROM purchase_order_lines l
         WHERE l.po_id = p_po_id;

        -- A PO without lines would become RECEIVED and add no stock at all.
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'PO ' || p_po_id || ' has no lines');
        END IF;

        UPDATE purchase_orders
           SET status = 'RECEIVED'
         WHERE po_id = p_po_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'PO ' || p_po_id || ' does not exist');
    END receive_po;

    PROCEDURE issue_stock (p_item_id IN items.item_id%TYPE,
                           p_qty     IN NUMBER,
                           p_reason  IN VARCHAR2 DEFAULT NULL) IS
        v_on_hand items.quantity_on_hand%TYPE;
    BEGIN
        -- A movement of zero or a negative quantity makes no sense; stop early.
        IF p_qty IS NULL OR p_qty <= 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Quantity must be greater than zero');
        END IF;

        -- FOR UPDATE locks the item row, so a second session cannot take the
        -- same stock while this issue is running.
        SELECT quantity_on_hand
          INTO v_on_hand
          FROM items
         WHERE item_id = p_item_id
           FOR UPDATE;

        -- Business rule: never let the stock go below zero. The CHECK constraint
        -- on items is the last line of defence, this is the friendly error.
        IF v_on_hand < p_qty THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Not enough stock for item ' || p_item_id ||
                ': on hand ' || v_on_hand || ', requested ' || p_qty);
        END IF;

        -- Only the movement is inserted here; the trigger updates the stock.
        INSERT INTO stock_movements (item_id, movement_type, quantity, movement_date, reason)
        VALUES (p_item_id, 'OUT', p_qty, SYSDATE, p_reason);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'Item ' || p_item_id || ' does not exist');
    END issue_stock;

    FUNCTION get_stock (p_item_id IN items.item_id%TYPE) RETURN NUMBER IS
        v_on_hand items.quantity_on_hand%TYPE;
    BEGIN
        SELECT quantity_on_hand
          INTO v_on_hand
          FROM items
         WHERE item_id = p_item_id;

        RETURN v_on_hand;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Unknown item: there is no stock to report. Returning NULL keeps the
            -- function usable in a SELECT, and callers can test IS NULL.
            RETURN NULL;
    END get_stock;

END inventory_pkg;
/
