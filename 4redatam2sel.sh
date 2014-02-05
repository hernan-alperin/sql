tabla="visor.centroides_climas"
columnas="grupo||'-'||tipo"

psql -tc "select distinct $columnas from $tabla order by $columnas" sig_20 > lineas

sed "s/ \(.*\)/select '0104******0'||link from $tabla where $columnas='\1';___\1/" lineas |\
sed 's/\(.*\)___\(.*\)/echo "*R+SP 2 \2" > "\2.sel"; psql -tc "\1" sig_20 >> "\2.sel"/'  > comandos

source comandos
