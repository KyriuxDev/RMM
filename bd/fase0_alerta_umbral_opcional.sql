-- Fase 0: una alerta ya no necesita umbral (multiplicidad 0..1 del modelo).
-- Las alertas de desconexión y de seguridad (HU-4) no vienen de un umbral.
-- Cada integrante debe correrlo UNA vez en su base local (MySQL).

USE rmm;

-- El tipo debe ser EXACTAMENTE el de umbral_alerta.id_umbral_alerta (INT UNSIGNED);
-- con INT a secas MySQL da el error 3780 por la llave foránea fk_alerta_umbral.
ALTER TABLE alerta MODIFY id_umbral_alerta INT UNSIGNED NULL;

-- Comprobación: IS_NULLABLE debe decir YES
SELECT COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'rmm' AND TABLE_NAME = 'alerta' AND COLUMN_NAME = 'id_umbral_alerta';
