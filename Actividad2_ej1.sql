-- ===============================================================
-- Actividad 2 - Pregunta 1 (UOC - Bases de Datos para DWH)
-- Creación del esquema `erp` y de las tablas necesarias:
-- tb_guest_type, tb_guest, tb_event, tb_event_guest, tb_access_log
-- Incluye estructura, claves primarias y foráneas según enunciado.
-- ===============================================================
-- -----------------------------------------------
-- Script para la Pregunta 1 - Actividad 2
-- -----------------------------------------------

-- Crear la base de datos (comentado)
-- CREATE DATABASE dbdw_pec2;
-- Comentario: Aquí se define la creación de la base de datos `dbdw_pec2`, pero está comentada. 
-- Esto implica que la base de datos debe ser creada previamente o ya existe.

-- Crear esquema
CREATE SCHEMA IF NOT EXISTS erp;
-- Comentario: Se crea un esquema llamado `erp` si no existe. Esto organiza las tablas dentro de un espacio lógico.

-- Eliminar tablas si existen (en orden por dependencias)
DROP TABLE IF EXISTS erp.tb_access_log;
DROP TABLE IF EXISTS erp.tb_event_guest;
DROP TABLE IF EXISTS erp.tb_event;
DROP TABLE IF EXISTS erp.tb_guest;
DROP TABLE IF EXISTS erp.tb_guest_type;
-- Comentario: Se eliminan las tablas en un orden específico para evitar conflictos de dependencias.
-- Por ejemplo, `tb_access_log` depende de `tb_event` y `tb_guest`, por lo que se elimina primero.

-- Crear tabla tb_guest_type
CREATE TABLE erp.tb_guest_type (
    guest_type_id CHAR(3) PRIMARY KEY,
    name VARCHAR(40) NOT NULL
);
-- Comentario: Se crea la tabla `tb_guest_type` que almacena los tipos de invitados.
-- `guest_type_id` es la clave primaria y tiene un tamaño fijo de 3 caracteres.
-- `name` es un campo obligatorio que almacena el nombre del tipo de invitado.

-- Crear tabla tb_guest
CREATE TABLE erp.tb_guest (
    guest_id INTEGER PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL UNIQUE,
    phone_number VARCHAR(40) NOT NULL,
    date_of_birth DATE,
    guest_type_id CHAR(3),
    CONSTRAINT fk_guest_type FOREIGN KEY (guest_type_id) REFERENCES erp.tb_guest_type(guest_type_id)
);
-- Comentario: Se crea la tabla `tb_guest` para almacenar información de los invitados.
-- `guest_id` es la clave primaria.
-- `email` es único para evitar duplicados.
-- `guest_type_id` es una clave foránea que referencia a `tb_guest_type`.

-- Crear tabla tb_event
CREATE TABLE erp.tb_event (
    event_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL CHECK (event_date > '2025-01-01'),
    max_guest_count INTEGER NOT NULL,
    event_location VARCHAR(50) NOT NULL,
    event_parent INTEGER,
    CONSTRAINT fk_event_parent FOREIGN KEY (event_parent) REFERENCES erp.tb_event(event_id)
);
-- Comentario: Se crea la tabla `tb_event` para almacenar información de eventos.
-- `event_id` es la clave primaria.
-- `event_date` tiene una restricción que asegura que la fecha sea posterior al 1 de enero de 2025.
-- `event_parent` es una clave foránea que permite eventos jerárquicos (eventos padres e hijos).

-- Crear tabla tb_event_guest
CREATE TABLE erp.tb_event_guest (
    event_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    confirmed CHAR(1),
    PRIMARY KEY (event_id, guest_id),
    CONSTRAINT fk_event_guest_event FOREIGN KEY (event_id) REFERENCES erp.tb_event(event_id),
    CONSTRAINT fk_event_guest_guest FOREIGN KEY (guest_id) REFERENCES erp.tb_guest(guest_id)
);
-- Comentario: Se crea la tabla `tb_event_guest` para relacionar invitados con eventos.
-- La clave primaria es compuesta por `event_id` y `guest_id`.
-- `confirmed` indica si la asistencia está confirmada (por ejemplo, 'Y' o 'N').
-- Se definen claves foráneas hacia `tb_event` y `tb_guest`.

-- Crear tabla tb_access_log
CREATE TABLE erp.tb_access_log (
    access_log_id INTEGER PRIMARY KEY,
    event_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    access_log_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    access_log_type CHAR(3) NOT NULL CHECK (access_log_type IN ('IN', 'OUT')),
    CONSTRAINT fk_access_event FOREIGN KEY (event_id) REFERENCES erp.tb_event(event_id),
    CONSTRAINT fk_access_guest FOREIGN KEY (guest_id) REFERENCES erp.tb_guest(guest_id)
);
-- Comentario: Se crea la tabla `tb_access_log` para registrar los accesos de los invitados a los eventos.
-- `access_log_id` es la clave primaria.
-- `access_log_date` tiene un valor predeterminado de la fecha y hora actual.
-- `access_log_type` tiene una restricción que solo permite los valores 'IN' (entrada) o 'OUT' (salida).
-- Se definen claves foráneas hacia `tb_event` y `tb_guest`.
