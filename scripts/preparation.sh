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
# SORTIE : les données prêtent à être exporter en json
# - les tables insee_cog et postcode préparés (menage dans les champs /champs supplémentaires
# - la table group_fnal avec les groupes des 4 sources, les appariements en place et les champs qui vons bien
# - la table housenumber avec les hn dgfip, ign et hn regroupés et appariés
# - la table position avec les positions dgfip et ign
#############################################################################
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
#############################################################################
Rep=$1

if [ $# -ne 1 ]; then
        echo "Usage : preparation.sh <repertoire preparation.sql>"
        exit 1
fi

echo "Etape 1 : preparation généralités"
psql -e -f ${Rep}/preparation_01_generalites.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation generalités"
  exit 1
fi


echo "Etape 2 : préparation de la table des libellés"
psql -e -f ${Rep}/preparation_02_libelles.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation de la table des libellés"
  exit 1
fi

echo "Etape 3 : appariement des groupes"
psql -e -f ${Rep}/preparation_03_app_group.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l'appariement des groupes "
  exit 1
fi

echo "Etape 4 : préparation hn et position"
psql -e -f ${Rep}/preparation_04_hn_position.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation des hn et position "
  exit 1
fi



echo "SUCCES : préparation des données terminée"
