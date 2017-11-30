#!/bin/sh
# But : preparer et exporter des fichiers json pour un ensemble 
# importable dans la ban
# avec la commande ban import:init
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel seront generes les json
################################################################################
# ENTREE : cf shell export_json.sh
##############################################################################
# SORTIE : les fichiers json dans $1 :
#############################################################################
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : export_json_rafale.sh <outPath>"
        exit 1
fi

#verification de l'exitence du repertoire data_path
if [ ! -d ${data_path} ] ; then
   echo "ERREUR : le répertoire ${data_path} n'existe pas"
   exit 1
fi

# on boucle par departement
deps="01 02 03 04 05 07 08 09 10 11 12 13 15 16 17 18 19 2A 2B 21 23 24 25 26 28 30 31 32 34 36 37 39 40 41 42 43 44 45 46 47 48 49 51 52 53 54 55 57 58 59 60 62 63 64 65 66 69 70 71 72 73 74 75 77 79 80 81 82 83 84 86 87 88 89 92 93 94 95 971 972 973 974 975 976"
for dep in ${deps}
do

   if [ ! -d ${data_path}/${dep} ] ; then
      rm -r ${data_path}/${dep}
   fi

   echo "Traitement du département ${dep}"
   /home/ban/donnees-initiales-wip/scripts/export_json.sh ${data_path} ${dep} > cr${dep}.txt

   if [ $? -ne 0 ]
   then
       echo "ERREUR lors traitement du département ${dep}"
       exit 1
   fi

done

echo "Traitement terminé avec succès"
