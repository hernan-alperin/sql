tabla="visor.centroides_climas"
columnas="grupo||'-'||tipo"

psql -tc "select distinct $columnas from $tabla order by $columnas" sig_20 > lineas

sed "s/ \(.*\)/select '0104******0'||link from $tabla where $columnas='\1';___\1/" lineas |\
#sed -e 's/á/a/g' -e 's/é/e/g' -e 's/í/i/g' -e 's/ó/o/g' -e 's/ú/u/g' -e 's/ü/u/g' -e 's/ñ/n/g' |\
#sed -e 's/Á/A/g' -e 's/É/E/g' -e 's/Ì/I/g' -e 's/Ò/O/g' -e 's/Ù/U/g' -e 's/Û/U/g' -e 's/Ñ/N/g' |\
sed 's/\(.*\)___\(.*\)/echo "*R+SP 2 \2" > "\2.sel"; psql -tc "\1" sig_20 >> "\2.sel"/'  > comandos

source comandos
