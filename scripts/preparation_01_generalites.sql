--------------------------------------------------------------------------
-- PREPARATION DES DONNEES DANS LA BASE TEMP AVANT L'EXPORT JSON : GENERALITES :
--   quelques menages basiques sur les libellés
--   fusion de communes (on fait pointer les objets les vers les bonnes communes
--   remplissage du champ kind sur les groupes
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing


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
UPDATE dgfip_fantoir set nature_voie = '' FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_court || ' %' AND abbrev_type_voie.nom_court = nature_voie;
UPDATE dgfip_fantoir set nature_voie = '' FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_long || ' %' AND abbrev_type_voie.nom_court = nature_voie;
UPDATE dgfip_fantoir set nature_voie = '' FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_long || ' %' AND abbrev_type_voie.nom_long = nature_voie;
UPDATE dgfip_fantoir set nature_voie = '' FROM abbrev_type_voie WHERE libelle_voie like abbrev_type_voie.nom_court || ' %' AND abbrev_type_voie.nom_long = nature_voie;

-- Ajout du kind (par defaut area, puis on update les way à partir de la table des abbrev_type_voieiations)
-- Croisement sur le champ nature_voie, puis sur le premier mot du libelle avec les noms long et nom court de la table abbrev_type_voie (tous les cas sont possibles dans le fantoir)
ALTER TABLE dgfip_fantoir DROP COLUMN IF EXISTS kind;
ALTER TABLE dgfip_fantoir ADD COLUMN kind varchar DEFAULT 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where nature_voie like nom_court and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where nature_voie like nom_long and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where libelle_voie like abbrev_type_voie.nom_court || ' %' and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where libelle_voie like nom_long and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';
UPDATE dgfip_fantoir SET kind='way' from abbrev_type_voie where libelle_voie like nom_long || ' %' and abbrev_type_voie.kind = 'way' and dgfip_fantoir.kind = 'area';

-- Remise à palt du code insee de Saint-Martin et Saint-Barth
UPDATE dgfip_fantoir SET code_insee = '97701' WHERE code_insee = '97123';
UPDATE dgfip_fantoir SET code_insee = '97801' WHERE code_insee = '97127';

-- ajout des champs suivants :
--   - fantoir sur 9 caracteres
--   - nom complet concaténation de la nature et du libelle
CREATE TABLE dgfip_fantoir_tmp AS SELECT *, left(replace(fantoir,'_',''),9)::varchar as fantoir_9, trim(nature_voie||' '||libelle_voie) as nom_maj FROM dgfip_fantoir;
DROP TABLE dgfip_fantoir;
ALTER TABLE dgfip_fantoir_tmp RENAME TO dgfip_fantoir;
CREATE INDEX idx_dgfip_fantoir_nom_maj on dgfip_fantoir(nom_maj);
CREATE INDEX idx_dgfip_fantoir_fantoir_9 on dgfip_fantoir(fantoir_9);

-- modification de quelques kind (RN RD)
UPDATE dgfip_fantoir SET kind='way' WHERE nom_maj ~ '^N[0-9][0-9]* ';
UPDATE dgfip_fantoir SET kind='way' WHERE nom_maj ~ '^N [0-9][0-9]* ';
UPDATE dgfip_fantoir SET kind='way' WHERE nom_maj ~ '^D[0-9][0-9]* ';
UPDATE dgfip_fantoir SET kind='way' WHERE nom_maj ~ '^D [0-9][0-9]* ';

-- Fusion de commune : si le groupe fantoir ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE dgfip_fantoir SET code_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE dgfip_fantoir.code_insee = f.insee_old AND code_insee NOT IN (SELECT insee from insee_cog);


----------------------
-- GROUP IGN
-- Suppression des detruits
DELETE FROM ign_group WHERE detruit is not null;
-- création d'un champ nom en majuscule, desaccentue
ALTER TABLE ign_group DROP COLUMN IF EXISTS nom_maj;
ALTER TABLE ign_group ADD COLUMN nom_maj varchar;
UPDATE ign_group SET nom_maj=upper(unaccent(nom));
UPDATE ign_group SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';
UPDATE ign_group SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';
CREATE INDEX idx_ign_group_nom_maj on ign_group(nom_maj);

-- Correction des fantoirs à 4 caractères (il manque le code insee)
UPDATE ign_group SET id_fantoir = code_insee||id_fantoir where length(id_fantoir) = 4;

-- Correction R -> RUE
UPDATE ign_group SET nom_maj=replace(nom_maj,'R ','RUE ') where nom_maj like 'R %';

-- Correction enceinte
update ign_group set nom = replace(nom,'enceinte ','en '), nom_maj =replace(nom_maj,'ENCEINTE ','EN ') where nom_maj like 'ENCEINTE %' and nom_afnor like 'EN %';

-- Correction sentier -> sente
update ign_group set nom = replace(nom,'sentier ','sente '), nom_maj =replace(nom_maj,'SENTIER ','SENTE ') where nom_maj like 'SENTIER %' and nom_afnor like 'SENTE %';

-- Creation de la colonne addressing
ALTER TABLE ign_group DROP COLUMN IF EXISTS addressing;
ALTER TABLE ign_group ADD COLUMN addressing varchar;
UPDATE ign_group SET addressing=case when type_d_adressage='Classique' then 'classical' when type_d_adressage='Mixte' then 'mixed' when type_d_adressage='Linéaire' then 'linear' when type_d_adressage='Anarchique' then 'anarchical' when type_d_adressage='Métrique' then 'metric' else '' end;
-- Creation de la colonne kind
ALTER TABLE ign_group DROP COLUMN IF EXISTS kind;
ALTER TABLE ign_group ADD COLUMN kind varchar;
UPDATE ign_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where nom_maj like nom_long||' %';
UPDATE ign_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where nom_maj like nom_court||' %';
UPDATE ign_group SET kind='area' where kind is null;

-- modification de quelques kind (RN RD)
UPDATE ign_group SET kind='way' WHERE nom_maj ~ '^N[0-9][0-9]* ';
UPDATE ign_group SET kind='way' WHERE nom_maj ~ '^N [0-9][0-9]* ';
UPDATE ign_group SET kind='way' WHERE nom_maj ~ '^D[0-9][0-9]* ';
UPDATE ign_group SET kind='way' WHERE nom_maj ~ '^D [0-9][0-9]* ';

-- Fusion de commune : si le groupe ign ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE ign_group SET code_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE ign_group.code_insee = f.insee_old AND code_insee NOT IN (SELECT insee from insee_cog);

-- quelques indexes
create index idx_ign_group_id_fantoir on ign_group(id_fantoir);
CREATE INDEX idx_ign_group_id_poste ON ign_group(id_poste);

----------------------
-- GROUP LA POSTE
-- On complete le co_voie a 8 caracteres
UPDATE ran_group SET co_voie=right('0000000'||co_voie,8) where length(co_voie) <> 8;

-- création d'un champ nom normalisé (majuscule, desaccentué, suppression des doubles espaces, remplacement - et ' par espace)
--ALTER TABLE ran_group DROP COLUMN IF EXISTS nom_norm;
--ALTER TABLE ran_group ADD COLUMN nom_norm varchar;
--UPDATE ran_group SET nom_norm=upper(unaccent(lb_voie));
--UPDATE ran_group SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';

-- Creation de la colonne kind
ALTER TABLE ran_group DROP COLUMN IF EXISTS kind;
ALTER TABLE ran_group ADD COLUMN kind varchar;
UPDATE ran_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where lb_voie like nom_long||' %';
UPDATE ran_group SET kind=abbrev_type_voie.kind from abbrev_type_voie where lb_voie like nom_court||' %' and ran_group.kind is null;
UPDATE ran_group SET kind='area' WHERE kind is null;

-- modification de quelques kind (RN RD)
UPDATE ran_group SET kind='way' WHERE lb_voie ~ '^N[0-9][0-9]* ';
UPDATE ran_group SET kind='way' WHERE lb_voie ~ '^N [0-9][0-9]* ';
UPDATE ran_group SET kind='way' WHERE lb_voie ~ '^D[0-9][0-9]* ';
UPDATE ran_group SET kind='way' WHERE lb_voie ~ '^D [0-9][0-9]* ';


-- Fusion de commune : si le groupe ran ne pointe pas vers un insee du cog, mais vers un insee ancien impliquee dans une fusion de commune, on le redirige vers le nouvel insee
UPDATE ran_group SET co_insee=f.insee_new FROM fusion_commune AS f, insee_cog WHERE ran_group.co_insee = f.insee_old AND co_insee NOT IN (SELECT insee from insee_cog);

-- quelques indexes
CREATE INDEX idx_ran_group_co_voie ON ran_group(co_voie);

----------------------
-- NOMS CADASTRE PREPARATION
-- création d'un champ nom en majuscule, desaccentue
ALTER TABLE dgfip_noms_cadastre DROP COLUMN IF EXISTS nom_maj;
ALTER TABLE dgfip_noms_cadastre ADD COLUMN nom_maj varchar;
UPDATE dgfip_noms_cadastre SET nom_maj=upper(unaccent(voie_cadastre));
UPDATE dgfip_noms_cadastre SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';
UPDATE dgfip_noms_cadastre SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';
CREATE INDEX idx_dgfip_noms_cadastre_nom_maj on dgfip_noms_cadastre(nom_maj);

-- Normalisation du nom
--ALTER TABLE dgfip_noms_cadastre DROP COLUMN IF EXISTS nom_norm;
--ALTER TABLE dgfip_noms_cadastre ADD COLUMN nom_norm varchar;
--UPDATE dgfip_noms_cadastre SET nom_norm=upper(unaccent(voie_cadastre));
--UPDATE dgfip_noms_cadastre SET nom_norm=regexp_replace(nom_norm,E'([\'-]|  *)',' ','g') WHERE nom_norm ~ E'([\'-]|  )';
