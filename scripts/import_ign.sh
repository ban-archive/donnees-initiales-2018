#!/bin/sh
# But : importer les fichiers csv fournis par l IGN dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les csv 
################################################################################
# ENTREE : les fichiers a importer doivent etre dans $1 et avoir les noms suivants 
# - ban.municipality<dep> : les communes
# - ban.postcode<dep> : les codes postaux
# - ban.group<dep> : les groupes
# - ban.house_number<dep> : les points adresses (housenumber + position)
# il y a un ensemble de fichiers par département
##############################################################################
# SORTIE : les tables PostgreSQL suivantes :
# - ign_municipality
# - ign_postcode
# - ign_group
# - ign_house_number
#############################################################################
# REMARQUE : 
# - la base PostgreSQL, le port doivent être passés dans les variables d'environnement
#     PGDATABASE et PGUSER
# - truc pour dezipper les fichiers IGN : for i in *zip; do unzip "$i"; done

csvRep=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_ign.sh <outPath> "
	echo "Exemple : import_csv_ign.sh /home/ban/ban-site/app/data/adresses"
        exit 1
fi

# creation des tables
echo "DROP TABLE IF EXISTS ign_municipality;" > commandeTemp.sql
echo "CREATE TABLE ign_municipality (code_insee varchar, nom_commune varchar);" >> commandeTemp.sql
echo "DROP TABLE IF EXISTS ign_postcode;" >> commandeTemp.sql
echo "CREATE TABLE ign_postcode (code_post varchar, libelle varchar, code_insee varchar);" >> commandeTemp.sql
echo "DROP TABLE IF EXISTS ign_group;">> commandeTemp.sql
echo "CREATE TABLE ign_group (id_pseudo_fpb varchar, nom varchar, alias varchar, type_d_adressage varchar, id_poste varchar, nom_afnor varchar,id_postes varchar,id_fantoir varchar,id_fantoirs varchar, code_insee varchar,source varchar, detruit boolean);" >> commandeTemp.sql
echo "DROP TABLE IF EXISTS ign_housenumber;">> commandeTemp.sql
echo "CREATE TABLE ign_housenumber (id varchar,numero varchar,rep varchar,designation_de_l_entree varchar,type_de_localisation varchar,indice_de_positionnement varchar,methode varchar,lon double precision,lat double precision,code_post varchar,code_insee varchar, id_pseudo_fpb varchar,id_poste varchar, id_postes varchar, source varchar, source_geom varchar, detruit boolean);">> commandeTemp.sql

psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import des fichiers csv du departement ${dep}"
   exit 1
fi

#Renommage des fichiers _errors.cvs
for f in ${csvRep}/ban.house_number_errors*.csv ; do
  mv $f $f.err
done

# Remplissage des tables par chaque fichier de chaque type par département
for f in ${csvRep}/ban.municipality*.csv ; do
  echo "import $f" 
  psql -c "\COPY ign_municipality FROM '$f' WITH CSV HEADER DELIMITER ';'"
  if [ $? -ne 0 ]
  then
     echo "Erreur lors de l import du fichier $f"
     exit 1
  fi
done

for f in ${csvRep}/ban.postcode*.csv ; do
  echo "import $f"
  psql -c "\COPY ign_postcode FROM '$f' WITH CSV HEADER DELIMITER ';'"
  if [ $? -ne 0 ]
  then
     echo "Erreur lors de l import du fichier $f"
     exit 1
  fi
done

for f in ${csvRep}/ban.group*.csv ; do
  echo "import $f"
  psql -c "\COPY ign_group FROM '$f' WITH CSV HEADER DELIMITER ';'"
  if [ $? -ne 0 ]
  then
     echo "Erreur lors de l import du fichier $f"
     exit 1
  fi
done

for f in ${csvRep}/ban.house_number*.csv ; do
  echo "import $f"
  psql -c "\COPY ign_housenumber FROM '$f' WITH CSV HEADER DELIMITER ';'"
  if [ $? -ne 0 ]
  then
     echo "Erreur lors de l import du fichier $f"
     exit 1
  fi
done

psql -e -c '
-- geométrie des points adresse
ALTER TABLE ign_housenumber ADD geom geometry;
-- index pour ign_housenumber
--CREATE UNIQUE INDEX idx_ign_housenumber_id ON ign_housenumber(id);
CREATE INDEX idx_ign_housenumber_id ON ign_housenumber(id);
CREATE INDEX idx_ign_housenumber_insee ON ign_housenumber(code_insee);
CREATE INDEX idx_ign_housenumber_pseudo_fpb ON ign_housenumber(id_pseudo_fpb);
CREATE INDEX idx_ign_housenumber_geom ON ign_housenumber USING gist (geom);

-- fantoir2 pour ign_group
ALTER TABLE ign_group ADD fantoir2 text COLLATE "C";
-- index pour ign_group
CREATE INDEX idx_ign_group_insee_no_fantoir ON ign_group(code_insee) WHERE (id_fantoir IS NULL);
CREATE UNIQUE INDEX idx_ign_group_pseudo_fpb ON ign_group(id_pseudo_fpb);
'

if [ $? -ne 0 ]
then
   echo "Erreur lors de la creation des indexes "
   exit 1
fi

rm commandeTemp.sql


echo "FIN"







