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
echo "CREATE TABLE ign_group (id_pseudo_fpb varchar, nom varchar, alias varchar, type_d_adressage varchar, id_poste varchar, nom_afnor varchar,id_postes varchar,id_fantoir varchar,id_fantoirs varchar, code_insee varchar, insee_obs varchar, source varchar, detruit boolean);" >> commandeTemp.sql
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

# prise en compte des fusions de communes : si un group ne pointe pas vers l'insee du cog et pointe vers un insee_old de la table de fusion de commmune :
# alors on met a jour son code insee et on bascule le code insee d'origine dans l'insee old
#on l'ajoute ici à cause des changements de départements autrement on aurait pu l'ajouter dans export_json.sh
echo "Mise a jour insee groupe suite au fusion de communes"
psql -c "
alter table ign_group add column insee_cog varchar;
update ign_group set insee_cog = insee_cog.insee FROM insee_cog where insee_cog.insee = ign_group.code_insee;
update ign_group set code_insee = f.insee_new, insee_obs = f.insee_old from fusion_commune as f where ign_group.code_insee = f.insee_old and ign_group.insee_cog is null;"

# Création des indexes
echo "Création des indexes"
psql -e -c '
-- geométrie des points adresse
ALTER TABLE ign_housenumber ADD geom geometry;
-- index pour ign_housenumber
CREATE INDEX idx_ign_housenumber_id ON ign_housenumber(id);
CREATE INDEX idx_ign_housenumber_code_insee ON ign_housenumber(code_insee);
CREATE INDEX idx_ign_housenumber_pseudo_fpb ON ign_housenumber(id_pseudo_fpb);
CREATE INDEX idx_ign_housenumber_geom ON ign_housenumber USING gist (geom);

-- index pour ign_group
CREATE INDEX idx_ign_group_code_insee ON ign_group(code_insee);
CREATE UNIQUE INDEX idx_ign_group_pseudo_fpb ON ign_group(id_pseudo_fpb);
'


if [ $? -ne 0 ]
then
   echo "Erreur lors de la creation des indexes "
   exit 1
fi

rm commandeTemp.sql


echo "FIN"







