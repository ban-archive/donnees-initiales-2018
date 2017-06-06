#!/bin/sh
# But : creer et importer la table des abbreviations
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel est le fichier csv des abbréviations 
################################################################################
data_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : preparation.sh <outPath> "
        exit 1
fi

dbname=ban_init
user=ban
csv=${data_path}/type_voies2.csv

#verification de la presence du fichier
if [ ! -f ${csv} ]; then
	echo "${csv} n'existe pas"
	exit 1
fi

# import des abbreviations
echo "DROP TABLE IF EXISTS abbreviations;" > commandeTemp.sql
echo "CREATE TABLE abbreviations (nom_maj varchar, nom_min varchar, nom_abbr varchar);" >> commandeTemp.sql
echo "\COPY abbreviations  FROM '${csv}' WITH CSV HEADER DELIMITER ';'" >> commandeTemp.sql

echo "ALTER TABLE abbreviations ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE abbreviations  SET kind = 'area' ;" >> commandeTemp.sql
#A/B
echo "UPDATE abbreviations SET kind = 'way' where nom_abbr like 'ALL' or nom_abbr like 'ACH' or nom_abbr like 'AMT' or nom_abbr like 'ART' or nom_abbr like 'AUT' or nom_abbr like 'ARC' or nom_abbr like 'AV' or nom_abbr like 'BCH' or nom_abbr like 'BER' or nom_abbr like 'BCLE' or nom_abbr like 'BD' or nom_abbr like 'BALI' or nom_abbr like 'BAN' or nom_abbr like 'BIDE%' or nom_abbr like 'BRECHE';">> commandeTemp.sql
#C/D
echo "UPDATE abbreviations SET kind = 'way' where nom_abbr like 'CALE'  or nom_abbr like 'CAU'  or nom_abbr like 'CAV' or nom_abbr like 'CARR%' or nom_abbr like 'CHE' or nom_abbr like 'CHS' or nom_abbr like 'CHI' or nom_abbr like 'CHV' or nom_abbr like 'CHEM'  or nom_abbr like 'CLOS' or nom_abbr like 'COTE' or nom_abbr like 'COUR' or nom_abbr like 'CTRE' or nom_abbr like 'CRS' or nom_abbr like 'DEG' or nom_abbr like 'DSC' or nom_abbr like 'DIG'  or nom_abbr like 'ESP%' or nom_abbr like 'ESC' or nom_abbr like 'CAMI%' or nom_abbr like 'CAP' or nom_abbr like 'CAUSSADE' or nom_abbr like 'CLAU%' or nom_abbr like 'CLOT%' or nom_abbr like 'COT' or nom_abbr like 'COST%' or nom_abbr like 'COUREE' or nom_abbr like 'DRAILLE' or nom_abbr like 'DREVE';" >> commandeTemp.sql
#->M
echo "UPDATE abbreviations SET kind = 'way' where nom_abbr like 'FG' or nom_abbr like 'FORM' or nom_abbr like 'FOS' or nom_abbr like 'GBD' or nom_abbr like 'GR' or nom_abbr like 'GDEN'or  nom_abbr like 'GR' or nom_abbr like 'GRIM'  or nom_abbr like 'HCH' or nom_abbr like 'IMP'  or nom_abbr like 'JTE' or nom_abbr like 'LEVE'  or nom_abbr like 'MTE' or nom_abbr like '% TRO' or nom_abbr like 'ESCAL%'or nom_abbr like 'ESCAIL%' or nom_abbr like 'GARENN%' or nom_abbr like 'GARRON%' or nom_abbr like 'GOUA' or nom_abbr like '%JENN' or nom_abbr like 'NTE' or nom_abbr like 'HENT%' or nom_abbr like 'HENCH%' or nom_abbr like 'HOURC%' or nom_abbr like 'FOURC%' or nom_abbr like '%PONT' or nom_abbr like '%HENT' or nom_abbr like 'KARRIKA%' or nom_abbr like 'KARRONT' or nom_abbr like 'LICES' or nom_abbr like 'LODENN' or nom_abbr like 'MOUNT';" >> commandeTemp.sql
#P/Q
echo "UPDATE abbreviations SET kind = 'way' where nom_abbr like 'PRV' or nom_abbr like 'PAS%' or nom_abbr like 'PERI' or nom_abbr like 'PSTY' or nom_abbr like 'PCH' or nom_abbr like 'PTR' or nom_abbr like 'PTA' or nom_abbr like 'PAE' or nom_abbr like 'PIM' or nom_abbr like 'PDEG' or nom_abbr like 'PRT' or nom_abbr like 'PONT' or nom_abbr like 'PROM' or nom_abbr like 'POUR' or nom_abbr like 'QU' or nom_abbr like 'STRAE%' or nom_abbr like 'STRE%' or nom_abbr like 'PECH' or nom_abbr like 'PEY' or nom_abbr like 'POND' or nom_abbr like 'POUECH' or nom_abbr like 'POURMENA%' or nom_abbr like 'POUSTERLE' or nom_abbr like 'PUJO%' or nom_abbr like 'QUERREUX';" >>commandeTemp.sql
#fin 
echo "UPDATE abbreviations SET kind = 'way' where nom_abbr like 'RAC' or nom_abbr like 'RAID' or nom_abbr like 'RPE' or nom_abbr like 'REM' or nom_abbr like 'ROC' or nom_abbr like 'RTE' or nom_abbr like 'R' or nom_abbr like 'RLE' or nom_abbr like 'RTTE' or nom_abbr like 'SEN' or nom_abbr like 'TRA' or nom_abbr like 'VEN' or nom_abbr like 'VIA' or nom_abbr like 'VTE' or nom_abbr like 'VCHE' or nom_abbr like 'VOI' or nom_abbr like 'VC' or nom_abbr like 'RAISE' or nom_abbr like 'RAIZE' or nom_abbr like 'RU' or nom_abbr like 'SARRAT' or nom_abbr like 'SERRE' or nom_abbr like 'SOUMET' or nom_abbr like 'TRE' or nom_abbr like 'TUC%' or nom_abbr like 'TUQUE';" >> commandeTemp.sql
echo "ALTER TABLE abbreviations ADD COLUMN priorite varchar;" >> commandeTemp.sql
echo "UPDATE abbreviations set priorite = 2;">> commandeTemp.sql
echo "UPDATE abbreviations set priorite= 1 where nom_maj='CENTRAL' or nom_maj='CHAUSSEES' or nom_maj='CHEMINS' or nom_maj='CHEMINEMENTS' or nom_maj='FOSSES' or nom_maj = 'COTEAUX' or nom_maj= 'GRANDE RUE' or nom_maj='PORTIQUES' or nom_maj='TERRASSES' or nom_maj='TERTRES' or nom_maj='PASSES' or nom_maj='ROUTES' or nom_maj='RUES' or nom_maj = 'RUELLES' or nom_maj = 'RUETTES' or nom_maj='SENTIERS' or nom_maj='VENELLES' or nom_maj='DEGRES' or nom_maj='DESCENTES' or nom_maj='DIGUES' or nom_maj='ESCALIERS' or nom_maj='ESPLANADES' or nom_maj='GRANDS ENSEMBLES' or nom_maj='HAUTS CHEMINS' or nom_maj='IMPASSES' or nom_maj='JETEES' or nom_maj='MONTEES' or nom_maj='PETITES ALLEES' or nom_maj='PETITS DEGRES' or nom_maj='PONTS' or nom_maj='VOIES' or nom_maj= 'AIRES' or nom_maj='BARRIERES' or nom_maj='BEGUINAGES' or nom_maj='CARRIERES' or nom_maj='ALLEES' or nom_maj = 'ANCIENNES MONTEES' or nom_maj='ANCIENNES ROUTES' or nom_maj='ANCIENS CHEMINS' or nom_maj='ARCADES' or nom_maj='BERGES' or nom_maj='CITES' or nom_maj = 'COLLINES' or nom_maj='CORNICHES' or nom_maj='COTTAGES' or nom_maj='FERMES' or nom_maj= 'ECLUSES' or nom_maj='GALERIES' or nom_maj='GROUPES' or nom_maj='HALLES' or nom_maj='HAMEAUX' or nom_maj='IMMEUBLES' or nom_maj='JARDINS' or nom_maj='ESCALES' or nom_maj='MARCHES' or nom_maj='MOULINS' or nom_maj='PARCS' or nom_maj = 'PASSERELLES' or nom_maj='PAVILLONS' or nom_maj = 'PLAGES' or nom_maj='PLATEAUX' or nom_maj = 'VILLAS' or nom_maj='VILLAGES' or nom_maj='CHEMINS VICINAUX' or nom_maj='CLAUX';" >> commandeTemp.sql
echo "UPDATE abbreviations set priorite= 0 where nom_maj= 'SENTE' or nom_maj='SENTES' or nom_maj='STR' or nom_maj= 'VAL' or nom_maj='VALLON' or nom_maj= 'COTE' or nom_maj = 'GRANDES RUES';" >> commandeTemp.sql

psql -d ${dbname} -U ${user} -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de la preparation"
   exit 1
fi

exit

rm commandeTemp.sql


echo "FIN"







