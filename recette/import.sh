#!/bin/sh
################################################################################
# BUT      : dumper/restorer les données fantoir / ign / la poste d'origine dans la ban
################################################################################
# REMARQUE : 
# - des fichiers dump sont générés à l'endroit où est envoyé le shell
# - les tables sont dumpées de la base ban_temp et recharhées dans la base ban
###############################################################################

#for table in dgfip_fantoir 
for table in ign_group ran_group
do
	echo "dump ${table}"
	pg_dump -Fc -t ${table} -f ${table}.dump ban_temp
	if [ $? -ne 0 ]
	then
   		echo "ERREUR lors du dump de ${table}"
   		exit 1
	fi

	echo "restore ${table}"
	psql -d ban -c "DROP TABLE IF EXISTS ${table}"
	pg_restore -d ban ${table}.dump
        if [ $? -ne 0 ]
        then
                echo "ERREUR lors du restore de ${table}"
                exit 1
        fi

done

