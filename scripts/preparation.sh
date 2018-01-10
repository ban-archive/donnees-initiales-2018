#!/bin/sh
# But : preparer les tables d'adresses et de voies des différentes sources 
# à l'importation dans la ban. 
# Les principaux traitements sont :
# - TODO
################################################################################
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel est le script sql preparation.sql  
################################################################################
# ENTREE : la base PostgreSQL temporaire dans laquelle ont ete importees
# les données des différentes sources dans les tables suivantes (France entiere):
# - insee_cog
# - poste_cp
# - dgfip_fantoir
# - dgfip_noms_cadastre
# - dgfip_housenumbers
# - ran_group
# - ran_housenumber
# - ign_municipality
# - ign_postcode
# - ign_group
# - ign_house_number
# - les aitf ????
##############################################################################
# SORTIE :
# - les mêmes tables que précédemment préparées
#############################################################################
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
#############################################################################
Rep=$1

if [ $# -ne 1 ]; then
        echo "Usage : preparation.sh <repertoire preparation.sql>"
        exit 1
fi

psql -e -f ${Rep}/preparation.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation"
  exit 1
fi

echo "SUCCES : préparation des données terminée"
