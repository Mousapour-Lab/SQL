-- 03_views.sql
-- Views are saved queries. Reports and the owner's future code can read them
-- instead of copying the same SQL in five places.

-- Items that reached their reorder point: the shopping list for the buyer.
CREATE OR REPLACE VIEW v_low_stock AS
SELECT i.item_id,
       i.sku,
       i.item_name,
       i.quantity_on_hand,
       i.reorder_point,
       -- LEFT JOIN keeps items without a supplier, and NVL gives them a label.
       NVL(s.supplier_name, 'No supplier') AS supplier_name
  FROM items i
  LEFT JOIN suppliers s
    ON s.supplier_id = i.supplier_id
 WHERE i.quantity_on_hand <= i.reorder_point;

-- TODO(owner): write a query that lists the items to reorder together with the
-- supplier contact details (supplier name and phone), so the buyer can call them.

-- How much we have ordered per supplier: one row per supplier, even with no POs.
CREATE OR REPLACE VIEW v_po_summary AS
SELECT s.supplier_id,
       s.supplier_name,
       -- DISTINCT counts the PO once, although the join repeats it for every line.
       COUNT(DISTINCT po.po_id) AS po_count,
       -- No lines at all means NULL from SUM; NVL makes it a readable 0.
       NVL(SUM(l.quantity * l.unit_price), 0) AS total_value
  FROM suppliers s
  LEFT JOIN purchase_orders po
    ON po.supplier_id = s.supplier_id
  LEFT JOIN purchase_order_lines l
    ON l.po_id = po.po_id
 GROUP BY s.supplier_id, s.supplier_name;
