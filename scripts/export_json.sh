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
#  Les donnees doivent etre dans la base PostgreSQL PGDATABASE (variable 
#  d'environnement)
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
# Extraction et export en json
echo "\COPY (select format('{\"type\":\"municipality\",\"insee\":\"%s\",\"name\":\"%s\"}',insee,name) from insee_cog WHERE insee like '${dep}%') to '${data_path}/${dep}/01_municipalities.json';" >> commandeTemp.sql

#####################################################################################
# POSTCODE
# extraction et export en json
echo "\COPY (select format('{\"type\":\"postcode\",\"postcode\":\"%s\",\"name\":\"%s\",\"municipality:insee\":\"%s\" ,\"complement\":\"%s\"}',co_postal,lb_l6,co_insee, lb_l5_nn) from poste_cp WHERE co_insee like '${dep}%' ) to '${data_path}/${dep}/02_postcodes.json';" >> commandeTemp.sql

#####################################################################################
# GROUP
# Export des groupes fantoirs
echo "\COPY (select format('{\"type\":\"group\",\"group\":\"%s\",\"fantoir\":\"%s\",\"municipality:insee\":\"%s\",\"name\":\"%s\",\"attributes\":{\"init_source_name\":\"fantoir\"}}',kind_fantoir,id_fantoir,code_insee, nom_maj_fantoir) from group_fnal WHERE code_insee like '${dep}%' and id_fantoir is not null) to '${data_path}/${dep}/03_A_groups.json';" >> commandeTemp.sql

# Export des groupes ign
echo "\COPY (select format('{\"type\":\"group\",\"group\":\"%s\",\"municipality:insee\":\"%s\",\"name\":\"%s\",\"ign\":\"%s\",\"attributes\":{\"init_source_name\":\"ign\"} %s %s %s}',kind_ign,code_insee,nom_ign_retenu,id_pseudo_fpb, case when id_fantoir is not null then ',\"fantoir\": \"'||id_fantoir||'\"' end, case when alias_ign is not null then ',\"alias\": \"'||alias_ign||'\"' end, case when addressing is not null then ',\"addressing\": \"'||addressing||'\"' end) from group_fnal where code_insee like '${dep}%' and id_pseudo_fpb is not null) to '${data_path}/${dep}/03_B_groups.json';" >> commandeTemp.sql

# Export des groupes La Poste
echo "\COPY (select format('{\"type\":\"group\",\"group\":\"%s\",\"municipality:insee\":\"%s\",\"name\":\"%s\",\"laposte\":\"%s\", \"attributes\":{\"init_source_name\":\"laposte\"} %s %s}',kind_laposte, code_insee, lb_voie, laposte, case when id_fantoir is not null then ',\"fantoir\": \"'||id_fantoir||'\"' end, case when id_pseudo_fpb is not null then ',\"ign\": \"'||id_pseudo_fpb||'\"' end) from group_fnal where code_insee like '${dep}%' and laposte is not null) to '${data_path}/${dep}/03_C_groups.json';" >> commandeTemp.sql

# Export des groupes cadastre
echo "\COPY (select format('{\"type\":\"group\",\"fantoir\":\"%s\",\"name\":\"%s\", \"attributes\":{\"init_source_name\":\"dgfip\"}}',id_fantoir, voie_cadastre) from group_fnal where code_insee like '${dep}%' and voie_cadastre is not null) to '${data_path}/${dep}/03_D_groups.json';" >> commandeTemp.sql

####################################################################################
# HOUSENUMBER
# Export des housenumbers lies au group via fantoir
echo "\COPY (select format('{\"type\":\"housenumber\", \"group:fantoir\":\"%s\", \"cia\":\"%s\" %s %s, \"numero\":\"%s\", \"ordinal\": \"%s\" %s %s %s}', group_fantoir, cia, case when ign is not null then ',\"ign\": \"'||ign||'\"' end, case when laposte is not null then ',\"laposte\": \"'||laposte||'\"' end, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||code_insee||'\", \"postcode:complement\":\"'||lb_l5||'\"' end ,case when ancestor_ign is not null then ',\"ancestor:ign\":\"'||ancestor_ign||'\"' end, ',\"attributes\":{\"source_init\":\"'||source_init||'\"}') from housenumber where group_fantoir is not null and code_insee like '${dep}%') to '${data_path}/${dep}/04_housenumbers.json';" >> commandeTemp.sql

# Export des housenumbers lies au group ign si group fantoir vide
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"group:ign\":\"%s\" , \"ign\": \"%s\", \"numero\":\"%s\", \"ordinal\":\"%s\" %s %s %s}', group_ign, ign, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||code_insee||'\", \"postcode:complement\":\"'||lb_l5||'\"' end, case when ancestor_ign is not null then ',\"ancestor:ign\":\"'||ancestor_ign||'\"' end,',\"attributes\":{\"source_init\":\"'||source_init||'\"}') from housenumber where group_ign is not null and group_fantoir is null and code_insee like '${dep}%') to '${data_path}/${dep}/05_housenumbers.json';" >> commandeTemp.sql

# Export des housenumbers lies au group la poste si group fantoir et group ign vide
echo "\COPY (select format('{\"type\":\"housenumber\", \"cia\": \"\", \"group:laposte\":\"%s\", \"laposte\":\"%s\", \"numero\": \"%s\", \"ordinal\":\"%s\" %s %s %s}', group_laposte, laposte, number, ordinal, case when postcode_code is not null then ',\"postcode:code\": \"'||postcode_code||'\", \"municipality:insee\": \"'||code_insee||'\", \"postcode:complement\":\"'||lb_l5||'\"' end, case when ancestor_ign is not null then ',\"ancestor:ign\":\"'||ancestor_ign||'\"' end,',\"attributes\":{\"source_init\":\"'||source_init||'\"}') from housenumber where group_laposte is not null and group_ign is null and group_fantoir is null and code_insee like '${dep}%') to '${data_path}/${dep}/06_housenumbers.json';" >> commandeTemp.sql

####################################################################################
# POSITION
# Export des positions liees au hn via cia
echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\" %s, \"positioning\":\"%s\", \"housenumber:cia\": \"%s\", \"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}, \"source\":\"%s\"}',kind, case when name is not null then ',\"name\":\"'||name||'\"' end, positioning, cia, ign, lon, lat,source_init) from position where cia is not null and cia <> '' and (insee1 like '${dep}%' OR insee2 like '${dep}%')) to '${data_path}/${dep}/07_positions.json';" >> commandeTemp.sql

# Export des positions liees au hn via l'id ign (cia vide)
echo "\COPY (select format('{\"type\":\"position\", \"kind\":\"%s\" %s, \"positioning\":\"%s\", \"housenumber:ign\": \"%s\",\"ign\": \"%s\",\"geometry\": {\"type\":\"Point\",\"coordinates\":[%s,%s]}, \"source\":\"%s\"}',kind, case when name is not null then ',\"name\":\"'||name||'\"' end, positioning, housenumber_ign, ign, lon, lat,source_init) from position where (cia is null or cia = '') and (insee1 like '${dep}%' OR insee2 like '${dep}%')) to '${data_path}/${dep}/08_positions.json';" >> commandeTemp.sql

psql -e -f commandeTemp.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l export des jsons"
  exit 1
fi

exit

##########################################
# AJOUT DES ANCIENNES COMMUNES DANS GROUP
# on ajoute les insee old pointees par les groupes, figurant dans la table fusion de commune mais pas le cog
#echo "DROP TABLE IF EXISTS group_secondary${dep};" >> commandeTemp.sql
#echo "CREATE TABLE group_secondary${dep} (insee varchar, name varchar, insee_old varchar, ign varchar);" >> commandeTemp.sql
#echo "INSERT INTO group_secondary${dep}(insee,insee_old) 
#SELECT g.insee,insee_old FROM group${dep} as g  left join insee_cog on (g.insee_old = insee_cog.insee) WHERE insee_old is not null and insee_cog.insee is null GROUP BY g.insee,insee_old ;" >> commandeTemp.sql
#echo "UPDATE group_secondary${dep} SET name = f.nom_old from fusion_commune as f where f.insee_old = group_secondary${dep}.insee_old;" >> commandeTemp.sql
#echo "DELETE FROM group_secondary${dep} WHERE name is null;" >> commandeTemp.sql
#echo "UPDATE group_secondary${dep} SET ign = insee_old||'####';" >> commandeTemp.sql
#echo "INSERT INTO group${dep} (name, kind, insee, ign) 
#SELECT name, 'area', insee, ign FROM group_secondary${dep};" >> commandeTemp.sql



#################################################################################
# HOUSENUMBER

########################################
# PREPARATION HOUSENUMBER IGN



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

# Mise a jour des postcodes dans la table housenumber${dep} à partir des données poste
echo "UPDATE housenumber${dep} h SET postcode_code=r.co_postal FROM housenumber_ran${dep} r WHERE r.co_cea=h.laposte and r.co_postal is not null;" >> commandeTemp.sql


# Ligne 5
# A partir des donnnées LP (on remonte a la ligne 5 contenu dans ran_group)
echo "UPDATE housenumber${dep} h SET lb_l5=g.lb_l5 FROM housenumber_ran${dep} r, group_ran${dep} g WHERE r.co_cea=h.laposte and r.co_voie=g.co_voie and g.lb_l5 is not null ;" >> commandeTemp.sql
# à partir de l'insee old des groupes que l'on retrouve dans postecode (on remonte par l'identitiant ign)
echo "UPDATE housenumber${dep} h SET lb_l5=c.lb_l5_nn FROM postcode${dep} c, group${dep} g WHERE h.group_ign = g.ign and g.insee_old = c.co_insee_anc and g.insee_old is not null and lb_l5 is not null and c.lb_l5_nn is not null ;" >> commandeTemp.sql

# traitement des fusions de communes : les anciennes communes sont mis en groupe secondaire des hn (ancestors) : 3 jointures différentes (hn -> group fantoir, hn -> group ign, hn -> group la poste)
echo "update housenumber${dep} h set ancestor_ign=s.ign from group${dep} g, group_secondary${dep} s where h.group_fantoir=g.fantoir and g.insee_old||'####'=s.ign;" >> commandeTemp.sql 
echo "update housenumber${dep} h set ancestor_ign=s.ign from group${dep} g, group_secondary${dep} s where h.group_ign=g.ign and g.insee_old||'####'=s.ign;" >> commandeTemp.sql
echo "update housenumber${dep} h set ancestor_ign=s.ign from group${dep} g, group_secondary${dep} s where h.group_laposte=g.laposte and g.insee_old||'####'=s.ign;" >> commandeTemp.sql
#echo "update housenumber${dep} h set insee=g.insee from group${dep} g where h.group_ign=g.ign and h.group_fantoir is null;" >> commandeTemp.sql
#echo "update housenumber${dep} h set insee=g.insee from group${dep} g where h.group_laposte=g.laposte and h.group_fantoir is null and h.group_ign is null;" >> commandeTemp.sql
#echo "update housenumber${dep} h set old_insee=g.old_insee from group${dep} g where h.group_ign=g.ign and h.group_fantoir is null;" >> commandeTemp.sql
#echo "update housenumber${dep} h set old_insee=g.old_insee from group${dep} g where h.group_laposte=g.laposte and h.group_fantoir is null and h.group_ign is null;" >> commandeTemp.sql

psql -e -f commandeTemp.sql

if [ $? -ne 0 ]
then
  echo "Erreur lors de l export des jsons"
  exit 1
fi

exit

rm commandeTemp.sql

echo "FIN"

