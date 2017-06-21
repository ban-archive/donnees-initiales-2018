#!/bin/sh
# But : importer le fichier cog de l'insee dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : le repertoire dans lequel sera enregistré le fichier
##############################################################################
# SORTIE : 
# - le fichier cog
# - la table insee_cog
#############################################################################
# REMARQUE : la base PostgreSQL, le port doivent être passés dans les variables d'environnement
# PGDATABASE et PGUSER

data_path=$1
set -x
if [ $# -ne 1 ]; then
        echo "Usage : import_cog.sh <DataPath> "
        exit 1
fi

mkdir ${data_path}

rm ${data_path}/comsimp2017-txt.zip
rm ${data_path}/comsimp2017.txt
rm ${data_path}/comsimp2017.csv

# COG 2017 de l'INSEE
wget -nc  https://www.insee.fr/fr/statistiques/fichier/2666684/comsimp2017-txt.zip -O ${data_path}/comsimp2017-txt.zip
if [ $? -ne 0 ]
then
   echo "Erreur lors du telechargement du fichier COG"
   exit 1
fi

unzip -o ${data_path}/comsimp2017-txt.zip -d ${data_path}
# conversion en CSV UTF-8
cat ${data_path}/comsimp2017.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > ${data_path}/comsimp2017.csv


echo  "drop table if exists insee_cog;" > commandeTemp.sql
echo  "create table insee_cog (CDC text,CHEFLIEU text,REG text,DEP text,COM text,AR text,CT text,TNCC text,ARTMAJ text,NCC text,ARTMIN text,NCCENR text);" >>commandeTemp.sql
echo  "\COPY insee_cog from '${data_path}/comsimp2017.csv' WITH CSV HEADER DELIMITER ','" >> commandeTemp.sql
echo  "alter table insee_cog add column insee text;" >> commandeTemp.sql
echo  "update insee_cog set insee=dep||com;" >> commandeTemp.sql
echo  "create index idx_insee_cog_insee on insee_cog (insee);" >> commandeTemp.sql

psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import du fichier COG"
   exit 1
fi

rm commandeTemp.sql


echo "FIN"


