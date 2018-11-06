drop table municipality90;
drop table postcode90;
drop table group90;
drop table housenumber90;
drop table position90;

create table municipality90 as select * from municipality where insee like '90%';
create index idx_municipaly90_pk on municipality90(pk);

create table postcode90 as select p.* from postcode p left join municipality90 m on (m.pk = p.municipality_id) where m.pk is not null;
create index idx_postcode90_pk on postcode90(pk);

create table group90 as select g.* from "group" g left join municipality90 m on (g.municipality_id = m.pk) where m.pk is not null;
create index idx_group90_pk on group90(pk);
create index idx_group90_ign on group90(ign);
create index idx_group90_laposte on group90(laposte);

create table housenumber90 as select h.* from housenumber h left join group90 g on (h.parent_id = g.pk) where g.pk is not null;
create index idx_housenumber90_pk on housenumber90(pk);
create index idx_housenumber90_ign on housenumber90(ign);
create index idx_housenumber90_laposte on housenumber90(laposte);
create index idx_housenumber90_cia on housenumber90(cia);

create table position90 as select p.* from position p left join housenumber90 h on (h.pk = p.housenumber_id) where h.pk is not null;

