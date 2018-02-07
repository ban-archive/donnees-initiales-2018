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
CREATE TABLE dgfip_housenumbers_temp2 AS SELECT *,CASE WHEN fantoir is not null or fantoir <> '' THEN upper(format('%s_%s_%s_%s',left(fantoir,5),left(right(fantoir,5),4),number,ordinal)) ELSE '' END AS cia FROM dgfip_housenumbers_temp;
DROP TABLE dgfip_housenumbers;
ALTER TABLE dgfip_housenumbers_temp2 RENAME TO dgfip_housenumbers;
DROP TABLE dgfip_housenumbers_temp;


-------------------------------------------------------------------------
-- HOUSENUMBER ign

-- Ménage des doublons parfaits, suppression des detruits et passage en majuscules de l'indice de repetition
UPDATE ign_housenumber SET rep = '' WHERE rep is null;
DROP TABLE IF EXISTS ign_housenumber_temp;
CREATE TABLE ign_housenumber_temp AS SELECT distinct on(numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree) id, id_poste, numero,upper(rep) as rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree FROM ign_housenumber where detruit is null;
-- and code_insee like '90%';

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
ALTER TABLE ran_housenumber DROP COLUMN IF EXISTS lb_ext_bis;
ALTER TABLE ran_housenumber DROP COLUMN IF EXISTS lb_l5;
CREATE TABLE ran_housenumber_temp AS SELECT h.*,right('0000000'||h.co_voie,8) as co_voie_bis,coalesce(lb_ext,'') as lb_ext_bis, lb_l5 FROM ran_housenumber AS h
LEFT JOIN ran_group g ON (h.co_voie = g.co_voie);
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
CREATE TABLE housenumber AS SELECT g.id_fantoir as group_fantoir, g.id_pseudo_fpb as group_ign, g.co_voie as group_laposte, h.number, h.ordinal, g.code_insee, true::bool as source_dgfip 
FROM dgfip_housenumbers h, group_fnal g 
WHERE fantoir_hn=g.id_fantoir
-- and h.insee_com like '90%' 
GROUP BY g.id_fantoir, g.id_pseudo_fpb, g.co_voie, h.number, h.ordinal, g.code_insee;

-- mise à jour de l'id ign sur housenumber pour les hn dont le group ign, le numero et l'ordinal sont deja présents
-- on récupère aussi le code postal sur la table ign
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT h.*, i.id as ign, i.code_post as code_post_ign FROM housenumber h
LEFT JOIN ign_housenumber_unique i ON (h.group_ign = i.id_pseudo_fpb and h.number=i.numero and h.ordinal=i.rep);
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;
CREATE INDEX idx_housenumber_ign ON housenumber(ign);

-- ajout des hn ign pas encore ajoutés 
INSERT INTO housenumber(ign,group_fantoir,group_ign,group_laposte,number,ordinal,code_insee,code_post_ign) 
SELECT i.id, g.id_fantoir,i.id_pseudo_fpb, g.co_voie, i.numero, i.rep, g.code_insee, i.code_post from ign_housenumber_unique i
left join housenumber h on (h.ign = i.id)
LEFT JOIN group_fnal g ON (g.id_pseudo_fpb = i.id_pseudo_fpb)
WHERE h.ign is null and g.id_pseudo_fpb is not null;

-- mise à jour de l'id poste sur housenumber pour les hn dont le group poste, le numero et l'ordinal sont deja présents
-- on met aussi à jour le code postal et la ligne 5
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT h.*, p.co_cea as laposte, p.co_postal, p.lb_l5 FROM housenumber h
LEFT JOIN ran_housenumber as p ON (h.group_laposte = p.co_voie and h.number=p.no_voie and h.ordinal=p.lb_ext);
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;
CREATE INDEX idx_housenumber_laposte ON housenumber(laposte);

-- ajout des hn laposte pas encore ajoutés
INSERT INTO housenumber(laposte,group_fantoir,group_ign,group_laposte,number,ordinal,code_insee,co_postal,lb_l5)
SELECT p.co_cea, g.id_fantoir, g.id_pseudo_fpb,p.co_voie, p.no_voie, p.lb_ext, g.code_insee, p.co_postal, p.lb_l5 from ran_housenumber p
left join housenumber h on (h.laposte = p.co_cea)
LEFT JOIN group_fnal g ON (g.co_voie = p.co_voie)
WHERE h.laposte is null and g.co_voie is not null;
--AND co_insee like '90%';

-- si le co_postal est vide, on le remplit avec le code postal ign
UPDATE housenumber SET co_postal = code_post_ign WHERE (co_postal is null or co_postal = '') and (code_post_ign is not null and code_post_ign <> '');

-- ajout CIA, source_init
DROP TABLE IF EXISTS housenumber_temp;
CREATE TABLE housenumber_temp AS SELECT *, CASE WHEN group_fantoir is not null THEN upper(format('%s_%s_%s_%s',left(group_fantoir,5),right(group_fantoir,4),number, coalesce(ordinal,''))) ELSE null END as cia, array_to_string(array[CASE WHEN source_dgfip is true THEN 'DGFIP' ELSE null END,CASE WHEN ign is null THEN null ELSE 'IGN' END,CASE WHEN laposte is null THEN null ELSE 'LAPOSTE' END],'|') as source_init FROM housenumber;
DROP TABLE housenumber;
ALTER TABLE housenumber_temp RENAME TO housenumber;

-- quelques indexes
CREATE INDEX idx_housenumber_cia ON housenumber(cia);
CREATE INDEX idx_housenumber_ign ON housenumber(ign);
CREATE INDEX idx_housenumber_laposte ON housenumber(laposte);

-- on vide les liens codes postaux -> hn non cohérents, cad qui ne pointent pas vers un cp existants ou unique au sens (code insee, code postal, ligne 5)
-- 2 cas observés :
-- hn ign avec cp, mais la poste pour ce cp a plusieurs lignes 5 et aucune vide. On ne sait pas vers quel cp faire pointer
-- hn avec incohérence entre l'insee poste te l'insee ign
create index idx_poste_cp_co_insee on poste_cp(co_insee);
create index idx_poste_cp_co_postal on poste_cp(co_postal);
create table housenumber_cp_error as select h.*,lb_l5_nn from housenumber h left join (select * from poste_cp where lb_l5_nn is null) p on (h.code_insee = p.co_insee and h.co_postal = p.co_postal ) where h.co_postal is not null and p.co_insee is null and lb_l5 is null;
create index idx_housenumber_cp_error_ign on housenumber_cp_error(ign);
create index idx_housenumber_cp_error_laposte on housenumber_cp_error(laposte);
update housenumber h set co_postal = null from housenumber_cp_error h2 where h.ign is not null and h.ign <> '' and h.ign = h2.ign;
update housenumber h set co_postal = null from housenumber_cp_error h2 where h.co_postal is not null and h.laposte is not null and h.laposte <> '' and h.laposte = h2.laposte;


-- ajout d'un hn null pour chaque groupe laposte pour stocker le cea des voies poste
INSERT INTO housenumber (group_laposte, laposte, co_postal, code_insee, lb_l5)
SELECT r.co_voie, r.cea, r.co_postal, r.co_insee, r.lb_l5 from ran_group r ;
--where co_insee like '90%';

-------------- TODO 
-- ajout ancestor ign vide
ALTER TABLE housenumber ADD COLUMN ancestor_ign varchar;


---------------------------------------------------------------------------------
-- POSITION IGN
DROP TABLE IF EXISTS ign_position;

-- position ign tête de pile
CREATE TABLE ign_position AS SELECT id as id_hn,* FROM ign_housenumber_temp2 where rank = 1;
CREATE INDEX idx_ign_position_id_pseudo_fpb on ign_position(id_pseudo_fpb);

-- les autres positions des piles (on les fait pointer vers le bon hn ign -> celui de la meme pile de rank 1)
INSERT INTO ign_position SELECT p.id_hn,h.* FROM ign_housenumber_temp2 h
LEFT JOIN ign_position p ON (p.numero = h.numero and p.rep = h.rep and p.id_pseudo_fpb = h.id_pseudo_fpb) 
where h.rank > 1;

-- ajout du champ cia, kind et positioning
DROP TABLE IF EXISTS ign_position_temp;
CREATE TABLE ign_position_temp AS SELECT
 	p.*, 
	CASE WHEN indice_de_positionnement = '5' THEN 'area' WHEN type_de_localisation = 'A la plaque' THEN 'entrance' WHEN type_de_localisation = 'Projetée du centre parcelle' THEN 'segment' WHEN type_de_localisation LIKE 'A la zone%' THEN 'area' WHEN type_de_localisation = 'Interpolée' THEN 'segment' ELSE 'unknown' END AS kind, 
	CASE WHEN type_de_localisation = 'Projetée du centre parcelle' THEN 'projection' WHEN type_de_localisation = 'Interpolée' THEN 'interpolation' ELSE 'other' END AS positioning, 
	CASE WHEN g.id_fantoir is not null THEN format('%s_%s_%s_%s',left(g.id_fantoir,5), right(g.id_fantoir,4),numero, rep) ELSE '' END AS cia 
FROM ign_position p
LEFT JOIN group_fnal g ON (g.id_pseudo_fpb = p.id_pseudo_fpb);
DROP TABLE ign_position;
ALTER TABLE ign_position_temp RENAME TO ign_position;



---------------------------------------------------------------------------------
-- REGROUPEMENT DES POSITIONS DANS UNE MËME TABLE
DROP TABLE IF EXISTS position;

-- insertion des positions ign sauf les kind unkown (centre commune)
-- au passage on tronque les coordonnées à 6 chiffres après la virgule ( => 1 dm au max environ)
CREATE TABLE position AS SELECT cia,round(lon::numeric,6) as lon,round(lat::numeric,6) as lat,id as ign,id_hn as housenumber_ign,kind,positioning, designation_de_l_entree as name, 'IGN'::varchar AS source_init FROM ign_position WHERE kind <> 'unknown' ;

-- Insertion dans la table position des positions dgfip  
INSERT INTO position(cia,lon,lat,kind,positioning,source_init) SELECT d.cia, round(d.lon::numeric,6), round(d.lat::numeric,6), 'entrance','other', 'DGFIP' FROM dgfip_housenumbers d;
--WHERE insee_com like '90%';

CREATE INDEX idx_position_cia ON position(cia);
CREATE INDEX idx_position_ign ON position(ign);
CREATE INDEX idx_position_housenumber_ign ON position(housenumber_ign);

-- on rabbat le code insee de hn
DROP TABLE IF EXISTS position_temp;
CREATE TABLE position_temp AS SELECT p.*,h1.code_insee as insee1,h2.code_insee as insee2 FROM position p
LEFT JOIN housenumber h1 ON (p.cia = h1.cia)
LEFT JOIN housenumber h2 ON (p.housenumber_ign = h2.ign)
WHERE (h1.cia is not null and h1.cia <> '') OR
(h2.ign is not null and h2.ign <> '');
DROP TABLE position;
ALTER TABLE position_temp RENAME TO position;


