\set ON_ERROR_STOP 1
\timing


-----------------------------------------------------------------------------------------------------------------------------------
-- APPARIEMENT Groupes FANTOIR - IGN

-- groupe ign et groupe fantoir avec le même fantoir et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
DROP TABLE IF EXISTS ign_group_app;
CREATE TABLE ign_group_app AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor,'fantoir = id fantoir ign, nom maj fantoir = nom maj ign'::varchar as commentaire from ign_group i left join dgfip_fantoir f on (fantoir_9 = id_fantoir) and (i.nom_maj = f.nom_maj) where f.fantoir_9 is not null and f.fantoir_9 <> '' ;
CREATE INDEX idx_ign_group_app_id_fantoir on ign_group_app(id_fantoir);
CREATE INDEX idx_ign_group_app_id_pseudo_fpb on ign_group_app(id_pseudo_fpb);

ALTER TABLE ign_group_app ADD COLUMN id_fantoir_old varchar;

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

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et avec nom ign confirmé par nom afnor
--INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
--SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, 'fantoir = id fantoir ign, nom maj ign = nom afnor' from ign_group i
--left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
--LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
--where a.id_pseudo_fpb is null and i.id_fantoir is not null
--and i.nom_maj = i.nom_afnor and i.nom_maj is not null and i.nom_maj <> ''
--and fantoir_9 is not null and fantoir_9 <> '';

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et avec nom fantoir confirmé par nom afnor
--INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
--SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, 'fantoir = id fantoir ign, nom maj fantoir = nom afnor' from ign_group i
--left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
--LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
--where a.id_pseudo_fpb is null and i.id_fantoir is not null
--and f.nom_maj = i.nom_afnor and f.nom_maj is not null and f.nom_maj <> '';

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et avec nom court fantoir confirmé par nom court afnor
--INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
--SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj, i.nom_afnor, 'fantoir = id fantoir ign, nom court fantoir = nom court afnor' from ign_group i
--left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
--LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
--LEFT JOIN libelles l1 ON (l1.long = i.nom_afnor)
--LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
--where a.id_pseudo_fpb is null and i.id_fantoir is not null
--and l1.court = l2.court and i.nom_afnor is not null and i.nom_afnor <> '';

-- groupe ign et groupe fantoir non apparié précédemment avec le même fantoir et avec nom court ign confirmé par nom court afnor
--INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire)
--SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj, i.nom_afnor, 'fantoir = id fantoir ign, nom court ign = nom court afnor' from ign_group i
--left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb)
--LEFT JOIN dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
--LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
--LEFT JOIN libelles l2 ON (l2.long = i.nom_afnor)
--where a.id_pseudo_fpb is null and i.id_fantoir is not null
--and l1.court = l2.court and i.nom_afnor is not null and i.nom_afnor <> '' 
--and fantoir_9 is not null and fantoir_9 <> '';


-- groupe ign (avec ou sans fantoir) et groupe fantoir non apparié précédemment. 
-- --> appariement par les nom maj (on ne fait que les cas 1-1)
-- Par exemple :
--    si le fantoir (sans id ign) contient une seule "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", OK
--    si le fantoir (sans id ign) contient deux "RUE DE L'EGLISE" et l'IGN (sans fantoir) un seule "RUE DE L'EGLISE", appariement NOK
--    si le fantoir (sans id ign) contient une "RUE DE L'EGLISE" et l'IGN (sans fantoir) deux "RUE DE L'EGLISE", appariement NOK
DROP TABLE IF exists dgfip_fantoir_candidat;
-- table candidat fantoir
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
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,f.nom_maj from dgfip_fantoir_candidat as f, ign_group_candidat as i where f.code_insee = i.code_insee and f.nom_maj = i.nom_maj group by f.code_insee,f.nom_maj having count(*) = 1;
-- injection dans la table des groupes ign appariés
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire,id_fantoir_old)
SELECT a.id_fantoir,a.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, 'nom maj ign = nom maj fantoir, appariement 1-1', fantoir_ign from ign_group_app2 a
LEFT JOIN ign_group i ON (i.id_pseudo_fpb = a.id_pseudo_fpb);


-- groupe ign (avec ou sans fantoir) et groupe fantoir non apparié précédemment. 
-- --> appariement par les nom court (on ne fait que les cas 1-1)
DROP TABLE IF exists dgfip_fantoir_candidat;
--i table candidat fantoir
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
-- appariement
DROP TABLE IF exists ign_group_app2;
CREATE TABLE ign_group_app2 as select max(fantoir_9) as id_fantoir, max(id_fantoir) as fantoir_ign,max(id_pseudo_fpb) as id_pseudo_fpb,l1.court 
from dgfip_fantoir_candidat as f, ign_group_candidat as i, libelles l1, libelles l2
where f.code_insee = i.code_insee and l1.long = i.nom_maj and l2.long = f.nom_maj and l1.court = l2.court
group by f.code_insee,l1.court having count(*) = 1;
-- injection dans la table des groupes ign appariés
INSERT INTO ign_group_app(id_fantoir,id_pseudo_fpb,nom,alias,kind,addressing,nom_maj,nom_afnor,commentaire,id_fantoir_old)
SELECT a.id_fantoir,a.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, 'nom court ign = nom court fantoir, appariement 1-1', fantoir_ign from ign_group_app2 a
LEFT JOIN ign_group i ON (i.id_pseudo_fpb = a.id_pseudo_fpb);


-- groupe ign avec fantoir et groupe fantoir non apparié précédemment
DROP TABLE IF EXISTS ign_group_non_app_with_fantoir;
CREATE TABLE ign_group_non_app_with_fantoir AS SELECT i.id_fantoir,i.id_pseudo_fpb,i.nom,i.alias,i.kind,i.addressing,i.nom_maj,i.nom_afnor, f.nom_maj as nom_maj_fantoir, l1.court as court_ign, l2.court as court_fantoir from ign_group i 
left join ign_group_app a on (i.id_pseudo_fpb = a.id_pseudo_fpb) 
left join dgfip_fantoir f on (fantoir_9 = i.id_fantoir)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = f.nom_maj)
where a.id_pseudo_fpb is null and i.id_fantoir is not null
and fantoir_9 is not null and fantoir_9 <> '';

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
CREATE TABLE group_fnal AS SELECT f.code_insee,f.fantoir_9 as id_fantoir,f.nature_voie,f.libelle_voie,f.nom_maj as nom_maj_fantoir,f.kind as kind_fantoir, a.id_pseudo_fpb, a.nom as nom_ign,a.nom_maj as nom_maj_ign, a.alias as alias_ign, a.kind as kind_ign, a.addressing, a.id_fantoir_old as id_fantoir_ign, commentaire   from dgfip_fantoir f
LEFT JOIN ign_group_app a on (a.id_fantoir = f.fantoir_9);

-- insertion des groupes ign non appariés
INSERT INTO group_fnal(code_insee,id_pseudo_fpb,nom_ign,nom_maj_ign,alias_ign,kind_ign,addressing,id_fantoir_ign) SELECT code_insee,id_pseudo_fpb,nom,nom_maj,alias,kind,addressing,id_fantoir from ign_group_non_app;

-- indexes
CREATE INDEX idx_group_fnal_id_pseudo_fpb on group_fnal(id_pseudo_fpb);

-----------------------------------------------------------------------------------------------------------------------------------
-- APPARIEMENT Groupes IGN - LA POSTE

-- groupe la poste et ign avec le même id poste et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
DROP TABLE IF EXISTS ran_group_app;
CREATE TABLE ran_group_app AS SELECT id_pseudo_fpb,laposte,lb_voie,p.kind,'id poste = id poste ign, nom maj poste = nom maj ign'::varchar as commentaire from ran_group p 
left join ign_group i on (laposte = i.id_poste) and (i.nom_maj = lb_voie) 
where id_pseudo_fpb is not null and id_pseudo_fpb <> '' ;
CREATE INDEX idx_ran_group_app_laposte on ran_group_app(laposte);
--CREATE INDEX idx_ign_group_app_id_pseudo_fpb on ign_group_app(id_pseudo_fpb);

-- groupe la poste et ign avec le même id poste et le même libellé court
INSERT INTO ran_group_app(laposte,id_pseudo_fpb,lb_voie,kind,commentaire)
SELECT p.laposte,i.id_pseudo_fpb,p.lb_voie,p.kind, 'id poste = id poste ign, nom court poste = nom court ign' from ran_group p
left join ran_group_app a on (p.laposte = a.laposte)
LEFT JOIN ign_group i on (p.laposte = i.id_poste)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = p.lb_voie)
where a.laposte is null and l1.court = l2.court 
and p.lb_voie is not null and p.lb_voie <> '';

-- groupe la poste et ign avec le même id poste, la même nature de voie et le même mot directeur
INSERT INTO ran_group_app(laposte,id_pseudo_fpb,lb_voie,kind,commentaire)
SELECT p.laposte,i.id_pseudo_fpb,p.lb_voie,p.kind, 'd poste = id poste ign, nature voie laposte = nature voie ign, mot directeur laposte = mot directeur ign' FROM ran_group p
left join ran_group_app a on (p.laposte = a.laposte)
LEFT JOIN ign_group i on (p.laposte = i.id_poste)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long =  p.lb_voie)
left join (select nom_court from abbrev_type_voie group by nom_court) as ab1 on (l1.court like ab1.nom_court || ' %')
left join (select nom_court from abbrev_type_voie group by nom_court) as ab2 on (l2.court like ab2.nom_court || ' %')
where a.laposte is null 
and i.nom_maj is not null 
and ab1.nom_court is not null and ab1.nom_court = ab2.nom_court
and regexp_replace(l1.court,'^.* ', '') = regexp_replace(l2.court,'^.* ', '')
and regexp_replace(l1.court,'^.* ', '') != ab1.nom_court;


-- groupe ign avec laposte et groupe laposte non apparié précédemment
DROP TABLE IF EXISTS ran_group_non_app_with_ign;
CREATE TABLE ran_group_non_app_with_ign AS SELECT p.laposte,i.id_pseudo_fpb,p.lb_voie,p.kind,i.nom_maj as nom_maj_ign, l1.court as court_ign, l2.court as court_laposte,l3.court as court_fantoir from ran_group p
left join ran_group_app a on (p.laposte = a.laposte)
left join ign_group i on (p.laposte = i.id_poste)
left join group_fnal g on (i.id_pseudo_fpb = g.id_pseudo_fpb)
LEFT JOIN libelles l1 ON (l1.long = i.nom_maj)
LEFT JOIN libelles l2 ON (l2.long = p.lb_voie)
LEFT JOIN libelles l3 ON (l3.long = g.nom_maj_fantoir)
where a.laposte is null 
and id_poste is not null and id_poste <> '';


