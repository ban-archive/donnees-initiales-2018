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

if [ $# -lt 2 ]; then
        echo "Usage : export_json.sh <outPath> <dep>"
        exit 1
fi

#verification du repertoire data_path
mkdir ${data_path}
rm -r ${data_path}/${dep}
mkdir ${data_path}/${dep}

echo "\\\set ON_ERROR_STOP 1" > commandeTemp.sql
echo "\\\timing" >> commandeTemp.sql

###############################################################################
# MUNICIPALITY
# Extraction du departement
echo "DROP TABLE IF EXISTS insee_cog${dep};" >> commandeTemp.sql
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
echo "\COPY (select format('{\"type\":\"municipality\",\"insee\":\"%s\",\"name\":\"%s\"}',insee,name) from insee_cog${dep}) to '${data_path}/${dep}/01_municipalities.json';" >> commandeTemp.sql

#####################################################################################
# POSTCODE
# Extraction du departement
echo "DROP TABLE IF EXISTS postcode${dep};" >> commandeTemp.sql
echo "CREATE TABLE postcode${dep} AS SELECT co_postal, co_insee, lb_l6, lb_l5_nn FROM poste_cp WHERE co_insee like '${dep}%' group by co_postal, co_insee, lb_l6, lb_l5_nn;" >> commandeTemp.sql
# Fusion de commune
echo "ALTER TABLE postcode${dep} ADD COLUMN code_old_insee varchar;" >> commandeTemp.sql
echo "UPDATE postcode${dep} SET code_old_insee=co_insee;" >> commandeTemp.sql
echo "UPDATE postcode${dep} SET co_insee=insee_new from fusion_commune where co_insee=insee_old;" >> commandeTemp.sql
echo "UPDATE postcode${dep} SET code_old_insee=null where code_old_insee=co_insee;" >> commandeTemp.sql
echo "UPDATE postcode${dep} SET lb_l5_nn = lb_l6 where (lb_l5_nn is null or lb_l5_nn = '') and code_old_insee is not null;" >> commandeTemp.sql

# exporte en json
echo "\COPY (select format('{\"type\":\"postcode\",\"postcode\":\"%s\",\"name\":\"%s\",\"municipality:insee\":\"%s\" ,\"complement\":\"%s\"}',co_postal,lb_l6,co_insee, lb_l5_nn) from postcode${dep}) to '${data_path}/${dep}/02_postcodes.json';" >> commandeTemp.sql

#####################################################################################
# GROUP
# Creation de la table group${dep}
echo "drop table if exists group${dep};" >> commandeTemp.sql
echo "CREATE TABLE group${dep}(
name character varying(200) NOT NULL,
alias character varying(255),
kind character varying(64) NOT NULL,
addressing character varying(16),
fantoir character varying(255),
laposte character varying(8),
ign character varying(24),
municipality_insee varchar NOT NULL,
nom_norm varchar,
old_insee varchar,
nom_comp varchar,
nom_fantoir varchar,
nom_ign varchar,
nom_laposte varchar);" >> commandeTemp.sql
echo "CREATE INDEX idx_group_nom_norm${dep} ON group${dep}(nom_norm);" >> commandeTemp.sql
echo "CREATE INDEX idx_group_municipality_insee${dep} ON group${dep}(municipality_insee);" >> commandeTemp.sql
echo "CREATE INDEX idx_group_nom_comp${dep} ON group${dep}(nom_comp);" >> commandeTemp.sql

#########################
# preparation de la table group_fantoir
# Extraction du departement
echo "DROP TABLE IF EXISTS group_fantoir${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_fantoir${dep} AS SELECT * FROM dgfip_fantoir where code_dept like '${dep}%';" >> commandeTemp.sql
# Suppression des detruits
echo "DELETE FROM group_fantoir${dep} WHERE caractere_annul not like ' ';" >> commandeTemp.sql
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
# Fusion de commune
echo "ALTER TABLE group_fantoir${dep} ADD COLUMN code_old_insee varchar;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET code_old_insee=code_insee;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET code_insee=insee_new from fusion_commune where code_insee=insee_old;" >> commandeTemp.sql
echo "UPDATE group_fantoir${dep} SET code_old_insee=null where code_old_insee=code_insee;" >> commandeTemp.sql
########################
# Integration dans la table group${dep}
echo "INSERT INTO group${dep} (kind, municipality_insee, fantoir, name, nom_norm, nom_fantoir, old_insee) 
SELECT kind, code_insee, fantoir_9, f.name , f.name, f.name, f.code_old_insee from group_fantoir${dep} f, insee_cog${dep} where insee=code_insee;" >> commandeTemp.sql

#################################
# Preparation de la table group_ign
# Extraction du departement
echo "DROP TABLE IF EXISTS group_ign${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_ign${dep} AS SELECT * FROM ign_group WHERE code_insee like '${dep}%';" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ign_code_insee${dep} ON group_ign${dep}(code_insee);" >> commandeTemp.sql
# Suppression des detruits
echo "DELETE FROM group_ign${dep} WHERE detruit is not null;" >> commandeTemp.sql
# normalisation du nom
echo "ALTER TABLE  group_ign${dep} ADD COLUMN nom_norm varchar;" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ign_nom_norm${dep} ON group_ign${dep}(nom_norm);" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET nom_norm=upper(unaccent(nom));" >> commandeTemp.sql
# doubles espaces, apostrophe, tiret
echo "UPDATE group_ign${dep} SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';" >> commandeTemp.sql
# Creation de la colonne addressing
echo "ALTER TABLE  group_ign${dep} ADD COLUMN addressing varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET addressing=case when type_d_adressage='Classique' then 'classical' when type_d_adressage='Mixte' then 'mixed' when type_d_adressage='Linéaire' then 'linear' when type_d_adressage='Anarchique' then 'anarchical' when type_d_adressage='Métrique' then 'metric' else '' end;" >> commandeTemp.sql
# Creation de la colonne kind
echo "ALTER TABLE  group_ign${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET kind=abbrev.kind from abbrev where nom_norm like nom_long||' %';" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET kind='area' where kind is null;" >> commandeTemp.sql
# Fusion de communes
echo "ALTER TABLE group_ign${dep} ADD COLUMN old_insee varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET old_insee=code_insee;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET code_insee=insee_new from fusion_commune where code_insee=insee_old;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET old_insee=null where old_insee=code_insee;" >> commandeTemp.sql
# Creation de la colonne fantoir_9
echo "ALTER TABLE  group_ign${dep} ADD COLUMN fantoir_9 varchar;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET fantoir_9=code_insee||id_fantoir;" >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET fantoir_9=old_insee||id_fantoir where old_insee is not null"; >> commandeTemp.sql
echo "UPDATE group_ign${dep} SET fantoir_9=old_insee||id_fantoir from fusion_commune  where old_insee=insee_old;" >> commandeTemp.sql 

#################################
# complete les groups deja dans la ban ayant un id fantoir avec les infos des groups ign avec le meme id fantoir
# les infos ajoutées sont : ign, alias et addressing
# Mise a jour de la table group${dep}
echo "UPDATE group${dep} SET ign=g.id_pseudo_fpb, addressing=g.addressing, alias=g.alias, laposte = g.id_poste, nom_ign=g.nom_norm from group_ign${dep} g where g.fantoir_9=fantoir;" >> commandeTemp.sql

#########################################
# GROUP IGN NON RETROUVE DANS FANTOIR (avec l'id fantoir): appariement par le nom normalise
# On crée une table ou on compte le nombre d'éléments dans la pile nom_norm/municipality insee dans les table group et group_ign
echo "drop table if exists group_ign_doublon${dep};" >> commandeTemp.sql
echo "create table group_ign_doublon${dep} as (select count(*), nom_norm, code_insee from group_ign${dep} group by nom_norm, code_insee);" >> commandeTemp.sql
echo "drop table if exists group_fantoir_doublon${dep};" >> commandeTemp.sql
echo "create table group_fantoir_doublon${dep} as (select count(*), nom_norm, municipality_insee from group${dep} group by nom_norm, municipality_insee);" >> commandeTemp.sql
# On reporte le nombre dans les tables group et group_ign
echo "alter table group${dep} add column doublon_nom_norm integer;" >> commandeTemp.sql
echo "update group${dep} g1 set doublon_nom_norm=count from group_fantoir_doublon${dep} g2 where g1.nom_norm=g2.nom_norm and g2.municipality_insee=g1.municipality_insee;" >> commandeTemp.sql
echo "alter table group_ign${dep} add column doublon_nom_norm integer;" >> commandeTemp.sql
echo "update group_ign${dep} g1 set doublon_nom_norm=count from group_ign_doublon${dep} g2 where g1.nom_norm=g2.nom_norm and g2.code_insee=g1.code_insee;" >> commandeTemp.sql
# On met a jour l'id ign dans la table group pour les elements appareilles dont les tailles de piles sont egales a 1
echo "UPDATE group${dep} g1 SET ign=g.id_pseudo_fpb, addressing=g.addressing, alias=g.alias, laposte=g.id_poste, nom_ign=g.nom_norm from group_ign${dep} g where g1.ign is null and g.fantoir_9 is null and g1.laposte is null and g1.nom_norm=g.nom_norm and g.code_insee=g1.municipality_insee and g1.doublon_nom_norm=1 and g.doublon_nom_norm=1;" >> commandeTemp.sql

#########################################
# 2E PASSE AVEC LE NOM SANS ESPACES
# On utilise le meme processus que ci dessus mais en elevant les espaces des noms normalises
echo "ALTER TABLE group_ign${dep} ADD COLUMN nom_comp varchar;" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ign_nom_comp${dep} on group_ign${dep}(nom_comp);" >> commandeTemp.sql
echo "UPDATE group_ign${dep} set nom_comp=replace(nom_norm,' ','');" >> commandeTemp.sql
echo "UPDATE group${dep} SET nom_comp=replace(nom_norm,' ','');" >> commandeTemp.sql
echo "drop table if exists group_ign_doublon${dep};" >> commandeTemp.sql
echo "create table group_ign_doublon${dep} as (select count(*), nom_comp, code_insee from group_ign${dep} group by nom_comp, code_insee);" >> commandeTemp.sql
echo "drop table if exists group_fantoir_doublon${dep};" >> commandeTemp.sql
echo "create table group_fantoir_doublon${dep} as (select count(*), nom_comp, municipality_insee from group${dep} group by nom_comp, municipality_insee);" >> commandeTemp.sql
echo "update group${dep} g1 set doublon_nom_norm=count from group_fantoir_doublon${dep} g2 where g1.nom_comp=g2.nom_comp and g2.municipality_insee=g1.municipality_insee;" >> commandeTemp.sql
echo "update group_ign${dep} g1 set doublon_nom_norm=count from group_ign_doublon${dep} g2 where g1.nom_comp=g2.nom_comp and g2.code_insee=g1.code_insee;" >> commandeTemp.sql
echo "update group${dep} g1 set ign=g.id_pseudo_fpb, addressing=g.addressing, alias=g.alias, laposte=g.id_poste , nom_ign=g.nom_norm from group_ign${dep} g where g1.ign is null and g.fantoir_9 is null and g1.laposte is null and g1.nom_comp=g.nom_comp and g.doublon_nom_norm=1 and g1.doublon_nom_norm=1 and g1.municipality_insee=g.code_insee;" >> commandeTemp.sql


#######################################
# 3E PASSE AVEC APPARIEMENT FLOU
# On crée une table d'appariement de nom et on calcule la distance de levenshtein, la similarite et un indice de confiance (une note sur 20)
echo "drop table if exists doublon_flou${dep};" >> commandeTemp.sql
echo "create table doublon_flou${dep} as (select g1.nom_norm as nom_1, g2.nom_norm as nom_2, g1.id_pseudo_fpb as ign_1, g2.ign as ign_2, g1.fantoir_9 as fantoir_1, g2.fantoir as fantoir_2, cast(levenshtein(g1.nom_comp, g2.nom_comp,1,1,2) as float), g2.municipality_insee, similarity(g1.nom_norm,g2.nom_norm) from group_ign${dep} g1, group${dep} g2 where dmetaphone(g1.nom_norm)=dmetaphone(g2.nom_norm) and dmetaphone_alt(g1.nom_norm)=dmetaphone_alt(g2.nom_norm) and g1.code_insee=g2.municipality_insee);" >> commandeTemp.sql
echo "delete from doublon_flou${dep} d where exists (select * from group${dep} g where d.ign_1=g.ign);" >> commandeTemp.sql
echo "delete from doublon_flou${dep} where similarity<0.5;" >> commandeTemp.sql
echo "alter table doublon_flou${dep} add column levenshtein_1 float;" >> commandeTemp.sql
echo "update doublon_flou${dep} set levenshtein_1=levenshtein/length(nom_1);" >> commandeTemp.sql
echo "alter table doublon_flou${dep} add column levenshtein_2 float;" >> commandeTemp.sql
echo "update doublon_flou${dep} set levenshtein_2=levenshtein/length(nom_2);" >> commandeTemp.sql
echo "alter table doublon_flou${dep} add column indice_1 float;" >> commandeTemp.sql
echo "alter table doublon_flou${dep} add column indice_2 float;" >> commandeTemp.sql
echo "update doublon_flou${dep} set indice_1=10*similarity+10*(1-levenshtein_1);" >> commandeTemp.sql
echo "update doublon_flou${dep} set indice_2=10*similarity+10*(1-levenshtein_2);" >> commandeTemp.sql
echo "alter table doublon_flou${dep} add column indice float;" >> commandeTemp.sql
echo "update doublon_flou${dep} set indice=(indice_1+indice_2)/2;" >> commandeTemp.sql
# On selectionne les appariements avec un indice de confiance >15
echo "drop table if exists doublon_flou_sup${dep};" >> commandeTemp.sql
echo "create table doublon_flou_sup${dep} as (select * from doublon_flou${dep} where indice>15);" >> commandeTemp.sql
# On calcule le nombre d'appariement par group ign et par group fantoir
echo "alter table doublon_flou_sup${dep} add column group_by_1 float;" >> commandeTemp.sql
echo "alter table doublon_flou_sup${dep} add column group_by_2 float;" >> commandeTemp.sql
echo "update doublon_flou_sup${dep} d1 set group_by_1=(select count(*) from doublon_flou_sup${dep} d2 where d1.nom_1=d2.nom_1 and d1.municipality_insee=d2.municipality_insee);" >> commandeTemp.sql
echo "update doublon_flou_sup${dep} d1 set group_by_2=(select count(*) from doublon_flou_sup${dep} d2 where d1.nom_2=d2.nom_2 and d1.municipality_insee=d2.municipality_insee);" >> commandeTemp.sql
# On exporte en fichier txt les groups ign avec un mauvais fantoir
echo "\COPY (select ign_1, fantoir_1, fantoir_2, nom_1, nom_2 from doublon_flou_sup${dep} where fantoir_1 is not null) to '${data_path}/group_mauvais_fantoir${dep}.txt';" >> commandeTemp.sql
echo "delete from doublon_flou_sup${dep} where ign_2 is not null or fantoir_1 is not null;" >> commandeTemp.sql

# On fait l'appariement sur les liens 1-1
echo "update group${dep} g1 set ign=g.id_pseudo_fpb, addressing=g.addressing, alias=g.alias, laposte=g.id_poste, nom_ign=g.nom_norm from group_ign${dep} g , doublon_flou_sup${dep} d where g.id_pseudo_fpb=d.ign_1 and g1.fantoir=d.fantoir_2 and d.group_by_1=1 and d.group_by_2=1;" >> commandeTemp.sql

#########################################
# GROUP IGN NON RETROUVE DANS FANTOIR (avec l'id fantoir ou nom normalise) : ajoute ces groups dans la ban
# Integration dans la table group${dep}
echo "INSERT INTO group${dep} (kind, ign, name, municipality_insee, addressing, alias, laposte, nom_norm, old_insee, nom_ign)
SELECT g.kind, g.id_pseudo_fpb, g.nom, g.code_insee, g.addressing, g.alias, g.id_poste, g.nom_norm, g.old_insee, g.nom_norm from group_ign${dep} g left join group${dep} i on g.id_pseudo_fpb=i.ign where name is null and id_pseudo_fpb is not null;" >> commandeTemp.sql


#######################################
# GROUP LAPOSTE : preparation
# Extraction du departement
echo "DROP TABLE IF EXISTS group_ran${dep};" >> commandeTemp.sql
echo "CREATE TABLE group_ran${dep} AS SELECT * FROM ran_group WHERE co_insee like '${dep}%';" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ran_co_insee${dep} ON group_ran${dep}(co_insee);" >> commandeTemp.sql 
# normalisation du nom
echo "ALTER TABLE  group_ran${dep} ADD COLUMN nom_norm varchar;" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ran_nom_norm${dep} ON group_ran${dep}(nom_norm);" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET nom_norm=upper(unaccent(lb_voie));" >> commandeTemp.sql
# doubles espaces, apostrophe, tiret
echo "UPDATE group_ran${dep} SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';" >> commandeTemp.sql
# Creation de la colonne laposte
echo "ALTER TABLE  group_ran${dep} ADD COLUMN laposte varchar;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET laposte=right('0000000'||co_voie,8);" >> commandeTemp.sql
# Creation de la colonne kind
echo "ALTER TABLE group_ran${dep} ADD COLUMN kind varchar;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET kind=abbrev.kind from abbrev where lb_voie like nom_long||' %';" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET kind='area' WHERE kind is null;" >> commandeTemp.sql
# Fusion de commune
echo "ALTER TABLE group_ran${dep} ADD COLUMN co_old_insee varchar;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET co_old_insee=co_insee;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET co_insee=insee_new from fusion_commune where co_insee=insee_old;" >> commandeTemp.sql
echo "UPDATE group_ran${dep} SET co_old_insee=null where co_old_insee=co_insee;" >> commandeTemp.sql 

echo "UPDATE group${dep} g set name=r.lb_voie, nom_laposte=r.nom_norm from group_ran${dep} r where g.laposte=r.laposte;" >> commandeTemp.sql

######################################
# RAPPROCHEMENT PAR LE NOM NORMALISE
echo "drop table if exists group_ran_doublon${dep};" >> commandeTemp.sql
echo "create table group_ran_doublon${dep} as (select count(*), nom_norm, co_insee from group_ran${dep} group by nom_norm, co_insee);" >> commandeTemp.sql
echo "drop table if exists group_fantoir_ign_doublon${dep};" >> commandeTemp.sql
echo "create table group_fantoir_ign_doublon${dep} as (select count(*), nom_norm, municipality_insee from group${dep} group by nom_norm, municipality_insee);" >> commandeTemp.sql
echo "update group${dep} g1 set doublon_nom_norm=count from group_fantoir_ign_doublon${dep} g2 where g1.nom_norm=g2.nom_norm and g2.municipality_insee=g1.municipality_insee;" >> commandeTemp.sql
echo "alter table group_ran${dep} add column doublon_nom_norm integer;" >> commandeTemp.sql
echo "update group_ran${dep} g1 set doublon_nom_norm=count from group_ran_doublon${dep} g2 where g1.nom_norm=g2.nom_norm and g2.co_insee=g1.co_insee;" >> commandeTemp.sql
echo "update group${dep} g1 set name=g.lb_voie, laposte=g.laposte, nom_laposte=g.nom_norm from group_ran${dep} g where g1.laposte is null and g1.nom_norm=g.nom_norm and g1.municipality_insee=g.co_insee and g1.doublon_nom_norm=1 and g.doublon_nom_norm=1 and not exists (select laposte from group${dep} g2 where g2.laposte=g.laposte);" >> commandeTemp.sql

###################################
# 2E PASSE AVEC LE NOM SANS ESPACES
echo "ALTER TABLE group_ran${dep} ADD COLUMN nom_comp varchar;" >> commandeTemp.sql
echo "CREATE INDEX idx_group_ran_nom_comp${dep} on group_ran${dep}(nom_comp);" >> commandeTemp.sql
echo "UPDATE group_ran${dep} set nom_comp=replace(nom_norm,' ','');" >> commandeTemp.sql
echo "UPDATE group${dep} set nom_comp=replace(nom_norm,' ','');" >> commandeTemp.sql
echo "drop table if exists group_ran_doublon${dep};" >> commandeTemp.sql
echo "create table group_ran_doublon${dep} as (select count(*), nom_comp, co_insee from group_ran${dep} group by nom_comp, co_insee);" >> commandeTemp.sql
echo "drop table if exists group_fantoir_ign_doublon${dep};" >> commandeTemp.sql
echo "create table group_fantoir_ign_doublon${dep} as (select count(*), nom_comp, municipality_insee from group${dep} group by nom_comp, municipality_insee);" >> commandeTemp.sql
echo "update group${dep} g1 set doublon_nom_norm=count from group_fantoir_ign_doublon${dep} g2 where g1.nom_comp=g2.nom_comp and g2.municipality_insee=g1.municipality_insee;" >> commandeTemp.sql
echo "update group_ran${dep} g1 set doublon_nom_norm=count from group_ran_doublon${dep} g2 where g1.nom_comp=g2.nom_comp and g2.co_insee=g1.co_insee;" >> commandeTemp.sql
echo "update group${dep} g1 set name=g.lb_voie, laposte=g.laposte , nom_laposte=g.nom_norm from group_ran${dep} g where g1.laposte is null and g1.nom_comp=g.nom_comp and g1.municipality_insee=g.co_insee and g1.doublon_nom_norm=1 and g.doublon_nom_norm=1 and not exists (select laposte from group${dep} g2 where g2.laposte=g.laposte);" >> commandeTemp.sql

#######################################
# 3E PASSE AVEC APPARIEMENT FLOU
# On crée une table d'appariement de nom et on calcule la distance de levenshtein, la similarite et un indice de confiance (une note sur 20)
echo "drop table if exists doublon_flou_laposte${dep};" >> commandeTemp.sql
echo "create table doublon_flou_laposte${dep} as (select g1.nom_norm as nom_1, g2.nom_norm as nom_2, g1.laposte as laposte_1, g2.laposte as laposte_2, cast(levenshtein(g1.nom_comp, g2.nom_comp,1,1,2) as float), g2.municipality_insee, similarity(g1.nom_norm,g2.nom_norm) from group_ran${dep} g1, group${dep} g2 where dmetaphone(g1.nom_norm)=dmetaphone(g2.nom_norm) and dmetaphone_alt(g1.nom_norm)=dmetaphone_alt(g2.nom_norm) and g1.co_insee=g2.municipality_insee);" >> commandeTemp.sql
echo "delete from doublon_flou_laposte${dep} d where exists (select * from group${dep} g where d.laposte_1=g.laposte);" >> commandeTemp.sql
echo "delete from doublon_flou_laposte${dep} where similarity<0.5;" >> commandeTemp.sql
echo "alter table doublon_flou_laposte${dep} add column levenshtein_1 float;" >> commandeTemp.sql
echo "update doublon_flou_laposte${dep} set levenshtein_1=levenshtein/length(nom_1);" >> commandeTemp.sql
echo "alter table doublon_flou_laposte${dep} add column levenshtein_2 float;" >> commandeTemp.sql
echo "update doublon_flou_laposte${dep} set levenshtein_2=levenshtein/length(nom_2);" >> commandeTemp.sql
echo "alter table doublon_flou_laposte${dep} add column indice_1 float;" >> commandeTemp.sql
echo "alter table doublon_flou_laposte${dep} add column indice_2 float;" >> commandeTemp.sql
echo "update doublon_flou_laposte${dep} set indice_1=10*similarity+10*(1-levenshtein_1);" >> commandeTemp.sql
echo "update doublon_flou_laposte${dep} set indice_2=10*similarity+10*(1-levenshtein_2);" >> commandeTemp.sql
echo "alter table doublon_flou_laposte${dep} add column indice float;" >> commandeTemp.sql
echo "update doublon_flou_laposte${dep} set indice=(indice_1+indice_2)/2;" >> commandeTemp.sql
# On selectionne les appariements avec un indice de confiance >15
echo "drop table if exists doublon_flou_laposte_sup${dep};" >> commandeTemp.sql
echo "create table doublon_flou_laposte_sup${dep} as (select * from doublon_flou_laposte${dep} where indice>15);" >> commandeTemp.sql
# On calcule le nombre d'appariement par group ign et par group fantoir
echo "alter table doublon_flou_laposte_sup${dep} add column group_by_1 float;" >> commandeTemp.sql
echo "alter table doublon_flou_laposte_sup${dep} add column group_by_2 float;" >> commandeTemp.sql
echo "update doublon_flou_laposte_sup${dep} d1 set group_by_1=(select count(*) from doublon_flou_laposte_sup${dep} d2 where d1.nom_1=d2.nom_1 and d1.municipality_insee=d2.municipality_insee);" >> commandeTemp.sql
echo "update doublon_flou_laposte_sup${dep} d1 set group_by_2=(select count(*) from doublon_flou_laposte_sup${dep} d2 where d1.nom_2=d2.nom_2 and d1.municipality_insee=d2.municipality_insee);" >> commandeTemp.sql
# On exporte en fichier txt les groups ign avec un mauvais fantoir
echo "delete from doublon_flou_laposte_sup${dep} where laposte_2 is not null;" >> commandeTemp.sql

# On fait l'appariement sur les liens 1-1
echo "update group${dep} g1 set name=g.lb_voie, laposte=g.laposte, nom_laposte=g.nom_norm from group_ran${dep} g , doublon_flou_laposte_sup${dep} d where g1.laposte is null and g.laposte=d.laposte_1 and g1.nom_norm=d.nom_2 and d.group_by_1=1 and d.group_by_2=1 and g1.municipality_insee=d.municipality_insee;" >> commandeTemp.sql


#####################################
# AJOUT DES GROUPES LAPOSTE NON RETROUVES 
echo "INSERT INTO group${dep} (kind, name, municipality_insee, laposte, nom_norm, old_insee, nom_laposte)
SELECT g.kind, g.lb_voie, g.co_insee, g.laposte, g.nom_norm, g.co_old_insee , g.nom_norm from group_ran${dep} g left join group${dep} on g.laposte = group${dep}.laposte where municipality_insee is null; " >> commandeTemp.sql


######################################
# AJOUT DES GROUPES DES ANCIENNES COMMUNES POUR ANCESTORS FUSION DE COMMUNES
echo "INSERT INTO group${dep} (name, kind, municipality_insee, old_insee, fantoir)
SELECT nom_old, 'area', insee_new, insee_old, insee_old||'####' FROM fusion_commune WHERE insee_new NOT LIKE insee_old AND insee_new like '${dep}%';" >> commandeTemp.sql


#########################################
# NOMS IGN QUAND IGN ET FANTOIR IDENTIQUES / IGN ET LAPOSTE IDENTIQUE
echo "UPDATE group${dep} g set name=i.nom FROM group_ign${dep} i where g.ign=i.id_pseudo_fpb and g.nom_ign=g.nom_fantoir and g.nom_laposte is null;" >> commandeTemp.sql
echo "UPDATE group${dep} g set name=i.nom FROM group_ign${dep} i where g.ign=i.id_pseudo_fpb and g.nom_ign=g.nom_laposte and g.nom_fantoir is null;" >> commandeTemp.sql
echo "UPDATE group${dep} g set name=i.nom FROM group_ign${dep} i where g.ign=i.id_pseudo_fpb and g.nom_ign=g.nom_fantoir and g.nom_ign=g.nom_laposte is null;" >> commandeTemp.sql

# NOMS CADASTRES
echo "UPDATE group${dep} g SET name=voie_cadastre FROM dgfip_noms_cadastre c WHERE left(c.fantoir,9)=g.fantoir and g.nom_fantoir=g.nom_ign and g.nom_fantoir=g.nom_laposte;" >> commandeTemp.sql
echo "UPDATE group${dep} g SET name=voie_cadastre FROM dgfip_noms_cadastre c WHERE left(c.fantoir,9)=g.fantoir and g.nom_fantoir=g.nom_ign and g.nom_laposte is null;" >> commandeTemp.sql
echo "UPDATE group${dep} g SET name=voie_cadastre FROM dgfip_noms_cadastre c WHERE left(c.fantoir,9)=g.fantoir and g.nom_ign is null and g.nom_fantoir=g.nom_laposte;" >> commandeTemp.sql

echo "UPDATE group${dep} SET name=regexp_replace(name,'\"','','g');" >> commandeTemp.sql

echo "\COPY (select format('{\"type\":\"group\",\"group\":\"%s\",\"municipality:insee\":\"%s\" %s ,\"name\":\"%s\" %s %s %s %s %s}',kind,municipality_insee, case when fantoir is not null then ',\"fantoir\": \"'||fantoir||'\"' end, name, case when ign is not null then ',\"ign\": \"'||ign||'\"' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' end, case when alias is not null then ',\"alias\": \"'||alias||'\"' end, case when addressing is not null then ',\"addressing\": \"'||addressing||'\"' end, case when old_insee is not null then ',\"attributes\":{\"insee\":\"'||old_insee||'\"}' end) from group${dep}) to '${data_path}/${dep}/03_groups.json';" >> commandeTemp.sql

#psql -e -f commandeTemp.sql
#exit

#################################################################################
# HOUSENUMBER
# Creation de la table housenumber${dep}
echo "DROP TABLE IF EXISTS housenumber${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber${dep} (\"number\" varchar, ordinal varchar, cia varchar, laposte varchar, ign varchar, group_fantoir varchar, group_ign varchar, group_laposte varchar, postcode_code varchar, insee varchar, no_pile_doublon integer, ancestor_fantoir varchar, old_insee varchar);" >> commandeTemp.sql

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
echo "INSERT INTO housenumber${dep} (group_fantoir, group_ign, group_laposte, number, ordinal, insee, old_insee)
SELECT g.fantoir, g.ign, g.laposte, h.number, h.ordinal, g.municipality_insee, g.old_insee from housenumber_bano${dep} h, group${dep} g where fantoir_hn=g.fantoir group by g.fantoir, g.ign, g.laposte, h.number, h.ordinal, g.municipality_insee, g.old_insee;" >> commandeTemp.sql


########################################
# PREPARATION HOUSENUMBER IGN
# Extraction du departement / suppression des doublons parfaits / suppression des detruits
echo "DROP TABLE IF EXISTS housenumber_ign${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_ign${dep} AS SELECT max(id) as id, max(id_poste) as id_poste, numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree FROM ign_housenumber WHERE code_insee like '${dep}%' and detruit is null group by (numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree);" >> commandeTemp.sql
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
echo "UPDATE housenumber_ign${dep} SET fantoir=g.fantoir FROM group${dep} g WHERE housenumber_ign${dep}.id_pseudo_fpb=g.ign;" >> commandeTemp.sql


########################################
# HOUSENUMBER IGN GROUP RAPPROCHES
# Mise a jour du champ ign de housenumber${dep}
echo "update housenumber${dep} h set ign=i.id from housenumber_ign${dep} i where h.group_ign=i.id_pseudo_fpb and h.number=i.numero and h.ordinal=i.rep;" >> commandeTemp.sql
# Mise a jour de no_pile_doublon
echo "update housenumber${dep} h set no_pile_doublon=i.no_pile_doublon from housenumber_ign${dep} i where h.ign=i.id;" >> commandeTemp.sql

###########################################
# HOUSENUMBER IGN GROUP NON RAPPROCHES
# Ajout des housenumber_ign non retrouves dans  housenumber${dep} (cles = fantoir, numero, dep) et dont le fantoir n'est pas nul
echo "INSERT INTO housenumber${dep} (ign, group_fantoir, group_ign, number, ordinal, no_pile_doublon, insee)
SELECT max(i.id), i.fantoir, i.id_pseudo_fpb, i.numero, i.rep, i.no_pile_doublon, code_insee from housenumber_ign${dep} i
left join housenumber${dep} h on (h.group_fantoir=i.fantoir and i.numero=h.number and i.rep=h.ordinal) where h.number is null and i.fantoir is not null group by i.fantoir, i.id_pseudo_fpb, i.numero, i.rep, i.no_pile_doublon, i.code_insee;" >> commandeTemp.sql
# Ajout dans la ban les housenumbers ign dont le fantoir est nul
echo "INSERT INTO housenumber${dep} (ign, group_ign, number, ordinal, no_pile_doublon, insee)
SELECT max(id), id_pseudo_fpb, numero, rep, no_pile_doublon, code_insee from housenumber_ign${dep} where fantoir is null group by id_pseudo_fpb, numero, rep, no_pile_doublon, code_insee;" >> commandeTemp.sql

########################################
# Mise à jour des champs la poste avec les données IGN
# Mise a jour du champ group_laposte de housenumber${dep}
echo "update housenumber${dep} h set group_laposte=g.laposte from group${dep} g where h.group_ign=g.ign;" >> commandeTemp.sql
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
echo "UPDATE housenumber${dep} h SET laposte=r.co_cea FROM housenumber_ran${dep} r WHERE r.group_laposte=h.group_laposte and h.number=r.no_voie and h.ordinal=r.lb_ext and h.laposte is null and not exists (select laposte from housenumber${dep} where laposte=r.co_cea);" >> commandeTemp.sql


# Mise a jour des postcodes null dans la table housenumber${dep}
echo "UPDATE housenumber${dep} h SET postcode_code=r.co_postal FROM housenumber_ran${dep} r WHERE r.co_cea=h.laposte and h.postcode_code is null;" >> commandeTemp.sql



#####################################
# HOUSENUMBERS LAPOSTE NON RAPPROCHES
# Insertion dans la table housenumber${dep}
echo "INSERT INTO housenumber${dep} (group_laposte, number, ordinal, postcode_code, laposte)
SELECT r.group_laposte, r.no_voie, r.lb_ext, r.co_postal, co_cea FROM housenumber_ran${dep} r left join housenumber${dep} h  on(r.co_cea=h.laposte) where insee is null;" >> commandeTemp.sql

# Colonne CIA
echo "update housenumber${dep} set cia=upper(format('%s_%s_%s_%s',left(group_fantoir,5),right(group_fantoir,4),number, coalesce(ordinal,''))) where group_fantoir is not null;" >> commandeTemp.sql

# Fusion de commune
echo "create index idx_group_fantoir${dep} on group${dep}(fantoir);" >> commandeTemp.sql
echo "create index idx_group_old_insee${dep} on group${dep}(old_insee);" >> commandeTemp.sql
echo "create index idx_group_ign${dep} on group${dep}(ign);" >> commandeTemp.sql
echo "create index idx_group_laposte${dep} on group${dep}(laposte);" >> commandeTemp.sql
echo "create index idx_housenumber_group_fantoir${dep} on housenumber${dep}(group_fantoir);" >> commandeTemp.sql
echo "create index idx_housenumber_group_ign${dep} on housenumber${dep}(group_ign);" >> commandeTemp.sql
echo "create index idx_housenumber_group_laposte${dep} on housenumber${dep}(group_laposte);" >> commandeTemp.sql
echo "update housenumber${dep} h set ancestor_fantoir=g1.fantoir from group${dep} g1, group${dep} g2 where h.group_fantoir=g2.fantoir and g2.old_insee||'####'=g1.fantoir;" >> commandeTemp.sql 
echo "update housenumber${dep} h set ancestor_fantoir=g1.fantoir from group${dep} g1, group${dep} g2 where h.group_ign=g2.ign and g2.old_insee||'####'=g1.fantoir;" >> commandeTemp.sql
echo "update housenumber${dep} h set ancestor_fantoir=g1.fantoir from group${dep} g1, group${dep} g2 where h.group_laposte=g2.laposte and g2.old_insee||'####'=g1.fantoir;" >> commandeTemp.sql 
echo "update housenumber${dep} h set insee=municipality_insee from group${dep} g where h.group_ign=g.ign and h.group_fantoir is null;" >> commandeTemp.sql
echo "update housenumber${dep} h set insee=municipality_insee from group${dep} g where h.group_laposte=g.laposte and h.group_fantoir is null and h.group_ign is null;" >> commandeTemp.sql
echo "update housenumber${dep} h set old_insee=g.old_insee from group${dep} g where h.group_ign=g.ign and h.group_fantoir is null;" >> commandeTemp.sql
echo "update housenumber${dep} h set old_insee=g.old_insee from group${dep} g where h.group_laposte=g.laposte and h.group_fantoir is null and h.group_ign is null;" >> commandeTemp.sql
# exporte en json
echo "\COPY (select format('{\"type\":\"housenumber\", \"group:fantoir\":\"%s\", \"cia\":\"%s\" %s %s, \"numero\":\"%s\", \"ordinal\": \"%s\" %s %s}', group_fantoir, cia, case when ign is not null then ',\"ign\": \"'||ign||'\"' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' end, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\", \"postcode:complement\":\"'||old_insee||'\"' end ,case when ancestor_fantoir is not null then ',\"ancestor:fantoir\":\"'||ancestor_fantoir||'\"' end) from housenumber${dep} where group_fantoir is not null) to '${data_path}/${dep}/04_housenumbers.json';" >> commandeTemp.sql
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"group:ign\":\"%s\" , \"ign\": \"%s\", \"numero\":\"%s\", \"ordinal\":\"%s\" %s %s}', group_ign, ign, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\", \"postcode:complement\":\"'||old_insee||'\"' end, case when ancestor_fantoir is not null then ',\"ancestor:fantoir\":\"'||ancestor_fantoir||'\"' end) from housenumber${dep} where group_ign is not null and group_fantoir is null) to '${data_path}/${dep}/05_housenumbers.json';" >> commandeTemp.sql
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"group:laposte\":\"%s\", \"laposte\":\"%s\", \"numero\": \"%s\", \"ordinal\":\"%s\" %s %s}', group_laposte, laposte, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||insee||'\", \"postcode:complement\":\"'||old_insee||'\"' end, case when ancestor_fantoir is not null then ',\"ancestor:fantoir\":\"'||ancestor_fantoir||'\"' end) from housenumber${dep} where group_laposte is not null and group_ign is null and group_fantoir is null) to '${data_path}/${dep}/06_housenumbers.json';" >> commandeTemp.sql


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
echo "CREATE INDEX idx_housenumber_ign_position${dep} ON position${dep}(housenumber_ign);" >> commandeTemp.sql
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

# Creation de la colonne name
echo "ALTER TABLE housenumber_ign${dep} ADD COLUMN name varchar;" >> commandeTemp.sql
echo "UPDATE housenumber_ign${dep} SET name=designation_de_l_entree where designation_de_l_entree not like '';" >> commandeTemp.sql

echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign, name)
SELECT i.cia, i.lon, i.lat, i.id, i.kind, i.pos, i.id, i.name FROM housenumber_ign${dep} i join housenumber_without_entrance${dep} as j on i.id=j.ign where i.kind like 'segment' and i.no_pile_doublon is null;" >> commandeTemp.sql

# Rebelote avec les piles
echo "DROP TABLE IF EXISTS housenumber_without_entrance${dep};" >> commandeTemp.sql
echo "CREATE TABLE housenumber_without_entrance${dep} AS SELECT * FROM housenumber${dep};" >> commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE ign IN (SELECT housenumber_ign FROM position${dep} where kind like 'entrance' );" >>  commandeTemp.sql
echo "DELETE FROM housenumber_without_entrance${dep} WHERE cia in (select housenumber_cia from position${dep} where kind like 'entrance' );" >> commandeTemp.sql
echo "DELETE  FROM housenumber_without_entrance${dep} WHERE no_pile_doublon is null;" >>  commandeTemp.sql

echo "INSERT INTO position${dep} (housenumber_cia, lon, lat, housenumber_ign, kind, positioning, ign)
SELECT i.cia, i.lon, i.lat, j.ign, i.kind, i.pos, i.id FROM housenumber_ign${dep} i join housenumber_without_entrance${dep} as j on (i.no_pile_doublon=j.no_pile_doublon) where i.kind like 'segment' and i.no_pile_doublon is not null;" >> commandeTemp.sql


echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\" %s, \"positioning\":\"%s\", \"housenumber:cia\": \"%s\", \"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}}',kind, case when name is not null then ',\"name\":\"'||name||'\"' end, positioning, housenumber_cia, ign, lon, lat) from position${dep} where housenumber_cia is not null) to '${data_path}/${dep}/07_positions.json';" >> commandeTemp.sql 
echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\" %s, \"positioning\":\"%s\", \"housenumber:ign\": \"%s\", \"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}}', kind, case when name is not null then ',\"name\":\"'||name||'\"' end, positioning, housenumber_ign, ign, lon, lat, ign) from position${dep} where housenumber_cia is null and housenumber_ign is not null) to '${data_path}/${dep}/08_positions.json';" >> commandeTemp.sql

psql -e -f commandeTemp.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l export des jsons"
  exit 1
fi

exit

rm commandeTemp.sql

echo "FIN"

