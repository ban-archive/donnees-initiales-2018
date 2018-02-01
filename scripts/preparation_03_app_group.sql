--------------------------------------------------------------------------
-- PREPARATION DES DONNEES : APPRIEMENTS DES GROUPES DES DIFFERENTES SOURCES
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing


----------------------------------------------------------------------
-- FONCTION PERMETTANT DE PREPARER LES GROUPES FANTOIR ET IGN NON ENCORE APPARIES
CREATE OR REPLACE FUNCTION prepa_non_app_fantoir_ign() RETURNS void AS $$
BEGIN
	-- table candidat fantoir
	DROP TABLE IF exists dgfip_fantoir_candidat;
	CREATE TABLE dgfip_fantoir_candidat AS SELECT f.code_insee, f.nom_maj, f.fantoir_9 from dgfip_fantoir f
	left join ign_group_app a on (f.fantoir_9 = a.id_fantoir)
	where a.id_fantoir is null;
	CREATE INDEX idx_dgfip_fantoir_candidat_code_insee on dgfip_fantoir_candidat(code_insee);
	-- table candidat ign
	DROP TABLE IF exists ign_group_candidat;
	CREATE TABLE ign_group_candidat AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.code_insee FROM ign_group i
	LEFT JOIN ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
	where a.id_pseudo_fpb is null;
	CREATE INDEX idx_ign_group_candidat_code_inse on ign_group_candidat(code_insee);
	
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- FONCTION PERMETTANT D'AJOUTER LES GROUPES IGN APPARIES de ign_group_app2 DANS les appariemenst généraux de ign_group_app avec le bon commentaire 
CREATE OR REPLACE FUNCTION insert_app_fantoir_ign(commentaire text) RETURNS void AS $$
BEGIN
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire,id_fantoir_old,trigram,levenshtein)
SELECT a.id_fantoir,a.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, $1, fantoir_ign,trigram,levenshtein from ign_group_app2 a
LEFT JOIN ign_group i ON (i.id_pseudo_fpb = a.id_pseudo_fpb);
END;
$$ LANGUAGE plpgsql;


-----------------------------------------------------------------------------------------------------------------------------------
-- APPARIEMENT Groupes FANTOIR - IGN

-- groupe ign et groupe fantoir avec le même fantoir et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
DROP TABLE IF EXISTS ign_group_app;
CREATE TABLE ign_group_app AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor,'fantoir = id fantoir ign, nom maj fantoir = nom maj ign'::varchar as commentaire from ign_group i left join dgfip_fantoir f on (fantoir_9 = id_fantoir) and (i.nom_maj = f.nom_maj) where f.fantoir_9 is not null and f.fantoir_9 <> '' ;
CREATE INDEX idx_ign_group_app_id_fantoir on ign_group_app(id_fantoir);
CREATE INDEX idx_ign_group_app_id_pseudo_fpb on ign_group_app(id_pseudo_fpb);

ALTER TABLE ign_group_app ADD COLUMN id_fantoir_old varchar;
ALTER TABLE ign_group_app ADD COLUMN trigram real;
ALTER TABLE ign_group_app ADD COLUMN levenshtein real;

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et le même libellé court
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj, i.nom_afnor, 'fantoir = id fantoir ign, nom court fantoir = nom court ign' from ign_group i
left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where a.id_pseudo_fpb is null and l1.court = l2.court and i.nom is not null and i.nom <> '';

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et le même nature et le même mot directeur
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj, i.nom_afnor, 'fantoir = id fantoir ign, nature voie fantoir = nature voie ign, mot directeur fantoir = mot directeur ign' FROM ign_group i
left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
left join (select nom_court from abbrev_type_voie group by nom_court) as ab1 on (l1.court like ab1.nom_court || ' %')
left join (select nom_court from abbrev_type_voie group by nom_court) as ab2 on (l2.court like ab2.nom_court || ' %')
where a.id_pseudo_fpb is null and i.id_fantoir is not null
and f.nom_maj is not null
and ab1.nom_court is not null and ab1.nom_court = ab2.nom_court
and regexp_replace(l1.court,'^.* ', '') = regexp_replace(l2.court,'^.* ', '')
and regexp_replace(l1.court,'^.* ', '') != ab1.nom_court;


-- groupe ign (avec ou sans fantoir) et groupe fantoir non apparié précédemment.
-- --> appariement par les nom maj (on ne fait que les cas 1-1)
-- Par exemple :
--    si le fantoir (sans id ign) contient une seule "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", OK
--    si le fantoir (sans id ign) contient deux "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", appariement NOK
--    si le fantoir (sans id ign) contient une "RUE DE L'EGLISE" et l'IGN (sans fantoir) deux "RUE DE L'EGLISE", appariement NOK
-- Préparatiobn des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,f.nom_maj, null::real as trigram, null:real as levenshtein from dgfip_fantoir_candidat as f, ign_group_candidat as i where f.code_insee = i.code_insee and f.nom_maj = i.nom_maj group by f.code_insee,f.nom_maj having count(*) = 1;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('nom maj ign = nom maj fantoir, appariement 1-1');


-- groupe ign (avec ou sans fantoir) et groupe fantoir non apparié précédemment.
-- --> appariement par les nom court (on ne fait que les cas 1-1)
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court, null::real as trigram, null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj and l1.court = l2.court
group by f.code_insee,l1.court having count(*) = 1;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('nom court ign = nom court fantoir, appariement 1-1');


-- groupe ign avec fantoir, fantoir = id fantoir ign, nom court ign like 'ENCEINTE xxx' et nom court fantoir ='EN xxx' 
-- Préparatiobn des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,null::real as trigram, null:real as levenshtein from ign_group_candidat i
LEFT JOIN dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir) 
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where l1.court like 'ENCEINTE %'  and l2.court like 'EN %' 
and regexp_replace(l1.court,'^ENCEINTE ','') = regexp_replace(l2.court,'^EN ','')
and f.nom_maj is not null and f.nom_maj <> '' and length(l1.court) > 11;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign,  nom court ign like ''ENCEINTE xxx'' et nom court fantoir =''EN xxx''');
-- Pour ces cas, on remplace ENCEINTE PAR EN dans le nom_maj_ign
update ign_group_app set nom_maj = regexp_replace(nom_maj,'^ENCEINTE ','EN ') where nom_maj like 'ENCEINTE %' and commentaire like '%ENCEINTE%'; 


-- groupe ign avec fantoir, fantoir = id fantoir ign, nom court ign = nom court fantoir + (E|S|X) (EGLISE STE AGATHE <-> EGLISE STE AGATH) 
-- Préparatiobn des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,null::real as trigram, null:real as levenshtein from ign_group_candidat i
LEFT JOIN dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where (l1.court = l2.court || 'E' or l1.court = l2.court || 'S' or l1.court = l2.court || 'X' or l2.court = l1.court || 'E' or l2.court = l1.court || 'S' or l2.court = l1.court || 'X') and f.nom_maj is not null and f.nom_maj <> '';
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, nom court fantoir + (E|S|X) = nom court ign + (E|S|X)');

-- groupe ign avec fantoir, trigram (nom court ign = nom court fantoir) = 0 (RUE VERCRAZ BAS <-> RUE BAS VERCRAZ)
-- Préparatiobn des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,0::real as trigram,null:real as levenshtein from ign_group_candidat i
LEFT JOIN dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where l1.court <-> l2.court = 0 and length(l1.court) > 6 
and f.nom_maj is not null and f.nom_maj <> '';
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, trigram (nom court ign = nom court fantoir) = 0');


-- groupe ign avec fantoir, fantoir = id fantoir ign, nom court ign = EN + nom court fantoir ou EN nom court ign = EN (collé) nom court fantoir
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparatiobn des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram, null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l2.court like 'EN %' and l1.court = regexp_replace(l2.court,'^EN ','')
group by f.code_insee,l1.court having count(*) = 1;
INSERT INTO ign_group_app2(id_fantoir,fantoir_ign,id_pseudo_fpb,court_ign,court_fantoir,trigram)
select max(fantoir_9), max(id_fantoir),max(id_pseudo_fpb),l1.court, max(l2.court),null
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l1.court like 'EN %' and regexp_replace(l1.court,'^EN ','EN') = l2.court
group by f.code_insee,l1.court having count(*) = 1;

DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, nom court ign = nom court fantoir au EN près, pas d''autres candidats sur la commune');



-- group ign avec fantoir,  fantoir = id fantoir ign, nom court ign = nom court fantoir au type de voie près (Ex RUE VERDUN <-> RTE VERDUN)
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement entre les groupes ign candidats et les groupes fantoir candidat (nom court ign = nom court fantoir au mot directeur près) (Ex RUE VERDUN <-> RTE VERDUN)
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram, null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2,
(select nom_court from abbrev_type_voie group by nom_court) as ab1, (select nom_court from abbrev_type_voie group by nom_court) as ab2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l1.court like ab1.nom_court || ' %' and l2.court like ab2.nom_court || ' %'
and ab1.nom_court is not null and ab2.nom_court is not null and ab1.nom_court <> ab2.nom_court
and regexp_replace(l1.court,ab1.nom_court,' ') = regexp_replace(l2.court,ab2.nom_court,' ')
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, nom court ign = nom court fantoir au type de voie près, les 2 types de voie sont remplis, pas d''autres candidats sur la commune');


-- group ign avec fantoir,  fantoir = id fantoir ign, nom court ign = type de voie + nom court fantoir (ou le contraire) (Ex LOT FLEURS <-> FLEURS)
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram,null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2,
(select nom_court from abbrev_type_voie group by nom_court) as ab1
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l1.court like ab1.nom_court || ' %' and regexp_replace(l1.court,ab1.nom_court || ' ','') = l2.court
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, nom court ign = nom court fantoir au type de voie près, un seul type de voie rempli, pas d''autres candidats sur la commune');
-- dans l'autre sens 
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram,null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2,
(select nom_court from abbrev_type_voie group by nom_court) as ab1
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l2.court like ab1.nom_court || ' %' and regexp_replace(l2.court,ab1.nom_court || ' ','') = l1.court
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, nom court ign = nom court fantoir au type de voie près, un seul type de voie rempli, pas d''autres candidats sur la commune');


-- group ign avec fantoir,  fantoir = id fantoir ign, trigram( nom_court_ign, nom_court_fantoir) < 0.15. Ex : PL ROBERT SCHUMANN <-> PL ROBERT SCHUMAN
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb, l1.court<->l2.court as trigram, null:real as levenshtein from ign_group_candidat i
LEFT JOIN dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where l1.court <-> l2.court < 0.15 and length(l1.court) > 6
and f.nom_maj is not null and f.nom_maj <> '';
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, trigram (nom court ign = nom court fantoir) < 0.15');


-- group ign avec fantoir,  fantoir = id fantoir ign, trigram( nom_court_ign, nom_court_fantoir) < 0.4. Ex : PL ROBERT SCHUMANN <-> PL ROBERT SCHUMAN
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,max(l1.court <-> l2.court) as trigram, null:real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and l1.court <-> l2.court < 0.4 and length(l1.court) > 6
and f.nom_maj is not null and f.nom_maj <> ''
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, trigram (nom court ign = nom court fantoir) < 0.4, pas d''autres candidats sur la commune');


-- group ign avec fantoir,  fantoir = id fantoir ign, levenshtein ( nom_court_ign, nom_court_fantoir) <= 1 et length(court) > 6 (Ex : BREDEVANT <-> BREDEVENT)
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,max(l1.court <-> l2.court) as trigram, max(levenshtein(l1.court, l2.court)) as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and length(l1.court) < 254 and levenshtein(l1.court, l2.court) < 2 and length(l1.court) > 6 and length(l2.court) > 6
and f.nom_maj is not null and f.nom_maj <> ''
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, leventshein (nom court ign = nom court fantoir) < 2, pas d''autres candidats sur la commune');


-- group ign avec fantoir,  fantoir = id fantoir ign, levenshtein ( nom_court_ign, nom_court_fantoir) <= 2 et length(court) > 10 (Ex : CLOSAL CLARITIERES <-> CLOSEL CLARITIERE)
-- pas d'autres candidats dans la commune avec le même type d'appariement
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- On ne retient que les candidats 1-1 dont le fantoir ign est egal au fantoir du fantoir
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,max(l1.court <-> l2.court) as trigram, max(levenshtein(l1.court, l2.court)) as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and length(l1.court) < 254 and levenshtein(l1.court, l2.court) < 3 and length(l1.court) > 10 and length(l2.court) > 10
and f.nom_maj is not null and f.nom_maj <> ''
group by f.code_insee,l1.court having count(*) = 1;
DELETE FROM ign_group_app2 WHERE id_fantoir <> fantoir_ign or fantoir_ign is null;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('fantoir = id fantoir ign, leventshein (nom court ign = nom court fantoir) < 3, pas d''autres candidats sur la commune');


-- groupe ign (avec ou sans fantoir), trigram sur les courts < 0.15 et pas d'autres candidats sur la commune 
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court, max(l1.court <-> l2.court) as trigram, null::real as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj 
and l1.court <-> l2.court < 0.15 and length(l1.court) > 6
group by f.code_insee,l1.court having count(*) = 1;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('trigram(nom court ign,nom court fantoir) < 0.15, appariement 1-1');


-- groupe ign (avec ou sans fantoir), trigram sur les courts < 0.15 et pas d'autres candidats sur la commune
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court, null::real as trigram, max(levenshtein(l1.court, l2.court)) as levenshtein
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj
and length(l1.court) < 254 and levenshtein(l1.court, l2.court) < 2 and length(l1.court) > 6 and length(l2.court) > 6
group by f.code_insee,l1.court having count(*) = 1;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('levenshtein(nom court ign,nom court fantoir) < 2, appariement 1-1');


-- groupe ign avec fantoir et groupe fantoir non apparié précédemment
SELECT prepa_non_app_fantoir_ign();
DROP TABLE IF EXISTS ign_group_non_app_with_fantoir;
CREATE TABLE ign_group_non_app_with_fantoir AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,f.nom_maj as nom_maj_fantoir, l1.court as court_ign, l2.court as court_fantoir from ign_group_candidat i
left join dgfip_fantoir_candidat f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where fantoir_9 is not null and fantoir_9 <> '';

-- groupe ign avec fantoir et groupe fantoir non apparié précédemment
DROP TABLE IF EXISTS ign_group_non_app;
CREATE TABLE ign_group_non_app AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.code_insee FROM ign_group i
LEFT JOIN ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
where a.id_pseudo_fpb is null;

---------------------------------------------------------------------------------------------------
-- RASSEMBLEMENT DES GROUPES IGN ET FANTOIR DANS UNE MEME TABLE
-------------------------------------------------------------------

-- groupes fantoir seuls ou appariés avec un groupe ign
DROP TABLE IF EXISTS group_fnal;
CREATE TABLE group_fnal AS SELECT f.code_insee,f.fantoir_9 as id_fantoir,f.nature_voie,f.libelle_voie,f.nom_maj as nom_maj_fantoir,f.kind as kind_fantoir, a.id_pseudo_fpb, a.nom as nom_ign,a.nom_maj as nom_maj_ign, a.alias as alias_ign, a.kind as kind_ign, a.addressing, a.id_fantoir_old as id_fantoir_ign, commentaire as commentaire_app_ign, a.trigram as trigram_court_ign_fantoir,levenshtein as levenshtein_court_ign_fantoir  from dgfip_fantoir f
LEFT JOIN ign_group_app a on (a.id_fantoir = f.fantoir_9);

-- insertion des groupes ign non appariés
INSERT INTO group_fnal(code_insee,id_pseudo_fpb,nom_ign,nom_maj_ign,alias_ign,kind_ign,addressing,id_fantoir_ign)
SELECT code_insee,id_pseudo_fpb,nom,nom_maj,alias,kind,addressing,id_fantoir from ign_group_non_app;

-- indexes
CREATE INDEX idx_group_fnal_id_pseudo_fpb on group_fnal(id_pseudo_fpb);

-----------------------------------------------------------------------------------------------------------------------------------
-- APPARIEMENT Groupes IGN - LA POSTE

-- groupe la poste et ign avec le même id poste et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
DROP TABLE IF EXISTS ran_group_app;
CREATE TABLE ran_group_app AS SELECT id_pseudo_fpb,co_voie,lb_voie,p.kind,'id poste = id poste ign, nom maj poste = nom maj ign'::varchar as commentaire from ran_group p
left join ign_group i on (co_voie = i.id_poste) and (i.nom_maj = lb_voie)
where id_pseudo_fpb is not null and id_pseudo_fpb <> '' ;
CREATE INDEX idx_ran_group_app_co_voie on ran_group_app(co_voie);
--CREATE INDEX idx_ign_group_app_id_pseudo_fpb on ign_group_app(id_pseudo_fpb);

-- groupe la poste et ign avec le même id poste et le même libellé court
INSERT INTO ran_group_app(co_voie,id_pseudo_fpb,lb_voie,kind,commentaire)
SELECT p.co_voie,i.id_pseudo_fpb,p.lb_voie,p.kind, 'id poste = id poste ign, nom court poste = nom court ign' from ran_group p
left join ran_group_app a on (p.co_voie = a.co_voie)
LEFT JOIN ign_group i on (p.co_voie = i.id_poste)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = p.lb_voie)
where a.co_voie is null and l1.court = l2.court
and p.lb_voie is not null and p.lb_voie <> '';

-- groupe la poste et ign avec le même id poste, la même nature de voie et le même mot directeur
INSERT INTO ran_group_app(co_voie,id_pseudo_fpb,lb_voie,kind,commentaire)
SELECT p.co_voie,i.id_pseudo_fpb,p.lb_voie,p.kind, 'id poste = id poste ign, nature voie laposte = nature voie ign, mot directeur laposte = mot directeur ign' FROM ran_group p
left join ran_group_app a on (p.co_voie = a.co_voie)
LEFT JOIN ign_group i on (p.co_voie = i.id_poste)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long =  p.lb_voie)
left join (select nom_court from abbrev_type_voie group by nom_court) as ab1 on (l1.court like ab1.nom_court || ' %')
left join (select nom_court from abbrev_type_voie group by nom_court) as ab2 on (l2.court like ab2.nom_court || ' %')
where a.co_voie is null
and i.nom_maj is not null
and ab1.nom_court is not null and ab1.nom_court = ab2.nom_court
and regexp_replace(l1.court,'^.* ', '') = regexp_replace(l2.court,'^.* ', '')
and regexp_replace(l1.court,'^.* ', '') != ab1.nom_court;

-- groupe ign avec laposte et groupe laposte non apparié précédemment
DROP TABLE IF EXISTS ran_group_non_app_with_ign;
CREATE TABLE ran_group_non_app_with_ign AS SELECT p.co_voie,i.id_pseudo_fpb,p.lb_voie,p.kind,i.nom_maj as nom_maj_ign, l1.court as court_ign, l2.court as court_laposte,l3.court as court_fantoir from ran_group p
left join ran_group_app a on (p.co_voie = a.co_voie)
left join ign_group i on (p.co_voie = i.id_poste)
left join group_fnal g on (i.id_pseudo_fpb = g.id_pseudo_fpb)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = p.lb_voie)
LEFT JOIN libelles l3 ON (l3.long = g.nom_maj_fantoir)
where a.co_voie is null
and id_poste is not null and id_poste <> '';

-- On ajoute les infos la poste dans la table group_fnal pour les groupes appariés avec l'id ign
-- On fait un create as suivant d'un rename pour eviter l'update trop lent
DROP TABLE IF EXISTS group_fnal_tmp;
CREATE TABLE group_fnal_tmp AS SELECT g.*, a.co_voie, a.lb_voie, a.kind as kind_laposte,a.commentaire as commentaire_app_lp FROM group_fnal g
LEFT JOIN ran_group_app a ON (g.id_pseudo_fpb = a.id_pseudo_fpb);

DROP TABLE IF EXISTS group_fnal;
ALTER TABLE group_fnal_tmp RENAME TO group_fnal;

CREATE INDEX idx_group_fnal_co_voie on group_fnal(co_voie);
CREATE INDEX idx_group_fnal_code_insee on group_fnal(code_insee);

-- groupe laposte et groupe fnal non apparié précédemment.
-- --> appariement par les nom maj (poste et fantoir). On ne fait que les cas 1-1)
-- table candidat laposte
DROP TABLE IF exists ran_group_candidat;
CREATE TABLE ran_group_candidat AS SELECT p.* FROM ran_group p
LEFT JOIN group_fnal g on (g.co_voie = p.co_voie)
where g.co_voie is null;
CREATE INDEX idx_ran_group_candidat_co_insee on ran_group_candidat(co_insee);
-- appariement
DROP TABLE IF exists ran_group_app;
CREATE TABLE ran_group_app as select max(id_fantoir) as id_fantoir, max(p.co_voie) as co_voie, p.lb_voie , max(p.kind) as kind, 'nom maj poste = nom maj fantoir'::varchar as commentaire from group_fnal g, ran_group_candidat p where g.code_insee = p.co_insee and g.nom_maj_fantoir = p.lb_voie and g.co_voie is null group by g.code_insee, p.lb_voie having count(*) = 1;
CREATE INDEX idx_ran_group_app_id_fantoir on ran_group_app(id_fantoir);
CREATE INDEX idx_ran_group_app_co_voie on ran_group_app(co_voie);

-- groupe laposte et groupe fnal non apparié précédemment.
-- --> appariement par les nom court fantoir et la poste (on ne fait que les cas 1-1)
--i table candidat fantoir
DROP TABLE IF exists group_fnal_candidat;
CREATE TABLE group_fnal_candidat AS SELECT g.code_insee, g.nom_maj_fantoir, g.id_fantoir from group_fnal g
left join ran_group_app a on (g.id_fantoir = a.id_fantoir)
where a.id_fantoir is null and g.co_voie is null;
CREATE INDEX idx_group_fnal_candidat_code_insee on group_fnal_candidat(code_insee);
-- table candidat la poste
DROP TABLE IF exists ran_group_candidat;
CREATE TABLE ran_group_candidat AS SELECT p.* FROM ran_group p
LEFT JOIN ran_group_app a on (p.co_voie = a.co_voie)
LEFT JOIN group_fnal g on (g.co_voie = p.co_voie)
where a.co_voie is null and g.co_voie is null;
CREATE INDEX idx_ran_group_candidat_co_insee on ran_group_candidat(co_insee);
-- appariement
DROP TABLE IF exists ran_group_app2;
CREATE TABLE ran_group_app2 as select max(id_fantoir) as id_fantoir,max(co_voie) as co_voie,l1.court
from group_fnal_candidat as g, ran_group_candidat as p, libelles l1, libelles l2
where g.code_insee = p.co_insee and l1.long = p.lb_voie and l2.long = g.nom_maj_fantoir and l1.court = l2.court
group by g.code_insee,l1.court having count(*) = 1;

-- injection dans la table des groupes appariés
INSERT INTO ran_group_app(id_fantoir,co_voie,lb_voie,kind,commentaire)
SELECT a.id_fantoir,a.co_voie,p.lb_voie,p.kind,'nom court laposte = nom court fantoir, appariement 1-1' from ran_group_app2 a
LEFT JOIN ran_group p ON (p.co_voie = a.co_voie);

-- On ajoute les infos la poste dans la table group_fnal pour les groupes appariés de ran_group_app
UPDATE group_fnal SET co_voie = a.co_voie, lb_voie = a.lb_voie, kind_laposte = a.kind, commentaire_app_lp = a.commentaire
FROM ran_group_app a
WHERE group_fnal.id_fantoir = a.id_fantoir;

-- groupe laposte et groupe fnal non apparié précédemment.
-- --> appariement par les nom maj ign et la poste (on ne fait que les cas 1-1)
DROP TABLE IF exists ran_group_candidat;
CREATE TABLE ran_group_candidat AS SELECT p.* FROM ran_group p
LEFT JOIN group_fnal g on (g.co_voie = p.co_voie)
where g.co_voie is null;
CREATE INDEX idx_ran_group_candidat_co_insee on ran_group_candidat(co_insee);
-- appariement
DROP TABLE IF exists ran_group_app;
CREATE TABLE ran_group_app as select max(id_pseudo_fpb) as id_pseudo_fpb, max(p.co_voie) as co_voie, p.lb_voie , max(p.kind) as kind, 'nom maj poste = nom maj ign'::varchar as commentaire from group_fnal g, ran_group_candidat p where g.code_insee = p.co_insee and g.nom_maj_ign = p.lb_voie and g.co_voie is null group by g.code_insee, p.lb_voie having count(*) = 1;
CREATE INDEX idx_ran_group_app_id_pseudo_fpb ON ran_group_app(id_pseudo_fpb);
-- On ajoute les infos la poste dans la table group_fnal pour les groupes appariés de ran_group_app
UPDATE group_fnal SET co_voie = a.co_voie, lb_voie = a.lb_voie, kind_laposte = a.kind, commentaire_app_lp = a.commentaire
FROM ran_group_app a
WHERE group_fnal.id_pseudo_fpb = a.id_pseudo_fpb;

-- groupe laposte et groupe fnal non apparié précédemment.
-- --> appariement par les nom court ign et la poste (on ne fait que les cas 1-1)
DROP TABLE IF exists ran_group_candidat;
CREATE TABLE ran_group_candidat AS SELECT p.* FROM ran_group p
LEFT JOIN group_fnal g on (g.co_voie = p.co_voie)
where g.co_voie is null;
CREATE INDEX idx_ran_group_candidat_co_insee on ran_group_candidat(co_insee);
-- appariement
DROP TABLE IF exists ran_group_app;
CREATE TABLE ran_group_app as select max(id_pseudo_fpb) as id_pseudo_fpb, max(p.co_voie) as co_voie, max(p.lb_voie) as lb_voie , max(p.kind) as kind, 'nom court poste = nom court ign'::varchar as commentaire
FROM group_fnal g, ran_group_candidat p, libelles l1, libelles l2
WHERE g.code_insee = p.co_insee and l1.long = p.lb_voie and l2.long = g.nom_maj_ign and l1.court = l2.court
and g.co_voie is null
group by g.code_insee, l1.court having count(*) = 1;
CREATE INDEX idx_ran_group_app_id_pseudo_fpb ON ran_group_app(id_pseudo_fpb);
-- On ajoute les infos la poste dans la table group_fnal pour les groupes appariés de ran_group_app
UPDATE group_fnal SET co_voie = a.co_voie, lb_voie = a.lb_voie, kind_laposte = a.kind, commentaire_app_lp = a.commentaire
FROM ran_group_app a
WHERE group_fnal.id_pseudo_fpb = a.id_pseudo_fpb;

-- groupe laposte non apparié ni avec fantoir et ign
DROP TABLE IF EXISTS ran_group_non_app;
CREATE TABLE ran_group_non_app AS SELECT p.* FROM ran_group p
LEFT JOIN group_fnal g on (g.co_voie = p.co_voie)
where g.co_voie is null;

-- insertion des groupes laposte non appariés dans la table des groupes fnal
INSERT INTO group_fnal(code_insee,co_voie,lb_voie,kind_laposte)
SELECT co_insee,co_voie,lb_voie,kind from ran_group_non_app;

-- ajout sur group_fnal d'une sequence et du nom maj fnal (par ordre de priorité LP, puis IGN, puis fantoir)
DROP SEQUENCE IF EXISTS seq_id_group_fnal;
CREATE SEQUENCE seq_id_group_fnal;
DROP TABLE IF EXISTS group_fnal_temp;
CREATE TABLE group_fnal_temp AS SELECT nextval('seq_id_group_fnal') as id,*, coalesce(lb_voie,nom_maj_ign,nom_maj_fantoir) AS nom_maj_fnal FROM group_fnal;

DROP TABLE group_fnal;
ALTER TABLE group_fnal_temp rename to group_fnal;

CREATE INDEX idx_group_fnal_id_fantoir on group_fnal(id_fantoir);


-----------------------------------------------------------------------------------------------------------------------------------
-- APPARIEMENT Groupes Cadastre - Nom maj

-- groupe cadastre et groupe fnal avec le même fantoir et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
DROP TABLE IF EXISTS cadastre_group_app;
CREATE TABLE cadastre_group_app AS SELECT id,c.fantoir,voie_cadastre,'cadastre fantoir = fantoir groupe fnal , nom maj cadastre  = nom maj groupe fnal'::varchar as commentaire from dgfip_noms_cadastre c
left join group_fnal g on (g.id_fantoir = substr(c.fantoir,1,9)) and (g.nom_maj_fnal = c.nom_maj)
where g.nom_maj_fnal is not null and g.nom_maj_fnal <> '' ;
CREATE INDEX idx_cadastre_group_app_id on cadastre_group_app(id);
CREATE INDEX idx_cadastre_group_app_fantoir on cadastre_group_app(fantoir);

-- A VOIR : groupe cadastre et groupe fnal avec le même fantoir et le meme nom court
DROP TABLE IF EXISTS cadastre_group_meme_nom_court;
CREATE TABLE cadastre_group_meme_nom_court as SELECT g.id,c.fantoir,c.voie_cadastre, g.nom_maj_fnal, 'cadastre fantoir = fantoir groupe fnal , nom court cadastre  = nom court groupe fnal'::varchar as commentaire from dgfip_noms_cadastre c
LEFT JOIN cadastre_group_app a on (c.fantoir = a.fantoir)
LEFT JOIN group_fnal g on (g.id_fantoir = substr(c.fantoir,1,9))
LEFT JOIN libelles l1 ON (l1.long = c.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = g.nom_maj_fnal)
where a.id is null and l1.court = l2.court and c.nom_maj is not null and c.nom_maj <> '';

-- A VOIR : groupe cadastre et groupe fnal source fantoir uniquement avec le même fantoir et le meme nom court
DROP TABLE IF EXISTS cadastre_group_meme_nom_court_source_fantoir;
CREATE TABLE cadastre_group_meme_nom_court_source_fantoir as SELECT g.id,c.fantoir,c.voie_cadastre, g.nom_maj_fnal, 'cadastre fantoir = fantoir groupe fnal , nom court cadastre  = nom court groupe fnal'::varchar as commentaire from dgfip_noms_cadastre c
LEFT JOIN cadastre_group_app a on (c.fantoir = a.fantoir)
LEFT JOIN group_fnal g on (g.id_fantoir = substr(c.fantoir,1,9))
LEFT JOIN libelles l1 ON (l1.long = c.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = g.nom_maj_fnal)
where a.id is null and l1.court = l2.court and c.nom_maj is not null and c.nom_maj <> ''
and id_pseudo_fpb is null and co_voie is null;

-- groupe cadastre et groupe fantoir non apparié précédemment
DROP TABLE IF EXISTS cadastre_group_non_app;
CREATE TABLE cadastre_group_non_app AS SELECT c.fantoir,c.nom_maj,c.voie_cadastre, g.nom_maj_fnal, l1.court as court_cadastre, l2.court as court_fnal from dgfip_noms_cadastre c
left join cadastre_group_app a on (c.fantoir = a.fantoir)
left join group_fnal g on (g.id_fantoir = substr(c.fantoir,1,9))
LEFT JOIN libelles l1 ON (l1.long = c.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = g.nom_maj_fnal)
where a.id is null;

-- On ajoute les infos cadastre dans la table group_fnal pour les groupes appariés de cadastre_group_app
ALTER TABLE group_fnal ADD column voie_cadastre varchar;
ALTER TABLE group_fnal ADD column commentaire_app_cadastre varchar;
UPDATE group_fnal SET voie_cadastre = a.voie_cadastre, commentaire_app_cadastre = a.commentaire
FROM cadastre_group_app a
WHERE group_fnal.id = a.id;

-------------------------------------------------------------------------
-- MISE EN FORME FINALE DE group_fnal

-- ajout du champ ign retenu (passage en majuscules simple et autres ...)
ALTER TABLE group_fnal ADD column nom_ign_retenu varchar;
UPDATE group_fnal SET nom_ign_retenu = upper(unaccent(nom_ign)) where nom_ign is not null and nom_ign <> '';
-- Pour ces cas, on remplace ENCEINTE PAR EN dans le nom_maj_ign
update group_fnal set nom_ign_retenu = regexp_replace(nom_ign_retenu,'^ENCEINTE ','EN ') where nom_ign_retenu like 'ENCEINTE %' and commentaire_app_ign like '%ENCEINTE%';

CREATE INDEX idx_group_fnal_code_insee on group_fnal(code_insee);
CREATE INDEX idx_group_fnal_id_pseudo_fpb on group_fnal(id_pseudo_fpb);*/
