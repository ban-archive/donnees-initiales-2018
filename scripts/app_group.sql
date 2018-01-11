\set ON_ERROR_STOP 1
\timing

-- Rapprochement groupe ign et groupe fantoir avec le même fantoir et le meme nom (majuscule, sans accent, remplacement ''', '-' , '  ' par ' ')
drop table if exists ign_group_travail;

create table ign_group_travail as select i.*, trim(nature_voie||' '||libelle_voie) as nom_fantoir, f.fantoir_9 from ign_group_travail i left join dgfip_fantoir f on (fantoir_9 = id_fantoir);

-- création d'un champ nom un peu nettoye normalisé (majuscule, desaccentué, suppression des doubles espaces, remplacement - et ' par espace)
ALTER TABLE ign_group_travail DROP COLUMN IF EXISTS nom_maj;
ALTER TABLE  ign_group_travail ADD COLUMN nom_maj varchar;
UPDATE ign_group_travail SET nom_maj=upper(unaccent(nom));
UPDATE ign_group_travail SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';
UPDATE ign_group_travail SET nom_maj=regexp_replace(nom_maj,E'([\'-]|  *)',' ','g') WHERE nom_maj ~ E'([\'-]|  )';


alter table group_ign_travail add column id_fantoir_new varchar;
update ign_group_travail set id_fantoir_new = fantoir_9 where id_fantoir=fantoir_9 and nom_maj=nom_fantoir and nom_maj is not null and nom_maj <> '';



select id_pseudo_fpb, id_fantoir, nom,nom_maj, string_agg(l2.long,','), string_agg(f.fantoir_9,','), f.nature_voie||' '||f.libelle_voie from (select  * from ign_group_travail where id_fantoir_new is null limit 100) i join libelles l1 on (l1.long=nom) join libelles l2 on (l2.court=l1.court and l2.long != l1.long) join dgfip_fantoir f on (trim(f.nature_voie||' '||f.libelle_voie) = l2.long and f.code_insee=i.code_insee and date_annul='0000000') where right(i.code_insee||i.id_fantoir,9) != f.fantoir_9 group by 1,2,3,4,7;



