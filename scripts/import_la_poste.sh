#!/bin/sh
# But : importer les donnees de La Poste bano dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : le repertoire dans lequel se trouve les fichiers 
################################################################################
# ENTREE : les fichiers a importer doivent avoir les noms suivants
# - ran_postcode.csv : le fihcier des codes postaux de la poste
# - ran_group.csv : le fichier des groupes de la Poste
# - ran_housenumber.csv : le fichier des housenumbers de la Poste
##############################################################################
# SORTIE : les tables PostgreSQL suivantes :
# - poste_cp
# - ran_group
# - ran_housenumber
#############################################################################
# REMARQUE : la base PostgreSQL, le port doivent être passés dans les variables d'environnement
# PGDATABASE et PGUSER
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_la_poste.sh <DataPath> "
        exit 1
fi

# import des codes postaux
echo "DROP TABLE IF EXISTS poste_cp;" > commandeTemp.sql
echo "CREATE TABLE poste_cp (co_insee varchar, lb_l5_nn varchar, co_insee_anc varchar, co_postal varchar, lb_l6 varchar);" >> commandeTemp.sql
echo "\COPY poste_cp FROM '${data_path}/ran_postcode.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

# import des groupes
echo "DROP TABLE IF EXISTS ran_group;" >> commandeTemp.sql
echo "CREATE TABLE ran_group (co_insee varchar, co_voie varchar, co_postal varchar, lb_type_voie varchar, lb_voie varchar, cea varchar,lb_l5 varchar, co_insee_l5 varchar);" >> commandeTemp.sql
echo "\COPY ran_group FROM '${data_path}/ran_group.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

# import des housenumbers
echo "DROP TABLE IF EXISTS ran_housenumber;" >> commandeTemp.sql
echo "CREATE TABLE ran_housenumber (co_insee varchar, co_voie varchar, co_postal varchar, no_voie varchar, lb_ext varchar, co_cea varchar);" >> commandeTemp.sql
echo "\COPY ran_housenumber FROM '${data_path}/ran_housenumber.csv' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

psql -f commandeTemp.sql
if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers de la poste"
   exit 1
fi

rm commandeTemp.sql

echo "FIN"







