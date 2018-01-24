--------------------------------------------------------------------------
-- PREPARATION DES DONNEES DANS LA BASE TEMP AVANT L'EXPORT JSON : 
--   housenumber
--   position
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing


-------------------------------------------------------------------------
--  HOUSENUMBER dgfip bano

-- Ajout des colonnes suivantes : 
--    fantoir_hn (sur 9 caracteres)
--    number
--    ordinal
--    cia
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS fantoir_hn;
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS number;
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS ordinal;
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS cia;

DROP TABLE IF EXISTS dgfip_housenumbers_temp;
CREATE TABLE dgfip_housenumbers_temp AS SELECT 
	*, 
	left(fantoir,5)||left(right(fantoir,5),4) AS fantoir_hn,
	left(numero||' ',strpos(numero||' ',' ')-1) AS number,
	upper(trim(right(numero||' ',-strpos(numero||' ',' ')))) AS ordinal
FROM dgfip_housenumbers;
DROP TABLE IF EXISTS dgfip_housenumbers_temp2;
CREATE TABLE dgfip_housenumbers_temp2 AS SELECT *,upper(format('%s_%s_%s_%s',left(fantoir,5),left(right(fantoir,5),4),number,ordinal)) AS cia FROM dgfip_housenumbers_temp;
DROP TABLE dgfip_housenumbers;
ALTER TABLE dgfip_housenumbers_temp2 RENAME TO dgfip_housenumbers;
DROP TABLE dgfip_housenumbers_temp;


-------------------------------------------------------------------------
-- HOUSENUMBER ign

-- Ménage des doublons parfaits, suppression des detruits et passage en majuscules de l'indice de repetition
UPDATE ign_housenumber SET rep = '' WHERE rep is null;
DROP TABLE IF EXISTS ign_housenumber_temp;
CREATE TABLE ign_housenumber_temp AS SELECT distinct on(numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree) id, id_poste, numero,upper(rep) as rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree FROM ign_housenumber where detruit is null and code_insee like '90%';

-- ajout du champ rank qui indiquera le rang des hn ign au sein d'une même pile sémantique (même groupe ign, numero et indice de répetition, mais géométrie ou indice_de_positionnement ou methode ou designation_de_l_entree différents)
DROP TABLE IF EXISTS ign_housenumber_temp2;
CREATE TABLE ign_housenumber_temp2 AS SELECT id,numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree, rank() OVER (PARTITION BY numero,rep,id_pseudo_fpb order by id,lon,lat,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree,code_post,code_insee) FROM ign_housenumber_temp;

-- creation des hn unique ign (même groupe ign, numero et indice de répetition
DROP TABLE IF EXISTS ign_housenumber_unique ;
CREATE TABLE ign_housenumber_unique AS SELECT id,id_pseudo_fpb,numero,rep,code_insee,code_post FROM ign_housenumber_temp2 where rank = 1;
CREATE INDEX idx_ign_housenumber_unique_id_pseudo_fpb ON ign_housenumber_unique(id_pseudo_fpb);

-------------------------------------------------------------------------
-- HOUSENUMBER La Poste
-- on complete le champ co_voie par des 000 et on enleve les null sur les indices de répétition
DROP TABLE IF EXISTS ran_housenumber_temp;
ALTER TABLE ran_housenumber DROP COLUMN IF EXISTS co_voie_bis;
ALTER TABLE ran_housenumber DROP COLUMN IF EXISTS lb_ext_bis
CREATE TABLE ran_housenumber_temp AS SELECT *,right('0000000'||co_voie,8) as co_voie_bis,coalesce(lb_ext,'') as lb_ext_bis FROM ran_housenumber;
DROP TABLE IF EXISTS ran_housenumber;
ALTER TABLE ran_housenumber_temp RENAME TO ran_housenumber;
ALTER TABLE ran_housenumber DROP COLUMN co_voie;
ALTER TABLE ran_housenumber RENAME COLUMN co_voie_bis TO co_voie;
ALTER TABLE ran_housenumber DROP COLUMN lb_ext;
ALTER TABLE ran_housenumber RENAME COLUMN lb_ext_bis TO lb_ext;

CREATE INDEX idx_ran_housenumber_co_voie ON ran_housenumber(co_voie);
CREATE INDEX idx_ran_housenumber_co_cea ON ran_housenumber(co_cea);


----------------------------------------------------------------------
--  RASSEMBLEMENT des hns des differentes sources
DROP TABLE IF EXISTS housenumber;

-- dgfip bano
CREATE TABLE housenumber AS SELECT g.id_fantoir as group_fantoir, g.id_pseudo_fpb as group_ign, g.laposte as group_laposte, h.number, h.ordinal, g.code_insee, true::bool as source_dgfip 
FROM dgfip_housenumbers h, group_fnal g 
WHERE fantoir_hn=g.id_fantoir and h.insee_com like '90%' 
GROUP BY g.id_fantoir, g.id_pseudo_fpb, g.laposte, h.number, h.ordinal, g.code_insee;

-- mise à jour de l'id ign sur housenumber pour les hn dont le group ign, le numero et l'ordinal sont deja présents
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT h.*, i.id as ign FROM housenumber h
LEFT JOIN ign_housenumber_unique i ON (h.group_ign = i.id_pseudo_fpb and h.number=i.numero and h.ordinal=i.rep);
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;
CREATE INDEX idx_housenumber_ign ON housenumber(ign);

-- ajout des hn ign pas encore ajoutés 
INSERT INTO housenumber(ign,group_fantoir,group_ign,group_laposte,number,ordinal,code_insee) 
SELECT i.id, g.id_fantoir,i.id_pseudo_fpb, g.laposte, i.numero, i.rep, g.code_insee from ign_housenumber_unique i
left join housenumber h on (h.ign = i.id)
LEFT JOIN group_fnal g ON (g.id_pseudo_fpb = i.id_pseudo_fpb)
WHERE h.ign is null and g.id_pseudo_fpb is not null;

-- mise à jour de l'id poste sur housenumber pour les hn dont le group poste, le numero et l'ordinal sont deja présents
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT h.*, p.co_cea as laposte FROM housenumber h
LEFT JOIN ran_housenumber as p ON (h.group_laposte = p.co_voie and h.number=p.no_voie and h.ordinal=p.lb_ext);
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;
CREATE INDEX idx_housenumber_laposte ON housenumber(laposte);

-- ajout des hn laposte pas encore ajoutés
INSERT INTO housenumber(laposte,group_fantoir,group_ign,group_laposte,number,ordinal,code_insee)
SELECT p.co_cea, g.id_fantoir, g.id_pseudo_fpb,p.co_voie, p.no_voie, p.lb_ext, p.co_insee from ran_housenumber p
left join housenumber h on (h.laposte = p.co_cea)
LEFT JOIN group_fnal g ON (g.laposte = p.co_voie)
WHERE h.laposte is null and g.laposte is not null
AND co_insee like '90%';

-- ajout CIA, source_init
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT *, CASE WHEN group_fantoir is not null THEN upper(format('%s_%s_%s_%s',left(group_fantoir,5),right(group_fantoir,4),number, coalesce(ordinal,''))) ELSE null END as cia, array_to_string(array[CASE WHEN source_dgfip is true THEN 'DGFIP' ELSE null END,CASE WHEN ign is null THEN null ELSE 'IGN' END,CASE WHEN laposte is null THEN null ELSE 'LAPOSTE' END],'|') as source_init FROM housenumber;
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;

-------------- TODO 
-- ajout postcode vide
ALTER TABLE housenumber ADD COLUMN postcode_code varchar;
-- ajout ligne 5 vide
ALTER TABLE housenumber ADD COLUMN lb_l5 varchar;
-- ajout ancestor ign vide
ALTER TABLE housenumber ADD COLUMN ancestor_ign varchar;






