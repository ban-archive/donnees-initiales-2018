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

# on ne conserve qu'un groupe par identifiant la poste (il y a quelques voies avec le même identifiant la poste et même CEA mais code poste différent) -> voies multi CP. La Poste ne livre pas les bons cea et co_voie pour ces cas la. 
# cf https://github.com/BaseAdresseNationale/donnees-initiales/issues/6
#Exemple :
#  co_insee | co_voie  | co_postal | lb_type_voie |   lb_voie    |    cea     | lb_l5 | co_insee_l5 | insee_cog | laposte  | kind
#----------+----------+-----------+--------------+--------------+------------+-------+-------------+-----------+----------+------
# 66136    | 04377322 | 66000     |              | RUE DE BERGA | 6613624CCZ |       |             | 66136     | 04377322 | way
# 66136    | 04377322 | 66100     |              | RUE DE BERGA | 6613624CCZ |       |             | 66136     | 04377322 | way
echo "DROP TABLE IF EXISTS ran_group_unique;" >> commandeTemp.sql
echo "CREATE TABLE ran_group_unique AS SELECT distinct on(laposte) * FROM ran_group order by laposte, co_postal ASC;" >> commandeTemp.sql

# on fait une table avec les voies multi-CP
echo "DROP TABLE IF EXISTS ran_group_multi_cp;" >> commandeTemp.sql
echo "CREATE TABLE ran_group_multi_cp AS SELECT p.* FROM ran_group p LEFT JOIN (SELECT laposte FROM ran_group GROUP BY laposte HAVING count(*) > 1) as ss ON (ss.laposte = p.laposte) WHERE ss.laposte is not null;" >> commandeTemp.sql
echo "DROP TABLE ran_group;" >> commandeTemp.sql
echo "ALTER TABLE ran_group_unique RENAME TO ran_group;" >> commandeTemp.sql
echo "" >> commandeTemp.sql
 

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







