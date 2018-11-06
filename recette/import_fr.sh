#!/bin/sh
################################################################################
# BUT      : extraire/dumper/restorer les données fantoir / ign / la poste d'origine dans la ban
################################################################################
# REMARQUE : 
# - des fichiers dump sont générés à l'endroit où est envoyé le shell
# - les tables sont dumpées de la base ban_temp et recharhées dans la base ban
###############################################################################


base1="ban_temp"
base2="ban_20181018"


# dump/restoire
for table in insee_cog poste_cp ign_group dgfip_fantoir ran_group ign_housenumber ran_housenumber dgfip_housenumbers
do
	echo "dump ${table}"
	pg_dump -Fc -t ${table} -f ${table}.dump ${base1}
	if [ $? -ne 0 ]
	then
   		echo "ERREUR lors du dump de ${table}"
   		exit 1
	fi

	echo "restore ${table}"
	psql -d ${base2} -c "DROP TABLE IF EXISTS ${table}"
	pg_restore -d ${base2} ${table}.dump
        if [ $? -ne 0 ]
        then
                echo "ERREUR lors du restore de ${table}"
                exit 1
        fi

done

