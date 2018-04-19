#!/bin/sh
# But : charger le résultat de l'appariement interactif fantoir -ign
################################################################################
# ARGUMENT :* le repertoire contenant les fichiers d'appariement interactif des groupes 
################################################################################
# ENTREE : la base PostgreSQL temporaire dans laquelle ont ete importees
# les données des différentes sources 
# - ign_group_non_app_with_fantoir_app.csv : fichier appariement interactif ign - fantoir
##############################################################################
# SORTIE : 
# les tables PG d'appariement interactif :
#    ign_group_app_fantoir_interactif
#    la table ign_group_app mise à jour avec les appariements interactifs
#############################################################################
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
#############################################################################
appPath=$1
import=$2
finalisation=$3
set -x
if [ $# -ne 3 ]; then
        echo "Usage :  finalisation_01_app_group_ign.sh <appPath> <import> <finalisation>"
        exit 1
fi

psql -e -c "DROP TABLE IF EXISTS ign_group_app_fantoir_interactif;"
psql -e -c "CREATE TABLE ign_group_app_fantoir_interactif (id_fantoir varchar, id_pseudo_fpb varchar, nom_maj varchar, nom_maj_fantoir varchar, court_ign varchar, court_fantoir varchar, app real, comm varchar);"


if [ $import -eq 1 ]; then
	psql -e -c "\COPY ign_group_app_fantoir_interactif FROM '${appPath}/ign_group_non_app_with_fantoir_app.csv' WITH CSV HEADER DELIMITER ';';"

	if [ $? -ne 0 ]
	then
	  echo "Erreur lors de l'import des appariements interactifs ign-fantoir"
	  exit 1
	fi
	psql -e -c "delete from ign_group_app_fantoir_interactif where app is null;"
fi


if [ $finalisation -eq 1 ]; then

psql -e -c "

SELECT prepa_non_app_fantoir_ign();
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, 'fantoir = id fantoir ign, appariement interactif' from ign_group_candidat i
LEFT JOIN (select id_pseudo_fpb from ign_group_app_fantoir_interactif where app = '1') a ON (a.id_pseudo_fpb = i.id_pseudo_fpb)
where a.id_pseudo_fpb is not null;

SELECT prepa_non_app_fantoir_ign();
DROP TABLE IF EXISTS ign_group_non_app_with_fantoir;
CREATE TABLE ign_group_non_app_with_fantoir AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,f.nom_maj as nom_maj_fantoir, l1.court as court_ign, l2.court as court_fantoir from ign_group_candidat i
left join dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where fantoir_9 is not null and fantoir_9 <> '';

DROP TABLE IF EXISTS ign_group_non_app;
CREATE TABLE ign_group_non_app AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.code_insee FROM ign_group i
LEFT JOIN ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
where a.id_pseudo_fpb is null;
"

fi



echo "SUCCES : import des appariements terminés"
