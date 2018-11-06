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
        echo "Usage : import_dgfip_etalab.sh <DataPath> "
        exit 1
fi

#rm -f ${data_path}/adresses-dgfip-etalab-full.csv
#touch adresses-dgfip-etalab-full.csv

#for dep in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 2A 2B 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 976
#do
#   gunzip ${data_path}/adresses-dgfip-etalab-${dep}.csv.gz

#   cat ${data_path}/adresses-dgfip-etalab-${dep}.csv >> ${data_path}/adresses-dgfip-etalab-full.csv
#   gzip ${data_path}/adresses-dgfip-etalab-${dep}.csv

#done


#grep -v csv adresses-dgfip-etalab-full.csv > adresses-dgfip-etalab-full2.csv
#grep -v "^$" adresses-dgfip-etalab-full2.csv > adresses-dgfip-etalab-full3.csv
#cp adresses-dgfip-etalab-full3.csv adresses-dgfip-etalab-full.csv
#gzip adresses-dgfip-etalab-full.csv

# import des hn
psql -c "DROP TABLE IF EXISTS dgfip_housenumbers;" 
psql -c "CREATE TABLE dgfip_housenumbers (lon double precision,lat double precision,position_type varchar,numero varchar, libelle_voie varchar, libelle_voie_type varchar, fantoir varchar, libelle_fantoir varchar, code_postal varchar, libelle_acheminement varchar, insee_com varchar, destination varchar);"

for dep in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 2A 2B 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 976
#for dep in 01 02
do
   echo "Copie dep ${dep}"
   gunzip ${data_path}/adresses-dgfip-etalab-${dep}.csv.gz
   psql -c "\COPY dgfip_housenumbers FROM '${data_path}/adresses-dgfip-etalab-${dep}.csv' WITH CSV HEADER DELIMITER ','" 
   if  [ $? -ne 0 ]
   then
     echo "Erreur lors de l import des fichiers dgfip - etalab"
     exit 1
   fi

   gzip ${data_path}/adresses-dgfip-etalab-${dep}.csv
done

# les voies cadatre
echo "copy dgfip_noms_cadastre" 
psql -c "DROP TABLE IF EXISTS dgfip_noms_cadastre;" 
psql -c  "CREATE TABLE dgfip_noms_cadastre as select max(substr(fantoir,1,5)) as insee,fantoir,libelle_voie from dgfip_housenumbers where libelle_voie_type = 'plan-cadastral' group by fantoir,libelle_voie;" 

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers dgfip - etalab"
   exit 1
fi


echo "FIN"

