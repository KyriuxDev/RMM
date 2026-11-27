-- Fase 0: una alerta ya no necesita umbral (multiplicidad 0..1 del modelo).
-- Las alertas de desconexión y de seguridad (HU-4) no vienen de un umbral.
-- Cada integrante debe correrlo UNA vez en su base local.

-- PostgreSQL:
ALTER TABLE alerta ALTER COLUMN id_umbral_alerta DROP NOT NULL;

-- MySQL / MariaDB (usar esta en lugar de la de arriba):
-- ALTER TABLE alerta MODIFY id_umbral_alerta INT NULL;
