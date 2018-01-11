create table group_ign2 as select i.*, f.nom_norm as fantoir_nom_norm, f.fantoir_9 as id_fantoir_new from ign_group i left join dgfip_fantoir f on (fantoir_9 = id_fantoir);

\set ON_ERROR_STOP 1
\timing

-- creation de la table des libelles long et court des différentes sources
drop table if exists libelles;

-- libelles nom IGN non rapprochés 
CREATE TABLE libelles AS select nom as long, trim(regexp_replace(replace(trim(upper(unaccent(replace(replace(replace(i.nom,'œ','oe'),'-',' '), E'\'' ,' ')))),'LIEU DIT ',''),'(^| )((LE|LA|LES|L|D|DE|DE|DES|DU|A|AU|ET) )*',' ','g')) as court from ign_group i ;
CREATE INDEX idx_libelles_long on libelles (long);

-- libelles nom FANTOIR 
insert into libelles select trim(nature_voie||' '||libelle_voie) as long, trim(regexp_replace(replace(trim(nature_voie||' '||libelle_voie),'LIEU DIT ',''),'(^| )((LE|LA|LES|L|D|DE|DE|DES|DU|A|AU|ET) )*',' ','g')) as court from dgfip_fantoir f left join libelles l on (long=trim(nature_voie||' '||libelle_voie)) where long is null group by 1,2;
-- libellés RAN 
insert into libelles select lb_voie as long, regexp_replace(replace(lb_voie,'LIEU DIT ',''),'(^| )((LE|LA|LES|L|D|DE|DE|DES|DU|A|AU|ET) )*',' ','g') as court from ran_group left join libelles on (long=lb_voie) where long is null group by 1,2;

-- index par trigram sur le libellé court 
create index libelle_trigram on libelles using gin (court gin_trgm_ops);
analyze libelles;

-- libellés: 0 à la place des O 
update libelles set court = replace(replace(replace(replace(replace(replace(replace(replace(court,'0S','OS'),'0N','ON'),'0U','OU'),'0I','OI'),'0R','OR'),'C0','CO'),'N0','NO'),'L0','L ') where court ~ '[^0-9 ][0][^0-9 ]';
-- des *
update libelles set court=trim(replace(court,'*','')) where court like '%*%';
-- séparation chiffres 
update libelles set court = regexp_replace(court,'([^0-9 ])([0-9])','\1 \2') where court ~ '([^0-9 ])([0-9])';
update libelles set court = regexp_replace(court,'([0-9])([^0-9 ])','\1 \2') where court ~ '([0-9])([^0-9 ])';

-- libelles: chemin départemental -> CD 
UPDATE libelles SET court = regexp_replace(replace(regexp_replace(court,'(^| )(CD |CHE |)?(CH|CHE|CHEM|CHEMIN)\.? (DEP|DEPT|DEPTA|DEPTAL|DEPART|DEPARTE|DEPARTEM|DEPARTEME|DEPARTEMEN|DEPARTEME|DEPARTEMEN|DEPARTEMENT|DEPARTEMENTA|DEPARTEMTAL|DEPARTEMENTAL|DEPARTEMENTALE|DEPTARMENTAL|DEPARMENTAL|DEPARTEMEMTAL|DEPAETEMENTAL|DEPARTEMTALE)($|\.? ((N|NO|NR|NUM|NUMER|NUMERO|N\.|N°)([0-9 ]))?)','\1CD \8'),'CD CD','CD '),'  *',' ','g') WHERE court ~'(CH|CHE|CHEM|CHEMIN)\.? (DEP|DEPT|DEPART|DEPARTEM|DEPARTEMTAL|DEPARTEMENTA|DEPARTEMENTAL|DEPARTE|DEPTARMENTAL)\.?( N)?';
-- libelles: route départementale -> CD 
update libelles set court=regexp_replace(replace(regexp_replace(court,'(^| )(CD |RD |RTE |)?(RTE|ROUTE)\.? (DEP|DEPT|DEPTA|DEPTAL|DEPART|DEPARTE|DEPARTEM|DEPARTEME|DEPARTEMEN|DEPARTEME|DEPARTEMEN|DEPARTEMENT|DEPARTEMENTA|DEPARTEMTAL|DEPARTEMENTAL|DEPARTEMENTAL|DEPTARMENTAL|DEPARMENTAL|DEPARTEMEMTAL|DEPAETEMENTAL|DEPARTEMTAL|DEPARTEMANTAL|DEPATREMENTAL)E?($|\.? ((N|NO|NR|NUM|NUMER|NUMERO|N\.|N°)([0-9 ]))?)','\1CD \8'),'CD CD','CD '),'  *',' ','g') where court ~'(RTE|ROUTE)\.? (DEP|DEPT|DEPART|DEPARTEM|DEPARTEMTAL|DEPARTEMENTA|DEPARTEMENTAL|DEPARTE|DEPTARMENTAL)\.?( N)?';


with u as (select * from abbrev order by length(txt_long) desc) update libelles set court = replace(court,u.txt_long, u.txt_court) from u where court ~ (txt_long||' ');

update libelles set court=trim(court) where court like ' %' or court like '% ';

delete from libelles where long is null;
delete from libelles where long = '';

drop table if exists libelles2;
create table libelles2 as select long,court from libelles group by long,court;

drop table libelles;
alter table libelles2 rename to libelles;
