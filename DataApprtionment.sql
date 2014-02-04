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

------------------------------------------------------
-- sistemas hídricos

create table visor.centroides_sistemas_hidricos_distancias as
select distinct link, sistema_, st_distance(the_geom,st_centroid),
  varones, mujeres, total,
  hogares, viviendas
from visor.centroides
join visor.sistemas_hidricos
on true
order by link, sistema_, st_distance(the_geom,st_centroid)
;

create table visor.centroides_sistemas_hidricos as
select *
from visor.centroides_sistemas_hidricos_distancias
natural join (
  select link, min(st_distance) as st_distance
  from visor.centroides_sistemas_hidricos_distancias
  group by link
  ) as minimos
order by st_distance desc
;

create table visor.sistemas_hidricos_DataApportionment as
select
  sistema_,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_sistemas_hidricos
group by sistema_
order by sistema_
;

select * from visor.centroides_sistemas_hidricos
where st_distance>0
order by sistema_, link
;

select * from visor.sistemas_hidricos_DataApportionment
union
select null,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.sistemas_hidricos_DataApportionment
order by sistema_
;


/*
                                 sistema_                                  | varones  | mujeres  |  total   | hogares  | viviendas 
---------------------------------------------------------------------------+----------+----------+----------+----------+-----------
 Sistema Mar Chiquita                                                      |  2033528 |  2154052 |  4187580 |  1173456 |   1086073
 Sistema Pampeano                                                          |   437799 |   447344 |   885143 |   293852 |    284350
 Sistema Río Colorado                                                      |  1317401 |  1378699 |  2696100 |   753232 |    697022
 Sistema Río de la Plata y Provincia de Buenos Aires hasta el Río Colorado |  8508206 |  9134411 | 17642617 |  5652208 |   5233174
 Sistema Río Paraguay                                                      |   820838 |   837259 |  1658097 |   426244 |    386864
 Sistema Río Paraná                                                        |  4294673 |  4511482 |  8806155 |  2628083 |   2454433
 Sistema Ríos Patagónicos                                                  |   952421 |   955202 |  1907623 |   587835 |    554914
 Sistema Río Uruguay                                                       |   508691 |   514362 |  1023053 |   294116 |    280209
 Sistema Serrano                                                           |   481480 |   493740 |   975220 |   268187 |    253495
 Sistemas Independientes                                                   |   111386 |   109108 |   220494 |    58274 |     53450
 Vertiente Pacífica                                                        |    56451 |    56913 |   113364 |    35949 |     33308
                                                                           | 19522874 | 20592572 | 40115446 | 12171436 |  11317292
sobran 781 = 40115446+2224+190+17 - 40117096
debe haber superposición de sistemas (2+ centroides con distancia 0, o con = distancia)
*/

select * from visor.centroides_sistemas_hidricos
where link in (select link from visor.centroides_sistemas_hidricos group by link having count(*)>1)
;
/* hay un radio con = distancia
   link    |     st_distance     |      sistema_       | varones | mujeres | total | hogares | viviendas 
-----------+---------------------+---------------------+---------+---------+-------+---------+-----------
 540490308 | 0.00969868178751515 | Sistema Río Paraná  |     366 |     415 |   781 |     227 |       211
 540490308 | 0.00969868178751515 | Sistema Río Uruguay |     366 |     415 |   781 |     227 |       211
(2 filas)
hay que decidir a que sistema se asigna:
se decide asignarlo al sistema mayor

*/
delete from visor.centroides_sistemas_hidricos
where link='540490308' and sistema_='Sistema Río Uruguay'
;
-- recalcular
drop table visor.sistemas_hidricos_DataApportionment;
create table visor.sistemas_hidricos_DataApportionment as
select
  sistema_,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_sistemas_hidricos
group by sistema_
order by sistema_
;

-----------------------------------------
-- Cuencas

select * from visor.cuencas_DataApportionment
union
select null, null,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.cuencas_DataApportionment
order by sistema, nombre
;

/*

                                  sistema                                  |                                           nombre                                           | varones  | mujeres  |  total   | hogares  | viviendas
---------------------------------------------------------------------------+--------------------------------------------------------------------------------------------+----------+----------+----------+----------+-----------
 SISTEMA MAR CHIQUITA                                                      | CUENCA DE LOS RIOS PRIMERO Y SEGUNDO                                                       |   988207 |  1063023 |  2051230 |   628280 |    588105
 SISTEMA MAR CHIQUITA                                                      | CUENCA DE LOS RIOS ROSARIO U HORCONES Y URUEÑA                                             |    46436 |    44817 |    91253 |    23202 |     20009
 SISTEMA MAR CHIQUITA                                                      | CUENCA DEL RIO SALI-DULCE                                                                  |   998885 |  1046212 |  2045097 |   521974 |    477959
 SISTEMA PAMPEANO                                                          | CUENCA DEL RIO QUINTO Y ARROYOS MENORES DE SAN LUIS                                        |   127024 |   128873 |   255897 |    79252 |     75517
 SISTEMA PAMPEANO                                                          | REGION LAGUNERA DEL SO DE BUENOS AIRES                                                     |    64952 |    67272 |   132224 |    47415 |     46425
 SISTEMA PAMPEANO                                                          | REGION SIN DRENAJE SUPERFICIAL DE SAN LUIS, CORDOBA, LA PAMPA Y BUENOS AIRES               |   245823 |   251199 |   497022 |   167185 |    162408
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO ATUEL                                                                       |    37396 |    38362 |    75758 |    22735 |     21744
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO COLORADO                                                                    |    42460 |    39612 |    82072 |    24963 |     23782
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO DESAGUADERO Y AREAS VECINAS SIN DRENAJE DEFINIDO                            |   127121 |   129551 |   256672 |    73538 |     67641
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO DIAMANTE                                                                    |    70091 |    76544 |   146635 |    44817 |     43060
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO JACHAL                                                                      |    16716 |    14113 |    30829 |     7118 |      6676
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO MENDOZA                                                                     |   564044 |   600688 |  1164732 |   329790 |    303515
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO SAN JUAN                                                                    |   307819 |   325694 |   633513 |   165890 |    151615
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO TUNUYAN                                                                     |   143760 |   146517 |   290277 |    80131 |     74875
 SISTEMA RIO COLORADO                                                      | CUENCA DEL RIO VINCHINA - BERMEJO                                                          |     7994 |     7618 |    15612 |     4250 |      4114
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCA DE ARROYOS DEL SE DE BUENOS AIRES                                                   |   319778 |   348882 |   668660 |   227174 |    217571
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCA DE DESAGUE AL RIO DE LA PLATA AL S DEL RIO SAMBOROMBON                              |  5065064 |  5524774 | 10589838 |  3466118 |   3180453
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCA DEL RIO SALADO DE BUENOS AIRES                                                      |   416731 |   436760 |   853491 |   288771 |    278216
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCAS DE ARROYOS DEL NE DE BUENOS AIRES                                                  |  2088700 |  2173993 |  4262693 |  1239363 |   1139569
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCAS Y ARROYOS DEL S DE BUENOS AIRES                                                    |   343287 |   364539 |   707826 |   241142 |    233627
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | REGION DE MEDANOS COSTEROS SIN DRENAJE DEFINIDO DEL E DE BUENOS AIRES                      |    37522 |    38927 |    76449 |    27228 |     26459
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | RIOS Y ARROYOS MENORES CON VERTIENTE ATLANTICA ENTRE EL SO DE BUENOS AIRES Y EL RIO CHUBUT |    17031 |    15876 |    32907 |    11173 |     10911
 SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | ZONA DE CANALES AL S DEL RIO SALADO DE BUENOS AIRES                                        |   220490 |   231122 |   451612 |   151502 |    146628
 SISTEMA RIO PARAGUAY                                                      | CUENCA DEL RIO BERMEJO MEDIO E INFERIOR                                                    |   125351 |   121088 |   246439 |    64257 |     60598
 SISTEMA RIO PARAGUAY                                                      | CUENCA DEL RIO BERMEJO SUPERIOR                                                            |    74311 |    74576 |   148887 |    34399 |     31474
 SISTEMA RIO PARAGUAY                                                      | CUENCA DEL RIO SAN FRANSISCO                                                               |   368728 |   382946 |   751674 |   193824 |    171889
 SISTEMA RIO PARAGUAY                                                      | CUENCA PROPIA DEL RIO PARAGUAY EN ARGENTINA                                                |     8031 |     7944 |    15975 |     4415 |      4096
 SISTEMA RIO PARAGUAY                                                      | PARTE ARGENTINA DE LA CUENCA DEL RIO PILCOMAYO                                             |    65446 |    65240 |   130686 |    33041 |     30625
 SISTEMA RIO PARAGUAY                                                      | ZONA DE RIOS Y ARROYOS EN SALTA Y FORMOSA AFLUENTES DEL RIO PARAGUAY                       |   178971 |   185465 |   364436 |    96308 |     88182
 SISTEMA RIO PARANA                                                        | ALTA CUENCA DEL RIO JURAMENTO                                                              |   311616 |   331795 |   643411 |   161986 |    142094
 SISTEMA RIO PARANA                                                        | CUENCA DE ARROYOS DEL SE DE SANTA FE Y N DE BUENOS AIRES                                   |   624589 |   660861 |  1285450 |   402612 |    366005
 SISTEMA RIO PARANA                                                        | CUENCA DE ARROYOS DE MISIONES SOBRE EL RIO PARANA HASTA POSADAS                            |   295096 |   298152 |   593248 |   161402 |    154219
 SISTEMA RIO PARANA                                                        | CUENCA DEL ARROYO COLASTINE, CORRALITO Y OTROS                                             |   114146 |   118605 |   232751 |    76128 |     73105
 SISTEMA RIO PARANA                                                        | CUENCA DEL ARROYO SALADILLO Y AFLUENTES MENORES DEL RIO SAN JAVIER                         |   226619 |   247452 |   474071 |   150564 |    140791
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO ARRECIFES                                                                   |   121308 |   130713 |   252021 |    83096 |     80255
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO CARCARAÑA                                                                   |   427720 |   447899 |   875619 |   289175 |    280130
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO CORRIENTES                                                                  |    89385 |    92610 |   181995 |    48225 |     45853
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO FELICIANO                                                                   |    12870 |    12418 |    25288 |     6783 |      6550
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO GUALEGUAY                                                                   |    93264 |    96699 |   189963 |    58086 |     55834
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO GUAYQUIRARO                                                                 |     9956 |     9546 |    19502 |     5314 |      5192
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO NOGOYA                                                                      |    20734 |    21649 |    42383 |    13354 |     13002
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO PASAJE O SALADO                                                             |   374998 |   380575 |   755573 |   218371 |    203298
 SISTEMA RIO PARANA                                                        | CUENCA DEL RIO SANTA LUCIA                                                                 |   226685 |   240427 |   467112 |   123783 |    113505
 SISTEMA RIO PARANA                                                        | CUENCA PROPIA DE LOS BAJOS SUBMERIDIONALES                                                 |   121216 |   120503 |   241719 |    66149 |     62102
 SISTEMA RIO PARANA                                                        | CUENCA PROPIA DEL PARANA MEDIO                                                             |   251036 |   269237 |   520273 |   155243 |    145576
 SISTEMA RIO PARANA                                                        | CUENCA PROPIA DEL RIO PARANA HASTA CONFLUENCIA                                             |   107275 |   116688 |   223963 |    66125 |     62614
 SISTEMA RIO PARANA                                                        | DELTA DEL PARANA                                                                           |   393992 |   429632 |   823624 |   279573 |    260413
 SISTEMA RIO PARANA                                                        | PARTE ARGENTINA DE LA CUENCA DEL RIO IGUAZU                                                |    17638 |    16619 |    34257 |     8513 |      8240
 SISTEMA RIO PARANA                                                        | ZONA SIN RIOS NI ARROYOS DE IMPORTANCIA EN SALTA, CHACO, SANTA FE Y SANTIAGO DEL ESTERO    |   454530 |   469402 |   923932 |   253601 |    235655
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DE LOS RIOS GALLEGOS Y CHICO                                                        |    56689 |    55660 |   112349 |    33476 |     31419
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DE LOS RIOS SENGUERR Y CHICO                                                        |    12006 |    10208 |    22214 |     6721 |      6330
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO CHICO                                                                       |     2915 |     2184 |     5099 |     1425 |      1368
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO CHUBUT                                                                      |    76951 |    78594 |   155545 |    49008 |     46629
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO COILE O COIG                                                                |      453 |       87 |      540 |      235 |       210
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO DESEADO                                                                     |    10397 |     9297 |    19694 |     5842 |      5360
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO LIMAY                                                                       |   227510 |   233881 |   461391 |   143480 |    134731
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO NEGRO                                                                       |   190071 |   196439 |   386510 |   120584 |    115586
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO NEUQUEN                                                                     |    98881 |    99435 |   198316 |    60802 |     57698
 SISTEMA RIOS PATAGONICOS                                                  | CUENCA DEL RIO SANTA CRUZ                                                                  |    12817 |    12061 |    24878 |     7333 |      6869
 SISTEMA RIOS PATAGONICOS                                                  | CUENCAS VARIAS DE TIERRA DEL FUEGO                                                         |    63420 |    60465 |   123885 |    38035 |     35831
 SISTEMA RIOS PATAGONICOS                                                  | RIOS Y ARROYOS MENORES CON VERTIENTE ATLANTICA ENTRE EL SO DE BUENOS AIRES Y EL RIO CHUBUT |    61362 |    60545 |   121907 |    37270 |     35314
 SISTEMA RIOS PATAGONICOS                                                  | ZONA DE RIOS Y ARROYOS MENORES CON VERTIENTE ATLANTICA DEL SE DE CHUBUT Y E DE SANTA CRUZ  |   138949 |   136346 |   275295 |    83624 |     77569
 SISTEMA RIO URUGUAY                                                       | CUENCA DE ARROYOS MENORES DE ENTRE RIOS AFLUENTES DEL RIO URUGUAY                          |   115569 |   114917 |   230486 |    66584 |     62728
 SISTEMA RIO URUGUAY                                                       | CUENCA DEL RIO AGUAPEY                                                                     |    18902 |    18282 |    37184 |     9568 |      8924
 SISTEMA RIO URUGUAY                                                       | CUENCA DEL RIO GUALEGUAYCHU                                                                |    62220 |    65067 |   127287 |    40334 |     38755
 SISTEMA RIO URUGUAY                                                       | CUENCA DEL RIO MIRIÑAY                                                                     |    19343 |    20264 |    39607 |    11240 |     10678
 SISTEMA RIO URUGUAY                                                       | CUENCA DEL RIO MOCORETA                                                                    |    20438 |    20192 |    40630 |    11975 |     11469
 SISTEMA RIO URUGUAY                                                       | CUENCA PROPIA DEL RIO PEPIRI-GUAZU EN ARGENTINA                                            |     3578 |     3715 |     7293 |     1978 |      1884
 SISTEMA RIO URUGUAY                                                       | CUENCA PROPIA DEL RIO URUGUAY EN ARGENTINA                                                 |    93296 |   100020 |   193316 |    59098 |     56028
 SISTEMA RIO URUGUAY                                                       | CUENCAS DE AROYOS DE MISIONES AFLUENTES DEL RIO URUGUAY                                    |   134591 |   129671 |   264262 |    70397 |     68440
 SISTEMA RIO URUGUAY                                                       | CUENCAS DE ARROYOS MENORES DE CORRIENTES AFLUENTES DEL RIO URUGUAY                         |    11011 |    11267 |    22278 |     6443 |      6217
 SISTEMA RIO URUGUAY                                                       | CUENCAS MENORES DE CORRIENTES AFLUENTES DEL RIO URUGUAY                                    |    29743 |    30967 |    60710 |    16499 |     15086
 SISTEMA SERRANO                                                           | CUENCA DE LA FALDA ORIENTAL DE AMBATO                                                      |   107933 |   113553 |   221486 |    57705 |     53260
 SISTEMA SERRANO                                                           | CUENCA DEL RIO ABAUCAN                                                                     |   117192 |   120705 |   237897 |    64749 |     60966
 SISTEMA SERRANO                                                           | CUENCA DEL SALAR DE PIPANACO                                                               |    24992 |    24253 |    49245 |    12428 |     11655
 SISTEMA SERRANO                                                           | CUENCA DE PAMPA DE LAS SALINAS                                                             |    13050 |    12539 |    25589 |     7093 |      6843
 SISTEMA SERRANO                                                           | CUENCAS DE RIO CONLARA Y DE ARROYOS MENORES DEL N DE SAN LUIS Y O DE CORDOBA               |    86883 |    88889 |   175772 |    52086 |     49630
 SISTEMA SERRANO                                                           | CUENCAS VARIAS DE LAS SALINAS GRANDES                                                      |    96026 |    98134 |   194160 |    54915 |     52738
 SISTEMA SERRANO                                                           | CUENCA VARIAS DE VELAZCO                                                                   |    35404 |    35667 |    71071 |    19211 |     18403
 SISTEMAS INDEPENDIENTES                                                   | CUENCA DE LA LAGUNA DE LLANCANELO                                                          |    11829 |    12058 |    23887 |     6821 |      6238
 SISTEMAS INDEPENDIENTES                                                   | CUENCA DEL RIO ITIYURO O CARAPARI                                                          |    57569 |    58371 |   115940 |    28185 |     25801
 SISTEMAS INDEPENDIENTES                                                   | CUENCAS DE RIOS Y ARROYOS DE LA MESETA PATAGONICA                                          |    26644 |    22776 |    49420 |    15409 |     14300
 SISTEMAS INDEPENDIENTES                                                   | CUENCAS VARIAS DE LA PUNA                                                                  |    15344 |    15903 |    31247 |     7859 |      7111
 VERTIENTE PACIFICA                                                        | CUENCA DEL LAGO FAGNANO                                                                    |     1657 |     1456 |     3113 |      913 |       850
 VERTIENTE PACIFICA                                                        | CUENCA DEL LOS RIOS MANSO Y PUELO                                                          |    15684 |    15441 |    31125 |    10110 |      9074
 VERTIENTE PACIFICA                                                        | CUENCA DE LOS LAGOS BUENOS AIRES - PUEYRREDON                                              |     1967 |     1732 |     3699 |     1187 |      1118
 VERTIENTE PACIFICA                                                        | CUENCA DE LOS RIOS CARRENLEUFU Y PICO                                                      |     2010 |     1816 |     3826 |     1244 |      1033
 VERTIENTE PACIFICA                                                        | CUENCA DEL RIO FUTALEUFU                                                                   |    21056 |    22092 |    43148 |    13706 |     12959
 VERTIENTE PACIFICA                                                        | CUENCA DEL RIO HUA-HUM                                                                     |    14015 |    14366 |    28381 |     8764 |      8254
 VERTIENTE PACIFICA                                                        | CUENCA DEL RIO MAYER Y LAGO SAN MARTIN                                                     |       62 |       10 |       72 |       25 |        20
                                                                           |                                                                                            | 19523271 | 20593034 | 40116305 | 12171699 |  11317552

sobran 1640
*/

/*
   link    |     st_distance     |                                  sistema                                  |                             nombre                              | varones | mujeres | total | hogares | viviendas 
-----------+---------------------+---------------------------------------------------------------------------+-----------------------------------------------------------------+---------+---------+-------+---------+-----------
 067560501 |  0.0134878141479585 | SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCA DE DESAGUE AL RIO DE LA PLATA AL S DEL RIO SAMBOROMBON   |     397 |     462 |   859 |     263 |       260
 067560501 |  0.0134878141479585 | SISTEMA RIO DE LA PLATA Y PROVINCIA DE BUENOS AIRES HASTA EL RIO COLORADO | CUENCAS DE ARROYOS DEL NE DE BUENOS AIRES                       |     397 |     462 |   859 |     263 |       260
 540490308 | 0.00969868178751515 | SISTEMA RIO URUGUAY                                                       | CUENCA PROPIA DEL RIO PEPIRI-GUAZU EN ARGENTINA                 |     366 |     415 |   781 |     227 |       211
 540490308 | 0.00969868178751515 | SISTEMA RIO PARANA                                                        | CUENCA DE ARROYOS DE MISIONES SOBRE EL RIO PARANA HASTA POSADAS |     366 |     415 |   781 |     227 |       211
(4 filas)

se repiten 2 radios con = distancia
nos quedamos con el de mayor población

*/

delete from visor.centroides_cuencas
where link='540490308' and sistema='SISTEMA RIO URUGUAY'
or link='067560501' and nombre='CUENCAS DE ARROYOS DEL NE DE BUENOS AIRES'
;
-- recálculo
drop table visor.sistemas_cuencas;
create table visor.sistemas_cuencas as
select
  sistema, nombre,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.centroides_cuencas
group by sistema, nombre
order by sistema, nombre
;

-------------------------------------------------------------
--- EcoRegiones



select * from visor.ecorregiones_DataApportionment
union
select null,
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas
from visor.ecorregiones_DataApportionment
order by ecorregion
;

/*
          ecorregion          | varones  | mujeres  |  total   | hogares  | viviendas 
------------------------------+----------+----------+----------+----------+-----------
 Altos Andes                  |    24910 |    22459 |    47369 |    12417 |     11364
 Bosques Patagónicos          |    55926 |    52723 |   108649 |    33292 |     31232
 Campos y Malezales           |   257270 |   272732 |   530002 |   149304 |    140305
 Chaco Húmedo                 |   286962 |   283837 |   570799 |   155040 |    146808
 Chaco Seco                   |  2390961 |  2456308 |  4847269 |  1279321 |   1180936
 Delta e Islas del Río Paraná |  1814617 |  1955775 |  3770392 |  1145244 |   1052278
 Espinal                      |  1627241 |  1710820 |  3338061 |  1040611 |    983918
 Estepa Patagónica            |   506220 |   495108 |  1001328 |   302157 |    283208
 Esteros del Iberá            |    72449 |    71790 |   144239 |    37410 |     36047
 Monte de Llanuras y Mesetas  |  1330205 |  1380180 |  2710385 |   783549 |    732013
 Monte de Sierras y Bolsones  |   441227 |   466123 |   907350 |   258086 |    240041
 Pampa                        |  9605583 | 10279193 | 19884776 |  6387140 |   5939322
 Puna                         |    50415 |    51175 |   101590 |    25536 |     22957
 Selva de las Yungas          |   699572 |   742548 |  1442120 |   370412 |    331389
 Selva Paranaense             |   358950 |   351386 |   710336 |   191690 |    185263
                              | 19522508 | 20592157 | 40114665 | 12171209 |  11317081

40114665+2224+190+17 = 40117096
estan todos
*/


------------------------------------------------------------
--- Relieve

select * from visor.relieve_DataApportionment
union
select null, 
  sum(varones) as varones, sum(mujeres) as mujeres, sum(total) as total,
  sum(hogares) as hogares, sum(viviendas) as viviendas, null
from visor.relieve_DataApportionment
order by orden
;

/*
        rango        | varones  | mujeres  |  total   | hogares  | viviendas | orden 
---------------------+----------+----------+----------+----------+-----------+-------
 Menos de 200 mts.   | 13873519 | 14719550 | 28593069 |  8929966 |   8311681 |     1
 De 201 a 500 mts.   |  2393556 |  2482421 |  4875977 |  1421929 |   1330527 |     2
 De 501 a 1000 mts.  |  1967777 |  2038874 |  4006651 |  1095260 |   1014661 |     3
 De 1001 a 3000 mts. |  1224800 |  1289437 |  2514237 |   692512 |    631698 |     4
 Mas de 3001 mts.    |    62856 |    61875 |   124731 |    31542 |     28514 |     5
                     | 19522508 | 20592157 | 40114665 | 12171209 |  11317081 |      

estan todos
*/




