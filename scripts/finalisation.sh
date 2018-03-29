#!/bin/sh
# But : Apparier/Regrouper les tables groupe/hn/position des différentes sources
################################################################################
# ARGUMENT :*   
################################################################################
# ENTREE : la base PostgreSQL temporaire dans laquelle ont ete importees
# les données des différentes sources 
##############################################################################
# SORTIE : 
# - la table group_fnal qui regroupe les groupes des différentes sources
# - la table housenumber qui regroupe les hn des différentes sources
# - la table position avec les positions dgfip et ign
#############################################################################
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
#############################################################################
BinPath=`dirname $0`

echo "Etape 1 : appariement groupes ign"
psql -e -f ${BinPath}/finalisation_01_app_group_ign.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l'appariement des groupes"
  exit 1
fi


echo "Etape 2 : appariement groupes laposte"
psql -e -f ${BinPath}/finalisation_02_app_group_laposte.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l'appariement des groupes laposte"
  exit 1
fi

echo "Etape 3 : finalisation appariement des groupes"
psql -e -f ${BinPath}/finalisation_02_app_group.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de la finalisation de l'appariement des groupes "
  exit 1
fi

echo "Etape 4 : regroupement/appariement hn et position"
psql -e -f ${BinPath}/finalisation_04_hn_position.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors du regroupement/appariement hn et position"
  exit 1
fi



echo "SUCCES : finalisation des données terminée"
