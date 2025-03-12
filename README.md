# Proceso de migración de base de datos de Excel a un servidor MySQL

En este repositorio tendra los pasos detallados de como migrar una base de datos con un volumen enorme de datos a un servidor MySQL, explicando también los conflictos que se presentaron en el proceso y como se solucionaron.

## PROCEDIMIENTO

### I. Normalización y diseño de esquema

Primero se realizó una verificación de los registros del excel así como la estructura de las tablas para comprobar si cumple con las 3 reglas formales (3FN) de la normalización de una base de datos. En el proceso se eliminaron columnas redundantes cuyos campos en su mayoría estaban incompletos. Se verificó que se cumpliera la regla de la atomicidad para cada uno de los registros haciendo uso de Apps Script para filtrar la data y encontrar registros que tuvieran listas y no fueran atómicos. Después, se diseñó el esquema de la base de datos con sus distintas tablas y relaciones. Una vez más verifiqué que mi esquema definido cumpla con las 3FN para proceder con la migración. Al seguir mi esquema, separé las columnas en hojas diferentes. Posteriormente cada hoja individual se exportó a CSV en formato UTF-8.

### II. Creación de la base de datos en MySQL

Después de tener todos los datos en formato CSV, procedí a crear la base de datos en el servidor MySQL siguiendo la estructura de las tablas y las relaciones del archivo Excel (mismo que se realizó en base al esquema). Primero se crearon las tablas que no dependen de ninguna otra tabla, es decir, que ninguno de sus atributos es una llave foranea para relacionarse con otra tabla (actividades, municipio y contacto_empresa). Después se creó la tabla ubicacion_empresa porque esta si tiene una llave foranea que referencía a la tabla municipio. Finalmente se creó la tabla de empresa porque es la que tiene relación con actividades, ubicación_empresa y contacto_empresa. En el repositorio puedes ver el script inegi_buzo.sql, el cual crea y diseña estas tablas con las relaciones mencionadas.

### III. Migración de los datos en los archivos CSV a la base de datos

Para no tener problemas al momento de insertar datos en las tablas, se comienza insertando los datos en las tablas que no tienen dependencia de otras tablas, porque de ser así, nos va a arrojar un error en la consola cuando insertemos los datos en una tabla, pues no va a existir la primary key en las otras tablas para relacionarse. Así que migramos primero los datos de la tabla actividades, después municipio, después contacto_empresa, posteriormnete ubicacion_empresa y al último la migración de la tabla empresa.

#### Ejemplo de inserción para cada columna

```bash
LOAD DATA INFILE '/ruta/del/csv/archivo.csv'
INTO TABLE tabla_correspondiente
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
```

#### Ejemplo de inserción para columna **contacto_empresa**

Este caso es particular, porque las columnas telefono_empresa, correo_empresa y web_emprsa almacenan cada uno un JSON con el objetivo de poder guardar muchos datos en un solo JSON.
Pasamos tal cual el id_contacto_empresa a la tabla, pero creamos 3 variables temporales con
"@", con el objetivo de poder modificarlas ANTES de hacer la inserción en la tabla. Con estas variables temporales, almacenamos el valor original que leemos del CSV antes de transformarlo a JSON.
Posteriormente en el bloque del SET, definimos que cada campo original de la tabla, va a guardar un JSON con una **key** y su **value** será un **arreglo que almacenará cada inserción ya sea de telefono, correo o web**

```bash
LOAD DATA INFILE '/ruta/del/csv/contacto_empresa.csv'
INTO TABLE contacto_empresa
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id_contacto_empresa,
  @telefono_empresa,
  @correo_empresa,
  @web_empresa)
SET
  telefono_empresa = JSON_OBJECT('telefonos', JSON_ARRAY(@telefono_empresa)),
  correo_empresa = JSON_OBJECT('correos', JSON_ARRAY(@correo_empresa)),
  web_empresa = JSON_OBJECT('webs', JSON_ARRAY(@web_empresa));
```

### IV. Prueba de consultas.

Ahora solo verificamos que la migración se haya hecho correctamente con una consulta pequeña como la siguiente. Obtendremos el nombre de todos los negocios que coincidan con la misma actividad económica.

```bash
SELECT nombre_empresa FROM empresa WHERE codigo_actividad_empresa = 115111;
```

# CONFLICTOS PRESENTADOS

## Conflicto al leer data local

Inicialmente tenia los archivos CSV en la misma ruta de la terminal donde me encontraba cuando estaba en mi servidor de MySQL pero me arrojaba un error:
**ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option**
El error se debe a que MySQL cuando está configurado con la opción **--secure-file-priv** limita las rutas por dodne podemos cargar archivos con el comando **LOAD DATA INFILE**. Una forma rápida de solucionarlo sin tener que modificar dicha configuración es mover todos los archivos CSV a la ruta: /var/lib/mysql-files/ . Cuando MySQL está configurado con --secure-file-priv, el servidor solo permite el acceso a archivos que se encuentren en una de las rutas permitidas en dicha configuración, y esa ruta es la ruta de seguridad especificada.

## Conflicto con tabulaciones indeseadas al hacer consultas pequeñas

Otro problema muy grande que tuve, fue cuando ya había migrado todos los datos de todos los archivos CSV. Cuando hacia consultas pequeñas, por alguna razón que desconocía en ese momento se estaban imprimiendo con tabulaciones que deformaban la impresión de los resultados en consola. Revisé muchas veces que los archivos CSV no tuvieran espacios vacios ni tabulaciones adicionales y a su vez, intentaba convertir nuevamente a CSV con el formato UTF-8.
El problema principal es por **como maneja Windows los saltos de linea** a diferencia de Linux, pues mi servidor MySql lo estoy ejecutando en mi entorno WSL y los archivos CSV los convertí desde Windows. Por lo que los saltos de linea estaban escritos como "\r\n" y no "\n"
Entonces cuando cargaba la data de los CSV, en la linea **LINES TERMINATED BY '\r\n'** estaba colocando únicamente **'\n'** en lugar de **'\r\n'**, lo que alteraba la inserción
de los datos por como interpretan estos dos sistemas el salto de linea. La solución fue simplemente colocar que las lineas terminaban en **\r\n ** porque son archivos convertidos desde Windows.
