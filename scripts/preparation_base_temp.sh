#!/bin/sh
# But : preparer la base postgresql de travail en y ajoutant la table des 
# abbreviations et la table des communes fusionnées
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les fichiers d'abbréviations et 
#                   des communes fusionnees 
################################################################################
# ENTREE : les fichiers  
# - abbre.csv : les abbreviations
# - fusion_commune.sql : les fusions de commune
##############################################################################
# SORTIE : les tables PostgreSQL suivantes :
# - abbrev
# - fusion_commune
#############################################################################

Rep=$1

if [ $# -ne 1 ]; then
        echo "Usage : preparation_base_temp.sh <Rep> "
        exit 1
fi

# creation de la table des abbreviations
echo "DROP TABLE IF EXISTS abbrev;" > commandeTemp.sql
echo "CREATE TABLE abbrev
(
  nom_long character varying,
  nom_min character varying,
  nom_court character varying,
  kind character varying,
  code character varying
); " >> commandeTemp.sql
echo "\COPY abbrev FROM '${Rep}/abbre.csv' WITH CSV HEADER DELIMITER ';';" >> commandeTemp.sql

psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers csv des abbreviations"
   exit 1
fi

# creation de la table des fusions de communes
psql -f ${Rep}/fusion_commune.sql
if [ $? -ne 0 ]
then
   echo "Erreur lors de la creation de la table fusion_commune"
   exit 1
fi

rm commandeTemp.sql


echo "FIN"







