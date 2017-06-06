#!/bin/sh
# But : preparer et exporter un fichier json directement importable dans la ban 
# avec la commande ban import:init
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel seront generes les json
#	    * $2 : departement à traiter 
################################################################################
#  Les donnees doivent etre dans la base ban_init en local et avoir la structure provenant 
# des csv IGN
#############################################################################
data_path=$1
dep=$2

if [ $# -ne 2 ]; then
        echo "Usage : export_json.sh <outPath> <dep>"
        exit 1
fi

dbname=ban_init

#Fonction pour enlever les accents
echo "CREATE OR REPLACE FUNCTION unaccent_string(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE SQL
AS \$\$
SELECT translate(
    \$1,
    'àâãäåÀÁÂÃÄÅèééêëÈÉÉÊËìíîïìÌÍÎÏÌóôõöÒÓÔÕÖùúûüÙÚÛÜçÇ',
    'aaaaaAAAAAAeeeeeEEEEEiiiiiIIIIIooooOOOOOuuuuUUUUcC'
);
\$\$;" > commandeTemp.sql


#########################
# MUNICIPALITY
echo "\COPY (select format('{\"type\":\"municipality\",\"source\":\"INSEE/COG (2016)\",\"insee\":\"%s\",\"name\":\"%s\"}',code_insee,nom_commune) from municipality${dep} )  to '${data_path}/${dep}_municipality.json'" >> commandeTemp.sql

#########################
# GROUP
echo "DROP TABLE IF EXISTS group${dep}_temp ;" >> commandeTemp.sql
echo "CREATE TABLE group${dep}_temp AS SELECT * FROM group${dep};" >> commandeTemp.sql

# suppression des detruits
echo "DELETE FROM group${dep}_temp WHERE detruit = true;">> commandeTemp.sql

#accentuation des mots directeur
echo "ALTER TABLE abbreviations ADD COLUMN nom_min_unaccent varchar;">>commandeTemp.sql
echo "UPDATE abbreviations SET nom_min_unaccent = unaccent_string(nom_min);">>commandeTemp.sql
echo "UPDATE group${dep}_temp AS G SET nom=regexp_replace(nom,'^'||A.nom_min_unaccent||' ',A.nom_min|| ' ') FROM abbreviations as A where G.nom like A.nom_min_unaccent||' %';">>commandeTemp.sql

# normalisation des noms (passage en majuscules, non accentuees, abregees)
echo "ALTER TABLE group${dep}_temp ADD COLUMN nom_unaccent varchar;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET nom_unaccent = unaccent_string(upper(nom));" >> commandeTemp.sql
echo "ALTER TABLE group${dep}_temp ADD COLUMN nom_normalise varchar;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp AS G SET nom_normalise = regexp_replace(nom_unaccent,'^' || A.nom_maj || ' ',A.nom_abbr || ' ') FROM abbreviations as A where G.nom_unaccent like A.nom_maj||' %' ;" >> commandeTemp.sql
#echo "UPDATE group${dep}_temp AS G SET nom_normalise = replace(nom_normalise,' ' || A.nom_maj || ' ',' ' || A.nom_abbr || ' ') FROM abbreviations AS A  where G.nom_normalise like '% ' || A.nom_maj ||' %';" >> commandeTemp.sql
echo "UPDATE group${dep}_temp AS G SET nom_normalise = nom_unaccent where nom_normalise is null;" >> commandeTemp.sql

# remplisage du kind
echo "ALTER TABLE group${dep}_temp ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp AS G SET kind = A.kind FROM abbreviations as A where (regexp_split_to_array (nom_normalise,' '))[1] = A.nom_abbr;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET kind='way' WHERE (regexp_split_to_array (nom_normalise,' '))[1] = 'PISTE';" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET kind='way' WHERE (regexp_split_to_array (nom_normalise,' '))[1] = 'GRAND RUE';" >> commandeTemp.sql
echo "UPDATE group${dep}_temp AS G SET kind = 'area' WHERE kind IS NULL;" >> commandeTemp.sql

# Calcul du nom final en minuscules, si possible accentuees, desabrege et capitalise
echo "ALTER TABLE group${dep}_temp ADD COLUMN nom_final varchar;" >> commandeTemp.sql
# S'il est deja en minuscule, on prend le nom d'origine (il vient des pseudo-voies qui sont correctes)
echo "UPDATE group${dep}_temp AS G SET nom_final = nom where nom ~ '[a-z]' ;" >> commandeTemp.sql
# Autrement on prend le nom normalise et on le desabrege
echo "UPDATE group${dep}_temp AS G SET nom_final = regexp_replace(nom_normalise,'^' || A.nom_abbr || ' ',A.nom_min || ' ') FROM abbreviations as A where G.nom_normalise like A.nom_abbr||' %' and nom_final is null and A.priorite = '2';" >> commandeTemp.sql
# Remplissage complementaire si le nom final est vide avec nom (cas où le nom d'origine n'est ni en minuscule accentuées et ne contient pas de type de voie)
echo "UPDATE group${dep}_temp AS G SET nom_final = nom where nom_final is null ;" >> commandeTemp.sql

# Passage en minuscules capitalisées
echo "UPDATE group${dep}_temp AS G SET nom_final = initcap(nom_final);" >> commandeTemp.sql

#Correction des chiffres romains
echo "ALTER TABLE group${dep}_temp ADD COLUMN chiffre text;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET chiffre = substring(nom_final, ' [XVIxvi]{1,} ');">> commandeTemp.sql
echo "UPDATE group${dep}_temp SET chiffre = substring(nom_final, ' [XVIxvi]{1,}$') WHERE chiffre is null;" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET nom_final = replace(nom_final,chiffre, upper(chiffre)) WHERE chiffre is not null;" >> commandeTemp.sql

# TODO: accents et apostrophes

# remplissage type d'adressage en anglais
echo "UPDATE group${dep}_temp SET type_d_adressage ='classical' WHERE type_d_adressage = 'Classique' ;">> commandeTemp.sql
echo "UPDATE group${dep}_temp SET type_d_adressage ='metric' WHERE type_d_adressage = 'Métrique';" >> commandeTemp.sql
echo "UPDATE group${dep}_temp SET type_d_adressage ='linear' WHERE type_d_adressage = 'Linéaire' ;">> commandeTemp.sql
echo "UPDATE group${dep}_temp SET type_d_adressage ='mixed' WHERE type_d_adressage = 'Mixte' ;">> commandeTemp.sql
echo "UPDATE group${dep}_temp SET type_d_adressage ='anarchical' WHERE type_d_adressage = 'Anarchique' ;">> commandeTemp.sql
echo "UPDATE group${dep}_temp SET id_fantoir=(code_insee || id_fantoir);">> commandeTemp.sql 
echo "UPDATE group${dep}_temp SET nom_final = replace(nom_final,'\"',''); ">> commandeTemp.sql

# TODO: multiples fantoir et idposte?
echo "\COPY (select format('{\"type\":\"group\",\"source\":\"%s\",\"group\":\"%s\",\"municipality:insee\":\"%s\",\"fantoir\":\"%s\",\"name\":\"%s\",\"addressing\":\"%s\",\"laposte\":\"%s\",\"ign\":\"%s\"}',source,kind,code_insee,id_fantoir,nom_final,type_d_adressage,id_poste,id_pseudo_fpb) from group${dep}_temp)  to '${data_path}/${dep}_group.json'" >> commandeTemp.sql

####################################
# POSTCODE
echo "\COPY (select format('{\"type\":\"postcode\",\"source\":\"La Poste\",\"postcode\":\"%s\",\"name\":\"%s\",\"municipality:insee\":\"%s\"}',code_post, libelle, code_insee) from postcode${dep})to '${data_path}/${dep}_postcode.json'" >> commandeTemp.sql

####################################
# HOUSENUMBER
# fichiers de Quest: {"type":"housenumber", "source":"BAN (2016-06-05)", "cia":"06001_0020_1001_", "group:fantoir":"060010020", "numero":"1001", "ordinal":"", "ign":"ADRNIVX_0000000261486167", "postcode:code":"06910"}
# delete detruit
echo "DELETE FROM house_number${dep}  WHERE detruit = true;">> commandeTemp.sql
# TODO: doublons à supprimer?
echo "\COPY (select format('{\"type\":\"housenumber\", \"source\":\"%s\", \"laposte\":\"%s\",\"ign\":\"%s\", \"group:ign\":\"%s\", \"numero\":\"%s\", \"ordinal\":\"%s\", \"postcode:code\":\"%s\", \"municipality:insee\":\"%s\"}',source, id_poste, id, id_pseudo_fpb,numero,rep,code_post,code_insee) from house_number${dep})to '${data_path}/${dep}_housenumber.json'" >> commandeTemp.sql

echo "DROP TABLE IF EXISTS position${dep}_temp ;" >> commandeTemp.sql
echo "CREATE TABLE position${dep}_temp AS SELECT * FROM house_number${dep};" >> commandeTemp.sql
# ajout colonne kind et interpolation
echo "ALTER TABLE position${dep}_temp ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "ALTER TABLE position${dep}_temp ADD COLUMN positioning  varchar;" >> commandeTemp.sql
echo "UPDATE position${dep}_temp  SET designation_de_l_entree = replace(designation_de_l_entree,'"''"',''); ">> commandeTemp.sql
# supprimer ligne de position${dep} quand type_de_localisation = Au centre commune ou indice de positionnement = 6
echo "DELETE FROM position${dep}_temp WHERE type_de_localisation =  'Au centre commune' or indice_de_positionnement = '6' ;">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='entrance', positioning='other'  WHERE type_de_localisation = 'A la plaque' ;">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='area', positioning='other' WHERE indice_de_positionnement = '5' or type_de_localisation like 'A la zone d%' ;">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='segment', positioning='projection'  WHERE type_de_localisation = 'Projetée du centre parcelle' ;">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='segment', positioning ='interpolation' WHERE type_de_localisation = 'Interpolée' ;">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='building', positioning ='other' WHERE type_de_localisation like 'Au complément d%' and (designation_de_l_entree like 'BATIMENT%' or designation_de_l_entree like 'ENTREE%' or designation_de_l_entree like 'CAGE%');">> commandeTemp.sql
echo "UPDATE position${dep}_temp SET kind ='entrance', positioning ='base map' WHERE type_de_localisation like 'Au complément d%' and (designation_de_l_entree is null or designation_de_l_entree not like 'BATIMENT%' or designation_de_l_entree not like 'ENTREE%' or designation_de_l_entree not like 'CAGE%') ;" >> commandeTemp.sql

# TODO?:complément d adressage=name à garder dans le json?

###############################################
# POSITION
# fichiers Quest: {"type":"position", "kind":"unknown", "source":"BAN (2016-06-05)", "housenumber:cia": "06001_0020_1350_", "ign":"ADRNIVX_0000000261486172", "geometry": {"type":"Point","coordinates":[6.940988,43.862757]}}
echo "\COPY (select format('{\"type\":\"position\",\"kind\":\"%s\",\"positioning\":\"%s\", \"source\":\"%s\", \"housenumber:ign\":\"%s\", \"ign\":\"%s\",  \"geometry\": {\"type\":\"Point\",\"coordinates\":[\"%s\",\"%s\"]}}',kind, positioning, source_geom, id, id, lon, lat) from position${dep}_temp)to '${data_path}/${dep}_position.json'" >> commandeTemp.sql
# TODO: detruit?

# TODO remplir housenumber_group_through? comment?


psql -d ${dbname} -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l export des jsons"
   exit 1
fi

rm commandeTemp.sql

echo "FIN"







