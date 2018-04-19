#!/bin/sh
################################################################################
# BUT      : extraire/dumper/restorer les données fantoir / ign / la poste d'origine dans la ban
################################################################################
# REMARQUE : 
# - des fichiers dump sont générés à l'endroit où est envoyé le shell
# - les tables sont dumpées de la base ban_temp et recharhées dans la base ban
###############################################################################
dep=$1

if [ $# -ne 1 ]; then
        echo "Usage : import.sh <dep>"
        exit 1
fi


base1="ban_temp"
base2="ban_20180417_recette"


# extraction cog 
psql -d ${base1} -c "DROP TABLE IF EXISTS insee_cog${dep}"
psql -d ${base1} -c "CREATE TABLE insee_cog${dep} AS SELECT * FROM insee_cog WHERE insee like '${dep}%'"

# extraction postcode
psql -d ${base1} -c "DROP TABLE IF EXISTS poste_cp${dep}"
psql -d ${base1} -c "CREATE TABLE poste_cp${dep} AS SELECT * FROM poste_cp WHERE co_insee like '${dep}%'"

# extraction ign_group
psql -d ${base1} -c "DROP TABLE IF EXISTS ign_group${dep}"
psql -d ${base1} -c "CREATE TABLE ign_group${dep} AS SELECT * FROM ign_group WHERE code_insee like '${dep}%'"

# extraction dgfip_fantoir
psql -d ${base1} -c "DROP TABLE IF EXISTS dgfip_fantoir${dep}"
psql -d ${base1} -c "CREATE TABLE dgfip_fantoir${dep} AS SELECT * FROM dgfip_fantoir WHERE code_insee like '${dep}%'"

# extraction ran_group
psql -d ${base1} -c "DROP TABLE IF EXISTS ran_group${dep}"
psql -d ${base1} -c "CREATE TABLE ran_group${dep} AS SELECT * FROM ran_group WHERE co_insee like '${dep}%'"

# extraction ign_housenumber
psql -d ${base1} -c "DROP TABLE IF EXISTS ign_housenumber${dep}"
psql -d ${base1} -c "CREATE TABLE ign_housenumber${dep} AS SELECT * FROM ign_housenumber WHERE code_insee like '${dep}%'"

# extraction ran_housenumber
psql -d ${base1} -c "DROP TABLE IF EXISTS ran_housenumber${dep}"
psql -d ${base1} -c "CREATE TABLE ran_housenumber${dep} AS SELECT * FROM ran_housenumber WHERE co_insee like '${dep}%'"

# extraction dgfip_housenumbers
psql -d ${base1} -c "DROP TABLE IF EXISTS dgfip_housenumbers${dep}"
psql -d ${base1} -c "CREATE TABLE dgfip_housenumbers${dep} AS SELECT * FROM dgfip_housenumbers WHERE insee_com like '${dep}%'"


# dump/restoire
for table in insee_cog${dep} poste_cp${dep} ign_group${dep} dgfip_fantoir${dep} ran_group${dep} ign_housenumber${dep} ran_housenumber${dep} dgfip_housenumbers${dep}
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

