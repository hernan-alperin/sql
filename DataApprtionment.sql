create table visor.centroides as
select nombre, st_centroid(the_geom), estilo_id, link, fuente_id, toponimo_id
from pais_x_radio
;

alter table visor.centroides add column varones numeric;
alter table visor.centroides add column mujeres numeric;
alter table visor.centroides add column total numeric;
alter table visor.centroides add column hogares numeric;
alter table visor.centroides add column viviendas numeric;

update visor.centroides
set
  varones=varon,
  mujeres=mujer,
  total=data.total,
  hogares=data.hogares,
  viviendas=viv_part_hab
from censo2010.data
where codigo=link
;

update visor.centroides
set st_centroid=transform(st_centroid,4326)
;

--- 1st version using within (but some points don't get included)

select
  grupo, tipo,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides
join visor.climas
on st_within(centroides.st_centroid,climas.the_geom)
group by grupo, tipo
order by grupo, tipo
;

--- so we get them listed

select distinct link,
  varones, mujeres, total,
  hogares, viviendas
from visor.centroides
join (select st_union(climas.the_geom) from visor.climas) as todo_climas
on not st_within(centroides.st_centroid,st_union)  
;

--- 2nd versioncreate table visor.centroides_climas_distancias as
select distinct link, grupo, tipo, st_distance(the_geom,st_centroid),
  varones, mujeres, total,
  hogares, viviendas
from visor.centroides
join visor.climas
on true
order by link, grupo, tipo, st_distance(the_geom,st_centroid)
;

create table visor.centroides_climas as
select *
from visor.centroides_climas_distancias
natural join (
  select link, min(st_distance) as st_distance
  from visor.centroides_climas_distancias
  group by link
  ) as minimos
order by st_distance desc
;

create table visor.climas_DataApportionment as
select
  grupo, tipo,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_climas
group by grupo, tipo
order by grupo, tipo
;

select * from visor.centroides_climas
where st_distance>0
order by grupo, tipo, link
;


--- finally the table

select grupo, tipo, 
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total, 
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_climas
group by grupo, tipo
union
select 'Total', '',
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total, 
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_climas
order by grupo, tipo
;

/*
  grupo   |                      tipo                      | varones  | mujeres  |  total   | hogares  | viviendas 
----------+------------------------------------------------+----------+----------+----------+----------+-----------
 Árido    | Andino Puneño                                  |    18028 |    14241 |    32269 |     7178 |      6423
 Árido    | de Sierras y Bolsones                          |  1328256 |  1391974 |  2720230 |   742472 |    686357
 Árido    | Patagónico                                     |   298977 |   291066 |   590043 |   180481 |    169182
 Árido    | Semiárido                                      |   635491 |   651121 |  1286612 |   391812 |    370657
 Cálido   | Subtropical sin Estación Seca                  |  1649824 |  1705744 |  3355568 |   921439 |    865333
 Cálido   | Tropical con Estación Seca                     |   978038 |   978912 |  1956950 |   508153 |    471326
 Cálido   | Tropical Serrano                               |  1533099 |  1604924 |  3138023 |   796440 |    715224
 Frío     | Húmedo de la Cordilleras Patagónica y Fueguina |   156370 |   156045 |   312415 |    96869 |     91781
 Frío     | Magallánico                                    |    91769 |    88508 |   180277 |    54285 |     50638
 Frío     | Nival                                          |    27853 |    26939 |    54792 |    16806 |     15883
 Templado | de Transición                                  |   168666 |   172846 |   341512 |   102994 |     96089
 Templado | Oceánico                                       |   419695 |   453808 |   873503 |   294964 |    283145
 Templado | Pampeano                                       | 11545034 | 12342846 | 23887880 |  7645160 |   7106402
 Templado | Serrano                                        |   671408 |   713183 |  1384591 |   412156 |    388641
 Total    |                                                | 19522508 | 20592157 | 40114665 | 12171209 |  11317081
*/

