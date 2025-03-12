#Proceso de migración de base de datos de Excel a un servidor MySQL
En este repositorio tendra los pasos detallados de como migrar una base de datos con un volumen enorme de datos a un servidor MySQL, explicando también los conflictos que se presentaron en el proceso y como se solucionaron.

##PROCEDIMIENTO

### I. Normalización y diseño de esquema

Primero se realizó una verificación de los registros del excel así como la estructura de las tablas para comprobar si cumple con las 3 reglas formales (3FN) de la normalización de una base de datos. En el proceso se eliminaron columnas redundantes cuyos campos en su mayoría estaban incompletos. Se verificó que se cumpliera la regla de la atomicidad para cada uno de los registros haciendo uso de Apps Script para filtrar la data y encontrar registros que tuvieran listas y no fueran atómicos. Después, se diseñó el esquema de la base de datos con sus distintas tablas y relaciones. Una vez más verifiqué que mi esquema definido cumpla con las 3FN para proceder con la migración. Al seguir mi esquema, separé las columnas en hojas diferentes. Posteriormente cada hoja individual se exportó a CSV en formato UTF-8.

### II. Creación de la base de datos en MySQL

Después de tener todos los datos en formato CSV, procedí a crear la base de datos en el servidor MySQL siguiendo la estructura de las tablas y las relaciones del archivo Excel (mismo que se realizó en base al esquema). Primero se crearon las tablas que no dependen de ninguna otra tabla, es decir, que ninguno de sus atributos es una llave foranea para relacionarse con otra tabla (actividades, municipio y contacto_empresa). Después se creó la tabla ubicacion_empresa porque esta si tiene una llave foranea que referencía a la tabla municipio. Finalmente se creó la tabla de empresa porque es la que tiene relación con actividades, ubicación_empresa y contacto_empresa. En el repositorio puedes ver el script inegi_buzo.sql, el cual crea y diseña estas tablas con las relaciones mencionadas.

### III. Migración de los datos en los archivos CSV a la base de datos

Para no tener problemas al momento de insertar datos en las tablas, se comienza insertando los datos en las tablas que no tienen dependencia de otras tablas, porque de ser así, nos va a arrojar un error en la consola cuando insertemos los datos en una tabla, pues no va a existir la primary key en las otras tablas para relacionarse. Así que migramos primero los datos de la tabla actividades, después municipio, después contacto_empresa, posteriormnete ubicacion_empresa y al último la migración de la tabla empresa.
####Ejemplo de inserción para cada columna

```bash
LOAD DATA INFILE '/ruta/del/csv/archivo.csv'
INTO TABLE tabla_correspondiente
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
```

Hola
