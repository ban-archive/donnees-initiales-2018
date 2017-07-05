#!/bin/sh
# But : preparer et exporter des fichiers json pour un departement directement
# importable dans la ban
# avec la commande ban import:init
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel seront generes les json
#           * $2 : departement à traiter
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
# SORTIE : les fichiers json dans $1 :
# - a completer
#############################################################################
#  Les donnees doivent etre dans la base ban_init en local et avoir la structure provenant
# des csv IGN
#############################################################################
data_path=$1
dep=$2

if [ $# -ne 2 ]; then
        echo "Usage : export_json.sh <outPath> <dep>"
        exit 1
fi

#verification du repertoire data_path
mkdir ${data_path}
rm -r ${data_path}/${dep}
mkdir ${data_path}/${dep}

###############################################################################
# MUNICIPALITY
# Extraction du departement
echo "DROP TABLE IF EXISTS insee_cog${dep};" > commandeTemp.sql
echo "CREATE TABLE insee_cog${dep} AS SELECT * FROM insee_cog WHERE insee like '${dep}%';" >> commandeTemp.sql
# remplacement des articles null par ''
echo "UPDATE insee_cog${dep} set artmin = coalesce(artmin,'');"  >> commandeTemp.sql
# Suppression des parentheses sur les articles
echo "UPDATE insee_cog${dep} set artmin = replace(artmin,'(','');"  >> commandeTemp.sql
echo "UPDATE insee_cog${dep} set artmin = replace(artmin,')','');"  >> commandeTemp.sql
# on ajoute le champ name
echo "ALTER TABLE insee_cog${dep} ADD COLUMN name varchar;" >> commandeTemp.sql
echo "UPDATE insee_cog${dep} set name = trim(artmin ||' ' || nccenr);" >> commandeTemp.sql
echo "UPDATE insee_cog${dep} set name = replace(name, E'\' '::text, E'\''::text);" >> commandeTemp.sql
# exporte en json
echo "\COPY (select format('{\"source\": \"\", \"type\":\"municipality\",\"insee\":\"%s\",\"name\":\"%s\"}',insee,name) from insee_cog${dep}) to '${data_path}/${dep}/01_municipalities.json';" >> commandeTemp.sql

#####################################################################################
# POSTCODE
# Extraction du departement
echo "DROP TABLE IF EXISTS postcode${dep};" >> commandeTemp.sql
echo "CREATE TABLE postcode${dep} AS SELECT co_postal, co_insee, lb_l6 FROM poste_cp WHERE co_insee like '${dep}%' group by co_postal, co_insee, lb_l6;" >> commandeTemp.sql
# exporte en json
echo "\COPY (select format('{\"source\": \"\", \"type\":\"postcode\",\"postcode\":\"%s\",\"name\":\"%s\",\"municipality:insee\":\"%s\"}',co_postal,lb_l6,co_insee) from postcode${dep}) to '${data_path}/${dep}/02_postcodes.json';" >> commandeTemp.sql

#####################################################################################
# GROUP
# Creation de la table group${dep}
echo "DROP TABLE IF EXISTS group${dep};" >> commandeTemp.sql
echo "CREATE TABLE group${dep}(
name character varying(200) NOT NULL,
alias character varying(255),
kind character varying(64) NOT NULL,
addressing character varying(16),
fantoir character varying(255),
laposte character varying(8),
ign character varying(24),
municipality_insee varchar NOT NULL,
nom_norm varchar);" >> commandeTemp.sql

#########################
# preparation de la table group_fantoir
# Extraction du departement
echo "DROP TABLE IF EXISTS group_fantoir${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_fantoir${dep} AS SELECT * FROM dgfip_fantoir where code_dept like '${dep}%';" >> commandeTemp.sql
# Majuscule désaccentué
echo "update group_fantoir${dep} set libelle_voie=upper(unaccent(libelle_voie));" >> commandeTemp.sql
# Nettoyage doubles espaces, apostrophes, trait d'union
echo "update group_fantoir${dep} set libelle_voie=regexp_replace(libelle_voie,E'([\'-]|  *)',' ','g') WHERE libelle_voie ~ E'([\'-]|  )';" >> commandeTemp.sql
# Pour eviter les RUE RUE VICTOR HUGO
echo "update group_fantoir${dep} set nature_voie=trim(nom_long), libelle_voie=trim(substr(libelle_voie,length(nom_long)+1)) from abbrev where libelle_voie like nom_long||' %';" >> commandeTemp.sql
echo "update group_fantoir${dep} set nature_voie=trim(nom_long), libelle_voie=trim(substr(libelle_voie,length(nom_court)+1)) from abbrev where libelle_voie like nom_court||' %';" >> commandeTemp.sql
# Désabréviation de la nature_voie
echo "update group_fantoir${dep} set nature_voie=nom_long from abbrev where nature_voie=nom_court and code like '2';" >> commandeTemp.sql
# Creation de la colonne kind
echo "ALTER TABLE group_fantoir${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET kind=abbrev.kind from abbrev where nature_voie like nom_long;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET kind='area' WHERE kind is null;" >> commandeTemp.sql
# Creation de la colonne fantoir_9
echo "ALTER TABLE  group_fantoir${dep} ADD COLUMN fantoir_9 varchar;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET fantoir_9=left(replace(fantoir,'_',''),9);" >> commandeTemp.sql
# Creation de la colonne name
echo "ALTER TABLE group_fantoir${dep} ADD COLUMN name varchar;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET name=trim(replace(format('%s %s',nature_voie,libelle_voie),'\"',' '));" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET name=libelle_voie from abbrev a, abbrev b where a.nom_long=libelle_voie and  b.nom_long=nature_voie and a.nom_court=b.nom_court;" >> commandeTemp.sql 

########################
# Integration dans la table group${dep}
echo "INSERT INTO group${dep} (kind, municipality_insee, fantoir, name, nom_norm) 
SELECT kind, code_insee, fantoir_9, f.name , f.name from group_fantoir${dep} f, insee_cog${dep} where insee=code_insee;" >> commandeTemp.sql


#################################
# Preparation de la table group_ign
# Extraction du departement
echo "DROP TABLE IF EXISTS group_ign${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_ign${dep} AS SELECT * FROM ign_group WHERE code_insee like '${dep}%';" >> commandeTemp.sql
# Suppression des detruits
echo "DELETE FROM group_ign${dep} WHERE detruit is not null;" >> commandeTemp.sql
# normalisation du nom
echo "ALTER TABLE  group_ign${dep} ADD COLUMN nom_norm varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET nom_norm=upper(unaccent(nom));" >> commandeTemp.sql
# doubles espaces, apostrophe, tiret
echo "UPDATE group_ign${dep} SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';" >> commandeTemp.sql
# Creation de la colonne fantoir_9
echo "ALTER TABLE  group_ign${dep} ADD COLUMN fantoir_9 varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET fantoir_9=code_insee||id_fantoir;" >> commandeTemp.sql
# Creation de la colonne addressing
echo "ALTER TABLE  group_ign${dep} ADD COLUMN addressing varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET addressing=case when type_d_adressage='Classique' then 'classical' when type_d_adressage='Mixte' then 'mixed' when type_d_adressage='Linéaire' then 'linear' when type_d_adressage='Anarchique' then 'anarchical' when type_d_adressage='Métrique' then 'metric' else '' end;" >> commandeTemp.sql
# Creation de la colonne kind
echo "ALTER TABLE  group_ign${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET kind=abbrev.kind from abbrev where nom_norm like nom_long||' %';" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET kind='area' where kind is null;" >> commandeTemp.sql


#################################
# complete les groups deja dans la ban ayant un id fantoir avec les infos des groups ign avec le meme id fantoir
# les infos ajoutées sont : ign, alias et addressing
# Mise a jour de la table group${dep}
echo "UPDATE group${dep} SET ign=g.id_pseudo_fpb, addressing=g.addressing, alias=g.alias, laposte = g.id_poste from group_ign${dep} g where g.fantoir_9=fantoir;" >> commandeTemp.sql

#########################################
# GROUP IGN NON RETROUVE DANS FANTOIR (avec l'id fantoir) : ajoute ces groups dans la ban
# Integration dans la table group${dep}
echo "INSERT INTO group${dep} (kind, ign, name, municipality_insee, addressing, alias, laposte, nom_norm) 
SELECT g.kind, g.id_pseudo_fpb, g.nom, g.code_insee, g.addressing, g.alias, g.id_poste, g.nom_norm from group_ign${dep} g where id_fantoir is null;" >> commandeTemp.sql


#######################################
# GROUP LAPOSTE : preparation
# Extraction du departement
echo "DROP TABLE IF EXISTS group_ran${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_ran${dep} AS SELECT * FROM ran_group WHERE co_insee like '${dep}%';" >> commandeTemp.sql
# Creation de la colonne laposte
echo "ALTER TABLE  group_ran${dep} ADD COLUMN laposte varchar;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET laposte=right('0000000'||co_voie,8);" >> commandeTemp.sql
# Creation de la colonne kind
echo "ALTER TABLE group_ran${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET kind=abbrev.kind from abbrev where lb_voie like nom_long||' %';" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET kind='area' WHERE kind is null;" >> commandeTemp.sql


#####################################
# AJOUT DES GROUPES LAPOSTE NON RETROUVES 
echo "INSERT INTO group${dep} (kind, name, municipality_insee, laposte, nom_norm)
SELECT g.kind, g.lb_voie, g.co_insee, g.laposte, g.lb_voie from group_ran${dep} g left join group${dep} on g.laposte = group${dep}.laposte where municipality_insee is null; " >> commandeTemp.sql

echo "\COPY (select format('{\"source\": \"\", \"type\":\"group\",\"group\":\"%s\",\"municipality:insee\":\"%s\" %s ,\"name\":\"%s\" %s %s %s %s}',kind,municipality_insee, case when fantoir is not null then ',\"fantoir\": \"'||fantoir||'\"' else '' end, name, case when ign is not null then ',\"ign\": \"'||ign||'\"' else '' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' else '' end, case when alias is not null then ',\"alias\": \"'||alias||'\"' else '' end, case when addressing is not null then ',\"addressing\": \"'||addressing||'\"' else '' end) from group${dep}) to '${data_path}/${dep}/03_groups.json';" >> commandeTemp.sql

#########################################
# GROUP LAPOSTE RETOUVES
# Extraction du departement
#echo "DROP TABLE IF EXISTS group_ran${dep};" >> commandeTemp.sql
#echo "CREATE TABLE group_ran${dep} AS SELECT * FROM ran_group WHERE co_insee like '${dep}%';" >> commandeTemp.sql
# Creation de la colonne laposte
#echo "ALTER TABLE  group_ran${dep} ADD COLUMN laposte varchar;" >> commandeTemp.sql
#echo "UPDATE group_ran${dep} SET laposte=right('0000000'||co_voie,8);" >> commandeTemp.sql
# Mise a jour de la table group${dep}
#echo "UPDATE group${dep} SET laposte=r.laposte from group_ran${dep} r 
#WHERE municipality_insee=r.co_insee and r.lb_voie=nom_norm;" >> commandeTemp.sql
# Mise ajour de la table group_ran${dep}
#echo "ALTER TABLE  group_ran${dep} ADD COLUMN ign varchar;" >> commandeTemp.sql
#echo "UPDATE group_ran${dep} SET ign=g.ign from group${dep} g where g.municipality_insee=co_insee and lb_voie=g.nom_norm;" >> commandeTemp.sql
#echo "ALTER TABLE  group_ran${dep} ADD COLUMN fantoir varchar;" >> commandeTemp.sql
#echo "UPDATE group_ran${dep} SET fantoir=g.fantoir from group${dep} g where g.municipality_insee=co_insee and lb_voie=g.nom_norm;" >> commandeTemp.sql

#######################################
# GROUP LAPOSTE NON RETROUVES
# Creation de la colonne kind
#echo "ALTER TABLE group_ran${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
#echo "UPDATE group_ran${dep} SET kind=abbrev.kind from abbrev where lb_voie like nom_long||' %';" >> commandeTemp.sql
#echo "UPDATE group_ran${dep} SET kind='area' WHERE kind is null;" >> commandeTemp.sql
# Insertion dans la table group${dep}
#echo "INSERT INTO group${dep} (kind, name, municipality_insee, laposte, nom_norm)
#SELECT g.kind, g.lb_voie, g.co_insee, g.laposte, g.lb_voie from group_ran${dep} g where laposte not in ( select laposte from group${dep});" >> commandeTemp.sql

#########################################
# NOMS CADASTRES
echo "UPDATE group${dep} g SET name=voie_cadastre FROM dgfip_noms_cadastre c WHERE left(c.fantoir,9)=g.fantoir;" >> commandeTemp.sql
echo "UPDATE group${dep} SET name=regexp_replace(name,'\"','','g');" >> commandeTemp.sql

echo "\COPY (select format('{\"source\": \"\", \"type\":\"group\",\"group\":\"%s\",\"municipality:insee\":\"%s\" %s ,\"name\":\"%s\" %s %s %s %s}',kind,municipality_insee, case when fantoir is not null then ',\"fantoir\": \"'||fantoir||'\"' else '' end, name, case when ign is not null then ',\"ign\": \"'||ign||'\"' else '' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' else '' end, case when alias is not null then ',\"alias\": \"'||alias||'\"' else '' end, case when addressing is not null then ',\"addressing\": \"'||addressing||'\"' else '' end) from group${dep}) to '${data_path}/${dep}/03_groups.json';" >> commandeTemp.sql


#################################################################################
# HOUSENUMBER
# Creation de la table housenumber${dep}
echo "DROP TABLE IF EXISTS housenumber${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber${dep} (\"number\" varchar, ordinal varchar, cia varchar, laposte varchar, ign varchar, group_fantoir varchar, group_ign varchar, group_laposte varchar, postcode_code varchar, insee varchar, no_pile_doublon integer);" >> commandeTemp.sql

###################################
# Preparation de la table housenumber_bano
# Extraction du departement
echo "DROP TABLE IF EXISTS housenumber_bano${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_bano${dep} AS SELECT * FROM dgfip_housenumbers WHERE insee_com like '${dep}%';" >> commandeTemp.sql
# Creation de la colonne fantoir_hn
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN fantoir_hn varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET fantoir_hn=left(fantoir,5)||left(right(fantoir,5),4);" >> commandeTemp.sql
# Creation de la colonne number
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN number varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET number=left(numero||' ',strpos(numero||' ',' ')-1);" >> commandeTemp.sql
# Creation de la colonne ordinal
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN ordinal varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET ordinal=upper(trim(right(numero||' ',-strpos(numero||' ',' '))));" >> commandeTemp.sql
# Creation de la colonne cia
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN cia varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET cia=upper(format('%s_%s_%s_%s',left(fantoir,5),left(right(fantoir,5),4),number,ordinal));" >> commandeTemp.sql


# Insertion dans la table housenumber${dep}
echo "INSERT INTO housenumber${dep} (group_fantoir,number, ordinal, insee)
SELECT fantoir_hn, number, ordinal, insee_com from housenumber_bano${dep} h, group${dep} g where fantoir_hn=g.fantoir;" >> commandeTemp.sql


########################################
# PREPARATION HOUSENUMBER IGN
# Extraction du departement / suppression des doublons parfaits / suppression des detruits
echo "DROP TABLE IF EXISTS housenumber_ign${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_ign${dep} AS SELECT max(id) as id, max(id_poste) as id_poste, numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode FROM ign_housenumber WHERE code_insee like '${dep}%' and detruit is null group by (numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode);" >> commandeTemp.sql
# Passage en majuscule du rep
echo "UPDATE housenumber_ign${dep} SET rep = upper(rep);" >> commandeTemp.sql
#Marquage des doublons (meme numero et indice de repetition)
# etape1 : creation des piles de doublons sémantiques
echo "DROP TABLE IF EXISTS doublon_ign_${dep};" >> commandeTemp.sql
echo "CREATE TABLE doublon_ign_${dep} AS SELECT numero,rep,code_post,code_insee,id_pseudo_fpb,count(*) FROM housenumber_ign${dep} GROUP BY (numero,rep,code_post,code_insee,id_pseudo_fpb) HAVING COUNT(*) > 1;" >> commandeTemp.sql
echo "DROP SEQUENCE IF EXISTS seq_doublons_ign_${dep};" >> commandeTemp.sql
echo "CREATE SEQUENCE seq_doublons_ign_${dep};" >> commandeTemp.sql
echo "ALTER TABLE doublon_ign_${dep} ADD no_pile_doublon integer;" >> commandeTemp.sql
echo "UPDATE doublon_ign_${dep} SET no_pile_doublon = nextval('seq_doublons_ign_${dep}');" >> commandeTemp.sql

# etape 2 : marquage du numéro de piles doublons sémantiques sur les hns ign
echo "ALTER TABLE housenumber_ign${dep} ADD no_pile_doublon integer;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} AS hn SET no_pile_doublon = d.no_pile_doublon FROM doublon_ign_${dep} AS d WHERE 
	(hn.numero = d.numero and 
	 hn.rep = d.rep and 
	 hn.code_post = d.code_post and
	 hn.code_insee = d.code_insee and
	 hn.id_pseudo_fpb = d.id_pseudo_fpb);" >> commandeTemp.sql

# Creation de la colonne fantoir
echo "ALTER TABLE  housenumber_ign${dep} ADD COLUMN fantoir varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} SET fantoir=g.fantoir_9 FROM group_ign${dep} g WHERE housenumber_ign${dep}.id_pseudo_fpb=g.id_pseudo_fpb;" >> commandeTemp.sql


########################################
# HOUSENUMBER IGN GROUP RAPPROCHES
# Mise a jour du champ group_ign de housenumber${dep}
echo "update housenumber${dep} h set group_ign=i.id_pseudo_fpb from housenumber_ign${dep} i where h.group_fantoir=i.fantoir;" >> commandeTemp.sql
# Mise a jour du champ ign de housenumber${dep}
echo "update housenumber${dep} h set ign=i.id from housenumber_ign${dep} i where h.group_ign=i.id_pseudo_fpb and h.number=i.numero and h.ordinal=i.rep;" >> commandeTemp.sql
# Mise a jour de no_pile_doublon
echo "update housenumber${dep} h set no_pile_doublon=i.no_pile_doublon from housenumber_ign${dep} i where h.ign=i.id;" >> commandeTemp.sql

###########################################
# HOUSENUMBER IGN GROUP NON RAPPROCHES
# Ajout des housenumber_ign non retrouves dans  housenumber${dep} (cles = fantoir, numero, dep) et dont le fantoir n'est pas nul
echo "INSERT INTO housenumber${dep} (ign, group_fantoir, group_ign, number, ordinal, insee, no_pile_doublon)
SELECT max(i.id), i.fantoir, i.id_pseudo_fpb, i.numero, i.rep, i.code_insee, i.no_pile_doublon from housenumber_ign${dep} i
left join housenumber${dep} h on (h.group_fantoir=i.fantoir and i.numero=h.number and i.rep=h.ordinal) where h.number is null and i.fantoir is not null group by i.fantoir, i.id_pseudo_fpb, i.numero, i.rep, i.code_insee, i.no_pile_doublon;" >> commandeTemp.sql
# Ajout dans la ban les housenumbers ign dont le fantoir est nul
echo "INSERT INTO housenumber${dep} (ign, group_ign, number, ordinal, insee, no_pile_doublon)
SELECT max(id), id_pseudo_fpb, numero, rep, code_insee, no_pile_doublon from housenumber_ign${dep} where fantoir is null group by id_pseudo_fpb, numero, rep, code_insee, no_pile_doublon;" >> commandeTemp.sql

########################################
# Mise à jour des champs la poste avec les données IGN
# Mise a jour du champ group_laposte de housenumber${dep}
echo "update housenumber${dep} h set group_laposte=g.id_poste from group_ign${dep} g where h.group_ign=g.id_pseudo_fpb ;" >> commandeTemp.sql
# Mise a jour du champ laposte de housenumber${dep}
echo "update housenumber${dep} h set laposte=i.id_poste from housenumber_ign${dep} i where h.ign=i.id;" >> commandeTemp.sql

##################################################
# Mise à jour du code postal avec les adresses IGN
echo "update housenumber${dep} h set postcode_code=i.code_post from housenumber_ign${dep} i where h.ign=i.id and i.code_post in (select co_postal from postcode${dep});" >> commandeTemp.sql

######################################
# Creation d'un housenumber null pour chaque group laposte, pour stoker le cea de la voie poste
# Insertion dans la table housenumber${dep}
echo "INSERT INTO housenumber${dep} (group_laposte, laposte, postcode_code, insee)
SELECT g.laposte, r.cea, r.co_postal, r.co_insee from group_ran${dep} r, group${dep} g where g.laposte=r.laposte and lb_l5 is null;" >> commandeTemp.sql


#####################################
# Preparation de housenumber_ran
# Extraction du departement
echo "DROP TABLE IF EXISTS housenumber_ran${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_ran${dep} AS SELECT * FROM ran_housenumber WHERE co_insee like '${dep}%';" >> commandeTemp.sql
# Creation de la colonne group_laposte
echo "ALTER TABLE  housenumber_ran${dep} ADD COLUMN group_laposte varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_ran${dep} SET group_laposte=right('0000000'||co_voie,8);" >> commandeTemp.sql
# Passage à vide de l'indice de répétition pour être conforme aux autres sources
echo "UPDATE housenumber_ran${dep} SET lb_ext='' where lb_ext is null;" >> commandeTemp.sql



#####################################
# Mise a jour de laposte dans la table housenumber${dep}
echo "UPDATE housenumber${dep} h SET laposte=r.co_cea FROM housenumber_ran${dep} r WHERE r.group_laposte=h.group_laposte and h.number=r.no_voie and h.ordinal=r.lb_ext and h.laposte is null;" >> commandeTemp.sql


# Mise a jour des postcodes null dans la table housenumber${dep}
echo "UPDATE housenumber${dep} h SET postcode_code=r.co_postal FROM housenumber_ran${dep} r WHERE r.co_cea=h.laposte and h.postcode_code is null;" >> commandeTemp.sql



#####################################
# HOUSENUMBERS LAPOSTE NON RAPPROCHES
# Insertion dans la table housenumber${dep}
echo "INSERT INTO housenumber${dep} (group_laposte, number, ordinal, postcode_code, insee, laposte)
SELECT r.group_laposte, r.no_voie, r.lb_ext, r.co_postal, r.co_insee, co_cea FROM housenumber_ran${dep} r left join housenumber${dep} h on (r.co_cea=h.laposte)  WHERE h.insee is null;" >> commandeTemp.sql

# Colonne CIA
echo "update housenumber${dep} set cia=upper(format('%s_%s_%s_%s',left(group_fantoir,5),right(group_fantoir,4),number, coalesce(ordinal,''))) where group_fantoir is not null;" >> commandeTemp.sql

# exporte en json
echo "\COPY (select format('{\"type\":\"housenumber\", \"source\":\"\", \"group:fantoir\":\"%s\", \"cia\":\"%s\" %s %s, \"numero\":\"%s\", \"ordinal\": \"%s\" %s}', group_fantoir, cia, case when ign is not null then ',\"ign\": \"'||ign||'\"' else '' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' else '' end, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\"' else '' end) from housenumber${dep} where group_fantoir is not null) to '${data_path}/${dep}/04_housenumbers.json';" >> commandeTemp.sql
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"source\":\"\", \"group:ign\":\"%s\" , \"ign\": \"%s\", \"numero\":\"%s\", \"ordinal\":\"%s\" %s}', group_ign, ign, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\"' else '' end) from housenumber${dep} where group_ign is not null and group_fantoir is null) to '${data_path}/${dep}/05_housenumbers.json';" >> commandeTemp.sql
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"source\":\"\", \"group:laposte\":\"%s\", \"laposte\":\"%s\", \"numero\": \"%s\", \"ordinal\":\"%s\" %s}', group_laposte, laposte, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\"' else '' end) from housenumber${dep} where group_laposte is not null and group_ign is null and group_fantoir is null) to '${data_path}/${dep}/06_housenumbers.json';" >> commandeTemp.sql


####################################################################################################
# POSITIONS
echo "DROP TABLE IF EXISTS position${dep};" >> commandeTemp.sql
echo "CREATE TABLE position${dep} (name varchar, lon varchar, lat varchar, housenumber_cia varchar, housenumber_ign varchar, housenumber_laposte varchar, kind varchar, positioning varchar, ign varchar, laposte varchar,no_pile_doublon integer);" >> commandeTemp.sql

#########################################
# POSITION IGN
echo "ALTER TABLE housenumber_ign${dep} ADD COLUMN cia varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} SET cia=format('%s_%s_%s_%s',left(fantoir,5), right(fantoir,4),numero, rep) where fantoir is not null;" >> commandeTemp.sql
# Creation de la colonne kind et positioning
echo "ALTER TABLE housenumber_ign${dep} ADD kind text;" >> commandeTemp.sql
echo "ALTER TABLE housenumber_ign${dep} ADD pos text;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} SET kind = CASE WHEN indice_de_positionnement = '5' THEN 'area' WHEN type_de_localisation = 'A la plaque' THEN 'entrance' WHEN type_de_localisation = 'Projetée du centre parcelle' THEN 'segment' WHEN type_de_localisation LIKE 'A la zone%' THEN 'area' WHEN type_de_localisation = 'Interpolée' THEN 'segment' ELSE 'unknown' END;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} SET pos = CASE WHEN type_de_localisation = 'Projetée du centre parcelle' THEN 'projection' WHEN type_de_localisation = 'Interpolée' THEN 'interpolation' ELSE 'other' END;" >> commandeTemp.sql
# Insertion dans la table des kind entrance
# 	Passe 1 : on ajoute une position par hn (on ne traite pas les piles)
echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign, no_pile_doublon)
SELECT i.cia, lon, lat, i.id, i.kind, i.pos ,i.id, i.no_pile_doublon FROM housenumber_ign${dep} i, housenumber${dep} h where i.id=h.ign and (i.kind not like 'segment' and i.kind not like 'unknown') and i.no_pile_doublon is null;" >> commandeTemp.sql
#       Passe 2 : on ajoute les piles
echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign, no_pile_doublon)
SELECT i.cia, i.lon, i.lat, h.ign, i.kind, i.pos ,i.id, i.no_pile_doublon FROM housenumber${dep} h left join housenumber_ign${dep} i on (h.no_pile_doublon=i.no_pile_doublon) where (i.kind not like 'segment' and i.kind not like 'unknown') and h.no_pile_doublon is not null;" >> commandeTemp.sql


##########################################
# POSITION DGFIP
# racroché au housenumber grace au cia
# Creation des colonnes x et y
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN x varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET x=round(lon::numeric,7)::text;" >> commandeTemp.sql
echo "ALTER TABLE  housenumber_bano${dep} ADD COLUMN y varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_bano${dep} SET y=round(lat::numeric,7)::text;" >> commandeTemp.sql
# Insertion dans la table position des positions bano pour les hn qui n'ont pas de positions ou pas de positions entrance 
echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, kind, positioning)
SELECT b.cia, b.x, b.y, 'entrance', 'other' FROM housenumber_bano${dep} b join (select cia from housenumber${dep} h left join position${dep} p on (p.housenumber_ign = h.ign) where p.kind not like 'entrance' or p.kind is null) as j on b.cia = j.cia;" >> commandeTemp.sql
# Insertion dans la table position des positions bano si elles sont eloignees de plus de 5 m des positions déjà existantes
echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, kind, positioning)
SELECT b.cia, b.x, b.y, 'entrance', 'other' FROM housenumber_bano${dep} b join position${dep} p on (b.cia=p.housenumber_cia) where st_distance(ST_GeographyFromText('POINT('||p.lon||' '||p.lat||')'),ST_GeographyFromText('POINT('||b.x||' '||b.y||')'))>5;" >> commandeTemp.sql


##########################################
# POSITION IGN
# Insertion dans la table des positions ign "segment" si il n'y a pas de position entrance dejà présente (en 2 passes sans pile puis pile)
# on commence par faire une table temporaire avec les housenumbers qui n'ont pas de position entrance
echo "DROP TABLE IF EXISTS housenumber_without_entrance${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_without_entrance${dep} AS SELECT * FROM housenumber${dep};" >> commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE ign IN (SELECT housenumber_ign FROM position${dep} where kind like 'entrance' );" >>  commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE cia in (select housenumber_cia from position${dep} where kind like 'entrance' );" >> commandeTemp.sql
echo "DELETE  FROM housenumber_without_entrance${dep} WHERE no_pile_doublon is not null;" >>  commandeTemp.sql

echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign)
SELECT i.cia, i.lon, i.lat, i.id, i.kind, i.pos, i.id FROM housenumber_ign${dep} i join housenumber_without_entrance${dep} as j on i.id=j.ign where i.kind like 'segment' and i.no_pile_doublon is null;" >> commandeTemp.sql

# Rebelote avec les piles
echo "DROP TABLE IF EXISTS housenumber_without_entrance${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_without_entrance${dep} AS SELECT * FROM housenumber${dep};" >> commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE ign IN (SELECT housenumber_ign FROM position${dep} where kind like 'entrance' );" >>  commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE cia in (select housenumber_cia from position${dep} where kind like 'entrance' );" >> commandeTemp.sql
echo "DELETE  FROM housenumber_without_entrance${dep} WHERE no_pile_doublon is null;" >>  commandeTemp.sql

echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign)
SELECT i.cia, i.lon, i.lat, j.ign, i.kind, i.pos, i.id FROM housenumber_ign${dep} i join housenumber_without_entrance${dep} as j on (i.no_pile_doublon=j.no_pile_doublon) where i.kind like 'segment' and i.no_pile_doublon is not null;" >> commandeTemp.sql


echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\", \"positioning\":\"%s\", \"source\":\"\", \"housenumber:cia\": \"%s\", \"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}}',kind, positioning, housenumber_cia, ign, lon, lat) from position${dep} where housenumber_cia is not null) to '${data_path}/${dep}/07_positions.json';" >> commandeTemp.sql 
echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\", \"positioning\":\"%s\", \"source\":\"\", \"housenumber:ign\": \"%s\", \"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}}', kind, positioning, housenumber_ign, ign, lon, lat, ign) from position${dep} where housenumber_cia is null and housenumber_ign is not null) to '${data_path}/${dep}/08_positions.json';" >> commandeTemp.sql

psql -e -f commandeTemp.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l export des jsons"
  exit 1
fi

exit

rm commandeTemp.sql

echo "FIN"

