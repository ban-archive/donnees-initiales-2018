#!/bin/sh
# But : importer les fichiers dgfip bano dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : le repertoire dans lequel se trouve les fichiers 
################################################################################
# ENTREE : les fichiers a importer doivent avoir les noms suivants
# - noms_cadastre.csv : contient les noms des voies (insee_com,voie_cadastre,fantoir)
# - cadastre.csv : contient les points adresses (lon,lat,numero,voie_cadastre,fantoir,insee_com,voie_fantoir)
##############################################################################
# SORTIE : les tables PostgreSQL suivantes :
# - dgfip_noms_cadastre
# - dgfip_housenumbers
#############################################################################
# REMARQUE : la base PostgreSQL, le port doivent être passés dans les variables d'environnement
# PGDATABASE et PGUSER
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_dgfip_bano.sh <DataPath> "
        exit 1
fi

# import des noms dgfip - bano
echo "DROP TABLE IF EXISTS dgfip_noms_cadastre;" > commandeTemp.sql
echo "CREATE TABLE dgfip_noms_cadastre (insee_com varchar, voie_cadastre varchar, fantoir varchar);" >> commandeTemp.sql
echo "\COPY dgfip_noms_cadastre FROM '${data_path}/noms_cadastre.csv' WITH CSV HEADER DELIMITER ','" >> commandeTemp.sql

# import des noms dgfip - bano
echo "DROP TABLE IF EXISTS dgfip_housenumbers;" >> commandeTemp.sql
echo "CREATE TABLE dgfip_housenumbers (lon double precision,lat double precision,numero varchar, voie_cadastre varchar, fantoir varchar,insee_com varchar,voie_fantoir varchar);" >> commandeTemp.sql
echo "\COPY dgfip_housenumbers FROM '${data_path}/cadastre.csv' WITH CSV HEADER DELIMITER ','" >> commandeTemp.sql

psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers dgfip - bano"
   exit 1
fi

rm commandeTemp.sql

echo "FIN"







