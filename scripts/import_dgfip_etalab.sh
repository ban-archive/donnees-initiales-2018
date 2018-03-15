#!/bin/sh
# But : importer les fichiers dgfip (obtenus par la méthode EtaLab) dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : le repertoire dans lequel se trouve les fichiers 
################################################################################
# ENTREE : le fichier cadastre-dgfip.csv avec les champs suivants 
# lon,lat,position_type,numero,libelle_voie,libelle_voie_type,fantoir,libelle_fantoir,code_postal,libelle_acheminement,insee_com,destination
##############################################################################
# SORTIE : les tables PostgreSQL suivantes :
# - dgfip_noms_cadastre
# - dgfip_housenumbers
#############################################################################
# REMARQUE : la base PostgreSQL, le port doivent être passés dans les variables d'environnement
# PGDATABASE et PGUSER
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_dgfip.sh <DataPath> "
        exit 1
fi

# grep -v csv adresses-dgfip-etalab-full.csv > adresses-dgfip-etalab-full2.csv
# grep -v "^$" adresses-dgfip-etalab-full.csv > adresses-dgfip-etalab-full2.csv

# import des hn
echo "DROP TABLE IF EXISTS dgfip_housenumbers;" > commandeTemp.sql
echo "CREATE TABLE dgfip_housenumbers (lon double precision,lat double precision,position_type varchar,numero varchar, libelle_voie varchar, libelle_voie_type varchar, fantoir varchar, libelle_fantoir varchar, code_postal varchar, libelle_acheminement varchar, insee_com varchar, destination varchar);" >> commandeTemp.sql
echo "\COPY dgfip_housenumbers FROM '${data_path}/adresses-dgfip-etalab-full.csv' WITH CSV HEADER DELIMITER ','" >> commandeTemp.sql

# les voies cadatre 
echo "DROP TABLE IF EXISTS dgfip_noms_cadastre;" >> commandeTemp.sql
echo "CREATE TABLE dgfip_noms_cadastre as select max(substr(fantoir,1,5)) as insee,fantoir,libelle_voie from dgfip_housenumbers where libelle_voie_type = 'plan-cadastral' group by fantoir,libelle_voie;" >> commandeTemp.sql

psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers dgfip - etalab"
   exit 1
fi

rm commandeTemp.sql

echo "FIN"

