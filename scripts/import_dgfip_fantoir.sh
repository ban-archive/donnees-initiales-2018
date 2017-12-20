# récupération et décompression du fichier FANTOIR sur data.gouv.fr via son API
#echo "Telechargement"
#URL=`http 'https://www.data.gouv.fr/api/1/datasets/53699580a3a729239d204738/' | jq '.resources|sort_by(.published)|.[].url' -r | tail -n 1`
#FANTOIR=`echo $URL | sed 's".*/"";s".zip""'`

#wget -nc $URL
#unzip -u $FANTOIR.zip

# import dans SQL en format fixe (delimiter et quote spéciaux pour ignorer)
echo "copy ..."
psql -c "create table if not exists dgfip_fantoir_temp (raw text); truncate dgfip_fantoir_temp;"
psql -c "\copy dgfip_fantoir_temp from 'FANTOIR1017' with csv delimiter '#' quote '>';"

echo "Mise en forme"
psql -c "
drop table if exists dgfip_fantoir cascade; 
create table dgfip_fantoir as (select substr(raw,1,2)||substr(raw,4,3)||'_'||substr(raw,7,4)||substr(raw,11,1) as fantoir, substr(raw,1,2) as code_dept, substr(raw,3,1) as code_dir, substr(raw,4,3) as code_com, substr(raw,1,2)||substr(raw,4,3) as code_insee, substr(raw,7,4) as id_voie, substr(raw,11,1) as cle_rivoli, rtrim(substr(raw,12,4)) as nature_voie, rtrim(substr(raw,16,26)) as libelle_voie,  substr(raw,49,1) as type_commune, substr(raw,50,1) as caractere_rur, substr(raw,51,1) as caractere_voie, substr(raw,52,1) as caractere_pop, substr(raw,60,7)::integer as pop_a_part, substr(raw,67,7)::integer as pop_fictive, substr(raw,74,1) as caractere_annul, substr(raw,75,7) as date_annul, substr(raw,82,7) as date_creation, substr(raw,104,5) as code_majic, substr(raw,109,1) as type_voie, substr(raw,110,1) as ld_bati, trim(substr(raw,113,8)) as dernier_mot from dgfip_fantoir_temp where raw not like '______ %' and raw not like '___ %');

-- plus besoin de la table fantoir RAW
drop table dgfip_fantoir_temp;"

# prise en compte des fusions de communes : si un group ne pointe pas vers l'insee du cog et pointe vers un insee_old de la table de fusion de commmune :
# alors on met a jour son code insee et on bascule le code insee d'origine dans l'insee old
#on l'ajoute ici à cause des changements de départements autrement on aurait pu l'ajouter dans export_json.sh
echo "Prise en compte des fusions de communes"
psql -c "
alter table dgfip_fantoir add column insee_cog varchar;
update dgfip_fantoir set insee_cog = insee_cog.insee FROM insee_cog where insee_cog.insee = dgfip_fantoir.code_insee;
update dgfip_fantoir set code_insee = f.insee_new from fusion_commune as f where dgfip_fantoir.code_insee = f.insee_old and dgfip_fantoir.insee_cog is null;"

# ajout de la colonne fantoir sur 9 caracteres
echo "Ajout de la colonne fantoir_9"
psql -c "alter table dgfip_fantoir add column fantoir_9 varchar;
update dgfip_fantoir set fantoir_9=left(replace(fantoir,'_',''),9);"

# ajout des indexes
echo "Ajout des indexes"
psql -c "create index idx_dgfip_fantoir_code_insee on dgfip_fantoir(code_insee);"
