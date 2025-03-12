CREATE DATABASE IF NOT EXISTS inegi_buzo;
USE inegi_buzo;

CREATE TABLE actividades (
    id_actividad INT PRIMARY KEY,
    descripcion_actividad VARCHAR(255) NOT NULL
);

CREATE TABLE municipio (
    id_municipio INT PRIMARY KEY,
    nombre_municipio VARCHAR(255) NOT NULL
);

CREATE TABLE contacto_empresa (
    id_contacto_empresa INT AUTO_INCREMENT PRIMARY KEY,
    telefono_empresa JSON NOT NULL,
    correo_empresa JSON NOT NULL,
    web_empresa JSON NOT NULL
);

CREATE TABLE ubicacion_empresa (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    tipo_vialidad_ubicacion VARCHAR(100),
    numero_exterior_ubicacion VARCHAR(10),
    numero_interior_ubicacion VARCHAR(10),
    id_municipio INT,
    codigo_postal_ubicacion VARCHAR(10),
    tipo_asentamiento_ubicacion VARCHAR(100),
    nombre_asentamiento_ubicacion VARCHAR(255),
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    FOREIGN KEY (id_municipio) REFERENCES municipio(id_municipio) ON DELETE SET NULL
);

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY,
    nombre_empresa VARCHAR(255) NOT NULL,
    razon_social_empresa VARCHAR(255),
    codigo_actividad_empresa INT,
    id_ubicacion INT,
    fecha_alta_empresa DATE NOT NULL,
    id_contacto_empresa INT,
    FOREIGN KEY (codigo_actividad_empresa) REFERENCES actividades(id_actividad) ON DELETE SET NULL,
    FOREIGN KEY (id_ubicacion) REFERENCES ubicacion_empresa(id_ubicacion) ON DELETE SET NULL,
    FOREIGN KEY (id_contacto_empresa) REFERENCES contacto_empresa(id_contacto_empresa) ON DELETE SET NULL
);
