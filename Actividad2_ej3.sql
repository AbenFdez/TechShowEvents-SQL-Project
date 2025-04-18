-- A) Añadir columna y actualizar valores
ALTER TABLE erp.tb_event
ADD COLUMN catering_cost_guest NUMERIC(6,2) CHECK (catering_cost_guest >= 0);

UPDATE erp.tb_event
SET catering_cost_guest = CASE
    WHEN name = 'Opening party' THEN 73.67
    WHEN name = 'CEO gala dinner' THEN 158.00
    WHEN name = 'Closing party' THEN 73.67
    WHEN name = 'General Entrance Day 1' THEN 8.76
    WHEN name = 'General Entrance Day 2' THEN 8.76
    ELSE NULL
END;

-- B) Insertar evento y asignar invitados
INSERT INTO erp.tb_event (event_id, name, event_date, max_guest_count, event_location, event_parent)
VALUES (16, 'Press Briefing', '2025-03-03', 20, 'Exhibition Hall PII', NULL);

INSERT INTO erp.tb_event_guest (event_id, guest_id, confirmed)
SELECT 16, g.guest_id, NULL
FROM erp.tb_guest g
JOIN erp.tb_guest_type gt ON g.guest_type_id = gt.guest_type_id
WHERE gt.name = 'Media & Press'
  AND g.name <> 'Katie Andrews';

DELETE FROM erp.tb_event_guest
WHERE event_id = 16 AND guest_id IN (
  SELECT guest_id FROM erp.tb_guest WHERE name = 'Katie Andrews'
);

-- C) Crear vista de ocupación
CREATE OR REPLACE VIEW erp.event_occupation AS
SELECT 
    e.name AS event_name,
    e.max_guest_count,
    COUNT(eg.guest_id) AS total_guests,
    ROUND((COUNT(eg.guest_id) * 100.0 / e.max_guest_count), 2) AS occupancy_percent
FROM erp.tb_event e
LEFT JOIN erp.tb_event_guest eg ON e.event_id = eg.event_id
GROUP BY e.event_id, e.name, e.max_guest_count;
