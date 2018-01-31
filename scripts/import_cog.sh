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

# Ajout des arrondissements municipaux de Paris, Lyon et Marseille
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13201','MARSEILLE-1ER-ARRONDISSEMENT','Marseille 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13202','MARSEILLE-2E-ARRONDISSEMENT','Marseille 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13203','MARSEILLE-3E-ARRONDISSEMENT','Marseille 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13204','MARSEILLE-4E-ARRONDISSEMENT','Marseille 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13205','MARSEILLE-5E-ARRONDISSEMENT','Marseille 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13206','MARSEILLE-6E-ARRONDISSEMENT','Marseille 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13207','MARSEILLE-7E-ARRONDISSEMENT','Marseille 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13208','MARSEILLE-8E-ARRONDISSEMENT','Marseille 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13209','MARSEILLE-9E-ARRONDISSEMENT','Marseille 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13210','MARSEILLE-10E-ARRONDISSEMENT','Marseille 10e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13211','MARSEILLE-11E-ARRONDISSEMENT','Marseille 11e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13212','MARSEILLE-12E-ARRONDISSEMENT','Marseille 12e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13213','MARSEILLE-13E-ARRONDISSEMENT','Marseille 13e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13214','MARSEILLE-14E-ARRONDISSEMENT','Marseille 14e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13215','MARSEILLE-15E-ARRONDISSEMENT','Marseille 15e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13216','MARSEILLE-16E-ARRONDISSEMENT','Marseille 16e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69381','LYON-1ER-ARRONDISSEMENT','Lyon 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69382','LYON-2E-ARRONDISSEMENT','Lyon 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69383','LYON-3E-ARRONDISSEMENT','Lyon 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69384','LYON-4E-ARRONDISSEMENT','Lyon 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69385','LYON-5E-ARRONDISSEMENT','Lyon 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69386','LYON-6E-ARRONDISSEMENT','Lyon 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69387','LYON-7E-ARRONDISSEMENT','Lyon 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69388','LYON-8E-ARRONDISSEMENT','Lyon 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69389','LYON-9E-ARRONDISSEMENT','Lyon 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75101','PARIS-1ER-ARRONDISSEMENT','Paris 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75102','PARIS-2E-ARRONDISSEMENT','Paris 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75103','PARIS-3E-ARRONDISSEMENT','Paris 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75104','PARIS-4E-ARRONDISSEMENT','Paris 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75105','PARIS-5E-ARRONDISSEMENT','Paris 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75106','PARIS-6E-ARRONDISSEMENT','Paris 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75107','PARIS-7E-ARRONDISSEMENT','Paris 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75108','PARIS-8E-ARRONDISSEMENT','Paris 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75109','PARIS-9E-ARRONDISSEMENT','Paris 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75110','PARIS-10E-ARRONDISSEMENT','Paris 10e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75111','PARIS-11E-ARRONDISSEMENT','Paris 11e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75112','PARIS-12E-ARRONDISSEMENT','Paris 12e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75113','PARIS-13E-ARRONDISSEMENT','Paris 13e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75114','PARIS-14E-ARRONDISSEMENT','Paris 14e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75115','PARIS-15E-ARRONDISSEMENT','Paris 15e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75116','PARIS-16E-ARRONDISSEMENT','Paris 16e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75117','PARIS-17E-ARRONDISSEMENT','Paris 17e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75118','PARIS-18E-ARRONDISSEMENT','Paris 18e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75119','PARIS-19E-ARRONDISSEMENT','Paris 19e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75120','PARIS-20E-ARRONDISSEMENT','Paris 20e Arrondissement');" >> commandeTemp.sql

#Ajout des communes de saint-pierre et miquelon
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97501','MIQUELON-LANGLADE','Miquelon-Langlade');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97502','SAINT-PIERRE','Saint-Pierre');" >> commandeTemp.sql

#Ajout de Saint-Barthélémy et Saint Martin
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97701','SAINT-BARTHELEMY','Saint-Barthélemy');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97801','SAINT-MARTIN','Saint-Martin');" >> commandeTemp.sql

#Ajout de Monaco
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('99138','MONACO','Monaco');" >> commandeTemp.sql


psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import du fichier COG"
   exit 1
fi

rm commandeTemp.sql


echo "FIN"


