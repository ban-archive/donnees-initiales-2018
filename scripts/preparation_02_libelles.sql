--------------------------------------------------------------------------
-- PREPARATION DES DONNEES : CONSITUTION DE LA TABLE LIEBELLES LONG, LIBELLES COURTS DES GROUPES
-- Cette table sert ensuite aux appariements des libellés des différentes sources
--------------------------------------------------------------------------

\set ON_ERROR_STOP 1
\timing

DROP TABLE IF EXISTS libelles;

-- libelles nom IGN
CREATE TABLE libelles AS SELECT nom_maj AS long, trim(nom_maj) AS court FROM ign_group;
CREATE INDEX idx_libelles_long ON libelles (long);

-- libelles afnor contenu dans les donnes ign
INSERT INTO libelles SELECT nom_afnor AS long, trim(nom_afnor) AS court FROM ign_group LEFT JOIN libelles ON (long=nom_afnor) WHERE long IS NULL GROUP BY 1,2;

-- libelles nom FANTOIR
INSERT INTO libelles SELECT nom_maj AS long, trim(nom_maj) AS court FROM dgfip_fantoir f left join libelles l ON (long=nom_maj) WHERE long IS NULL GROUP BY 1,2;

-- libellés RAN
INSERT INTO libelles SELECT lb_voie AS long, trim(lb_voie) AS court FROM ran_group LEFT JOIN libelles ON (long=lb_voie) WHERE long IS NULL GROUP BY 1,2;

-- index par trigram sur le libellé court
create index libelle_trigram on libelles using gin (court gin_trgm_ops);
analyze libelles;

-- nettoyage pour ne conserver que les chiffres et lettres
UPDATE libelles SET court = regexp_replace(regexp_replace(court,'[^A-Z 0-9]',' ','g'),'  *',' ','g') WHERE court ~ '[^A-Z 0-9]';

-- suppression des articles
UPDATE libelles SET regexp_replace(court,'(^| )((LE|LA|LES|L|D|DE|DE|DES|DU|A|AU|AUX|ET) )*',' ','g') WHERE court ~ '(^| )((LE|LA|LES|L|D|DE|DE|DES|DU|A|AU|AUX|ET) )*';

UPDATE libelles SET court = regexp_replace(replace(court,'Œ','OE'),'^(LIEU DIT|LD) ','');

-- élimination des libélés répétés XXX/XXX
update libelles set court = regexp_replace(court,'^(.*)[/ ]\1$','\1') where court ~ '^(.*)[/ ]\1$';


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
update libelles set court=regexp_replace(replace(regexp_replace(court,'(^| )(CD |RD |RTE |CHE )?(CD|CHE|RTE|ROUTE|ROUTES|CHEMIN|CHENIN|VC|VOIE|RUE)\.? (DEP|DEPT|DEPTA|DEPTAL|DEPART|DEPARTE|DEPARTEM|DEPARTEME|DEPARTEMEN|DEPARTEME|DEPARTEMENT|DEPARTEMENTA|DEPARTEMTAL|DEPARTEMENTAL|DEPARTMENTAL|DEPARTEMENATALE|DEPARTENTALE|DEPARTMEMENTALE|DEPARTT|DEPTARMENTAL|DEPARMENTAL|DEPARTEMEMTAL|DEPAETEMENTAL|DEPARTEMANTAL|DEPATREMENTAL|DEPARTEMETAL|DEPATEMENTALE)E?($|\.? ((N|NO|NR|NUM|NUMER|NUMERO|N 0)([0-9 ]))?)','\1CD \8'),'CD CD','CD '),'  *',' ','g')
  where court ~'(^| )(CD |RD |RTE |CHE )?(CD|CHE|RTE|ROUTE|ROUTES|CHEMIN|CHENIN|VC|VOIE|RUE)\.? (DEP|DEPT|DEPTA|DEPTAL|DEPART|DEPARTE|DEPARTEM|DEPARTEME|DEPARTEMEN|DEPARTEME|DEPARTEMENT|DEPARTEMENTA|DEPARTEMTAL|DEPARTEMENTAL|DEPARTMENTAL|DEPARTEMENATALE|DEPARTENTALE|DEPARTMEMENTALE|DEPARTT|DEPTARMENTAL|DEPARMENTAL|DEPARTEMEMTAL|DEPAETEMENTAL|DEPARTEMANTAL|DEPATREMENTAL|DEPARTEMETAL|DEPATEMENTALE)E?($|\.? ((N|NO|NR|NUM|NUMER|NUMERO|N 0)([0-9 ]))?)';
-- CH/CHE/CHEM/CHEMIN CD/RD... sans les DU xxx AU yyy
update libelles set court = regexp_replace(court,'^(CH|CHE|CHEM|CHEMIN) (CD|RD) ','CD ') where court ~ '^(CH|CHE|CHEM|CHEMIN) (CD|RD) ' and long !~ 'DU.* (A|AU) ';

-- abbreviation des types de voies dans les libelles court (environ 1.7 millions de lignes) (remarque on ne met pas l'option g car autrement on risque de remplacer les chaines de caractères de milieu de mot)
with u as (select * from abbrev order by length(txt_long) desc) update libelles set court = regexp_replace(court,u.txt_long, u.txt_court) from u where court ~ (txt_long||' ') and regexp_replace(court,u.txt_long, u.txt_court) <> court;

-- une deuxième fois pour les doubles abbréviations (environ 126 000 lignes)
with u as (select * from abbrev order by length(txt_long) desc) update libelles set court = regexp_replace(court,u.txt_long, u.txt_court) from u where court ~ (txt_long||' ') and regexp_replace(court,u.txt_long, u.txt_court) <> court;

-- une troisième fois (environ 2860 lignes)
with u as (select * from abbrev order by length(txt_long) desc) update libelles set court = regexp_replace(court,u.txt_long, u.txt_court) from u where court ~ (txt_long||' ') and regexp_replace(court,u.txt_long, u.txt_court) <> court;

-- une quatrième fois (environ 136 lignes)
with u as (select * from abbrev order by length(txt_long) desc) update libelles set court = regexp_replace(court,u.txt_long, u.txt_court) from u where court ~ (txt_long||' ') and regexp_replace(court,u.txt_long, u.txt_court) <> court;

-- correction de quelques scories
update libelles set court = 'GR' where court = 'GD RUE';
update libelles set court = 'GR' where court = 'GDE RUE';
update libelles set court = 'GR' where court = 'GRD RUE';
update libelles set court = 'GR' where court = 'GR GRD RUE';
update libelles set court = 'GR' where court = 'GR GD RUE';
update libelles set court = 'GR' where court = 'GR RUE';
update libelles set court = 'GR' where court = 'RUE GDE RUE';
update libelles set court = 'GR' where court = 'RUE GRANDE';
update libelles set court = 'PTR' where court = 'PETITE RUE';
update libelles set court = 'PTR' where court = 'PTR PETITE RUE';
update libelles set court = regexp_replace (court,'^R ','RUE ') where court ~ '^R ';
update libelles set court = 'PETITE IMPASSE' where court = 'IMP PETITE IMPASSE';

-- simplification anciens CHEMINS de différentes natures (ruraux, communaux, ordinaires, vicinaux, etc)
update libelles set court = regexp_replace(court,'^AN(C|) (CH|CHE|CHEM|CHEMIN|C R|CR|C C|CC|CV|C V|CVO|C V O)( RURAL| COMMUNAL| VICINAL| ORDINAIRE|)( DIT |) ','ACH ')
  where court ~ '^AN(C|) (CH|CHE|CHEM|CHEMIN|C R|CR|C C|CC|CV|C V|CVO|C V O)( RURAL| COMMUNAL| VICINAL| ORDINAIRE|)( DIT |) ';
update libelles set court = regexp_replace(court,'^(CC|CE|CH|CHE|CHEMD|CHV|CR)( CHE| COM| C R| CR| EXP| EXPL| EXPLOIT| EXPLOITATION| R| RUR| RURAL)( NUMERO|) .* (DIT|DITE)( CHE|) ','CHE ') where court ~ '^(CC|CE|CH|CHE|CHEMD|CHV|CR)( CHE| COM| C R| CR| EXP| EXPL| EXPLOIT| EXPLOITATION| R| RUR| RURAL)( NUMERO|) .* (DIT|DITE) ';

-- voies Numérotées DIT/DITE ...
update libelles set court= regexp_replace(court,' (N|NO) [0-9]* (DIT|DITE) ',' ') where court ~ ' (N|NO) [0-9]* (DIT|DITE) ';
update libelles set court = regexp_replace(court,'^(CH|CE|CC|CHEM|CHE|CR|CV|CVO) (NUMERO |)[0-9]+ DIT (CHE |)','CHE ') where court ~ '^(CH|CE|CC|CHEM|CHE|CR|CV|CVO) (NUMERO |)[0-9]+ DIT ';

-- traitement de "HAMEAU" en fin ou début de libellé
update libelles set court = regexp_replace(court,' HAMEAU$','') where court ~' HAMEAU$' and long !~ '(^| )(LE|DU|D|L|AU|JEAN|GRAND|PETIT|VIEUX) HAMEAU$';
update libelles set court = regexp_replace(court,'^HAM ','') where court ~'^HAM ';

-- traitement des xxxxC'H bretons
update libelles set court = regexp_replace(court, '([A-Z]C) H( |$)','\1H\2','g') where court ~'[A-Z]C H( |$)';

-- chiffres romains
UPDATE libelles set court=regexp_replace(court,' (HENRI|LOUIS|NAPOLEON) I( |$)',' \1 1\2') where court ~ ' (HENRI|LOUIS|NAPOLEON) I( |$)';

UPDATE libelles set court=regexp_replace(court,' II( |$)',' 2\1') where court ~ ' II( |$)';
UPDATE libelles set court=regexp_replace(court,' III( |$)',' 3\1') where court ~ ' III( |$)';
UPDATE libelles set court=regexp_replace(court,' IV( |$)',' 4\1') where court ~ ' IV( |$)';

UPDATE libelles set court=regexp_replace(court,' (CHARLES|LOUIS|GEORGES|GUSTAVE|HENRI|MOHAMMED) V( |$)',' \1 5\2') where court ~ ' (CHARLES|LOUIS|GEORGES|GUSTAVE|HENRI|MOHAMMED) V( |$)';

UPDATE libelles set court=regexp_replace(court,' (CHARLES|GEORGES|HENRI|LOUIS) VI( |$)',' \1 6\2') where court ~ ' (CHARLES|GEORGES|HENRI|LOUIS) VI( |$)';

UPDATE libelles set court=regexp_replace(court,' VII( |$)',' 7\1') where court ~ ' VII( |$)';
UPDATE libelles set court=regexp_replace(court,' VIII( |$)',' 8\1') where court ~ ' VIII( |$)';
UPDATE libelles set court=regexp_replace(court,' IX( |$)',' 9\1') where court ~ ' IX( |$)';

UPDATE libelles set court=regexp_replace(court,' (CHARLES|LOUIS) X( |$)',' \1 10\2') where court ~ ' (CHARLES|LOUIS) X( |$)';

UPDATE libelles set court=regexp_replace(court,' XI( |$)',' 11\1') where court ~ ' XI( |$)';
UPDATE libelles set court=regexp_replace(court,' XII( |$)',' 12\1') where court ~ ' XII( |$)';
UPDATE libelles set court=regexp_replace(court,' XIII( |$)',' 13\1') where court ~ ' XIII( |$)';
UPDATE libelles set court=regexp_replace(court,' XIV( |$)',' 14\1') where court ~ ' XIV( |$)';
UPDATE libelles set court=regexp_replace(court,' XV( |$)',' 15\1') where court ~ ' XV( |$)';
UPDATE libelles set court=regexp_replace(court,' XVI( |$)',' 16\1') where court ~ ' XVI( |$)';
UPDATE libelles set court=regexp_replace(court,' XVII( |$)',' 17\1') where court ~ ' XVII( |$)';
UPDATE libelles set court=regexp_replace(court,' XVIII( |$)',' 18\1') where court ~ ' XVIII( |$)';
UPDATE libelles set court=regexp_replace(court,' XIX( |$)',' 19\1') where court ~ ' XIX( |$)';
UPDATE libelles set court=regexp_replace(court,' XX( |$)',' 20\1') where court ~ ' XX( |$)';
UPDATE libelles set court=regexp_replace(court,' XXI( |$)',' 21\1') where court ~ ' XXI( |$)';
UPDATE libelles set court=regexp_replace(court,' XXII( |$)',' 22\1') where court ~ ' XXII( |$)';
UPDATE libelles set court=regexp_replace(court,' XXIII( |$)',' 23\1') where court ~ ' XXIII( |$)';

-- quantièmes dans les dates... 1 ER / 1ER / PREMIER -> 1
UPDATE libelles set court=regexp_replace(court,' (1 ER|1ER|PREMIER) (JANVIER|JANV|FEVRIER|FEVR|MARS|AVRIL|MAI|JUIN|JUILLET|JUIL|AOUT|SEPTEMBRE|SEPT|OCTOBRE|OCT|NOVEMBRE|NOV|DECEMBRE|DEC)( |$)',' 1 \2\3') where court ~ ' (1 ER|1ER|PREMIER) (JANVIER|JANV|FEVRIER|FEVR|MARS|AVRIL|MAI|JUIN|JUILLET|JUIL|AOUT|SEPTEMBRE|SEPT|OCTOBRE|OCT|NOVEMBRE|NOV|DECEMBRE|DEC)( |$)';
-- mois dans les dates
UPDATE libelles SET court = replace(court,' JANVIER',' JANV') WHERE court ~ 'JANVIER';
UPDATE libelles SET court = replace(court,' FEVRIER',' FEVR') WHERE court ~ 'FEVRIER';
UPDATE libelles SET court = replace(court,' JUILLET',' JUIL') WHERE court ~ 'JUILLET';
UPDATE libelles SET court = replace(court,' SEPTEMBRE',' SEPT') WHERE court ~ 'SEPTEMBRE';
UPDATE libelles SET court = replace(court,' OCTOBRE',' OCT') WHERE court ~ 'OCTOBRE';
UPDATE libelles SET court = replace(court,' NOVEMBRE',' NOV') WHERE court ~ 'NOVEMBRE';
UPDATE libelles SET court = replace(court,' NOVENBRE',' NOV') WHERE court ~ 'NOVENBRE';
UPDATE libelles SET court = replace(court,' DECEMBRE',' DEC') WHERE court ~ 'DECEMBRE';
-- 11 NOVEMBRE 18/1918 -> 11 NOV
UPDATE libelles SET court = replace(court,' 11 NOV (18( |$)|1918)',' 11 NOV') WHERE court ~ ' 11 NOV (18( |$)|1918)';
-- 8 MAI 45/1945-> 8 MAI
UPDATE libelles SET court = replace(court,' 8 MAI (45( |$)|1945)',' 8 MAI') WHERE court ~ ' 8 MAI (45( |$)|1945)';

-- premier et variations...
update libelles set court=regexp_replace(court,' 1 (E|EM|EME|ER|ERE|ERS|ERES)( |$)',' 1E\2') where court ~ ' 1 (E|EM|EME|ER|ERE|ERS|ERES)( |$)';
update libelles set court=regexp_replace(court,' (PREM|PREMI|PREMIER|PREMIERS|PREMIERE|PREMIERES)( |$)',' 1E\2') WHERE court ~ ' (PREM|PREMI|PREMIER|PREMIERS|PREMIERE|PREMIERES)( |$)';

-- second et variations...
update libelles set court=regexp_replace(court,' 2(( |)(E|EM|EME|ND|NDE))( |$)',' 2E\4') where court ~ ' 2(( |)(E|EM|EME|ND|NDE|NDS|NDES))( |$)';
update libelles set court=regexp_replace(court,' (SECOND|SECONDAI|SECONDAIR|SECONDAIRE|SECONDE)(S|)( |$)',' 2E\3') WHERE court ~ ' (SECOND|SECONDAI|SECONDAIR|SECONDAIRE|SECONDE)(S|)( |$)';

-- quantièmes... cas généraux jusqu'à 999 !
-- la requête génère toutes les combinaisons des quantièmes par unité, dizaine, centaine
-- certaines sont incorrectes (QUATRE VING DIX SEIZIEME), mais ne seront jamais trouvées
WITH u AS (SELECT cent+diz+num as quantieme,format(' (%s EM|%sEM|%s EME|%sEME|%s)(E|ES|S|)( |$)',cent+diz+num,cent+diz+num,cent+diz+num,cent+diz+num,trim(txt_cent||' '||txt_diz||' '||txt)) AS re FROM (SELECT regexp_split_to_table(',CENT,DEUX CENT,TROIS CENT,QUATRE CENT,CINQ CENT,SIX CENT,SEPT CENT,HUIT CENT,NEUF CENT',',') AS txt_cent, generate_series(0,9)*100 AS cent) centaine, (SELECT regexp_split_to_table(',DIX,VINGT,TRENTE,QUARANTE,CINQUANTE,SOIXANTE,SOIXANTE DIX,QUATRE VINGT,QUATRE VINGT DIX',',') AS txt_diz, generate_series(0,90,10) AS diz) dizaine, (SELECT regexp_split_to_table('UNIEME,DEUXIEME,TROISIEME,QUATRIEME,CINQUIEME,SIXIEME,SEPTIEME,HUITIEME,NEUVIEME,DIXIEME,ONZIEME,DOUZIEME,TREIZIEME,QUATORZIEME,QUINZIEME,SEIZIEME',',') AS txt, generate_series(1,16) AS num) AS q ORDER BY quantieme DESC)
  UPDATE libelles SET court = regexp_replace(court,re,format(' %sE\3',quantieme)) FROM u WHERE court ~ re;

-- suppression finale des mot répétés (de 2 lettres minimum)
update libelles set court= regexp_replace(court,'( |$)([A-Z]{2,}) \2( |$)','\1\2\3') where court ~ '( |$)([A-Z]{2,}) \2( |$)';

-- menage final
update libelles set court=trim(court) where court like ' %' or court like '% ';
delete from libelles where long is null;
delete from libelles where long = '';


-- suppression des doublons
drop table if exists libelles2;
create table libelles2 as select long,court from libelles group by long,court;
drop table libelles;
alter table libelles2 rename to libelles;

-- index
CREATE INDEX idx_libelles_long ON libelles (long);
CREATE INDEX idx_libelles_court ON libelles (court);
-- index inutilisé par la suite, mais utile pour les tests...
create index libelle_trigram on libelles using gin (court gin_trgm_ops);
