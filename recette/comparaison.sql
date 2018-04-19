---------------------------
-- municipality
select count(*) from municipality;
select count(*) from insee_cog33 ;
select * from insee_cog33 order by insee limit 10;
select name,insee from municipality order by insee limit 10;

---------------------------
-- postcode
select count(*) from postcode;
select count(*) from poste_cp33 ;
select * from poste_cp33 order by co_insee,co_postal limit 10;
select insee,code,p.name,p.complement from postcode p left join municipality m on (p.municipality_id = m.pk) order by insee,code limit 10;

---------------------------
-- group 
select count(*) from "group";

-- comparaison fantoir
select count(*) from "group" where fantoir is not null and fantoir <> '';
select count(*) from dgfip_fantoir33;
drop table if exists dgfip_fantoir33_comp;
create index idx_dgfip_fantoir33_fantoir_9 on dgfip_fantoir33(fantoir_9);
create table dgfip_fantoir33_comp as select g.*,f.fantoir_9 as fantoir_ori, f.nom_maj as nom_maj_ori from "group" g left join dgfip_fantoir33 f on (g.fantoir = f.fantoir_9);
select count(*) from dgfip_fantoir33_comp where fantoir = fantoir_ori and fantoir_ori is not null;
select count(*) from dgfip_fantoir33_comp where fantoir = fantoir_ori and upper(unaccent(name)) <> nom_maj_ori;
select name,nom_maj_ori,kind from dgfip_fantoir33_comp where fantoir = fantoir_ori and upper(unaccent(name)) <> nom_maj_ori limit 100;

-- comparaison ign
select count(*) from "group" where ign is not null;
select count(*) from ign_group33;
drop table if exists ign_group33_comp;
create index idx_ign_group33_id_pseudo_fpb on ign_group33(id_pseudo_fpb);
create table ign_group33_comp as select g.*, i.id_pseudo_fpb, i.nom, i.alias as alias_ori, i.type_d_adressage from "group" g left join ign_group33 i on (g.ign = i.id_pseudo_fpb);
-- identifiant ign
select count(*) from ign_group33_comp where id_pseudo_fpb is not null and id_pseudo_fpb <> '' and id_pseudo_fpb = ign;
-- nom
select count(*) from ign_group33_comp where id_pseudo_fpb = ign and upper(unaccent(name)) <> upper(unaccent(nom));
select name,nom from ign_group33_comp where id_pseudo_fpb = ign and upper(unaccent(name)) <> upper(unaccent(nom)) limit 100;
-- alias
select count(*) from ign_group33_comp where id_pseudo_fpb = ign and alias_ori is not null and array_length(alias,1) is null;
select alias,alias_ori from ign_group33_comp where id_pseudo_fpb = ign and alias_ori is not null;
-- type d'adressage
select count(*) from ign_group33_comp where addressing is not null ;
select count(*) from ign_group33_comp where type_d_adressage is not null and type_d_adressage <> '';
select count(*) from ign_group33_comp where type_d_adressage = 'Classique' and (addressing <> 'classical' or addressing is null);
select count(*) from ign_group33_comp where type_d_adressage = 'Linéaire' and (addressing <> 'linear' or addressing is null);
select count(*) from ign_group33_comp where type_d_adressage = 'Métrique' and (addressing <> 'metric' or addressing is null);
select count(*) from ign_group33_comp where type_d_adressage = 'Mixte' and (addressing <> 'mixed' or addressing is null);
select count(*) from ign_group33_comp where type_d_adressage = 'Anarchique' and (addressing <> 'anarchical' or addressing is null);

-- comparaison la poste
select count(*) from "group" where laposte is not null;
select count(*) from ran_group33;
drop table if exists ran_group33_comp;
create index idx_ran_group33_co_voie on ran_group33(co_voie);
create table ran_group33_comp as select g.*, p.co_voie, p.lb_voie from "group" g left join ran_group33 p on (g.laposte = p.co_voie);
select count(*) from ran_group33_comp where co_voie is not null and laposte = co_voie;
select count(*) from ran_group33_comp where upper(unaccent(name)) <> upper(unaccent(lb_voie));
select name,lb_voie from ran_group33_comp where upper(unaccent(name)) <> upper(unaccent(lb_voie)) limit 100;


---------------------------
-- housenumber
select count(*) from housenumber;
select count(*), attributes->'source_init' from housenumber group by attributes->'source_init';

-- comparaison dgfip
select count(*) from housenumber where attributes->'source_init' like '%DGFIP%';
select count(*) from dgfip_housenumbers33;
-- Recherche des hn perdus
drop table if exists dgfip_housenumbers33_comp;
create table dgfip_housenumbers33_comp as select h1.*,h2.cia as cia_ban, h2.number as number_ban,h2.ordinal as ordinal_ban, h2.ign, h2.laposte,g.fantoir as fantoir_ban,c.code,m.insee,c.complement,h2.attributes from dgfip_housenumbers33 h1 
left join housenumber h2 on (h1.cia = h2.cia)
left join "group" g on (h2.parent_id = g.pk)
left join postcode c on (h2.postcode_id =c.pk)
left join municipality m on (c.municipality_id = m.pk);
-- cia non retrouvées
select count(*) from dgfip_housenumbers33_comp where cia_ban is null;
select count(*) from dgfip_housenumbers33_comp where fantoir is null;
drop table if exists dgfip_housenumbers33_comp_group;
create table dgfip_housenumbers33_comp_group as select h1.*,g.fantoir as fantoir_fantoir from dgfip_housenumbers33 h1
left join "group" g on (substr(h1.fantoir,1,9) = g.fantoir);
select count(*) from dgfip_housenumbers33_comp_group where fantoir_fantoir is null;
-- cia en double dans les données d'origine
select count(*),cia from dgfip_housenumbers33_comp group by cia having count(*) > 1;
-- comparaison numero et ordinal
select count(*) from dgfip_housenumbers33_comp where cia_ban is not null and (number <> number_ban or number_ban is null);
select count(*) from dgfip_housenumbers33_comp where cia_ban is not null and number = number_ban and (ordinal <> ordinal_ban or (ordinal is null and (ordinal_ban is not null and ordinal_ban <> '')));
--lien vers les groupes (fantoir)
select count(*) from dgfip_housenumbers33_comp where cia_ban is not null and (substr(fantoir,1,9) <> fantoir_ban or fantoir_ban is null);
-- code postaux
select count(*),attributes->'source_init' from dgfip_housenumbers33_comp where code_postal <> code group by attributes->'source_init';
select count(*) from dgfip_housenumbers33_comp where code_postal is not null and code is null and ign is null and laposte is null and cia_ban is not null;


-- comparaison ign
select count(*) from housenumber where attributes->'source_init' like '%IGN%';
select count(*) from housenumber where ign is not null;
delete from ign_housenumber33 where detruit is true;
create table ign_housenumber33_unique as select max(id) as id,id_pseudo_fpb,numero,rep,code_insee,code_post,array_agg(id) from ign_housenumber33 group by(id_pseudo_fpb,numero,rep,code_insee,code_post,geom);
select count(*) from ign_housenumber33_unique;
-- 
drop table if exists ign_housenumber33_comp;
create table ign_housenumber33_comp as select i.*,h.ign as ign_ban,g.ign as id_pseudo_fpb_ban,h.number,h.ordinal,h.laposte,c.code,m.insee,c.complement,h.attributes from ign_housenumber33_unique i 
left join housenumber h on (h.ign = any(array_agg))
left join "group" g on (h.parent_id = g.pk)
left join postcode c on (h.postcode_id =c.pk)
left join municipality m on (c.municipality_id = m.pk);
-- verification id ign
select count(*) from ign_housenumber33_comp where ign_ban = any(array_agg) and ign_ban is not null;
-- comparaison numero et ordinal
select count(*) from ign_housenumber33_comp where number <> numero or number is null;
select count(*) from ign_housenumber33_comp where number = numero and (ordinal <> rep or (ordinal is null and (rep is not null and rep <> '')));
--lien vers les groupes ign
select count(*) from ign_housenumber33_comp where id_pseudo_fpb <> id_pseudo_fpb_ban or id_pseudo_fpb_ban is null;
-- comparaison code postaux,
select count(*) from ign_housenumber33_comp where code_post <> code or code is null;

-- comparaison laposte
select count(*) from housenumber where attributes->'source_init' like '%POSTE%';
select count(*) from ran_housenumber33;
-- 
drop table if exists ran_housenumber33_comp;
create table ran_housenumber33_comp as select p.*,h.laposte as laposte_ban, g.laposte as co_voie_ban, h.number, h.ordinal,c.code,m.insee,c.complement from ran_housenumber33 p
left join housenumber h on (p.co_cea = h.laposte)
left join "group" g on (h.parent_id = g.pk)
left join postcode c on (h.postcode_id =c.pk)
left join municipality m on (c.municipality_id = m.pk);
-- verification id poste
select count(*) from ran_housenumber33_comp where co_cea <> laposte_ban or laposte_ban is null;
-- comparaison numero et ordinal
select count(*) from ran_housenumber33_comp where no_voie <> number or number is null;
select count(*) from ran_housenumber33_comp where no_voie = number and (ordinal <> lb_ext or ( ordinal is null and (lb_ext is not null and lb_ext <> '')));
-- comparaison code postaux, insee , ligne 5
select count(*) from ran_housenumber33_comp where (co_insee <> insee or co_postal <> code or lb_l5 <> complement) and insee is null;


-- vérification cohérence remplissage id et source init
select count(*) from housenumber where attributes->'source_init' like '%POSTE%' and laposte is null;
select count(*) from housenumber where attributes->'source_init' like '%IGN%' and ign is null;



---------------------------
-- position
select count(*) from position;
select count(*),source from position group by source;
select count(*),source_kind from position group by source_kind;

-- dgfip
drop table if exists dgfip_position33_comp;
create table dgfip_position33_comp as select d.*, center,h.cia as cia_ban,p.pk from dgfip_housenumbers33 d
left join housenumber h on (d.cia = h.cia)
left join (select * from position where source_kind = 'dgfip') p on (p.housenumber_id = h.pk);
-- position perdue
select count(*) from dgfip_position33_comp where cia_ban is null;
select count(*) from dgfip_position33_comp where fantoir is null;
select count(*) from dgfip_position33_comp where pk is null;
select count(*) from dgfip_position33_comp where cia_ban is not null and pk is null;
-- distance
select cia,st_distance(center::geography,st_geomfromtext('POINT('||lon||' '||lat||')',4326)::geography),st_astext(center),lon,lat from dgfip_position33_comp where st_distance(center::geography,st_geomfromtext('POINT('||lon||' '||lat||')',4326)::geography) > 0.1;

-- ign
drop table if exists ign_position33_comp;
create table ign_position33_comp as select i.*, center, kind, name, positioning from ign_housenumber33 i
left join position p on (p.ign = i.id)
where detruit is null or detruit = false;
-- a la recherche des positions perdues
select count(*) from ign_position33_comp where center is null;
drop table if exists ign_position33_perdu;
create table ign_position33_perdu as select * from ign_position33_comp where center is null;
delete from ign_position33_comp where center is null;
create index idx_ign_position33_comp_id_pseudo_fpb on ign_position33_comp(id_pseudo_fpb);
drop table if exists ign_position33_perdu_retrouve;
-- on va chercher dans les positions rapprochés s'il y en une identique (me^me id_pseudo_fpb, numero ... geometrie)
create table ign_position33_perdu_retrouve as select p.*,c.id_pseudo_fpb as id_pseudo_fpb2, c.numero as numero2, c.rep as rep2 from ign_position33_perdu p 
left join ign_position33_comp c on (p.id_pseudo_fpb = c.id_pseudo_fpb and p.numero = c.numero and p.rep = c.rep and p.designation_de_l_entree = c.designation_de_l_entree and c.type_de_localisation = p.type_de_localisation and p.lon =c.lon and p.lat = c.lat and p.code_insee = c.code_insee and p.code_post = c.code_post);
select count(*) from ign_position33_perdu_retrouve where id_pseudo_fpb2 is not null;
select count(*) from ign_position33_perdu_retrouve where id_pseudo_fpb2 is null and indice_de_positionnement = '6';
-- distance
select id,st_distance(center::geography,st_geomfromtext('POINT('||lon||' '||lat||')',4326)::geography),st_astext(center),lon,lat from ign_position33_comp where st_distance(center::geography,st_geomfromtext('POINT('||lon||' '||lat||')',4326)::geography) > 0.1;
-- kind
select count(*) from ign_position33_comp where type_de_localisation = 'Projetée du centre parcelle' and (kind <> 'segment' or kind is null);
select count(*) from ign_position33_comp where type_de_localisation = 'Interpolée' and (kind <> 'segment' or kind is null);
select count(*) from ign_position33_comp where type_de_localisation = 'A la zone d''adressage' and (kind <> 'area' or kind is null);
select count(*) from ign_position33_comp where type_de_localisation = 'A la plaque' and (kind <> 'entrance' or kind is null);
-- positioning 
select count(*),positioning from position group by positioning;
select count(*) from ign_position33_comp where type_de_localisation = 'Projetée du centre parcelle' and (positioning <> 'projection' or positioning is null);
select count(*) from ign_position33_comp where type_de_localisation = 'Interpolée' and (positioning <> 'interpolation' or positioning is null);
-- name
select count(*) from ign_position33_comp where name <> designation_de_l_entree;


-- vérification remplissage id poste si source init poste
select count(*) from housenumber where attributes->'source_init' like '%POSTE%' and laposte is null;


