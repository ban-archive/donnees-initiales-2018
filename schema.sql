--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ign_housenumber; Type: TABLE; Schema: public; Owner: -
--

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
    geom geography
);


SET default_tablespace = ssd;

--
-- Name: ign_housenumber_id; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE UNIQUE INDEX ign_housenumber_id ON ign_housenumber USING btree (id);


--
-- Name: ign_housenumber_insee; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ign_housenumber_insee ON ign_housenumber USING btree (code_insee);


--
-- Name: ign_housenumber_pseudo_fpb; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ign_housenumber_pseudo_fpb ON ign_housenumber USING spgist (id_pseudo_fpb);


--
-- Name: ign_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ign_group (
    id_pseudo_fpb text COLLATE pg_catalog."C",
    nom character varying,
    alias character varying,
    type_d_adressage character varying,
    id_poste text COLLATE pg_catalog."C",
    nom_afnor text COLLATE pg_catalog."C",
    id_fantoir text COLLATE pg_catalog."C",
    code_insee text COLLATE pg_catalog."C",
    fantoir2 text COLLATE pg_catalog."C"
);


SET default_tablespace = ssd;

--
-- Name: ign_group_insee_no_fantoir; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ign_group_insee_no_fantoir ON ign_group USING btree (code_insee) WHERE (id_fantoir IS NULL);


--
-- Name: ign_group_pseudo_fpb; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE UNIQUE INDEX ign_group_pseudo_fpb ON ign_group USING btree (id_pseudo_fpb);


--
-- Name: ran_postcode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ran_postcode (
    co_insee text COLLATE pg_catalog."C",
    co_postal text COLLATE pg_catalog."C",
    lb_l6 text COLLATE pg_catalog."C"
);


SET default_tablespace = ssd;

--
-- Name: ran_postcode_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE UNIQUE INDEX ran_postcode_idx ON ran_postcode USING btree (co_insee, co_postal, lb_l6);

--
-- Name: ran_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ran_group (
    co_insee text COLLATE pg_catalog."C",
    co_voie text COLLATE pg_catalog."C",
    co_postal text COLLATE pg_catalog."C",
    co_cea text COLLATE pg_catalog."C",
    lb_type_voie text COLLATE pg_catalog."C",
    lb_voie text COLLATE pg_catalog."C",
    lb_ligne5 text COLLATE pg_catalog."C",
    c_oldinsee text COLLATE pg_catalog."C"
);


SET default_tablespace = ssd;

--
-- Name: ran_group_idx_insee; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ran_group_idx_insee ON ran_group USING btree (co_insee);

--
-- Name: ran_housenumber; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ran_housenumber (
    co_insee text COLLATE pg_catalog."C",
    co_voie text COLLATE pg_catalog."C",
    co_postal text COLLATE pg_catalog."C",
    va_no_voie text COLLATE pg_catalog."C",
    lb_ext text COLLATE pg_catalog."C",
    co_cea text COLLATE pg_catalog."C"
);


SET default_tablespace = ssd;

--
-- Name: ran_housenumber_cea; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE UNIQUE INDEX ran_housenumber_cea ON ran_housenumber USING btree (co_cea);


--
-- Name: ran_housenumber_idx_voie; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ran_housenumber_idx_voie ON ran_housenumber USING btree (co_voie);


--
-- Name: ran_housenumber_insee; Type: INDEX; Schema: public; Owner: -; Tablespace: ssd
--

CREATE INDEX ran_housenumber_insee ON ran_housenumber USING btree (co_insee);


--
-- PostgreSQL database dump complete
--

