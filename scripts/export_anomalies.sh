#!/bin/sh
# But : generer des fichiers d'anomalies a l'issue des appariements
################################################################################
# ARGUMENT :* $1 : répertoire où seront générés les fichiers d'anomalies  
################################################################################
# ENTREE : la base PostgreSQL ban_temp temporaire dans laquelle ont ete importees les 
# donnees des différentes sources : ban_temp
##############################################################################
# SORTIE : 
# - inco_cp.txt
#############################################################################
#  La variable d'envionnement PGDATABASE doit valoir base_temp
#############################################################################
Rep=$1

if [ $# -ne 1 ]; then
        echo "Usage : annomalies.sh <repertoire de sortie>"
        exit 1
fi

echo "Export des anomalies insee/cp ign-lp"
psql -e -c "\COPY anomalies_cp_insee TO '${Rep}/anomalies_cp_insee.csv' WITH CSV HEADER DELIMITER ';'"

if [ $? -ne 0 ]
then
  echo "Erreur lors l'export des anomalies insee/cp"
  exit 1
fi

echo "SUCCES : Export terminé"
