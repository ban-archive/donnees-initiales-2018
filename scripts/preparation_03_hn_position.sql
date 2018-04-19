--------------------------------------------------------------------------
-- PREPARATION DES HOUSENUMBERS ET DES POSITIONS
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing

-------------------------------------------------------------------------
--  HOUSENUMBER dgfip etalab

-- changement du code insee de saint-barth et saint martin
UPDATE dgfip_housenumbers SET insee_com = '97701' WHERE insee_com = '97123';
UPDATE dgfip_housenumbers SET insee_com = '97801' WHERE insee_com = '97127';

-- Ajout des colonnes suivantes : 
--    fantoir_hn (sur 9 caracteres)
--    number
--    ordinal
--    cia
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS number;
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS ordinal;
ALTER TABLE dgfip_housenumbers DROP COLUMN IF EXISTS cia;

DROP TABLE IF EXISTS dgfip_housenumbers_temp;
CREATE TABLE dgfip_housenumbers_temp AS SELECT 
	*, 
	left(numero||' ',strpos(numero||' ',' ')-1) AS number,
	upper(trim(right(numero||' ',-strpos(numero||' ',' ')))) AS ordinal
FROM dgfip_housenumbers;
DROP TABLE IF EXISTS dgfip_housenumbers_temp2;
CREATE TABLE dgfip_housenumbers_temp2 AS SELECT *,CASE WHEN fantoir is not null or fantoir <> '' THEN upper(format('%s_%s_%s_%s',left(fantoir,5),right(fantoir,4),number,ordinal)) ELSE '' END AS cia FROM dgfip_housenumbers_temp;
DROP TABLE dgfip_housenumbers;
ALTER TABLE dgfip_housenumbers_temp2 RENAME TO dgfip_housenumbers;
DROP TABLE dgfip_housenumbers_temp;


-------------------------------------------------------------------------
-- HOUSENUMBER ign

-- Ménage des doublons parfaits, suppression des detruits et passage en majuscules de l'indice de repetition
UPDATE ign_housenumber SET rep = '' WHERE rep is null;
DROP TABLE IF EXISTS ign_housenumber_temp;
CREATE TABLE ign_housenumber_temp AS SELECT distinct on(numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree) id, id_poste, numero,upper(rep) as rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree FROM ign_housenumber where detruit is null 
--and code_insee like '94%'
order by numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree,id DESC;

-- ajout du champ rank qui indiquera le rang des hn ign au sein d'une même pile sémantique (même groupe ign, numero et indice de répetition, mais géométrie ou indice_de_positionnement ou methode ou designation_de_l_entree différents)
DROP TABLE IF EXISTS ign_housenumber_temp2;
CREATE TABLE ign_housenumber_temp2 AS SELECT id,numero,rep,lon,lat,code_post,code_insee,id_pseudo_fpb,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree, rank() OVER (PARTITION BY numero,rep,id_pseudo_fpb order by id,lon,lat,type_de_localisation,indice_de_positionnement,methode,designation_de_l_entree,code_post,code_insee) FROM ign_housenumber_temp order by id DESC;

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

