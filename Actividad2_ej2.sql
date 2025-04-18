-- ===============================================================
-- Actividad 2 - Pregunta 2 (UOC - Bases de Datos para DWH)
-- Consultas SQL para recuperar información de la BBDD creada.
-- Contiene las consultas a los apartados a), b) y c) del enunciado.
-- ===============================================================
-- -----------------------------------------------
-- Script para la Pregunta 2 - Actividad 2
-- -----------------------------------------------

-- a) Eventos del 4 de marzo de 2025 con aforo >= 20 y no en “Auditorium”
SELECT 
    event_id, 
    name, 
    event_date, 
    max_guest_count, 
    event_location
FROM erp.tb_event
WHERE 
    event_date = '2025-03-04'
    AND max_guest_count >= 20
    AND event_location <> 'Auditorium'
ORDER BY name;

-- b) Invitados cuyo tipo es VIP, Government & Regulatory Officials o Media & Press, excluyendo teléfonos que comienzan por +34
SELECT 
    g.guest_id,
    g.name,
    g.email,
    g.phone_number,
    gt.name AS guest_type
FROM erp.tb_guest g
JOIN erp.tb_guest_type gt ON g.guest_type_id = gt.guest_type_id
WHERE 
    gt.name IN ('VIP Guests', 'Government & Regulatory Officials', 'Media & Press')
    AND g.phone_number NOT LIKE '+34%'
ORDER BY g.name;

-- c) Invitados al evento "CEO gala dinner" sin confirmación o con confirmación nula
SELECT 
    g.name AS guest_name,
    e.name AS event_name,
    g.phone_number,
    eg.confirmed
FROM erp.tb_event_guest eg
JOIN erp.tb_guest g ON eg.guest_id = g.guest_id
JOIN erp.tb_event e ON eg.event_id = e.event_id
WHERE 
    e.name = 'CEO gala dinner'
    AND (eg.confirmed IS NULL OR eg.confirmed <> 'S');

-- d) Invitados al "Opening party" que no han asistido
SELECT 
    g.name,
    g.email
FROM erp.tb_event_guest eg
JOIN erp.tb_guest g ON eg.guest_id = g.guest_id
JOIN erp.tb_event e ON eg.event_id = e.event_id
WHERE 
    e.name = 'Opening party'
    AND NOT EXISTS (
        SELECT 1
        FROM erp.tb_access_log al
        WHERE 
            al.event_id = eg.event_id
            AND al.guest_id = eg.guest_id
    );

-- e) Invitados registrados en menos de 2 eventos (incluye los que no tienen ninguno)
SELECT 
    g.guest_id,
    g.name,
    g.email,
    COUNT(eg.event_id) AS total_events
FROM erp.tb_guest g
LEFT JOIN erp.tb_event_guest eg ON g.guest_id = eg.guest_id
GROUP BY g.guest_id, g.name, g.email
HAVING COUNT(eg.event_id) < 2
ORDER BY total_events DESC;
