-- comptage BAN
select count(*) from "group";
select count(*) from "group" where fantoir is not null;
select count(*) from "group" where ign is not null;
select count(*) from "group" where laposte is not null;

-- recherche des groupes fantoir du departement 90 non present dans la ban
drop table if exists dgfip_fantoir90;
create table dgfip_fantoir90 as select * from dgfip_fantoir where code_insee like '90%';
select count(*) from dgfip_fantoir90;
select count(*) from dgfip_fantoir90 where (caractere_annul is not null and caractere_annul <> '' and caractere_annul <> ' ');
alter table dgfip_fantoir90 add column fantoir_ban varchar;
update dgfip_fantoir90 set fantoir_ban = "group".fantoir from "group" where "group".fantoir = dgfip_fantoir90.fantoir_9;
select count(*) from dgfip_fantoir90 where fantoir_ban is not null and fantoir_9 = fantoir_ban;

-- recherche des groupes ign du departement 90 non present dans la ban
drop table if exists ign_group90;
create table ign_group90 as select * from ign_group where code_insee like '90%';
select count(*) from ign_group90;
select count(*) from ign_group90 where detruit  = true;
alter table ign_group90 add column ign_ban varchar;
update ign_group90 set ign_ban = "group".ign from "group" where "group".ign = ign_group90.id_pseudo_fpb;
select count(*) from ign_group90 where ign_ban is not null and id_pseudo_fpb = ign_ban;

-- recherche des groupes lp du departement 90 non present dans la ban
drop table if exists ran_group90;
create table ran_group90 as select * from ran_group where co_insee like '90%';
select count(*) from ran_group90;
alter table ran_group90 add column ran_co_voie varchar;
update ran_group90 set ran_co_voie = "group".laposte from "group" where "group".laposte = ran_group90.co_voie;
select count(*) from ran_group90 where ran_co_voie is not null and co_voie = ran_co_voie;




