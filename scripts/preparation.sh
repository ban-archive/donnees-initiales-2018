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
##############################################################################
# SORTIE : 
# - les tables insee_cog et postcode préparées (menage dans les champs /champs supplémentaires)
# - les tables dgfip_fantoir, ign_group, ran_group, dgfip_noms_cadastre préparées (menage dans les champs /champs supplémentaires -> kind)
# - les tables dgfip_housenumbers, ran_housenumber, ign_house_number préparées (menage dans les champs /champs supplémentaires)
# - la table libelle qui contient la normalisation de tous les noms de groupes
# - la table ign_housenumber_unique qui contient les hn ign regroupés par voie, numero et ordinal
#############################################################################
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
#############################################################################
BinPath=`dirname $0`

echo "Etape 1 : preparation des municipalités, cp et groupes"
psql -e -f ${BinPath}/preparation_01_municipality_cp_group.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation des municipalités, cp et groupes"
  exit 1
fi


echo "Etape 2 : préparation de la table des libellés"
psql -e -f ${BinPath}/preparation_02_libelles.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation de la table des libellés"
  exit 1
fi

echo "Etape 3 : préparation des hn"
psql -e -f ${BinPath}/preparation_03_hn_position.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la preparation des hn"
  exit 1
fi



echo "SUCCES : préparation des données terminée"
