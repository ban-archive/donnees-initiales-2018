#!/bin/sh
# But : importer les fichiers csv fournis par l IGN dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les csv 
#	    * $2 : departement à traiter 
################################################################################
data_path=$1
dep=$2

if [ $# -ne 2 ]; then
        echo "Usage : import_csv_ign.sh <outPath> <dep>"
	echo "Exemple : import_csv_ign.sh /home/ban/ban-site/app/data/adresses 90"
        exit 1
fi

dbname=ban_init
user=ban
csvRep=${data_path}


# import des municipalities
echo "DROP TABLE IF EXISTS municipality${dep};" > commandeTemp.sql
echo "CREATE TABLE municipality${dep} (code_insee varchar, nom_commune varchar);" >> commandeTemp.sql
echo "\COPY municipality${dep} FROM '${csvRep}/${dep}/ban.municipality${dep}.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

# import des postcodes
echo "DROP TABLE IF EXISTS postcode${dep};" >> commandeTemp.sql
echo "CREATE TABLE postcode${dep} (code_post varchar, libelle varchar, code_insee varchar);" >> commandeTemp.sql
echo "\COPY postcode${dep} FROM '${csvRep}/${dep}/ban.postcode${dep}.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

# import des groupes
echo "DROP TABLE IF EXISTS group${dep};">> commandeTemp.sql
echo "CREATE TABLE group${dep} (id_pseudo_fpb varchar, nom varchar, alias varchar, type_d_adressage varchar, id_poste varchar, nom_afnor varchar,id_postes varchar,id_fantoir varchar,id_fantoirs varchar, code_insee varchar,source varchar, detruit boolean);" >> commandeTemp.sql
echo "\COPY group${dep} FROM '${csvRep}/${dep}/ban.group${dep}.csv' WITH CSV HEADER DELIMITER ';'">> commandeTemp.sql

# import des housenumbers
echo "DROP TABLE IF EXISTS house_number${dep};">> commandeTemp.sql
echo "CREATE TABLE house_number${dep} (id varchar,numero varchar,rep varchar,designation_de_l_entree varchar,type_de_localisation varchar,indice_de_positionnement varchar,methode varchar,lon double precision,lat double precision,code_post varchar,code_insee varchar, id_pseudo_fpb varchar,id_poste varchar, id_postes varchar, source varchar, source_geom varchar, detruit boolean);">> commandeTemp.sql
echo "\COPY house_number${dep} FROM '${csvRep}/${dep}/ban.house_number${dep}.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql


psql -d ${dbname} -U ${user} -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers csv du departement ${dep}"
   exit 1
fi

exit

rm commandeTemp.sql


echo "FIN"







