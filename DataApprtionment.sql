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



    
