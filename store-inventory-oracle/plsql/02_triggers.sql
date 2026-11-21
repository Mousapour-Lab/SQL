-- 02_triggers.sql
-- Two small row triggers. They protect the two columns that are calculated
-- rather than typed: items.quantity_on_hand and items.updated_at.
--
-- Why triggers and not package code: someone will always insert a movement
-- directly from SQL Workshop or from a data import. A trigger follows the data,
-- whatever wrote it.

-- Stock is the sum of the movements, so an inserted movement moves the stock.
CREATE OR REPLACE TRIGGER trg_movements_ai
AFTER INSERT ON stock_movements
FOR EACH ROW
BEGIN
    IF :NEW.movement_type = 'IN' THEN
        UPDATE items
           SET quantity_on_hand = quantity_on_hand + :NEW.quantity
         WHERE item_id = :NEW.item_id;
    ELSE
        -- An OUT bigger than the stock would break ck_items_qty; Oracle then
        -- rejects the whole INSERT, so the movement is not recorded either.
        UPDATE items
           SET quantity_on_hand = quantity_on_hand - :NEW.quantity
         WHERE item_id = :NEW.item_id;
    END IF;
END;
/

-- updated_at is bookkeeping, so nobody should have to remember to set it.
-- :NEW is the row as it will be stored; changing it here changes what is saved.
CREATE OR REPLACE TRIGGER trg_items_biu
BEFORE INSERT OR UPDATE ON items
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/

-- TODO(owner): add an audit trigger on items that writes the old and the new
-- unit_price to a small audit table whenever the price changes.
