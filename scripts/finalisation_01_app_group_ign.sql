--------------------------------------------------------------------------
-- APPARIEMENTS DES GROUPES FANTOIR ET IGN
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,f.nom_maj, null::real as trigram, null::real as levenshtein from dgfip_fantoir_candidat as f, ign_group_candidat as i where f.code_insee = i.code_insee and f.nom_maj = i.nom_maj group by f.code_insee,f.nom_maj having count(*) = 1;
-- injection dans la table des groupes ign appariés
select insert_app_fantoir_ign('nom maj ign = nom maj fantoir, appariement 1-1');


-- groupe ign (avec ou sans fantoir) et groupe fantoir non apparié précédemment.
-- --> appariement par les nom court (on ne fait que les cas 1-1)
-- Préparation des tables des objets ign et fantoir non encore apparies
SELECT prepa_non_app_fantoir_ign();
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court, null::real as trigram, null::real as levenshtein
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
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,null::real as trigram, null::real as levenshtein from ign_group_candidat i
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
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,null::real as trigram, null::real as levenshtein from ign_group_candidat i
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
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb,0::real as trigram,null::real as levenshtein from ign_group_candidat i
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram, null::real as levenshtein
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram, null::real as levenshtein
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram,null::real as levenshtein
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,null::real as trigram,null::real as levenshtein
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
CREATE TABLE ign_group_app2 as SELECT id_fantoir,id_fantoir as fantoir_ign,id_pseudo_fpb, l1.court<->l2.court as trigram, null::real as levenshtein from ign_group_candidat i
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
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court as court_ign, max(l2.court) as court_fantoir,max(l1.court <-> l2.court) as trigram, null::real as levenshtein
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
delete from ign_group_app2 where id_fantoir in (select id_fantoir from ign_group_app2 group by id_fantoir having count(*) > 1);
delete from ign_group_app2 where id_pseudo_fpb in (select id_pseudo_fpb from ign_group_app2 group by id_pseudo_fpb having count(*) > 1);
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
delete from ign_group_app2 where id_fantoir in (select id_fantoir from ign_group_app2 group by id_fantoir having count(*) > 1);
delete from ign_group_app2 where id_pseudo_fpb in (select id_pseudo_fpb from ign_group_app2 group by id_pseudo_fpb having count(*) > 1);
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



-- \COPY (select id_fantoir,id_pseudo_fpb,nom_maj,nom_maj_fantoir,court_ign,court_fantoir,null as app from ign_group_non_app_with_fantoir order by id_fantoir ASC) TO '/home/bduni/ban/init/travail/ign_group_non_app_with_fantoir.csv' WITH CSV HEADER DELIMITER ';'

