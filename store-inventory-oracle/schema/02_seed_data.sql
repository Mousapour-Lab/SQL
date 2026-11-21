-- 02_seed_data.sql
-- Sample data: 5 suppliers, 15 items, 6 purchase orders, 15 lines and 37 stock movements.
-- Run after 01_create_tables.sql and before the plsql/ scripts.

-- Suppliers. A few columns are NULL on purpose (missing contact details).
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, phone, email, is_active)
VALUES (1, 'Northwind Industrial Supply', 'Alice Moreau', '514-555-0101', 'sales@northwind-supply.example', 'Y');
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, phone, email, is_active)
VALUES (2, 'Pacific Tools Co.', 'Kenji Sato', NULL, 'orders@pacific-tools.example', 'Y');
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, phone, email, is_active)
VALUES (3, 'Metro Fasteners', 'Lucia Fernandes', '514-555-0148', NULL, 'Y');
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, phone, email, is_active)
VALUES (4, 'Atlas Safety Products', 'Peter Novak', NULL, NULL, 'Y');
-- This supplier is no longer active, and we have no contact name for it.
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, phone, email, is_active)
VALUES (5, 'Harbor Electrical', NULL, '450-555-0199', 'info@harbor-electrical.example', 'N');

-- Items. quantity_on_hand below is exactly the net result of the movements
-- further down (IN minus OUT). The trigger is created later, so it does not
-- touch these rows.
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (1, 'SKU-1001', 'Cordless Drill 18V', 1, 129.99, 22, 10, DATE '2026-11-09');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (2, 'SKU-1002', 'Angle Grinder 125mm', 1, 89.50, 9, 8, DATE '2026-11-09');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (3, 'SKU-1003', 'Circular Saw 190mm', 1, 149.00, 5, 5, DATE '2026-11-17');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (4, 'SKU-2001', 'Screwdriver Set 12pc', 2, 24.99, 18, 15, DATE '2026-10-14');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (5, 'SKU-2002', 'Adjustable Wrench 250mm', 2, 18.75, 9, 12, DATE '2026-10-19');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (6, 'SKU-2003', 'Claw Hammer 500g', 2, 12.40, 24, 20, DATE '2026-10-21');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (7, 'SKU-3001', 'Wood Screws 4x40 (box of 200)', 3, 7.95, 100, 40, DATE '2026-10-23');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (8, 'SKU-3002', 'Nails 2.5in (box of 500)', 3, 9.60, 12, 30, DATE '2026-11-18');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (9, 'SKU-3003', 'Bolts M8x60 (box of 100)', 3, 15.20, 25, 25, NULL);
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (10, 'SKU-4001', 'Safety Goggles', 4, 6.80, 48, 50, DATE '2026-11-14');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (11, 'SKU-4002', 'Work Gloves size L', 4, 4.25, 45, 40, DATE '2026-11-02');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (12, 'SKU-4003', 'Ear Plugs (box of 200)', 4, 11.90, 30, 25, DATE '2026-11-16');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (13, 'SKU-5001', 'Extension Cord 10m', 5, 21.50, 4, 10, DATE '2026-11-05');
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (14, 'SKU-5002', 'LED Work Light 30W', 5, 34.90, 9, 8, DATE '2026-11-09');
-- No supplier yet and no stock: a new item nobody has ordered.
INSERT INTO items (item_id, sku, item_name, supplier_id, unit_price, quantity_on_hand, reorder_point, updated_at)
VALUES (15, 'SKU-5003', 'Cable Ties (pack of 100)', NULL, 3.10, 0, 6, NULL);

-- Purchase orders. Two were received, two are still coming, one is a draft.
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (1, 1, DATE '2026-09-10', 'RECEIVED', 'Monthly restock');
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (2, 3, DATE '2026-09-25', 'RECEIVED', NULL);
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (3, 4, DATE '2026-10-12', 'ORDERED', 'Safety items are low');
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (4, 2, DATE '2026-10-26', 'ORDERED', NULL);
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (5, 1, DATE '2026-11-03', 'DRAFT', 'Waiting for budget approval');
INSERT INTO purchase_orders (po_id, supplier_id, order_date, status, notes)
VALUES (6, 5, DATE '2026-11-10', 'CANCELLED', 'Supplier is no longer active');

-- Order lines. Each PO can list an item only once (unique constraint po_id + item_id).
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (1, 1, 1, 10, 119.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (2, 1, 2, 6, 82.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (3, 1, 3, 4, 139.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (4, 2, 7, 100, 6.90);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (5, 2, 8, 80, 8.50);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (6, 2, 9, 50, 13.75);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (7, 3, 11, 120, 3.75);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (8, 3, 12, 40, 10.50);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (9, 4, 4, 20, 21.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (10, 4, 5, 25, 16.40);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (11, 4, 6, 30, 11.20);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (12, 5, 1, 5, 119.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (13, 5, 2, 5, 82.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (14, 6, 13, 20, 19.00);
INSERT INTO purchase_order_lines (line_id, po_id, item_id, quantity, unit_price)
VALUES (15, 6, 14, 10, 31.00);

-- Stock movements, part 1: the opening balance that every item starts from.
-- INSERT ... SELECT with UNION ALL is the usual way to add many rows at once in Oracle.
INSERT INTO stock_movements (item_id, movement_type, quantity, movement_date, reason)
SELECT 1, 'IN', 15, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 2, 'IN', 8, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 3, 'IN', 6, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 4, 'IN', 20, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 5, 'IN', 20, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 6, 'IN', 30, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 7, 'IN', 60, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 8, 'IN', 20, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 9, 'IN', 25, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 10, 'IN', 60, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 11, 'IN', 50, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 12, 'IN', 40, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 13, 'IN', 10, DATE '2026-09-01', 'Opening balance' FROM dual UNION ALL
SELECT 14, 'IN', 12, DATE '2026-09-01', 'Opening balance' FROM dual;

-- Part 2: the goods received from purchase orders 1 and 2.
INSERT INTO stock_movements (item_id, movement_type, quantity, movement_date, reason, po_id)
SELECT 1, 'IN', 10, DATE '2026-09-15', 'Received PO 1', 1 FROM dual UNION ALL
SELECT 2, 'IN', 6, DATE '2026-09-15', 'Received PO 1', 1 FROM dual UNION ALL
SELECT 3, 'IN', 4, DATE '2026-09-15', 'Received PO 1', 1 FROM dual UNION ALL
SELECT 7, 'IN', 100, DATE '2026-09-29', 'Received PO 2', 2 FROM dual UNION ALL
SELECT 8, 'IN', 80, DATE '2026-09-29', 'Received PO 2', 2 FROM dual UNION ALL
SELECT 9, 'IN', 50, DATE '2026-09-29', 'Received PO 2', 2 FROM dual;

-- Part 3: stock that left the warehouse. One row has no reason (NULL); the CAST
-- gives that NULL a type, which keeps the UNION ALL happy.
INSERT INTO stock_movements (item_id, movement_type, quantity, movement_date, reason)
SELECT 1, 'OUT', 3, DATE '2026-10-05', 'Sold at counter' FROM dual UNION ALL
SELECT 2, 'OUT', 5, DATE '2026-10-08', 'Sold at counter' FROM dual UNION ALL
SELECT 3, 'OUT', 2, DATE '2026-10-12', 'Sold at counter' FROM dual UNION ALL
SELECT 4, 'OUT', 2, DATE '2026-10-14', 'Sold at counter' FROM dual UNION ALL
SELECT 5, 'OUT', 11, DATE '2026-10-19', 'Sold at counter' FROM dual UNION ALL
SELECT 6, 'OUT', 6, DATE '2026-10-21', 'Sold at counter' FROM dual UNION ALL
SELECT 7, 'OUT', 60, DATE '2026-10-23', 'Sold to contractor' FROM dual UNION ALL
SELECT 8, 'OUT', 40, DATE '2026-10-27', 'Sold to contractor' FROM dual UNION ALL
SELECT 9, 'OUT', 20, DATE '2026-10-29', 'Sold to contractor' FROM dual UNION ALL
SELECT 11, 'OUT', 5, DATE '2026-11-02', 'Damaged in storage' FROM dual UNION ALL
SELECT 13, 'OUT', 6, DATE '2026-11-05', 'Damaged in storage' FROM dual UNION ALL
SELECT 14, 'OUT', 3, DATE '2026-11-09', CAST(NULL AS VARCHAR2(120)) FROM dual UNION ALL
SELECT 10, 'OUT', 12, DATE '2026-11-14', 'Sold at counter' FROM dual UNION ALL
SELECT 12, 'OUT', 10, DATE '2026-11-16', 'Sold at counter' FROM dual UNION ALL
SELECT 3, 'OUT', 3, DATE '2026-11-17', 'Sold at counter' FROM dual UNION ALL
SELECT 9, 'OUT', 30, DATE '2026-11-17', 'Sold to contractor' FROM dual UNION ALL
SELECT 8, 'OUT', 48, DATE '2026-11-18', 'Sold to contractor' FROM dual;

COMMIT;

-- The ids above were typed by hand, so the identity columns are still at their
-- starting value. Move them past the inserted ids, otherwise a later insert
-- (a new item, a new PO, ...) would collide with an existing id.
-- stock_movements has no hand-typed ids, so it needs no fix.
ALTER TABLE suppliers MODIFY (supplier_id GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE items MODIFY (item_id GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE purchase_orders MODIFY (po_id GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
ALTER TABLE purchase_order_lines MODIFY (line_id GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE));
