--------------------------------------------------------------------------
-- PREPARATION DES DONNEES DANS LA BASE TEMP AVANT L'EXPORT JSON
-- Par exemple : correction des noms, appariements des noms des différentes sources ...
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing
/*
-------------------------------------------------------------------------
--  MUNICIPALITY
-- remplacement des articles null par ''
UPDATE insee_cog SET artmin = coalesce(artmin,'') WHERE artmin is null;
-- Suppression des parentheses sur les articles
UPDATE insee_cog SET artmin = replace(artmin,'(','') WHERE artmin LIKE '%(%';
UPDATE insee_cog set artmin = replace(artmin,')','') WHERE artmin LIKE '%)%';
-- on ajoute le champ name
ALTER TABLE insee_cog DROP COLUMN IF EXISTS name;
ALTER TABLE insee_cog ADD COLUMN name varchar;
UPDATE insee_cog SET name = trim(artmin ||' ' || nccenr);
UPDATE insee_cog SET name = replace(name, E'\' '::text, E'\''::text);

-------------------------------------------------------------------------
-- POSTCODE
-- Fusion de commune : 
-- - si le postcode ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
--- on bascule le nom de l'ancien poste code dans la ligne 5
UPDATE poste_cp SET co_insee=f.insee_new, lb_l5_nn = CASE WHEN lb_l5_nn is null or lb_l5_nn = '' THEN lb_l6 END FROM fusion_commune AS f, insee_cog WHERE poste_cp.co_insee = f.insee_old AND co_insee NOT IN (SELECT insee from insee_cog);


-------------------------------------------------------------------------
-- GROUP

----------------------
-- GROUP Fantoir 
-- Suppression des detruits
DELETE FROM dgfip_fantoir WHERE caractere_annul not like ' ';
-- On remplace les " par un blanc
UPDATE dgfip_fantoir SET libelle_voie = replace(libelle_voie,'"',' ') WHERE  libelle_voie LIKE '%"%';
-- Nettoyage doubles espaces, apostrophes, trait d'union (à lancer plusieurs fois car si une fois, il reste des doubles blancs)
UPDATE dgfip_fantoir SET libelle_voie=regexp_replace(libelle_voie,E'([\'-]|  *)',' ','g') WHERE libelle_voie ~ E'([\'-]|  )';
UPDATE dgfip_fantoir SET libelle_voie=regexp_replace(libelle_voie,E'([\'-]|  *)',' ','g') WHERE libelle_voie ~ E'([\'-]|  )';
UPDATE dgfip_fantoir SET libelle_voie=regexp_replace(libelle_voie,E'([\'-]|  *)',' ','g') WHERE libelle_voie ~ E'([\'-]|  )';
-- Nettoyage des doubles de nature voie identique : on vide la nature de voie si elle est deja rempli dans le libelle de voie (avec la même valeur abbregé ou non)
--  CAS 1 : nature_voie = AV et libelle_voie = AV DES ACCACIAS ->  nature_voie = NULL et libelle_voie = AV DES ACCACIAS 
--  CAS 2 : nature_voie = AV et libelle_voie = AVENUE DES ACCACIAS ->  nature_voie = NULL et libelle_voie = AVENUE DES ACCACIAS
--  CAS 3 : nature_voie = AVENUE et libelle_voie = AVENUE DES ACCACIAS ->  nature_voie = NULL et libelle_voie = AVENUE DES ACCACIAS
--  CAS 4 : nature_voie = AVENUE et libelle_voie = AV DES ACCACIAS ->  nature_voie = NULL et libelle_voie = AVENUE DES ACCACIAS
-- Attention on ne traite pas les autres cas : par exemple si la nature_voie est rempli et est aussi présent dans le libelle voie mais avec une autre valeur. Cela est correct dans de nombreux cas (EX : nature_voie = LOT et libelle voie = CLOS MONTMAJOUR -> le nom complet de la voie est bien LOT CLOS MONTMAJOUR)
UPDATE dgfip_fantoir set nature_voie = null FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_court || ' %' AND abbrev_type_voie.nom_court = nature_voie;
UPDATE dgfip_fantoir set nature_voie = null FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_long || ' %' AND abbrev_type_voie.nom_court = nature_voie;
UPDATE dgfip_fantoir set nature_voie = null FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_long || ' %' AND abbrev_type_voie.nom_long = nature_voie;
UPDATE dgfip_fantoir set nature_voie = null FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_court || ' %' AND abbrev_type_voie.nom_long = nature_voie;

-- Ajout de la colonne nom normalise (concatenation nature_voie et libelle_voie et dessabbreviation du type de voie et divers)
-- On dessabrege au préalable les 2 colonnes
-- Attention dans le fantoir la nature_voie peut aussi être dans le libelle_voie (et en plus en abbrégé ou non)
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS nature_voie_norm;
ALTER TABLE dgfip_fantoir ADD nature_voie_norm varchar;
UPDATE dgfip_fantoir set nature_voie_norm = nature_voie;
UPDATE dgfip_fantoir set nature_voie_norm = abbrev_type_voie.nom_long FROM abbrev_type_voie WHERE nature_voie_norm = abbrev_type_voie.nom_court and code = '2';
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS libelle_voie_norm;
ALTER TABLE dgfip_fantoir ADD libelle_voie_norm varchar;
UPDATE dgfip_fantoir set libelle_voie_norm = libelle_voie;
UPDATE dgfip_fantoir set libelle_voie_norm = nom_long || ' ' || trim(substr(libelle_voie_norm,length(nom_court)+1))  FROM abbrev_type_voie WHERE libelle_voie_norm like abbrev_type_voie.nom_court || ' %' and nom_court != nom_long AND code = '2';
UPDATE dgfip_fantoir set libelle_voie_norm = nom_long || ' ' || trim(substr(libelle_voie_norm,length(nom_court)+1))  FROM abbrev_divers WHERE libelle_voie_norm like abbrev_divers.nom_court || ' %' AND code = '2';
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS nom_norm;
ALTER TABLE dgfip_fantoir ADD nom_norm varchar;
UPDATE dgfip_fantoir SET nom_norm =  trim(nature_voie_norm||' '||libelle_voie_norm) ;

-- Ajout du kind (par defaut area, puis on update les way à partir de la table des abbrev_type_voieiations)
-- Croisement sur le champ nature_voie, puis sur le premier mot du libelle avec les noms long et nom court de la table abbrev_type_voie (tous les cas sont possibles dans le fantoir)
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS kind;
ALTER TABLE dgfip_fantoir ADD COLUMN kind varchar DEFAULT 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where nature_voie like nom_court and abbrev_type_voie.kind = 'way';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where nature_voie like nom_long and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where libelle_voie like abbrev_type_voie.nom_court || ' %' and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where libelle_voie like nom_long and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';

-- ajout de la colonne fantoir sur 9 caracteres
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS fantoir_9;
ALTER TABLE dgfip_fantoir ADD COLUMN fantoir_9 varchar;
UPDATE dgfip_fantoir SET fantoir_9=left(replace(fantoir,'_',''),9);

-- Fusion de commune : si le groupe fantoir ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE dgfip_fantoir SET code_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE dgfip_fantoir.code_insee = f.insee_old AND code_insee NOT IN (SELECT insee from insee_cog);


----------------------
-- GROUP IGN
-- Suppression des detruits
DELETE FROM ign_group WHERE detruit is not null;
-- création d'un champ nom normalisé (majuscule, desaccentué, desabbrege, suppression des doubles espaces, remplacement - et ' par espace)
ALTER TABLE ign_group DROP COLUMN IF EXISTS nom_norm;
ALTER TABLE  ign_group ADD COLUMN nom_norm varchar;
UPDATE ign_group SET nom_norm=upper(unaccent(nom));
UPDATE ign_group SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';
UPDATE ign_group SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';
UPDATE ign_group SET nom_norm = abbrev_type_voie.nom_long || substr(nom_norm,length(split_part(nom_norm,' ',1))+1) FROM abbrev_type_voie WHERE split_part(nom_norm,' ',1) = abbrev_type_voie.nom_court and nom_court != nom_long and code = '2';

UPDATE ign_group SET nom_norm = nom_long || ' ' || trim(substr(nom_norm,length(nom_court)+1)) FROM abbrev_divers WHERE nom_norm like abbrev_divers.nom_court || ' %' and code = '2';
-- Creation de la colonne addressing
ALTER TABLE ign_group DROP COLUMN IF EXISTS addressing;
ALTER TABLE ign_group ADD COLUMN addressing varchar;
UPDATE ign_group SET addressing=case when type_d_adressage='Classique' then 'classical' when type_d_adressage='Mixte' then 'mixed' when type_d_adressage='Linéaire' then 'linear' when type_d_adressage='Anarchique' then 'anarchical' when type_d_adressage='Métrique' then 'metric' else '' end;
-- Creation de la colonne kind
ALTER TABLE ign_group DROP COLUMN IF EXISTS kind;
ALTER TABLE ign_group ADD COLUMN kind varchar;
UPDATE ign_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where nom_norm like nom_long||' %';
UPDATE ign_group SET kind='area' where kind is null;

-- Fusion de commune : si le groupe ign ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE ign_group SET code_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE ign_group.code_insee = f.insee_old AND code_insee NOT IN (SELECT insee from insee_cog);

-- quelques indexes
create index idx_ign_group_id_fantoir on ign_group(id_fantoir);

----------------------
-- GROUP LA POSTE
-- Creation de la colonne laposte
ALTER TABLE ran_group DROP COLUMN IF EXISTS laposte;
ALTER TABLE ran_group ADD COLUMN laposte varchar;
UPDATE ran_group SET laposte=right('0000000'||co_voie,8);
*/
-- création d'un champ nom normalisé (majuscule, desaccentué, suppression des doubles espaces, remplacement - et ' par espace)
ALTER TABLE ran_group DROP COLUMN IF EXISTS nom_norm;
ALTER TABLE ran_group ADD COLUMN nom_norm varchar;
UPDATE ran_group SET nom_norm=upper(unaccent(lb_voie));
UPDATE ran_group SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';
-- Creation de la colonne kind
ALTER TABLE ran_group DROP COLUMN IF EXISTS kind;
ALTER TABLE ran_group ADD COLUMN kind varchar;
UPDATE ran_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where lb_voie like nom_long||' %';
UPDATE ran_group SET kind='area' WHERE kind is null;

-- Fusion de commune : si le groupe ran ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE ran_group SET co_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE ran_group.co_insee = f.insee_old AND co_insee NOT IN (SELECT insee from insee_cog);

----------------------
-- NOMS CADASTRE PREPARATION
-- Normalisation du nom
ALTER TABLE dgfip_noms_cadastre DROP COLUMN IF EXISTS nom_norm;
ALTER TABLE dgfip_noms_cadastre ADD COLUMN nom_norm varchar;
UPDATE dgfip_noms_cadastre SET nom_norm=upper(unaccent(voie_cadastre));
UPDATE dgfip_noms_cadastre SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';
-- index sur fantoir
CREATE INDEX idx_dgfip_noms_cadastre_fantoir ON dgfip_noms_cadastre(fantoir);

----------------------
-- AJOUT id fantoir sur group IGN par rapprochement sur les noms normalisés
-- on apparie les groupes fantoirs sans identifiant ign avec les groups ign sans fantoir
-- On ne retient que les appariements 1-1 de nom normalisé
-- Par exemple : 
--    si le fantoir (sans id ign) contient une seule "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", on reporte l'id fantoir
--    si le fantoir (sans id ign) contient deux "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", on ne reporte pas l'id fantoir
--    si le fantoir (sans id ign) contient une "RUE DE L'EGLISE" et l'IGN (sans fantoir) deux "RUE DE L'EGLISE", on ne reporte pas l'id fantoir
-- Préparation de la table des groupes fantoir sans correspondant ign
DROP TABLE IF exists dgfip_fantoir_non_ign;
CREATE TABLE dgfip_fantoir_non_ign as select f.code_insee,f.nom_norm,f.fantoir_9 from dgfip_fantoir f left join ign_group i on (f.fantoir_9 = i.id_fantoir) where i.id_fantoir is null;
CREATE INDEX idx_dgfip_fantoir_non_ign_code_insee on dgfip_fantoir_non_ign(code_insee);
-- jointure entre les groupes ign sans fantoir et les groupes fantoir non ign sur le code insee et le nom normalisé (on ne retient que les appariements 1-1)
DROP TABLE IF exists fantoir_ign_join_nom_norm;
CREATE TABLE fantoir_ign_join_nom_norm as select max(fantoir_9) as fantoir, max(id_pseudo_fpb) as id_pseudo_fpb,f.code_insee,f.nom_norm from dgfip_fantoir_non_ign as f, ign_group as i where f.code_insee = i.code_insee and f.nom_norm = i.nom_norm AND i.id_fantoir is null group by f.code_insee,f.nom_norm having count(*) = 1;
-- on rabbat l'id fantoir sur la table ign
CREATE INDEX idx_fantoir_ign_join_nom_norm_id_pseudo_fpb on fantoir_ign_join_nom_norm(id_pseudo_fpb);
UPDATE ign_group SET id_fantoir = f.fantoir from fantoir_ign_join_nom_norm f where ign_group.id_pseudo_fpb = f.id_pseudo_fpb and ign_group.id_fantoir is null;

