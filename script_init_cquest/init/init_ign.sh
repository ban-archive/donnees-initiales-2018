psql -c '
DROP TABLE IF EXISTS ign_group;
CREATE TABLE ign_group (
    id_pseudo_fpb text COLLATE pg_catalog."C",
    nom character varying,
    alias character varying,
    type_d_adressage character varying,
    id_poste text COLLATE pg_catalog."C",
    nom_afnor text COLLATE pg_catalog."C",
    id_fantoir text COLLATE pg_catalog."C",
    code_insee text COLLATE pg_catalog."C",
);

DROP TABLE IF EXISTS ign_housenumber;

CREATE TABLE ign_housenumber (
    id text COLLATE pg_catalog."C",
    numero text COLLATE pg_catalog."C",
    rep text COLLATE pg_catalog."C",
    designation_de_l_entree character varying,
    type_de_localisation character varying,
    indice_de_positionnement character varying,
    methode character varying,
    lon double precision,
    lat double precision,
    code_post text COLLATE pg_catalog."C",
    code_insee text COLLATE pg_catalog."C",
    id_pseudo_fpb text COLLATE pg_catalog."C",
    id_poste text COLLATE pg_catalog."C",
    kind_pos text,
);


DROP TABLE IF EXISTS ign_housenumber_errors;
CREATE TABLE ign_housenumber_errors (
    id character varying,
    numero character varying,
    rep character varying,
    nom_voie character varying,
    nom_ld character varying,
    designation_de_l_entree character varying,
    type_de_localisation character varying,
    indice_de_positionnement character varying,
    methode character varying,
    lon double precision,
    lat double precision,
    code_post character varying,
    code_insee character varying,
    id_pseudo_fpb character varying,
    id_poste character varying
);'

for f in ../../data/IGN/SGA/*/ban.house_number_errors*.csv ; do
  mv $f $f.err
done

for f in ../../data/IGN/SGA/*/ban.group*.csv ; do
  psql -c "\COPY ign_group FROM '$f' WITH CSV HEADER DELIMITER ';';"
done
for f in ../../data/IGN/SGA/*/ban.house_number*.csv ; do
  psql -c "\COPY ign_housenumber FROM '$f' WITH CSV HEADER DELIMITER ';';"
done
for f in ../../data/IGN/SGA/*/ban.house_number*.err ; do
  psql -c "\COPY ign_housenumber_errors FROM '$f' WITH CSV HEADER DELIMITER ';';"
done

psql -c '
-- geométrie des points adresse
ALTER TABLE ign_housenumber ADD geom geometry;
-- index pour ign_housenumber
CREATE UNIQUE INDEX ign_housenumber_id ON ign_housenumber USING btree (id);
CREATE INDEX ign_housenumber_insee ON ign_housenumber USING btree (code_insee);
CREATE INDEX ign_housenumber_pseudo_fpb ON ign_housenumber USING spgist (id_pseudo_fpb);
CREATE INDEX ign_housenumber_geom ON ign_housenumber USING gist (geom);

-- fantoir2 pour ign_group
ALTER TABLE ign_group ADD fantoir2 text COLLATE "C";
-- index pour ign_group
CREATE INDEX ign_group_insee_no_fantoir ON ign_group USING btree (code_insee) WHERE (id_fantoir IS NULL);
CREATE UNIQUE INDEX ign_group_pseudo_fpb ON ign_group USING btree (id_pseudo_fpb);
'


