---------------------------
-- municipality
select count(*) from municipality;
select count(*) from insee_cog90 ;
select * from insee_cog90 order by insee limit 10;
select name,insee from municipality order by insee limit 10;

---------------------------
-- postcode
select count(*) from postcode;
select count(*) from poste_cp90 ;
select * from poste_cp90 order by co_insee,co_postal limit 10;
select insee,code,p.name,p.complement from postcode p left join municipality m on (p.municipality_id = m.pk) order by insee,code limit 10;

---------------------------
-- group 
select count(*) from "group";

-- comparaison fantoir
select count(*) from "group" where fantoir is not null and fantoir <> '';
select count(*) from dgfip_fantoir90;
drop table if exists dgfip_fantoir90_comp;
create index idx_dgfip_fantoir90_fantoir_9 on dgfip_fantoir90(fantoir_9);
create table dgfip_fantoir90_comp as select g.*,f.fantoir_9 as fantoir_ori, f.nom_maj as nom_maj_ori from "group" g left join dgfip_fantoir90 f on (g.fantoir = f.fantoir_9);
select count(*) from dgfip_fantoir90_comp where fantoir = fantoir_ori;
select count(*) from dgfip_fantoir90_comp where fantoir = fantoir_ori and upper(unaccent(name)) <> nom_maj_ori;
select name,nom_maj_ori,kind from dgfip_fantoir90_comp where fantoir = fantoir_ori and upper(unaccent(name)) <> nom_maj_ori limit 100;

-- comparaison ign
select count(*) from "group" where ign is not null;
select count(*) from ign_group90;
drop table if exists ign_group90_comp;
create index idx_ign_group90_id_pseudo_fpb on ign_group90(id_pseudo_fpb);
create table ign_group90_comp as select g.*, i.id_pseudo_fpb, i.nom, i.alias as alias_ori, i.type_d_adressage from "group" g left join ign_group90 i on (g.ign = i.id_pseudo_fpb);
-- identifiant ign
select count(*) from ign_group90_comp where id_pseudo_fpb is not null and id_pseudo_fpb <> '' and id_pseudo_fpb = ign;
-- nom
select count(*) from ign_group90_comp where id_pseudo_fpb = ign and upper(unaccent(name)) <> upper(unaccent(nom));
select name,nom from ign_group90_comp where id_pseudo_fpb = ign and upper(unaccent(name)) <> upper(unaccent(nom));
-- alias
select count(*) from ign_group90_comp where id_pseudo_fpb = ign and alias_ori is not null and array_length(alias,1) is null;
select alias,alias_ori from ign_group90_comp where id_pseudo_fpb = ign and alias_ori is not null;
-- type d'adressage
select count(*) from ign_group90_comp where addressing is not null ;
select count(*) from ign_group90_comp where type_d_adressage is not null and type_d_adressage <> '';
select count(*) from ign_group90_comp where type_d_adressage = 'Classique' and (addressing <> 'classical' or addressing is null);
select count(*) from ign_group90_comp where type_d_adressage = 'Linéaire' and (addressing <> 'linear' or addressing is null);
select count(*) from ign_group90_comp where type_d_adressage = 'Métrique' and (addressing <> 'metric' or addressing is null);
select count(*) from ign_group90_comp where type_d_adressage = 'Mixte' and (addressing <> 'mixed' or addressing is null);
select count(*) from ign_group90_comp where type_d_adressage = 'Anarchique' and (addressing <> 'anarchical' or addressing is null);

-- comparaison la poste
select count(*) from "group" where laposte is not null;
select count(*) from ran_group90;
drop table if exists ran_group90_comp;
create index idx_ran_group90_co_voie on ran_group90(co_voie);
create table ran_group90_comp as select g.*, p.co_voie, p.lb_voie from "group" g left join ran_group90 p on (g.laposte = p.co_voie);
select count(*) from ran_group90_comp where co_voie is not null and laposte = co_voie;
select count(*) from ran_group90_comp where upper(unaccent(name)) <> upper(unaccent(lb_voie));
select name,lb_voie from ran_group90_comp where upper(unaccent(name)) <> upper(unaccent(lb_voie));


---------------------------
-- housenumber
select count(*) from housenumber;

-- comparaison dgfip
select count(*) from housenumber where attributes->'source_init' like '%DGFIP%';
select count(*) from dgfip_housenumbers90;
-- Recherche des hn perdus
drop table if exists dgfip_housenumbers90_comp;
create table dgfip_housenumbers90_comp as select h1.*,h2.cia as cia_ban, h2.number as number_ban,h2.ordinal as ordinal_ban, g.fantoir as fantoir_ban from dgfip_housenumbers90 h1 
left join housenumber h2 on (h1.cia = h2.cia)
left join "group" g on (h2.parent_id = g.pk);
-- cia non retrouvées
select count(*) from dgfip_housenumbers90_comp where cia_ban is null;
select count(*) from dgfip_housenumbers90_comp where fantoir is null;
-- cia en double dans les données d'origine
select count(*),cia from dgfip_housenumbers90_comp group by cia having count(*) > 1;
-- comparaison numero et ordinal
select count(*) from dgfip_housenumbers90_comp where cia_ban is not null and number <> number_ban;
select count(*) from dgfip_housenumbers90_comp where cia_ban is not null and number = number_ban and ordinal <> ordinal_ban;
--lien vers les groupes (fantoir)
select count(*) from dgfip_housenumbers90_comp where cia_ban is not null and substr(fantoir,1,9) <> fantoir_ban;




