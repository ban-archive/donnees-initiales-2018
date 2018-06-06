alter table municipality rename to municipality_ori;
alter table postcode rename to postcode_ori;
alter table "group" rename to group_ori;
alter table housenumber rename to housenumber_ori;
alter table position rename to position_ori;

drop table municipality;
drop table postcode;
drop table "group";
drop table housenumber;
drop table position;

create table municipality as select * from municipality_ori where insee like '971%';
create index idx_municipaly_pk on municipality(pk);

create table postcode as select p.* from postcode_ori p left join municipality m on (m.pk = p.municipality_id) where m.pk is not null;
create index idx_postcode_pk on postcode(pk);

create table "group" as select g.* from group_ori g left join municipality m on (g.municipality_id = m.pk) where m.pk is not null;
create index idx_group_pk on "group"(pk);
create index idx_group_ign on "group"(ign);
create index idx_group_laposte on "group"(laposte);

create table housenumber as select h.* from housenumber_ori h left join "group" g on (h.parent_id = g.pk) where g.pk is not null;
create index idx_housenumber_pk on housenumber(pk);
create index idx_housenumber_ign on housenumber(ign);
create index idx_housenumber_laposte on housenumber(laposte);
create index idx_housenumber_cia on housenumber(cia);

create table position as select p.* from position_ori p left join housenumber h on (h.pk = p.housenumber_id) where h.pk is not null;

