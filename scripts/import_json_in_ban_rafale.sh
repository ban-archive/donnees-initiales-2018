#!/bin/sh
# But : importer des fichiers json pour un ensemble de départements
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les json
################################################################################
# SORTIE : la ban (base PG) dans laquelle sont importés les fichiers json
#############################################################################
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_json_in_ban_rafale.sh <jsonPath>"
        exit 1
fi

#verification de l'exitence du repertoire data_path
if [ ! -d ${data_path} ] ; then
   echo "ERREUR : le répertoire ${data_path} n'existe pas"
   exit 1
fi

BinPath=`dirname $0`

# on boucle par departement
#deps="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 2A 2B 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 975 976 98"
#deps="90"
deps="30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 975 976 98"
for dep in ${deps}
do

   if [ ! -d ${data_path}/${dep} ] ; then
      echo "ERREUR le répertoire ${data_path}/${dep} n'existe pas"
   fi

   echo "Traitement du département ${dep}"
   ${BinPath}/import_json_in_ban.sh ${data_path}/${dep} > cr${dep}_import_json.txt

   if [ $? -ne 0 ]
   then
       echo "ERREUR lors traitement du département ${dep}"
       exit 1
   fi

done

echo "Traitement terminé avec succès"
