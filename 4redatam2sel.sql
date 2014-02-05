set search_path to visor;
/*
sig_20=# \d centroides_climas
           Tabla «visor.centroides_climas»
   Columna   |         Tipo          | Modificadores
-------------+-----------------------+---------------
 link        | character varying     |
 st_distance | double precision      |
 grupo       | character varying(50) |
 tipo        | character varying(50) |
 varones     | numeric               |
 mujeres     | numeric               |
 total       | numeric               |
 hogares     | numeric               |
 viviendas   | numeric               |
*/

select distinct grupo, tipo from centroides_climas order by grupo, tipo;

/*
  grupo   |                      tipo
----------+------------------------------------------------
 Árido    | Andino Puneño
 Árido    | de Sierras y Bolsones
 Árido    | Patagónico
 Árido    | Semiárido
 Cálido   | Subtropical sin Estación Seca
 Cálido   | Tropical con Estación Seca
 Cálido   | Tropical Serrano
 Frío     | Húmedo de la Cordilleras Patagónica y Fueguina
 Frío     | Magallánico
 Frío     | Nival
 Templado | de Transición
 Templado | Oceánico
 Templado | Pampeano
 Templado | Serrano
(14 filas)
*/

select '0104******0'||link from centroides_climas where grupo='Árido' and tipo='Andino Puneño';

