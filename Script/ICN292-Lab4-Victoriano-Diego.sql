-- ---------- ENTREGABLE 1: CREACIÓN DE LA BASE ----------
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT,
    nombre   VARCHAR(80) NOT NULL,
    pais     VARCHAR(60),
    genero   ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

CREATE TABLE colecciones (
    id_coleccion      INT AUTO_INCREMENT,
    titulo            VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

CREATE TABLE libros (
    id_libro            INT AUTO_INCREMENT,
    id_autor            INT,
    id_coleccion        INT,
    titulo              VARCHAR(120) NOT NULL,
    paginas             INT,
    ejemplares_vendidos INT,
    anio                INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

CREATE TABLE pagos (
    id_pago    INT AUTO_INCREMENT,
    id_autor   INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

-- ---------- CARGA OFICIAL ----------
INSERT INTO autores (nombre, pais, genero) VALUES
('Elena Pizarro',     'Chile',          'Novela'),
('Harold Finch',      'Inglaterra',     'Ensayo'),
('Rodrigo Bahamonde', 'Chile',          'Poesía'),
('Valentina Correa',  'Argentina',      'Infantil'),
('Nora Keller',       'Estados Unidos', 'Novela'),
('Kenji Arakawa',      NULL,            'Cómic');

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
(1, 'Cielo de Enero',      210, 1500, 2024),
(1, 'Marea Baja',          185,  800, 2023),
(1, 'El Norte',            200, 2200, 2024),
(2, 'Estrellas que Caen',  240, 3000, 2022),
(2, 'Máquinas',            215,  450, 2024),
(3, 'Luz Artificial',      300, 1200, 2024),
(3, 'Ruido Blanco',        280,  600, 2023),
(4, 'El Barrio de Lila',   190, 5000, 2024),
(4, 'Antes del Amanecer',  205, 2700, 2024),
(4, 'La Calle 8',          175,  900, 2023),
(5, 'Flor de Hierro',      195, 4100, 2024),
(5, 'Hora Dorada',         220, 1800, 2022);

-- ---------- ENTREGABLE 2: CONSULTAS ----------

-- Consulta 1: autores cuyo país no es Chile (incluye país vacío)
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2: libros con 190 a 220 páginas (ambos incluidos)
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas ASC;

-- Consulta 3: resumen del catálogo en una fila
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares
FROM libros;

-- Consulta 4: géneros distintos en orden alfabético
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- Consulta 5: autores con más de un libro publicado en 2024
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores a
JOIN libros l ON a.id_autor = l.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6: libros de 2024 con más de 2000 ejemplares, top 3
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- Consulta 7: insertar y eliminar 'Papel Mojado' 
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

SELECT * FROM libros WHERE titulo = 'Papel Mojado';   

DELETE FROM libros WHERE titulo = 'Papel Mojado';

SELECT * FROM libros WHERE titulo = 'Papel Mojado';  

-- Consulta 8: sumar 100 ejemplares a 'Cielo de Enero'
SELECT titulo, ejemplares_vendidos
FROM libros WHERE titulo = 'Cielo de Enero';          

UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

SELECT titulo, ejemplares_vendidos
FROM libros WHERE titulo = 'Cielo de Enero';  

-- ---------- DATOS DE PRUEBA (consultas 9 y 10) ----------
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
('Clásicos Australes', '2024-03-01'),
('Lecturas del Sur',   '2024-08-15');

UPDATE libros SET id_coleccion = 1 WHERE id_libro BETWEEN 1 AND 7;
UPDATE libros SET id_coleccion = 2 WHERE id_libro BETWEEN 8 AND 12;

INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
(1, '2024-03-31', 1250000.50),
(1, '2024-09-30',  980000.00),
(4, '2024-06-30', 2100000.75),
(5, '2024-06-30', 1750000.00);

-- Consulta 9: libro, colección y fecha de publicación de la colección
SELECT l.titulo AS titulo_libro,
       c.titulo AS titulo_coleccion,
       c.fecha_publicacion
FROM libros l
JOIN colecciones c ON l.id_coleccion = c.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- Consulta 10 - sentencia 1: pagos hechos a los autores
SELECT a.nombre, p.fecha_pago, p.monto
FROM pagos p
JOIN autores a ON p.id_autor = a.id_autor
ORDER BY p.fecha_pago;

-- Consulta 10 - sentencia 2: total pagado a cada autor
SELECT a.nombre, SUM(p.monto) AS total_pagado
FROM autores a
JOIN pagos p ON a.id_autor = p.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY total_pagado DESC;
