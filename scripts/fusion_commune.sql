--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: modification_insee; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--
DROP TABLE IF EXISTS fusion_commune;

CREATE TABLE fusion_commune (
    insee_old character varying,
    insee_new character varying,
    nom_new character varying(255),
    date text,
    nom_old character varying
);


--
-- Data for Name: modification_insee; Type: TABLE DATA; Schema: public; Owner: -
--

COPY fusion_commune (insee_old, insee_new, nom_new, date, nom_old) FROM stdin;
14543	14543	Rots	2015	Rots
50095	50095	Canisy	2017	Canisy
44004	44163	Vair-sur-Loire	2015	Anetz (rattachée à 44163)
74167	74167	Val de Chaise	2015	Val de Chaise
27049	27049	Mesnil-en-Ouche	2015	Mesnil-en-Ouche
27412	27412	Terres de Bord	2017	Terres de Bord
27554	27554	La Chapelle-Longueville	2017	La Chapelle-Longueville
39273	39273	Montlainsia	2017	Montlainsia
39576	39576	Val-Sonnette	2017	Val-Sonnette
67004	67004	Sommerau	2015	Sommerau
67202	67202	Hochfelden	2017	Hochfelden
73290	73290	Val-Cenis	2017	Val-Cenis
68006	68006	Bernwiller	2015	Bernwiller
68240	68240	Illtal	2015	Illtal
36093	36093	Levroux	2015	Levroux
73108	73010	Entrelacs	2015	Épersy (rattachée à 73010)
86053	86053	Champigny en Rochereau	2017	Champigny en Rochereau
51331	51564	Val de Livre	2015	Louvois (rattachée à 51564)
51347	51030	Ay-Champagne	2015	Mareuil-sur-Ay (rattachée à 51030)
39577	39577	Vincent-Froideville	2015	Vincent-Froideville
79168	79063	Val en Vignes	2017	Massais (rattachée à 79063)
89429	89411	Les Vallées de la Vanne	2015	Vareilles (rattachée à 89411)
89457	89196	Valravillon	2015	Villemer (rattachée à 89196)
36229	36229	Val-Fouzon	2015	Val-Fouzon
79187	79013	Argentonnay	2015	Moutiers-sous-Argenton (rattachée à 79013)
50018	50487	Saint-James	2017	Argouges (rattachée à 50487)
50318	50260	Juvigny les Vallees	2017	Le Mesnil-Rainfray (rattachée à 50260)
51064	51030	Ay-Champagne	2015	Bisseuil (rattachée à 51030)
08443	08490	Vouziers	2016	Terron-sur-Aisne (rattachée à 08490)
08493	08490	Vouziers	2016	Vrizy (rattachée à 08490)
50220	50041	La Hague	2017	Gréville-Hague (rattachée à 50041)
50242	50041	La Hague	2017	Herqueville (rattachée à 50041)
50257	50041	La Hague	2017	Jobourg (rattachée à 50041)
50333	50400	Picauville	2017	Les Moitiers-en-Bauptois (rattachée à 50400)
22192	22209	Beaussais-sur-Mer	2017	Plessix-Balisson (rattachée à 22209)
57184	57021	Ancy-Dornot	2015	Dornot (rattachée à 57021)
38145	38359	Saint Antoine l'Abbaye	2015	Dionay (rattachée à 38359)
38262	38439	Crêts en Belledonne	2015	Morêtel-de-Mailles (rattachée à 38439)
50280	50292	Marigny-Le-Lozon	2015	Lozon (rattachée à 50292)
50316	50363	Moyon Villages	2015	Le Mesnil-Opac (rattachée à 50363)
50330	50236	La Haye	2015	Mobecq (rattachée à 50236)
50375	50142	Vicq-sur-Mer	2015	Néville-sur-Mer (rattachée à 50142)
50380	50492	Saint-Jean-d'Elle	2015	Notre-Dame-d'Elle (rattachée à 50492)
50614	50082	Bricquebec-en-Cotentin	2015	Le Valdécie (rattachée à 50082)
50635	50492	Saint-Jean-d'Elle	2015	Vidouville (rattachée à 50492)
62294	62295	Enquin-lez-Guinegatte	2017	Enguinegatte (rattachée à 62295)
62295	62295	Enquin-lez-Guinegatte	2017	Enquin-lez-Guinegatte
57432	57148	Maizery	2016	Maizery (rattachée à 57148)
61496	61474	Gouffern en Auge	2017	Urou-et-Crennes (rattachée à 61474)
61110	61474	Gouffern en Auge	2017	La Cochère (rattachée à 61474)
48099	48099	Bourgs sur Colagne	2015	Bourgs sur Colagne
38541	38022	Les Avenières Veyrins-Thuellin	2015	Veyrins-Thuellin (rattachée à 38022)
38165	38001	Les Abrets en Dauphiné	2015	Fitilieu (rattachée à 38001)
50477	50041	La Hague	2017	Saint-Germain-des-Vaux (rattachée à 50041)
50608	50139	Conde-sur-Vire	2017	Troisgots (rattachée à 50139)
50620	50041	La Hague	2017	Vasteville (rattachée à 50041)
50627	50487	Saint-James	2017	Vergoncey (rattachée à 50487)
50132	50168	Ducey-Les Chéris	2015	Les Chéris (rattachée à 50168)
50470	50564	Terre-et-Marais	2015	Saint-Georges-de-Bohon (rattachée à 50564)
50520	50082	Bricquebec-en-Cotentin	2015	Saint-Martin-le-Hébert (rattachée à 50082)
50558	50236	La Haye	2015	Saint-Symphorien-le-Valois (rattachée à 50236)
50534	50099	Carentan les Marais	2017	Saint-Pellerin (rattachée à 50099)
74268	74010	Annecy	2017	Seynod (rattachée à 74010)
22051	22084	Jugon-les-Lacs - Commune nouvelle	2015	Dolo (rattachée à 22084)
22066	22046	Le Mené	2015	Le Gouray (rattachée à 22046)
22080	22203	Ploeuc-L'Hermitage	2015	L'Hermitage-Lorge (rattachée à 22203)
22058	22183	Les Moulins	2015	La Ferrière (rattachée à 22183)
22102	22046	Le Mené	2015	Langourla (rattachée à 22046)
74093	74010	Annecy	2017	Cran-Gevrier (rattachée à 74010)
74182	74010	Annecy	2017	Meythet (rattachée à 74010)
74204	74282	Filliere	2017	Les Ollières (rattachée à 74282)
74022	74282	Filliere	2017	Aviernoz (rattachée à 74282)
65480	65399	Saligos	2017	Vizos (rattachée à 65399)
50005	50400	Picauville	2015	Amfreville (rattachée à 50400)
50009	50565	Sartilly-Baie-Bocage	2015	Angey (rattachée à 50565)
50010	50099	Carentan les Marais	2015	Angoville-au-Plain (rattachée à 50099)
50012	50267	Lessay	2015	Angoville-sur-Ay (rattachée à 50267)
02026	02458	Dhuys et Morin-en-Brie	2015	Artonges (rattachée à 02458)
85165	85084	Essarts en Bocage	2015	L'Oie (rattachée à 85084)
85150	85197	Montréverd	2015	Mormaison (rattachée à 85197)
85091	85080	Doix lès Fontaines	2015	Fontaines (rattachée à 85080)
35176	35176	Guipry-Messac	2015	Guipry-Messac
02147	02458	Dhuys et Morin-en-Brie	2015	La Celle-sous-Montmirail (rattachée à 02458)
02161	02053	Vallées en Champagne	2015	La Chapelle-Monthodon (rattachée à 02053)
02325	02458	Dhuys et Morin-en-Brie	2015	Fontenelle-en-Brie (rattachée à 02458)
02348	02439	Les Septvallons	2015	Glennes (rattachée à 02439)
69222	69024	Val d Oingt	2017	Saint-Laurent-d'Oingt (rattachée à 69024)
02597	02439	Les Septvallons	2015	Perles (rattachée à 02439)
89174	89405	Les Hauts de Forterre	2017	Fontenailles (rattachée à 89405)
89260	89405	Les Hauts de Forterre	2017	Molesmes (rattachée à 89405)
73198	73227	Courchevel	2017	La Perrière (rattachée à 73227)
81113	81218	Puygouzon	2017	Labastide-Dénat (rattachée à 81218)
73287	73290	Val-Cenis	2017	Sollières-Sardières (rattachée à 73290)
02646	02439	Les Septvallons	2015	Révillon (rattachée à 02439)
02669	02053	Vallées en Champagne	2015	Saint-Agnan (rattachée à 02053)
16115	16046	Coteaux du Blanzacais	2017	Cressac-Saint-Genis (rattachée à 16046)
16129	16204	Bellevigne	2017	Éraville (rattachée à 16204)
08371	08053	Bazeilles	2017	Rubécourt-et-Lamécourt (rattachée à 08053)
56033	56033	Carentoir	2017	Carentoir
39017	39017	Arlay	2015	Arlay
39021	39021	La Chailleuse	2015	La Chailleuse
85030	85084	Essarts en Bocage	2015	Boulogne (rattachée à 85084)
85279	85019	Bellevigny	2015	Saligny (rattachée à 85019)
02771	02439	Les Septvallons	2015	Vauxcéré (rattachée à 02439)
67158	67539	Wingersheim les quatre Bans	2015	Gingsheim (rattachée à 67539)
67297	67539	Wingersheim les quatre Bans	2015	Mittelhausen (rattachée à 67539)
67374	67495	Truchtersheim	2015	Pfettisheim (rattachée à 67495)
39332	39177	Hauteroche	2015	Mirebel (rattachée à 39177)
39213	39329	Mièges	2015	Esserval-Combe (rattachée à 39329)
39215	39021	La Chailleuse	2015	Essia (rattachée à 39021)
51075	51075	Bourgogne-Fresne	2017	Bourgogne-Fresne
46201	46201	Montcuq-en-Quercy-Blanc	2015	Montcuq-en-Quercy-Blanc
51171	51171	Cormicy	2017	Cormicy
67431	67004	Sommerau	2015	Salenthal (rattachée à 67004)
67469	67004	Sommerau	2015	Singrist (rattachée à 67004)
67496	67372	Val de Moder	2015	Uberach (rattachée à 67372)
67512	67372	Val de Moder	2015	La Walck (rattachée à 67372)
45191	45191	Le Malesherbois	2015	Le Malesherbois
68031	68006	Bernwiller	2015	Bernwiller (rattachée à 68006)
68070	68056	Brunstatt-Didenheim	2015	Didenheim (rattachée à 68056)
39566	39018	Aromas	2017	Villeneuve-lès-Charnod (rattachée à 39018)
68108	68240	Illtal	2015	Grentzingen (rattachée à 68240)
68133	68240	Illtal	2015	Henflingen (rattachée à 68240)
68164	68162	Kaysersberg Vignoble	2015	Kientzheim (rattachée à 68162)
38297	38297	Arandon-Passins	2017	Arandon-Passins
39243	39577	Vincent-Froideville	2015	Froideville (rattachée à 39577)
68206	68012	Aspach-Michelbach	2015	Michelbach (rattachée à 68012)
68233	68201	Masevaux-Niederbruck	2015	Niederbruck (rattachée à 68201)
62226	62691	Saint-Augustin	2015	Clarques (rattachée à 62691)
68272	68143	Porte du Ried	2015	Riedwihr (rattachée à 68143)
68310	68162	Kaysersberg Vignoble	2015	Sigolsheim (rattachée à 68162)
68314	68219	Le Haut Soultzbach	2015	Soppe-le-Haut (rattachée à 68219)
68319	68320	Spechbach	2015	Spechbach-le-Bas (rattachée à 68320)
08053	08053	Bazeilles	2017	Bazeilles
08116	08116	Bairon et ses environs	2015	Bairon et ses environs
08145	08145	Douzy	2015	Douzy
39438	39286	Lavans-lès-Saint-Claude	2015	Ponthoux (rattachée à 39286)
08198	08198	Grandpré	2015	Grandpré
38225	38225	Autrans-Méaudre en Vercors	2015	Autrans-Méaudre en Vercors
65399	65399	Saligos	2017	Saligos
08490	08490	Vouziers	2016	Vouziers
08491	08491	Vrigne aux Bois	2017	Vrigne aux Bois
70345	70489	Servance-Miellin	2017	Miellin (rattachée à 70489)
70489	70489	Servance-Miellin	2017	Servance-Miellin
61341	61341	Écouves	2015	Écouves
61309	61309	Perche en Nocé	2015	Perche en Nocé
64225	64225	Ance Feas	2017	Ance Feas
73257	73257	Les Belleville	2015	Les Belleville
79053	79013	Argentonnay	2015	Le Breuil-sous-Argenton (rattachée à 79013)
79333	79013	Argentonnay	2015	Ulcot (rattachée à 79013)
54341	54099	Val de Briey	2017	Mance (rattachée à 54099)
54342	54099	Val de Briey	2017	Mancieulles (rattachée à 54099)
23192	23192	Fursac	2017	Fursac
23161	23149	Parsac-Rimondeix	2015	Rimondeix (rattachée à 23149)
26187	26001	Solaure en Diois	2015	Molières-Glandaz (rattachée à 26001)
05053	05053	Garde-Colombe	2015	Garde-Colombe
88465	88465	Capavenir Vosges	2015	Capavenir Vosges
01204	01204	Le Poizat-Lalleyriat	2015	Le Poizat-Lalleyriat
39130	39130	Nanchez	2015	Nanchez
37102	37123	Langeais	2017	Les Essards (rattachée à 37123)
37120	37232	Coteaux-sur-Loire	2017	Ingrandes-de-Touraine (rattachée à 37232)
37135	37021	Beaumont-Louestault	2017	Louestault (rattachée à 37021)
50639	50639	Villedieu-les-Poêles-Rouffigny	2015	Villedieu-les-Poêles-Rouffigny
49367	49367	Erdre-en-Anjou	2015	Erdre-en-Anjou
49345	49345	Bellevigne-en-Layon	2015	Bellevigne-en-Layon
89241	89086	Charny Orée de Puisaye	2015	Malicorne (rattachée à 89086)
14342	14342	Isigny-sur-Mer	2017	Isigny-sur-Mer
40243	40243	Rion-des-Landes	2017	Rion-des-Landes
53161	53161	Montsurs-Saint-Cenere	2017	Montsurs-Saint-Cenere
49244	49244	Mauges-sur-Loire	2015	Mauges-sur-Loire
61009	61474	Gouffern en Auge	2017	Aubry-en-Exmes (rattachée à 61474)
14654	14654	Saint-Pierre-en-Auge	2017	Saint-Pierre-en-Auge
61057	61474	Gouffern en Auge	2017	Le Bourg-Saint-Léonard (rattachée à 61474)
49373	49373	Lys-Haut-Layon	2015	Lys-Haut-Layon
39069	39485	Val Suran	2017	Bourcia (rattachée à 39485)
39195	39273	Montlainsia	2017	Dessia (rattachée à 39273)
39224	39290	Valzin en Petite Montagne	2017	Fétigny (rattachée à 39290)
01080	01080	Champdor-Corcelles	2015	Champdor-Corcelles
39264	39576	Val-Sonnette	2017	Grusse (rattachée à 39576)
53185	53185	Pré-en-Pail-Saint-Samson	2015	Pré-en-Pail-Saint-Samson
12005	12223	Argences en Aubrac	2015	Alpuech (rattachée à 12223)
12014	12224	Saint Geniez d'Olt et d'Aubrac	2015	Aurelle-Verlac (rattachée à 12224)
12040	12270	Sévérac d'Aveyron	2015	Buzeins (rattachée à 12270)
12081	12177	Palmas d'Aveyron	2015	Coussergues (rattachée à 12177)
12087	12177	Palmas d'Aveyron	2015	Cruéjouls (rattachée à 12177)
12114	12076	Conques-en-Rouergue	2015	Grand-Vabre (rattachée à 12076)
12123	12270	Sévérac d'Aveyron	2015	Lapanouse (rattachée à 12270)
12126	12270	Sévérac d'Aveyron	2015	Lavernhe (rattachée à 12270)
12173	12076	Conques-en-Rouergue	2015	Noailhac (rattachée à 12076)
12196	12270	Sévérac d'Aveyron	2015	Recoules-Prévinquières (rattachée à 12270)
12245	12021	Le Bas Ségala	2015	Saint-Salvadou (rattachée à 12021)
12271	12120	Laissac-Sévérac l'Eglise	2015	Sévérac-l'Église (rattachée à 12120)
12279	12223	Argences en Aubrac	2015	La Terrisse (rattachée à 12223)
12285	12021	Le Bas Ségala	2015	Vabre-Tizac (rattachée à 12021)
12304	12223	Argences en Aubrac	2015	Vitrac-en-Viadène (rattachée à 12223)
56197	56197	Val d'Oust	2015	Val d'Oust
69114	69159	Porte des Pierres Dorees	2017	Liergues (rattachée à 69159)
76618	76618	Petit-Caux	2015	Petit-Caux
41272	41167	Veuzain-sur-Loire	2017	Veuves (rattachée à 41167)
41033	41142	Valencisse	2017	Chambon-sur-Cisse (rattachée à 41142)
41169	41142	Valencisse	2015	Orchaise (rattachée à 41142)
41011	41171	Oucques La Nouvelle	2017	Baigneaux (rattachée à 41171)
21658	21195	Cormot-Vauchignon	2017	Vauchignon (rattachée à 21195)
38534	38253	Les Deux Alpes	2017	Vénosc (rattachée à 38253)
21318	21327	Val-Mont	2015	Ivry-en-Montagne (rattachée à 21327)
22167	22107	Bon Repos sur Blavet	2017	Perret (rattachée à 22107)
22290	22107	Bon Repos sur Blavet	2017	Saint-Gelven (rattachée à 22107)
29052	29003	Audierne	2015	Esquibien (rattachée à 29003)
29127	29266	Saint-Thegonnec Loc-Eguiner	2015	Loc-Eguiner-Saint-Thégonnec (rattachée à 29266)
16023	16023	Aunac-sur-Charente	2017	Aunac-sur-Charente
22151	22093	Lamballe	2015	Meslin (rattachée à 22093)
22007	22055	Binic - Etables-sur-Mer	2015	Binic (rattachée à 22055)
22357	22209	Beaussais-sur-Mer	2017	Trégon (rattachée à 22209)
22298	22158	Guerledan	2017	Saint-Guen (rattachée à 22158)
27265	27679	Verneuil d Avre et d Iton	2017	Francheville (rattachée à 27679)
56251	56251	Theix-Noyalo	2015	Theix-Noyalo
76476	76476	Port-Jérôme-sur-Seine	2015	Port-Jérôme-sur-Seine
76164	76164	Rives-en-Seine	2015	Rives-en-Seine
19282	19123	Malemort	2015	Venarsal (rattachée à 19123)
85052	85152	Les Achards	2017	La Chapelle-Achard (rattachée à 85152)
16046	16046	Coteaux du Blanzacais	2017	Coteaux du Blanzacais
76401	76401	Arelaune-en-Seine	2015	Arelaune-en-Seine
85044	85009	Auchay-sur-Vendee	2017	Chaix (rattachée à 85009)
85043	85213	Rives de l'Yon	2015	Chaillé-sous-les-Ormeaux (rattachée à 85213)
85069	85008	Aubigny-Les Clouzeaux	2015	Les Clouzeaux (rattachée à 85008)
85212	85084	Essarts en Bocage	2015	Sainte-Florence (rattachée à 85084)
85219	85154	Mouilleron-Saint-Germain	2015	Saint-Germain-l'Aiguiller (rattachée à 85154)
85257	85090	Sèvremont	2015	Saint-Michel-Mont-Mercure (rattachée à 85090)
85272	85197	Montréverd	2015	Saint-Sulpice-le-Verdon (rattachée à 85197)
85063	85090	Sèvremont	2015	Les Châtelliers-Châteaumur (rattachée à 85090)
85180	85090	Sèvremont	2015	La Pommeraie-sur-Sèvre (rattachée à 85090)
44008	44029	Divatte-sur-Loire	2015	Barbechat (rattachée à 44029)
44011	44213	Loireauxence	2015	Belligné (rattachée à 44213)
44040	44005	Chaumes-en-Retz	2015	Chéméré (rattachée à 44005)
44059	44021	Villeneuve-en-Retz	2015	Fresnay-en-Retz (rattachée à 44021)
44060	49160	Ingrandes-Le Fresne sur Loire	2015	Le Fresne-sur-Loire (rattachée à 49160)
71265	71204	Fragnes-La Loyère	2015	La Loyère (rattachée à 71204)
89070	89086	Charny Orée de Puisaye	2015	Chambeugle (rattachée à 89086)
89097	89086	Charny Orée de Puisaye	2015	Chêne-Arnoult (rattachée à 89086)
89103	89086	Charny Orée de Puisaye	2015	Chevillon (rattachée à 89086)
89107	89411	Les Vallées de la Vanne	2015	Chigy (rattachée à 89411)
39290	39290	Valzin en Petite Montagne	2017	Valzin en Petite Montagne
39186	39491	Coteaux du Lizon	2017	Cuttura (rattachée à 39491)
27637	27105	Grand Bourgtheroulde	2015	Thuit-Hébert (rattachée à 27105)
27639	27638	Le Thuit de l'Oison	2015	Le Thuit-Simer (rattachée à 27638)
22251	22251	Pordic	2015	Pordic
27283	27049	Mesnil-en-Ouche	2015	Gisay-la-Coudre (rattachée à 27049)
27262	27213	Vexin-sur-Epte	2015	Fourges (rattachée à 27213)
16204	16204	Bellevigne	2017	Bellevigne
16230	16230	Montmoreau	2017	Montmoreau
72384	72071	Vouvray-sur-Loir	2016	Vouvray-sur-Loir (rattachée à 72071)
23231	23192	Fursac	2017	Saint-Pierre-de-Fursac (rattachée à 23192)
53228	53228	Blandouet-Saint-Jean	2017	Blandouet-Saint-Jean
72063	72262	Loir en Vallee	2017	La Chapelle-Gaugain (rattachée à 72262)
72082	72308	Saint-Paterne - Le Chevain	2017	Le Chevain (rattachée à 72308)
72108	72025	Bazouges Cre sur Loir	2017	Cré (rattachée à 72025)
27484	27277	La Baronnie	2015	Quessigny (rattachée à 27277)
27634	27032	Chambois	2015	Thomer-la-Sôgne (rattachée à 27032)
27172	27032	Chambois	2015	Corneuil (rattachée à 27032)
72240	72262	Loir en Vallee	2017	Poncé-sur-le-Loir (rattachée à 72262)
72203	72071	Montabon	2016	Montabon (rattachée à 72071)
57523	57482	Ogy-Montoy-Flanville	2017	Ogy (rattachée à 57482)
72159	72262	Loir en Vallee	2017	Lavenay (rattachée à 72262)
72288	72363	Tuffé Val de la Chéronne	2015	Saint-Hilaire-le-Lierru (rattachée à 72363)
72301	72023	Ballon-Saint Mars	2015	Saint-Mars-sous-Ballon (rattachée à 72023)
39286	39286	Lavans-lès-Saint-Claude	2015	Lavans-lès-Saint-Claude
27532	27157	Marbois	2015	Saint-Denis-du-Béhélan (rattachée à 27157)
27573	27578	Sainte-Marie-d'Attez	2015	Saint-Nicolas-d'Attez (rattachée à 27578)
27159	27112	Breteuil	2015	Cintray (rattachée à 27112)
27107	27107	Bourneville-Sainte-Croix	2015	Bourneville-Sainte-Croix
29021	29021	Plouneour-Brignogan-plages	2017	Plouneour-Brignogan-plages
27150	27554	La Chapelle-Longueville	2017	La Chapelle-Réanville (rattachée à 27554)
16043	16148	Genac-Bignac	2015	Bignac (rattachée à 16148)
22093	22093	Lamballe	2015	Lamballe
69146	69024	Val d Oingt	2017	Oingt (rattachée à 69024)
69158	69066	Cours	2015	Pont-Trambouze (rattachée à 69066)
69237	69228	Chabaniere	2017	Saint-Sorlin (rattachée à 69228)
69195	69228	Chabaniere	2017	Saint-Didier-sous-Riverie (rattachée à 69228)
41015	41171	Oucques La Nouvelle	2017	Beauvilliers (rattachée à 41171)
27112	27112	Breteuil	2015	Breteuil
77316	77316	Moret-Loing-et-Orvanne	2017	Moret-Loing-et-Orvanne
77316	77316	Moret Loing et Orvanne	2015	Moret-Loing-et-Orvanne
10003	10003	Aix-Villemaur-Pâlis	2015	Aix-Villemaur-Pâlis
61315	61474	Gouffern en Auge	2017	Omméel (rattachée à 61474)
38456	38456	Chatel-en-Trieves	2017	Chatel-en-Trieves
61135	61096	Rives d'Andaine	2015	Couterne (rattachée à 61096)
61136	61167	La Ferté-en-Ouche	2015	Couvains (rattachée à 61167)
61155	61324	Passais Villages	2015	L'Épinay-le-Comte (rattachée à 61324)
61179	61339	Putanges-le-Lac	2015	La Fresnaye-au-Sauvage (rattachée à 61339)
61282	61167	La Ferté-en-Ouche	2015	Monnai (rattachée à 61167)
61306	61081	Chailloué	2015	Neuville-près-Sées (rattachée à 61081)
61313	61007	Athis-Val de Rouvre	2015	Notre-Dame-du-Rocher (rattachée à 61007)
22107	22107	Bon Repos sur Blavet	2017	Bon Repos sur Blavet
25576	25575	Vaire-le-Petit	2016	Vaire-le-Petit (rattachée à 25575)
33495	33018	Val de Virvée	2015	Salignac (rattachée à 33018)
62431	62471	Herbelles	2016	Herbelles (rattachée à 62471)
27565	27565	Le Lesme	2015	Le Lesme
62807	62757	Saint-Martin-lez-Tatinghem	2015	Tatinghem (rattachée à 62757)
33268	33268	Margaux-Cantenac	2017	Margaux-Cantenac
52411	52411	Rives Dervoises	2015	Rives Dervoises
88018	88218	Granges-Aumontzey	2015	Aumontzey (rattachée à 88218)
88337	88465	Capavenir Vosges	2015	Oncourt (rattachée à 88465)
88204	88465	Capavenir Vosges	2015	Girmont (rattachée à 88465)
88112	88361	Provenchères-et-Colroy	2015	Colroy-la-Grande (rattachée à 88361)
37227	37232	Coteaux-sur-Loire	2017	Saint-Michel-sur-Loire (rattachée à 37232)
36202	36202	Saint-Maur	2015	Saint-Maur
60453	60196	La Drenne	2017	La Neuville-d'Aumont (rattachée à 60196)
60532	60196	La Drenne	2017	Ressons-l'Abbaye (rattachée à 60196)
60649	60029	Auneuil	2017	Troussures (rattachée à 60029)
60018	60088	Bornel	2015	Anserville (rattachée à 60088)
12218	12076	Conques-en-Rouergue	2015	Saint-Cyprien-sur-Dourdou (rattachée à 12076)
12112	12223	Argences en Aubrac	2015	Graissac (rattachée à 12223)
12117	12223	Argences en Aubrac	2015	Lacalm (rattachée à 12223)
61205	61167	La Ferté-en-Ouche	2015	Heugon (rattachée à 61167)
61226	61491	Tourouvre au Perche	2015	Lignerolles (rattachée à 61491)
41064	41055	Valloire-sur-Cisse	2017	Coulanges (rattachée à 41055)
61477	61474	Gouffern en Auge	2017	Survie (rattachée à 61474)
61175	61341	Écouves	2015	Forges (rattachée à 61341)
61174	61339	Putanges-le-Lac	2015	La Forêt-Auvray (rattachée à 61339)
61115	61116	Sablons sur Huisne	2015	Condeau (rattachée à 61116)
61434	61167	La Ferté-en-Ouche	2015	Saint-Nicolas-des-Laitiers (rattachée à 61167)
61154	61196	Belforet-en-Perche	2017	Eperrais (rattachée à 61196)
61157	61474	Gouffern en Auge	2017	Exmes (rattachée à 61474)
61471	61196	Belforet-en-Perche	2017	Sérigny (rattachée à 61196)
61184	61167	La Ferté-en-Ouche	2015	Gauville (rattachée à 61167)
61185	61484	Val-au-Perche	2015	Gémages (rattachée à 61484)
61186	61096	Rives d'Andaine	2015	Geneslay (rattachée à 61096)
61191	61167	La Ferté-en-Ouche	2015	Glos-la-Ferrière (rattachée à 61167)
61200	61096	Rives d'Andaine	2015	Haleine (rattachée à 61096)
61236	61153	Écouché-les-Vallées	2015	Loucé (rattachée à 61153)
14475	14475	Val d Arry	2017	Val d Arry
61239	61211	Juvigny Val d'Andaine	2015	Lucé (rattachée à 61211)
61245	61050	Cour-Maugis sur Huisne	2015	Maison-Maugis (rattachée à 61050)
61246	61484	Val-au-Perche	2015	Mâle (rattachée à 61484)
61250	61230	Longny les Villages	2015	Marchainville (rattachée à 61230)
61253	61081	Chailloué	2015	Marmouillé (rattachée à 61081)
61270	61339	Putanges-le-Lac	2015	Ménil-Jean (rattachée à 61339)
61280	61230	Longny les Villages	2015	Monceaux-au-Perche (rattachée à 61230)
61318	61196	Belforet-en-Perche	2017	Origny-le-Butin (rattachée à 61196)
61325	61196	Belforet-en-Perche	2017	La Perrière (rattachée à 61196)
61296	61230	Longny les Villages	2015	Moulicent (rattachée à 61230)
41210	41171	Oucques La Nouvelle	2017	Sainte-Gemmes (rattachée à 41171)
41240	41055	Valloire-sur-Cisse	2017	Seillac (rattachée à 41055)
61201	61145	Domfront en Poiraie	2015	La Haute-Chapelle (rattachée à 61145)
61204	61484	Val-au-Perche	2015	L'Hermitière (rattachée à 61484)
61235	61211	Juvigny Val d'Andaine	2015	Loré (rattachée à 61211)
61449	61474	Gouffern en Auge	2017	Saint-Pierre-la-Rivière (rattachée à 61474)
61047	61167	La Ferté-en-Ouche	2015	Bocquencé (rattachée à 61167)
61058	61007	Athis-Val de Rouvre	2015	Bréel (rattachée à 61007)
61059	61491	Tourouvre au Perche	2015	Bresolettes (rattachée à 61491)
61073	61007	Athis-Val de Rouvre	2015	La Carneille (rattachée à 61007)
61106	61339	Putanges-le-Lac	2015	Chênedouit (rattachée à 61339)
61112	61309	Perche en Nocé	2015	Colonard-Corubert (rattachée à 61309)
61127	61153	Écouché-les-Vallées	2015	La Courbe (rattachée à 61153)
61045	61491	Tourouvre au Perche	2015	Bivilliers (rattachée à 61491)
61364	61339	Putanges-le-Lac	2015	Saint-Aubert-sur-Orne (rattachée à 61339)
61368	61309	Perche en Nocé	2015	Saint-Aubin-des-Grois (rattachée à 61309)
61378	61339	Putanges-le-Lac	2015	Sainte-Croix-sur-Orne (rattachée à 61339)
61380	61211	Juvigny Val d'Andaine	2015	Saint-Denis-de-Villenette (rattachée à 61211)
61504	61474	Gouffern en Auge	2017	Villebadin (rattachée à 61474)
61506	61167	La Ferté-en-Ouche	2015	Villers-en-Ouche (rattachée à 61167)
61509	61341	Écouves	2015	Vingt-Hanaps (rattachée à 61341)
61083	61474	Gouffern en Auge	2017	Chambois (rattachée à 61474)
61019	61474	Gouffern en Auge	2017	Avernes-sous-Exmes (rattachée à 61474)
61131	61474	Gouffern en Auge	2017	Courménil (rattachée à 61474)
38292	38292	Villages du Lac de Paladru	2017	Villages du Lac de Paladru
61161	61474	Gouffern en Auge	2017	Fel (rattachée à 61474)
61437	61196	Belforet-en-Perche	2017	Saint-Ouen-de-la-Cour (rattachée à 61196)
61320	61460	Sap-en-Auge	2015	Orville (rattachée à 61460)
61335	61491	Tourouvre au Perche	2015	La Poterie-au-Perche (rattachée à 61491)
61340	61339	Putanges-le-Lac	2015	Rabodanges (rattachée à 61339)
61343	61491	Tourouvre au Perche	2015	Randonnai (rattachée à 61491)
61353	61007	Athis-Val de Rouvre	2015	Ronfeugerai (rattachée à 61007)
61354	61339	Putanges-le-Lac	2015	Les Rotours (rattachée à 61339)
61355	61145	Domfront en Poiraie	2015	Rouellé (rattachée à 61145)
61356	61484	Val-au-Perche	2015	La Rouge (rattachée à 61484)
61359	61484	Val-au-Perche	2015	Saint-Agnan-sur-Erre (rattachée à 61484)
61428	61463	Les Monts d'Andaine	2015	Saint-Maurice-du-Désert (rattachée à 61463)
61431	61483	Bagnoles de l'Orne Normandie	2015	Saint-Michel-des-Andaines (rattachée à 61483)
61441	61153	Écouché-les-Vallées	2015	Saint-Ouen-sur-Maire (rattachée à 61153)
61455	61324	Passais Villages	2015	Saint-Siméon (rattachée à 61324)
61458	61230	Longny les Villages	2015	Saint-Victor-de-Réno (rattachée à 61230)
61465	61007	Athis-Val de Rouvre	2015	Ségrie-Fontaine (rattachée à 61007)
61469	61211	Juvigny Val d'Andaine	2015	Sept-Forges (rattachée à 61211)
61470	61153	Écouché-les-Vallées	2015	Serans (rattachée à 61153)
61478	61007	Athis-Val de Rouvre	2015	Taillebois (rattachée à 61007)
61489	61007	Athis-Val de Rouvre	2015	Les Tourailles (rattachée à 61007)
61003	61167	La Ferté-en-Ouche	2015	Anceins (rattachée à 61167)
61016	61491	Tourouvre au Perche	2015	Autheuil (rattachée à 61491)
61025	61211	Juvigny Val d'Andaine	2015	La Baroche-sous-Lucé (rattachée à 61211)
61033	61211	Juvigny Val d'Andaine	2015	Beaulandais (rattachée à 61211)
61042	61345	Rémalard en Perche	2015	Bellou-sur-Huisne (rattachée à 61345)
61145	61145	Domfront en Poiraie	2015	Domfront en Poiraie
73144	73290	Val-Cenis	2017	Lanslevillard (rattachée à 73290)
24430	24064	Brantôme en Périgord	2015	Saint-Julien-de-Bourdeilles (rattachée à 24064)
24435	24362	Sainte-Alvère-Saint-Laurent Les Bâtons	2015	Saint-Laurent-des-Bâtons (rattachée à 24362)
24497	24028	Beaumontois en Périgord	2015	Sainte-Sabine-Born (rattachée à 24028)
62757	62757	Saint-Martin-lez-Tatinghem	2015	Saint-Martin-lez-Tatinghem
53255	53255	Sainte-Suzanne-et-Chammes	2015	Sainte-Suzanne-et-Chammes
53137	53137	Loiron-Ruillé	2015	Loiron-Ruillé
17040	17277	Essouvert	2015	La Benâte (rattachée à 17277)
89454	89086	Charny Orée de Puisaye	2015	Villefranche (rattachée à 89086)
27303	27565	Le Lesme	2015	Guernanville (rattachée à 27565)
16262	16286	Rouillac	2015	Plaizac (rattachée à 16286)
16201	16175	Val des Vignes	2015	Mainfonds (rattachée à 16175)
26366	26179	Mercurol-Veaunes	2015	Veaunes (rattachée à 26179)
69247	69066	Cours	2015	Thel (rattachée à 69066)
16021	16175	Val des Vignes	2015	Aubeville (rattachée à 16175)
38014	38297	Arandon-Passins	2017	Arandon (rattachée à 38297)
38359	38359	Saint Antoine l'Abbaye	2015	Saint Antoine l'Abbaye
38407	38407	La Sure en Chartreuse	2017	La Sure en Chartreuse
22292	22046	Le Mené	2015	Saint-Gilles-du-Mené (rattachée à 22046)
22297	22046	Le Mené	2015	Saint-Gouéno (rattachée à 22046)
25585	25424	Les Premiers Sapins	2015	Vanclans (rattachée à 25424)
51564	51564	Val de Livre	2015	Val de Livre
27089	27089	Thenouville	2017	Thenouville
61196	61196	Belforet-en-Perche	2017	Belforet-en-Perche
61474	61474	Gouffern en Auge	2017	Gouffern en Auge
03153	03158	Haut-Bocage	2015	Louroux-Hodement (rattachée à 03158)
24118	24316	Parcoul-Chenaud	2015	Chenaud (rattachée à 24316)
24298	24142	Coux et Bigaroque-Mouzens	2015	Mouzens (rattachée à 24142)
24310	24028	Beaumontois en Périgord	2015	Nojals-et-Clotte (rattachée à 24028)
24447	24053	Boulazac Isle Manoire	2017	Sainte-Marie-de-Chignac (rattachée à 24053)
03123	03158	Haut-Bocage	2015	Givarlais (rattachée à 03158)
27032	27032	Chambois	2015	Chambois
17238	17295	Réaux sur Trèfle	2015	Moings (rattachée à 17295)
17371	17295	Réaux sur Trèfle	2015	Saint-Maurice-de-Tavernole (rattachée à 17295)
14281	14281	Formigny La Bataille	2017	Formigny La Bataille
58100	58026	Beaulieu	2015	Dompierre-sur-Héry (rattachée à 58026)
58167	58026	Beaulieu	2015	Michaugues (rattachée à 58026)
58022	58204	Vaux d Amognes	2017	Balleray (rattachée à 58204)
33018	33018	Val de Virvée	2015	Val de Virvée
63266	63255	Nonette-Orsonnette	2015	Orsonnette (rattachée à 63255)
89330	89441	Vermenton	2015	Sacy (rattachée à 89441)
89001	89130	Deux Rivieres	2017	Accolay (rattachée à 89130)
89078	89003	Montholon	2017	Champvallon (rattachée à 89003)
89473	89003	Montholon	2017	Villiers-sur-Tholon (rattachée à 89003)
24041	24087	Castels et Bezenac	2017	Bézenac (rattachée à 24087)
24093	24554	La Tour-Blanche-Cercles	2017	Cercles (rattachée à 24554)
24343	24376	Saint Aulaye-Puymangou	2015	Puymangou (rattachée à 24376)
24363	24035	Pays de Belvès	2015	Saint-Amand-de-Belvès (rattachée à 24035)
45057	45191	Le Malesherbois	2015	Labrosse (rattachée à 45191)
45106	45191	Le Malesherbois	2015	Coudray (rattachée à 45191)
24047	24147	Cubjac-Auvezere-Val d Ans	2017	La Boissière-d'Ans (rattachée à 24147)
24065	24312	Sanilhac	2017	Breuilh (rattachée à 24312)
24235	24253	Mareuil en Perigord	2017	Léguillac-de-Cercles (rattachée à 24253)
24239	24540	Sorges et Ligueux en Périgord	2015	Ligueux (rattachée à 24540)
45190	45191	Le Malesherbois	2015	Mainvilliers (rattachée à 45191)
24013	24053	Boulazac Isle Manoire	2015	Atur (rattachée à 24053)
24033	24253	Mareuil en Perigord	2017	Beaussac (rattachée à 24253)
24092	24362	Val de Louyre et Caudeau	2017	Cendrieux (rattachée à 24362)
24103	24026	Bassillac et Auberoche	2017	Le Change (rattachée à 24026)
24166	24026	Bassillac et Auberoche	2017	Eyliac (rattachée à 24026)
24178	24490	Saint Privat en Perigord	2017	Festalemps (rattachée à 24490)
24203	24253	Mareuil en Perigord	2017	Les Graulges (rattachée à 24253)
24204	24117	Les Coteaux Perigourdins	2017	Grèzes (rattachée à 24117)
45192	45191	Le Malesherbois	2015	Manchecourt (rattachée à 45191)
24219	24028	Beaumontois en Périgord	2015	Labouquerie (rattachée à 24028)
24258	24312	Sanilhac	2017	Marsaneix (rattachée à 24312)
24270	24026	Bassillac et Auberoche	2017	Milhac-d'Auberoche (rattachée à 24026)
24283	24253	Mareuil en Perigord	2017	Monsec (rattachée à 24253)
24333	24216	La Jemaye-Ponteyraud	2017	Ponteyraud (rattachée à 24216)
24439	24053	Boulazac Isle Manoire	2015	Saint-Laurent-sur-Manoire (rattachée à 24053)
24503	24253	Mareuil en Perigord	2017	Saint-Sulpice-de-Mareuil (rattachée à 24253)
24579	24253	Mareuil en Perigord	2017	Vieux-Mareuil (rattachée à 24253)
45211	45129	Douchy-Montcorbon	2015	Montcorbon (rattachée à 45129)
45221	45191	Le Malesherbois	2015	Nangeville (rattachée à 45191)
45236	45191	Le Malesherbois	2015	Orveau-Bellesauve (rattachée à 45191)
24344	24253	Mareuil en Perigord	2017	Puyrenier (rattachée à 24253)
24368	24490	Saint Privat en Perigord	2017	Saint-Antoine-Cumond (rattachée à 24490)
24369	24026	Bassillac et Auberoche	2017	Saint-Antoine-d'Auberoche (rattachée à 24026)
24475	24147	Cubjac-Auvezere-Val d Ans	2017	Saint-Pantaly-d'Ans (rattachée à 24147)
40048	40243	Rion-des-Landes	2017	Boos (rattachée à 40243)
25399	25460	Le Val	2017	Montfort (rattachée à 25460)
63018	63160	Aulhat-Flat	2015	Aulhat-Saint-Privat (rattachée à 63160)
63068	63244	Chambaron-sur-Morge	2015	Cellule (rattachée à 63244)
73227	73227	Courchevel	2017	Courchevel
73284	73284	Salins-Fontaine	2015	Salins-Fontaine
86146	86115	Jaunay-Marigny	2017	Marigny-Brizay (rattachée à 86115)
41133	41173	Beauce la Romaine	2015	Membrolles (rattachée à 41173)
41056	41173	Beauce la Romaine	2015	La Colombe (rattachée à 41173)
41023	41151	Montrichard Val de Cher	2015	Bourré (rattachée à 41151)
39378	39378	Les Trois Châteaux	2015	Les Trois Châteaux
35048	35168	Val d Anast	2017	Campel (rattachée à 35168)
15141	15141	Neussargues en Pinatelle	2016	Neussargues en Pinatelle
24117	24117	Les Coteaux Perigourdins	2017	Les Coteaux Perigourdins
33091	33268	Margaux-Cantenac	2017	Cantenac (rattachée à 33268)
25438	25438	Osselle-Routelle	2015	Osselle-Routelle
61116	61116	Sablons sur Huisne	2015	Sablons sur Huisne
61007	61007	Athis-Val de Rouvre	2015	Athis-Val de Rouvre
61167	61167	La Ferté-en-Ouche	2015	La Ferté-en-Ouche
61081	61081	Chailloué	2015	Chailloué
61324	61324	Passais Villages	2015	Passais Villages
61339	61339	Putanges-le-Lac	2015	Putanges-le-Lac
61491	61491	Tourouvre au Perche	2015	Tourouvre au Perche
35323	35191	Les Portes du Coglais	2017	La Selle-en-Coglès (rattachée à 35191)
35267	35257	Maen Roch	2017	Saint-Étienne-en-Coglès (rattachée à 35257)
61153	61153	Écouché-les-Vallées	2015	Écouché-les-Vallées
61230	61230	Longny les Villages	2015	Longny les Villages
35083	35191	Les Portes du Coglais	2017	Coglès (rattachée à 35191)
14658	14658	Noues de Sienne	2017	Noues de Sienne
46071	46311	Sousceyrac-en-Quercy	2015	Comiac (rattachée à 46311)
46325	46138	Cur de Causse	2015	Vaillac (rattachée à 46138)
39064	39576	Val-Sonnette	2017	Bonnaud (rattachée à 39576)
86115	86115	Jaunay-Marigny	2017	Jaunay-Marigny
39331	39331	Mignovillard	2015	Mignovillard
39368	39368	Hauts de Bienne	2015	Hauts de Bienne
39209	39209	Val d'Epy	2015	Val d'Epy
39510	39510	Septmoncel les Molunes	2017	Septmoncel les Molunes
71375	71279	Le Rousset-Marizy	2015	Le Rousset (rattachée à 71279)
39530	39530	Thoirette-Coisia	2017	Thoirette-Coisia
08009	08311	Mouzon	2015	Amblimont (rattachée à 08311)
25593	25147	Chemaudin et Vaux	2017	Vaux-les-Prés (rattachée à 25147)
27213	27213	Vexin-sur-Epte	2015	Vexin-sur-Epte
27022	27022	Le Val d'Hazey	2015	Le Val d'Hazey
27198	27198	Mesnils-sur-Iton	2015	Mesnils-sur-Iton
39537	39537	Trenal	2017	Trenal
39177	39177	Hauteroche	2015	Hauteroche
64020	64225	Ance Feas	2017	Ance (rattachée à 64225)
73158	73010	Entrelacs	2015	Mognard (rattachée à 73010)
73169	73006	Aime-la-Plagne	2015	Montgirod (rattachée à 73006)
73239	73010	Entrelacs	2015	Saint-Girod (rattachée à 73010)
73238	73010	Entrelacs	2015	Saint-Germain-la-Chambotte (rattachée à 73010)
73056	73290	Val-Cenis	2017	Bramans (rattachée à 73290)
61096	61096	Rives d'Andaine	2015	Rives d'Andaine
81026	81026	Bellegarde-Marsal	2015	Bellegarde-Marsal
81062	81062	Fontrieu	2015	Fontrieu
25076	25434	Ornans	2015	Bonnevaux-le-Prieuré (rattachée à 25434)
25028	25424	Les Premiers Sapins	2015	Athose (rattachée à 25424)
81218	81218	Puygouzon	2017	Puygouzon
08115	08115	Chémery-Chéhéry	2015	Chémery-Chéhéry
01176	01187	Haut Valromey	2015	Le Grand-Abergement (rattachée à 01187)
01271	01286	Parves et Nattages	2015	Nattages (rattachée à 01286)
01300	01204	Le Poizat-Lalleyriat	2015	Le Poizat (rattachée à 01204)
01340	01015	Arboys en Bugey	2015	Saint-Bois (rattachée à 01015)
16224	16224	Montmérac	2015	Montmérac
16286	16286	Rouillac	2015	Rouillac
01095	01095	Nivigne et Suran	2017	Nivigne et Suran
01098	01098	Chazey-Bons	2017	Chazey-Bons
01015	01015	Arboys en Bugey	2015	Arboys en Bugey
01119	01080	Champdor-Corcelles	2015	Corcelles (rattachée à 01080)
01292	01187	Haut Valromey	2015	Le Petit-Abergement (rattachée à 01187)
01312	01426	Val-Revermont	2015	Pressiat (rattachée à 01426)
01409	01187	Haut Valromey	2015	Songieu (rattachée à 01187)
01182	01338	Groslée-Saint-Benoit	2015	Groslée (rattachée à 01338)
35060	35060	La Chapelle-du-Lou-du-Lac	2015	La Chapelle-du-Lou-du-Lac
35158	35060	La Chapelle-du-Lou-du-Lac	2015	Le Lou-du-Lac (rattachée à 35060)
35129	35176	Guipry-Messac	2015	Guipry (rattachée à 35176)
35254	35069	Chateaugiron	2017	Saint-Aubin-du-Pavail (rattachée à 35069)
16092	16082	Boisné-La Tude	2015	Chavenat (rattachée à 16082)
16175	16175	Val des Vignes	2015	Val des Vignes
16417	16204	Bellevigne	2017	Viville (rattachée à 16204)
24099	24253	Mareuil en Perigord	2017	Champeaux-et-la-Chapelle-Pommier (rattachée à 24253)
86030	86281	Saint Martin la Pallu	2017	Blaslay (rattachée à 86281)
86060	86281	Saint Martin la Pallu	2017	Charrais (rattachée à 86281)
86019	86019	Beaumont Saint-Cyr	2017	Beaumont Saint-Cyr
73006	73006	Aime-la-Plagne	2015	Aime-la-Plagne
73150	73150	La Plagne Tarentaise	2015	La Plagne Tarentaise
86245	86245	Senillé-Saint-Sauveur	2015	Senillé-Saint-Sauveur
86208	86053	Champigny en Rochereau	2017	Le Rochereau (rattachée à 86053)
86219	86019	Beaumont Saint-Cyr	2017	Saint-Cyr (rattachée à 86019)
86281	86281	Saint Martin la Pallu	2017	Saint Martin la Pallu
73093	73150	La Plagne Tarentaise	2015	La Côte-d'Aime (rattachée à 73150)
73305	73150	La Plagne Tarentaise	2015	Valezan (rattachée à 73150)
73321	73257	Les Belleville	2015	Villarlurin (rattachée à 73257)
73115	73284	Salins-Fontaine	2015	Fontaine-le-Puits (rattachée à 73284)
73126	73006	Aime-la-Plagne	2015	Granier (rattachée à 73006)
73235	73235	Saint Francois Longchamp	2017	Saint Francois Longchamp
24026	24026	Bassillac et Auberoche	2017	Bassillac et Auberoche
24028	24028	Beaumontois en Périgord	2015	Beaumontois en Périgord
24035	24035	Pays de Belvès	2015	Pays de Belvès
24053	24053	Boulazac Isle Manoire	2017	Boulazac Isle Manoire
24053	24053	Boulazac Isle Manoire	2015	Boulazac Isle Manoire
24064	24064	Brantôme en Périgord	2015	Brantôme en Périgord
24087	24087	Castels et Bezenac	2017	Castels et Bezenac
24142	24142	Coux et Bigaroque-Mouzens	2015	Coux et Bigaroque-Mouzens
24147	24147	Cubjac-Auvezere-Val d Ans	2017	Cubjac-Auvezere-Val d Ans
24216	24216	La Jemaye-Ponteyraud	2017	La Jemaye-Ponteyraud
28422	28422	Les Villages Vovéens	2015	Les Villages Vovéens
72023	72023	Ballon-Saint Mars	2015	Ballon-Saint Mars
02344	51171	Cormicy	2017	Gernicourt (rattachée à 51171)
73038	73150	La Plagne Tarentaise	2015	Bellentre (rattachée à 73150)
73062	73010	Entrelacs	2015	Cessens (rattachée à 73010)
73143	73290	Val-Cenis	2017	Lanslebourg-Mont-Cenis (rattachée à 73290)
73163	73235	Saint Francois Longchamp	2017	Montaimont (rattachée à 73235)
73167	73235	Saint Francois Longchamp	2017	Montgellafrey (rattachée à 73235)
86071	86281	Saint Martin la Pallu	2017	Cheneché (rattachée à 86281)
72262	72262	Loir en Vallee	2017	Loir en Vallee
72308	72308	Saint-Paterne - Le Chevain	2017	Saint-Paterne - Le Chevain
72363	72363	Tuffé Val de la Chéronne	2015	Tuffé Val de la Chéronne
46268	46268	Saint Gery - Vers	2017	Saint Gery - Vers
24253	24253	Mareuil en Perigord	2017	Mareuil en Perigord
24312	24312	Sanilhac	2017	Sanilhac
24316	24316	Parcoul-Chenaud	2015	Parcoul-Chenaud
38253	38253	Les Deux Alpes	2017	Les Deux Alpes
38439	38439	Crêts en Belledonne	2015	Crêts en Belledonne
24490	24490	Saint Privat en Perigord	2017	Saint Privat en Perigord
35209	35069	Chateaugiron	2017	Ossé (rattachée à 35069)
24540	24540	Sorges et Ligueux en Périgord	2015	Sorges et Ligueux en Périgord
24554	24554	La Tour-Blanche-Cercles	2017	La Tour-Blanche-Cercles
16082	16082	Boisné-La Tude	2015	Boisné-La Tude
16094	16023	Aunac-sur-Charente	2017	Chenommet (rattachée à 16023)
16172	16082	Boisné-La Tude	2015	Juillaguet (rattachée à 16082)
16179	16224	Montmérac	2015	Lamérac (rattachée à 16224)
16257	16175	Val des Vignes	2015	Péreuil (rattachée à 16175)
16106	16106	Confolens	2015	Confolens
16004	16230	Montmoreau	2017	Aignes-et-Puypéroux (rattachée à 16230)
16033	16023	Aunac-sur-Charente	2017	Bayers (rattachée à 16023)
08072	08491	Vrigne aux Bois	2017	Bosseval-et-Briancourt (rattachée à 08491)
01426	01426	Val-Revermont	2015	Val-Revermont
28406	28406	Eole-en-Beauce	2015	Eole-en-Beauce
28383	28383	Theuville	2015	Theuville
28330	28330	Villemaury	2017	Villemaury
28254	28254	Mittainvilliers-Vérigny	2015	Mittainvilliers-Vérigny
28183	28183	Gommerville	2015	Gommerville
37123	37123	Langeais	2017	Langeais
28015	28015	Auneau-Bleury-Saint-Symphorien	2015	Auneau-Bleury-Saint-Symphorien
45129	45129	Douchy-Montcorbon	2015	Douchy-Montcorbon
45051	45051	Bray-Saint Aignan	2017	Bray-Saint Aignan
87097	87097	Val d'Issoire	2015	Val d'Issoire
42039	42039	Chalmazel-Jeansagnière	2015	Chalmazel-Jeansagnière
46150	46311	Sousceyrac-en-Quercy	2015	Lamativie (rattachée à 46311)
69228	69228	Chabaniere	2017	Chabaniere
63255	63255	Nonette-Orsonnette	2015	Nonette-Orsonnette
41173	41173	Beauce la Romaine	2015	Beauce la Romaine
41171	41171	Oucques La Nouvelle	2017	Oucques La Nouvelle
41167	41167	Veuzain-sur-Loire	2017	Veuzain-sur-Loire
41151	41151	Montrichard Val de Cher	2015	Montrichard Val de Cher
41142	41142	Valencisse	2017	Valencisse
41142	41142	Valencisse	2015	Valencisse
08311	08311	Mouzon	2015	Mouzon
61211	61211	Juvigny Val d'Andaine	2015	Juvigny Val d'Andaine
85213	85213	Rives de l'Yon	2015	Rives de l'Yon
85197	85197	Montréverd	2015	Montréverd
85154	85154	Mouilleron-Saint-Germain	2015	Mouilleron-Saint-Germain
85152	85152	Les Achards	2017	Les Achards
85090	85090	Sèvremont	2015	Sèvremont
85084	85084	Essarts en Bocage	2015	Essarts en Bocage
85080	85080	Doix lès Fontaines	2015	Doix lès Fontaines
85019	85019	Bellevigny	2015	Bellevigny
85009	85009	Auchay-sur-Vendee	2017	Auchay-sur-Vendee
41055	41055	Valloire-sur-Cisse	2017	Valloire-sur-Cisse
37232	37232	Coteaux-sur-Loire	2017	Coteaux-sur-Loire
05101	05101	Vallouise-Pelvoux	2017	Vallouise-Pelvoux
41183	41173	Beauce la Romaine	2015	Prénouvellon (rattachée à 41173)
41244	41173	Beauce la Romaine	2015	Semerville (rattachée à 41173)
41264	41173	Beauce la Romaine	2015	Tripleville (rattachée à 41173)
50209	50209	Gonneville-Le Theil	2015	Gonneville-Le Theil
88361	88361	Provenchères-et-Colroy	2015	Provenchères-et-Colroy
16148	16148	Genac-Bignac	2015	Genac-Bignac
58026	58026	Beaulieu	2015	Beaulieu
16247	16204	Bellevigne	2017	Nonaville (rattachée à 16204)
16294	16230	Montmoreau	2017	Saint-Amant (rattachée à 16230)
16314	16230	Montmoreau	2017	Saint-Eutrope (rattachée à 16230)
16328	16230	Montmoreau	2017	Saint-Laurent-de-Belzagot (rattachée à 16230)
16386	16204	Bellevigne	2017	Touzac (rattachée à 16204)
74120	74282	Filliere	2017	Évires (rattachée à 74282)
27302	27302	Le Bosc du Theil	2015	Le Bosc du Theil
27647	27676	Les Trois Lacs	2017	Tosny (rattachée à 27676)
27648	27412	Terres de Bord	2017	Tostes (rattachée à 27412)
60196	60196	La Drenne	2017	La Drenne
58204	58204	Vaux d Amognes	2017	Vaux d Amognes
70418	70418	La Romaine	2015	La Romaine
02458	02458	Dhuys et Morin-en-Brie	2015	Dhuys et Morin-en-Brie
02479	02439	Les Septvallons	2015	Merval (rattachée à 02439)
48009	48009	Peyre en Aubrac	2017	Peyre en Aubrac
48017	48017	Banassac-Canilhac	2015	Banassac-Canilhac
48050	48050	Bedoues-Cocures	2015	Bedoues-Cocures
48061	48061	Florac Trois Rivières	2015	Florac Trois Rivières
25424	25424	Les Premiers Sapins	2015	Les Premiers Sapins
17295	17295	Réaux sur Trèfle	2015	Réaux sur Trèfle
02811	02439	Les Septvallons	2015	Villers-en-Prayères (rattachée à 02439)
26179	26179	Mercurol-Veaunes	2015	Mercurol-Veaunes
01316	01098	Chazey-Bons	2017	Pugieu (rattachée à 01098)
63244	63244	Chambaron-sur-Morge	2015	Chambaron-sur-Morge
74275	74275	Talloires-Montmin	2015	Talloires-Montmin
01172	01095	Nivigne et Suran	2017	Germagnat (rattachée à 01095)
24044	24026	Bassillac et Auberoche	2017	Blis-et-Born (rattachée à 24026)
48087	48087	Prinsuejols-Malbouzon	2017	Prinsuejols-Malbouzon
48094	48094	Massegros Causses Gorges	2017	Massegros Causses Gorges
48105	48105	Naussac-Fontanes	2015	Naussac-Fontanes
48116	48116	Pont de Montvert - Sud Mont Lozère	2015	Pont de Montvert - Sud Mont Lozère
48139	48139	Saint Bonnet-Laval	2017	Saint Bonnet-Laval
48146	48146	Gorges du Tarn Causses	2017	Gorges du Tarn Causses
46141	46311	Sousceyrac-en-Quercy	2015	Lacam-d'Ourcet (rattachée à 46311)
22209	22209	Beaussais-sur-Mer	2017	Beaussais-sur-Mer
22203	22203	Ploeuc-L'Hermitage	2015	Ploeuc-L'Hermitage
76276	76276	Forges-les-Eaux	2015	Forges-les-Eaux
73010	73010	Entrelacs	2015	Entrelacs
48152	48152	Ventalon en Cévennes	2015	Ventalon en Cévennes
48166	48166	Cans et Cévennes	2015	Cans et Cévennes
01286	01286	Parves et Nattages	2015	Parves et Nattages
39303	39485	Val Suran	2017	Louvenne (rattachée à 39485)
22183	22183	Les Moulins	2015	Les Moulins
22158	22158	Guerledan	2017	Guerledan
24376	24376	Saint Aulaye-Puymangou	2015	Saint Aulaye-Puymangou
22084	22084	Jugon-les-Lacs - Commune nouvelle	2015	Jugon-les-Lacs - Commune nouvelle
69159	69159	Porte des Pierres Dorees	2017	Porte des Pierres Dorees
69024	69024	Val d Oingt	2017	Val d Oingt
14292	14740	La Vespière-Friardel	2015	Friardel (rattachée à 14740)
14074	14005	Valambray	2017	Billy (rattachée à 14005)
14073	14579	Seulline	2017	La Bigne (rattachée à 14579)
14099	14654	Saint-Pierre-en-Auge	2017	Bretteville-sur-Dives (rattachée à 14654)
14128	14027	Les Monts d Aunay	2017	Campandré-Valcongrain (rattachée à 14027)
14189	14431	Mezidon Vallee d Auge	2017	Coupesarte (rattachée à 14431)
14157	14098	Thue et Mue	2017	Cheux (rattachée à 14098)
14109	14098	Thue et Mue	2017	Brouay (rattachée à 14098)
14142	14342	Isigny-sur-Mer	2017	Castilly (rattachée à 14342)
14176	14005	Valambray	2017	Conteville (rattachée à 14005)
14158	14456	Moult-Chicheboville	2017	Chicheboville (rattachée à 14456)
14151	14658	Noues de Sienne	2017	Champ-du-Boult (rattachée à 14658)
14186	14406	Moulins en Bessin	2017	Coulombs (rattachée à 14406)
14636	14061	Souleuvre en Bocage	2015	Saint-Ouen-des-Besaces (rattachée à 14061)
14268	14005	Valambray	2017	Fierville-Bray (rattachée à 14005)
14208	14431	Mezidon Vallee d Auge	2017	Croissanville (rattachée à 14431)
14212	14406	Moulins en Bessin	2017	Cully (rattachée à 14406)
14279	14658	Noues de Sienne	2017	Fontenermont (rattachée à 14658)
14386	14431	Mezidon Vallee d Auge	2017	Magny-la-Campagne (rattachée à 14431)
14296	14658	Noues de Sienne	2017	Le Gast (rattachée à 14658)
14373	14475	Val d Arry	2017	Le Locheur (rattachée à 14475)
14376	14011	Aurseulles	2017	Longraye (rattachée à 14011)
14382	14281	Formigny La Bataille	2017	Louvières (rattachée à 14281)
14423	14098	Thue et Mue	2017	Le Mesnil-Patry (rattachée à 14098)
14462	14342	Isigny-sur-Mer	2017	Neuilly-la-Forêt (rattachée à 14342)
49331	49331	Segré-en-Anjou Bleu	2016	Segré-en-Anjou Bleu
49323	49323	Verrières-en-Anjou	2015	Verrières-en-Anjou
49307	49307	Loire-Authion	2015	Loire-Authion
49301	49301	Sèvremoine	2015	Sèvremoine
49292	49292	Val-du-Layon	2015	Val-du-Layon
39442	39130	Nanchez	2015	Prénovel (rattachée à 39130)
49228	49228	Noyant-Villages	2017	Noyant-Villages
49218	49218	Montrevault-sur-Èvre	2015	Montrevault-sur-Èvre
49200	49200	Longuenée-en-Anjou	2015	Longuenée-en-Anjou
49194	49194	Mazé-Milon	2015	Mazé-Milon
49183	49183	Val d'Erdre-Auxence	2016	Val d'Erdre-Auxence
49167	49167	Les Garennes sur Loire	2016	Les Garennes sur Loire
49163	49163	Jarzé Villages	2015	Jarzé Villages
49065	49065	les Hauts d'Anjou	2016	les Hauts d'Anjou
49160	49160	Ingrandes-Le Fresne sur Loire	2015	Ingrandes-Le Fresne sur Loire
49149	49149	Gennes-Val de Loire	2015	Gennes-Val de Loire
49138	49138	Les Bois d'Anjou	2015	Les Bois d'Anjou
49125	49125	Doue-en-Anjou	2017	Doue-en-Anjou
49092	49092	Chemillé-en-Anjou	2015	Chemillé-en-Anjou
49086	49086	Terranjou	2017	Terranjou
49069	49069	Orée d'Anjou	2015	Orée d'Anjou
49067	49067	Chenillé-Champteussé	2015	Chenillé-Champteussé
49050	49050	Brissac Loire Aubance	2016	Brissac Loire Aubance
49029	49029	Blaison-Saint-Sulpice	2015	Blaison-Saint-Sulpice
49023	49023	Beaupréau-en-Mauges	2015	Beaupréau-en-Mauges
49021	49021	Beaufort-en-Anjou	2015	Beaufort-en-Anjou
49018	49018	Baugé-en-Anjou	2015	Baugé-en-Anjou
49003	49003	Tuffalun	2015	Tuffalun
39509	39209	Val d'Epy	2015	Senaud (rattachée à 39209)
39018	39018	Aromas	2017	Aromas
39023	39378	Les Trois Châteaux	2015	L'Aubépin (rattachée à 39378)
39340	39329	Mièges	2015	Molpré (rattachée à 39329)
45267	45051	Bray-Saint Aignan	2017	Saint-Aignan-des-Gués (rattachée à 45051)
14568	14098	Thue et Mue	2017	Sainte-Croix-Grand-Tonne (rattachée à 14098)
14581	14011	Aurseulles	2017	Saint-Germain-d'Ectot (rattachée à 14011)
14666	14712	Saline	2017	Sannerville (rattachée à 14712)
14616	14654	Saint-Pierre-en-Auge	2017	Sainte-Marguerite-de-Viette (rattachée à 14654)
14608	14527	Belle Vie en Auge	2017	Saint-Loup-de-Fribois (rattachée à 14527)
02053	02053	Vallées en Champagne	2015	Vallées en Champagne
14422	14431	Mezidon Vallee d Auge	2017	Le Mesnil-Mauger (rattachée à 14431)
14493	14431	Mezidon Vallee d Auge	2017	Percy-en-Auge (rattachée à 14431)
14489	14654	Saint-Pierre-en-Auge	2017	Ouville-la-Bien-Tournée (rattachée à 14654)
14662	14357	Terres de Druance	2017	Saint-Vigor-des-Mézerets (rattachée à 14357)
14201	14431	Mezidon Vallee d Auge	2017	Crèvecoeur-en-Auge (rattachée à 14431)
14433	14654	Saint-Pierre-en-Auge	2017	Mittois (rattachée à 14654)
14081	14654	Saint-Pierre-en-Auge	2017	Boissey (rattachée à 14654)
14611	14658	Noues de Sienne	2017	Saint-Manvieu-Bocage (rattachée à 14658)
14697	14654	Saint-Pierre-en-Auge	2017	L'Oudon (vieux insee) (rattachée à 14654)
14028	14371	Livarot-Pays-d'Auge	2015	Auquainville (rattachée à 14371)
14029	14371	Livarot-Pays-d'Auge	2015	Les Autels-Saint-Bazile (rattachée à 14371)
14065	14726	Valdalliere	2015	Bernières-le-Patry (rattachée à 14726)
14105	14576	Val-de-Vie	2015	La Brévière (rattachée à 14576)
14113	14726	Valdalliere	2015	Burcy (rattachée à 14726)
14115	14061	Souleuvre en Bocage	2015	Bures-les-Monts (rattachée à 14061)
14139	14061	Souleuvre en Bocage	2015	Carville (rattachée à 14061)
14144	14689	Le Hom	2015	Caumont-sur-Orne (rattachée à 14689)
14148	14371	Livarot-Pays-d'Auge	2015	Cerqueux (rattachée à 14371)
14152	14174	Condé-en-Normandie	2015	La Chapelle-Engerbold (rattachée à 14174)
14153	14576	Val-de-Vie	2015	La Chapelle-Haute-Grue (rattachée à 14576)
14154	14570	Valorbiquet	2015	La Chapelle-Yvon (rattachée à 14570)
14155	14371	Livarot-Pays-d'Auge	2015	Cheffreville-Tonnencourt (rattachée à 14371)
14156	14726	Valdalliere	2015	Chênedollé (rattachée à 14726)
14170	14014	Colomby-Anguerny	2015	Colomby-sur-Thaon (rattachée à 14014)
14187	14762	Vire Normandie	2015	Coulonces (rattachée à 14762)
14188	14579	Seulline	2015	Coulvain (rattachée à 14579)
14210	14371	Livarot-Pays-d'Auge	2015	La Croupte (rattachée à 14371)
14213	14689	Le Hom	2015	Curcy-sur-Orne (rattachée à 14689)
14253	14726	Valdalliere	2015	Estry (rattachée à 14726)
14255	14061	Souleuvre en Bocage	2015	Étouvy (rattachée à 14061)
14259	14371	Livarot-Pays-d'Auge	2015	Familly (rattachée à 14371)
14264	14061	Souleuvre en Bocage	2015	La Ferrière-Harang (rattachée à 14061)
14265	14371	Livarot-Pays-d'Auge	2015	Fervaques (rattachée à 14371)
14317	14061	Souleuvre en Bocage	2015	La Graverie (rattachée à 14061)
14330	14371	Livarot-Pays-d'Auge	2015	Heurtevent (rattachée à 14371)
14356	14543	Rots	2015	Lasson (rattachée à 14543)
14361	14174	Condé-en-Normandie	2015	Lénault (rattachée à 14174)
14395	14061	Souleuvre en Bocage	2015	Malloué (rattachée à 14061)
14414	14371	Livarot-Pays-d'Auge	2015	Le Mesnil-Bacley (rattachée à 14371)
14418	14371	Livarot-Pays-d'Auge	2015	Le Mesnil-Durand (rattachée à 14371)
14420	14371	Livarot-Pays-d'Auge	2015	Le Mesnil-Germain (rattachée à 14371)
14429	14371	Livarot-Pays-d'Auge	2015	Meulles (rattachée à 14371)
14432	14475	Noyers-Missy	2015	Missy (rattachée à 14475)
14440	14061	Souleuvre en Bocage	2015	Montamy (rattachée à 14061)
14441	14061	Souleuvre en Bocage	2015	Mont-Bertrand (rattachée à 14061)
14442	14726	Valdalliere	2015	Montchamp (rattachée à 14726)
14443	14061	Souleuvre en Bocage	2015	Montchauvet (rattachée à 14061)
14459	14371	Livarot-Pays-d'Auge	2015	Les Moutiers-Hubert (rattachée à 14371)
14471	14371	Livarot-Pays-d'Auge	2015	Notre-Dame-de-Courson (rattachée à 14371)
14503	14726	Valdalliere	2015	Pierres (rattachée à 14726)
14518	14371	Livarot-Pays-d'Auge	2015	Préaux-Saint-Sébastien (rattachée à 14371)
14521	14726	Valdalliere	2015	Presles (rattachée à 14726)
02439	02439	Les Septvallons	2015	Les Septvallons
14523	14174	Condé-en-Normandie	2015	Proussy (rattachée à 14174)
14532	14061	Souleuvre en Bocage	2015	Le Reculey (rattachée à 14061)
14539	14726	Valdalliere	2015	La Rocque (rattachée à 14726)
14545	14762	Vire Normandie	2015	Roullours (rattachée à 14762)
14549	14726	Valdalliere	2015	Rully (rattachée à 14726)
14564	14726	Valdalliere	2015	Saint-Charles-de-Percy (rattachée à 14726)
14573	14061	Souleuvre en Bocage	2015	Saint-Denis-Maisoncelles (rattachée à 14061)
14583	14576	Val-de-Vie	2015	Saint-Germain-de-Montgommery (rattachée à 14576)
14584	14762	Vire Normandie	2015	Saint-Germain-de-Tallevende-la-Lande-Vaumont (rattachée à 14762)
14585	14174	Condé-en-Normandie	2015	Saint-Germain-du-Crioult (rattachée à 14174)
14599	14570	Valorbiquet	2015	Saint-Julien-de-Mailloc (rattachée à 14570)
14615	14371	Livarot-Pays-d'Auge	2015	Sainte-Marguerite-des-Loges (rattachée à 14371)
14618	14061	Souleuvre en Bocage	2015	Sainte-Marie-Laumont (rattachée à 14061)
14628	14689	Le Hom	2015	Saint-Martin-de-Sallen (rattachée à 14689)
14629	14061	Souleuvre en Bocage	2015	Saint-Martin-des-Besaces (rattachée à 14061)
14632	14061	Souleuvre en Bocage	2015	Saint-Martin-Don (rattachée à 14061)
14633	14371	Livarot-Pays-d'Auge	2015	Saint-Martin-du-Mesnil-Oury (rattachée à 14371)
14634	14371	Livarot-Pays-d'Auge	2015	Saint-Michel-de-Livet (rattachée à 14371)
14638	14371	Livarot-Pays-d'Auge	2015	Saint-Ouen-le-Houx (rattachée à 14371)
14647	14570	Valorbiquet	2015	Saint-Pierre-de-Mailloc (rattachée à 14570)
14653	14174	Condé-en-Normandie	2015	Saint-Pierre-la-Vieille (rattachée à 14174)
14655	14061	Souleuvre en Bocage	2015	Saint-Pierre-Tarentaine (rattachée à 14061)
14670	14543	Rots	2015	Secqueville-en-Bessin (rattachée à 14543)
14693	14570	Valorbiquet	2015	Tordouet (rattachée à 14570)
14696	14371	Livarot-Pays-d'Auge	2015	Tortisambert (rattachée à 14371)
14704	14061	Souleuvre en Bocage	2015	Le Tourneur (rattachée à 14061)
14718	14762	Vire Normandie	2015	Truttemer-le-Petit (rattachée à 14762)
14727	14035	Balleroy-sur-Drôme	2015	Vaubadon (rattachée à 14035)
14746	14726	Valdalliere	2015	Viessoix (rattachée à 14726)
14192	14658	Noues de Sienne	2017	Courson (rattachée à 14658)
33106	33106	Castets et Castillon	2017	Castets et Castillon
14164	14349	Laize-Clinchamps	2017	Clinchamps-sur-Orne (rattachée à 14349)
14517	14005	Valambray	2017	Poussy-la-Campagne (rattachée à 14005)
14508	14027	Les Monts d Aunay	2017	Le Plessis-Grimoult (rattachée à 14027)
14596	14672	Val de Drome	2017	Saint-Jean-des-Essartiers (rattachée à 14672)
14597	14357	Terres de Druance	2017	Saint-Jean-le-Blanc (rattachée à 14357)
14600	14431	Mezidon Vallee d Auge	2017	Saint-Julien-le-Faucon (rattachée à 14431)
14729	14654	Saint-Pierre-en-Auge	2017	Vaudeloges (rattachée à 14654)
14235	14281	Formigny La Bataille	2017	Écrammeville (rattachée à 14281)
14008	14355	Ponts sur Seulles	2017	Amblie (rattachée à 14355)
14031	14431	Mezidon Vallee d Auge	2017	Les Authieux-Papion (rattachée à 14431)
33371	33018	Val de Virvée	2015	Saint-Antoine (rattachée à 33018)
14750	14654	Saint-Pierre-en-Auge	2017	Vieux-Pont-en-Auge (rattachée à 14654)
14757	14200	Creully sur Seulles	2017	Villiers-le-Sec (rattachée à 14200)
14763	14342	Isigny-sur-Mer	2017	Vouilly (rattachée à 14342)
14749	14431	Mezidon Vallee d Auge	2017	Vieux-Fumé (rattachée à 14431)
14580	14654	Saint-Pierre-en-Auge	2017	Saint-Georges-en-Auge (rattachée à 14654)
14472	14654	Saint-Pierre-en-Auge	2017	L'Oudon (rattachée à 14654)
14415	14658	Noues de Sienne	2017	Le Mesnil-Benoist (rattachée à 14658)
14372	14143	Caumont-sur-Aure	2017	Livry (rattachée à 14143)
14416	14658	Noues de Sienne	2017	Le Mesnil-Caussois (rattachée à 14658)
14477	14027	Les Monts d Aunay	2017	Ondefontaine (rattachée à 14027)
14544	14027	Les Monts d Aunay	2017	Roucamps (rattachée à 14027)
14481	14342	Isigny-sur-Mer	2017	Les Oubeaux (rattachée à 14342)
39135	39378	Les Trois Châteaux	2015	Chazelles (rattachée à 39378)
39161	39331	Mignovillard	2015	Communailles-en-Montagne (rattachée à 39331)
27693	27693	Sylvains-Lès-Moulins	2015	Sylvains-Lès-Moulins
14075	14410	Mery-Bissieres-en-Auge	2017	Bissières (rattachée à 14410)
14387	14431	Mezidon Vallee d Auge	2017	Magny-le-Freule (rattachée à 14431)
14413	14347	Dialan sur Chaine	2017	Le Mesnil-Auzouf (rattachée à 14347)
01338	01338	Groslée-Saint-Benoit	2015	Groslée-Saint-Benoit
41270	41173	Beauce la Romaine	2015	Verdes (rattachée à 41173)
14056	14027	Les Monts d Aunay	2017	Bauquay (rattachée à 14027)
14217	14672	Val de Drome	2017	Dampierre (rattachée à 14672)
14548	14406	Moulins en Bessin	2017	Rucqueville (rattachée à 14406)
14551	14591	Aure sur Mer	2017	Russy (rattachée à 14591)
14444	14431	Mezidon Vallee d Auge	2017	Monteille (rattachée à 14431)
14359	14431	Mezidon Vallee d Auge	2017	Lécaude (rattachée à 14431)
14730	14762	Vire Normandie	2015	Vaudry (rattachée à 14762)
14388	14762	Vire Normandie	2015	Maisoncelles-la-Jourdan (rattachée à 14762)
14553	14037	Malherbe-sur-Ajon	2015	Saint-Agnan-le-Malherbe (rattachée à 14037)
14717	14762	Vire Normandie	2015	Truttemer-le-Grand (rattachée à 14762)
14331	14654	Saint-Pierre-en-Auge	2017	Hiéville (rattachée à 14654)
14313	14431	Mezidon Vallee d Auge	2017	Grandchamp-le-Château (rattachée à 14431)
14417	14658	Noues de Sienne	2017	Mesnil-Clinchamps (rattachée à 14658)
14350	14672	Val de Drome	2017	La Lande-sur-Drôme (rattachée à 14672)
14004	14281	Formigny La Bataille	2017	Aignerville (rattachée à 14281)
14450	14654	Saint-Pierre-en-Auge	2017	Montviette (rattachée à 14654)
14324	14689	Le Hom	2015	Hamars (rattachée à 14689)
14052	14061	Souleuvre en Bocage	2015	Beaulieu (rattachée à 14061)
14129	14061	Souleuvre en Bocage	2015	Campeaux (rattachée à 14061)
14695	14011	Aurseulles	2017	Torteval-Quesnay (rattachée à 14011)
14702	14475	Val d Arry	2017	Tournay-sur-Odon (rattachée à 14475)
14671	14658	Noues de Sienne	2017	Sept-Frères (rattachée à 14658)
14690	14355	Ponts sur Seulles	2017	Tierceville (rattachée à 14355)
14219	14027	Les Monts d Aunay	2017	Danvou-la-Ferrière (rattachée à 14027)
14577	14200	Creully sur Seulles	2017	Saint-Gabriel-Brécy (rattachée à 14200)
14525	14098	Thue et Mue	2017	Putot-en-Bessin (rattachée à 14098)
71279	71279	Le Rousset-Marizy	2015	Le Rousset-Marizy
14722	14143	Caumont-sur-Aure	2017	La Vacquerie (rattachée à 14143)
14688	14654	Saint-Pierre-en-Auge	2017	Thiéville (rattachée à 14654)
14686	14726	Valdalliere	2015	Le Theil-Bocage (rattachée à 14726)
14058	14371	Livarot-Pays-d'Auge	2015	Bellou (rattachée à 14371)
14222	14726	Valdalliere	2015	Le Désert (rattachée à 14726)
22046	22046	Le Mené	2015	Le Mené
22055	22055	Binic - Etables-sur-Mer	2015	Binic - Etables-sur-Mer
39491	39491	Coteaux du Lizon	2017	Coteaux du Lizon
49220	49220	Morannes-sur-Sarthe	2015	Morannes sur Sarthe-Daumeray
49220	49220	Morannes sur Sarthe-Daumeray	2017	Morannes sur Sarthe-Daumeray
28012	28012	Commune nouvelle d Arrou	2017	Commune nouvelle d Arrou
49248	49248	Ombrée d'Anjou	2016	Ombrée d'Anjou
61484	61484	Val-au-Perche	2015	Val-au-Perche
68056	68056	Brunstatt-Didenheim	2015	Brunstatt-Didenheim
61050	61050	Cour-Maugis sur Huisne	2015	Cour-Maugis sur Huisne
61168	61168	La Ferté Macé	2015	La Ferté Macé
61345	61345	Rémalard en Perche	2015	Rémalard en Perche
61460	61460	Sap-en-Auge	2015	Sap-en-Auge
61463	61463	Les Monts d'Andaine	2015	Les Monts d'Andaine
61483	61483	Bagnoles de l'Orne Normandie	2015	Bagnoles de l'Orne Normandie
68143	68143	Porte du Ried	2015	Porte du Ried
68162	68162	Kaysersberg Vignoble	2015	Kaysersberg Vignoble
68320	68320	Spechbach	2015	Spechbach
21195	21195	Cormot-Vauchignon	2017	Cormot-Vauchignon
21327	21327	Val-Mont	2015	Val-Mont
17277	17277	Essouvert	2015	Essouvert
23149	23149	Parsac-Rimondeix	2015	Parsac-Rimondeix
03158	03158	Haut-Bocage	2015	Haut-Bocage
24362	24362	Val de Louyre et Caudeau	2017	Val de Louyre et Caudeau
24362	24362	Sainte-Alvère-Saint-Laurent Les Bâtons	2015	Val de Louyre et Caudeau
61338	61491	Tourouvre au Perche	2015	Prépotin (rattachée à 61491)
61409	61309	Perche en Nocé	2015	Saint-Jean-de-la-Forêt (rattachée à 61309)
61430	61050	Cour-Maugis sur Huisne	2015	Saint-Maurice-sur-Huisne (rattachée à 61050)
61144	61309	Perche en Nocé	2015	Dancé (rattachée à 61309)
61027	61153	Écouché-les-Vallées	2015	Batilly (rattachée à 61153)
61247	61230	Longny les Villages	2015	Malétable (rattachée à 61230)
61220	61230	Longny les Villages	2015	La Lande-sur-Eure (rattachée à 61230)
61337	61309	Perche en Nocé	2015	Préaux-du-Perche (rattachée à 61309)
61305	61230	Longny les Villages	2015	Neuilly-sur-Eure (rattachée à 61230)
14579	14579	Seulline	2017	Seulline
14579	14579	Seulline	2015	Seulline
89484	89003	Montholon	2017	Volgré (rattachée à 89003)
04120	04120	Val d'Oronaye	2015	Val d'Oronaye
03318	03168	Meaulne-Vitray	2017	Vitray (rattachée à 03168)
63160	63160	Aulhat-Flat	2015	Aulhat-Flat
50385	50041	La Hague	2017	Omonville-la-Petite (rattachée à 50041)
56061	56061	La Gacilly	2017	La Gacilly
52064	52064	Bourmont	2016	Bourmont
52140	52140	Colombey les Deux Eglises	2017	Colombey les Deux Eglises
52331	52331	La Porte du Der	2015	La Porte du Der
27676	27676	Les Trois Lacs	2017	Les Trois Lacs
50115	50115	Le Grippon	2015	Le Grippon
52405	52405	Le Montsaugeonnais	2015	Le Montsaugeonnais
52449	52449	Saints-Geosmes	2015	Saints-Geosmes
52529	52529	Villegusien-le-Lac	2015	Villegusien-le-Lac
70281	70418	La Romaine	2015	Greucourt (rattachée à 70418)
29203	29021	Plouneour-Brignogan-plages	2017	Plounéour-Trez (rattachée à 29021)
44147	44213	Loireauxence	2015	La Rouxière (rattachée à 44213)
44181	44087	Machecoul-Saint-Même	2015	Saint-Même-le-Tenu (rattachée à 44087)
76027	76618	Petit-Caux	2015	Assigny (rattachée à 76618)
76037	76618	Petit-Caux	2015	Auquemesnil (rattachée à 76618)
76073	76618	Petit-Caux	2015	Belleville-sur-Mer (rattachée à 76618)
76081	76618	Petit-Caux	2015	Berneval-le-Grand (rattachée à 76618)
76089	76289	Saint Martin de l'If	2015	Betteville (rattachée à 76289)
76098	76618	Petit-Caux	2015	Biville-sur-Mer (rattachée à 76618)
76137	76618	Petit-Caux	2015	Bracquemont (rattachée à 76618)
76145	76618	Petit-Caux	2015	Brunville (rattachée à 76618)
46019	46138	Cur de Causse	2015	Beaumat (rattachée à 46138)
46166	46201	Montcuq-en-Quercy-Blanc	2015	Lebreil (rattachée à 46201)
46077	46156	Bellefont - La Rauze	2017	Cours (rattachée à 46156)
43176	43221	Saint-Privat-d Allier	2017	Saint-Didier-d'Allier (rattachée à 43221)
43255	43090	Esplantas-Vazeilles	2015	Vazeilles-près-Saugues (rattachée à 43090)
44034	44213	Loireauxence	2015	La Chapelle-Saint-Sauveur (rattachée à 44213)
39309	39537	Trenal	2017	Mallerey (rattachée à 39537)
33107	33106	Castets et Castillon	2017	Castillon-de-Castets (rattachée à 33106)
39329	39329	Mièges	2015	Mièges
39341	39510	Septmoncel les Molunes	2017	Les Molunes (rattachée à 39510)
15047	15141	Neussargues en Pinatelle	2016	Chavagnac (rattachée à 15141)
87026	87097	Val d'Issoire	2015	Bussière-Boffy (rattachée à 87097)
39482	39017	Arlay	2015	Saint-Germain-lès-Arlay (rattachée à 39017)
39488	39021	La Chailleuse	2015	Saint-Laurent-la-Roche (rattachée à 39021)
39544	39021	La Chailleuse	2015	Varessia (rattachée à 39021)
39485	39485	Val Suran	2017	Val Suran
59404	59260	Ghyvelde	2015	Les Moëres (rattachée à 59260)
59154	59588	Téteghem-Coudekerque-Village	2015	Coudekerque-Village (rattachée à 59588)
86259	86245	Senillé-Saint-Sauveur	2015	Senillé (rattachée à 86245)
25575	25575	Vaire-Arcier	2016	Vaire-Arcier
76146	76146	Buchy	2017	Buchy
38021	38225	Autrans-Méaudre en Vercors	2015	Autrans (rattachée à 38225)
38028	38001	Les Abrets en Dauphiné	2015	La Bâtie-Divisin (rattachée à 38001)
56037	56197	Val d'Oust	2015	La Chapelle-Caro (rattachée à 56197)
31307	31412	Peguilhan	2017	Lunax (rattachée à 31412)
56038	56061	La Gacilly	2017	La Chapelle-Gaceline (rattachée à 56061)
46275	46252	Les Pechs du Vers	2015	Saint-Martin-de-Vers (rattachée à 46252)
46287	46103	Saint-Paul - Flaugnac	2015	Saint-Paul-de-Loubressac (rattachée à 46103)
46291	46138	Cur de Causse	2015	Saint-Sauveur-la-Vallée (rattachée à 46138)
46326	46201	Montcuq-en-Quercy-Blanc	2015	Valprionde (rattachée à 46201)
46248	46063	Castelnau Montratier - Sainte Alauzie	2017	Sainte-Alauzie (rattachée à 46063)
46261	46201	Montcuq-en-Quercy-Blanc	2015	Sainte-Croix (rattachée à 46201)
46025	46201	Montcuq-en-Quercy-Blanc	2015	Belmontet (rattachée à 46201)
46048	46311	Sousceyrac-en-Quercy	2015	Calviac (rattachée à 46311)
46110	46138	Cur de Causse	2015	Fontanes-du-Causse (rattachée à 46138)
38305	38292	Villages du Lac de Paladru	2017	Le Pin (rattachée à 38292)
38312	38407	La Sure en Chartreuse	2017	Pommiers-la-Placette (rattachée à 38407)
50631	50099	Carentan les Marais	2017	Les Veys (rattachée à 50099)
61147	61345	Rémalard en Perche	2015	Dorceau (rattachée à 61345)
61128	61050	Cour-Maugis sur Huisne	2015	Courcerault (rattachée à 61050)
61065	61491	Tourouvre au Perche	2015	Bubertré (rattachée à 61491)
61090	61491	Tourouvre au Perche	2015	Champs (rattachée à 61491)
61004	61168	La Ferté Macé	2015	Antoigny (rattachée à 61168)
61125	61116	Sablons sur Huisne	2015	Coulonges-les-Sablons (rattachée à 61116)
27062	27062	Les Monts du Roumois	2017	Les Monts du Roumois
27085	27085	Flancourt-Crescy-en-Roumois	2015	Flancourt-Crescy-en-Roumois
38125	38456	Chatel-en-Trieves	2017	Cordéac (rattachée à 38456)
16322	16106	Confolens	2015	Saint-Germain-de-Confolens (rattachée à 16106)
16371	16286	Rouillac	2015	Sonneville (rattachée à 16286)
70551	70418	La Romaine	2015	Vezet (rattachée à 70418)
29266	29266	Saint-Thegonnec Loc-Eguiner	2015	Saint-Thegonnec Loc-Eguiner
56064	56061	La Gacilly	2017	Glénac (rattachée à 56061)
56142	56144	Évellys	2015	Moustoir-Remungol (rattachée à 56144)
56150	56251	Theix-Noyalo	2015	Noyalo (rattachée à 56251)
56187	56197	Val d'Oust	2015	Quily (rattachée à 56197)
56192	56144	Évellys	2015	Remungol (rattachée à 56144)
56183	56033	Carentoir	2017	Quelneuc (rattachée à 56033)
71587	71582	La Vineuse sur Fregande	2017	Vitry-lès-Cluny (rattachée à 71582)
71288	71582	La Vineuse sur Fregande	2017	Massy (rattachée à 71582)
71180	71582	La Vineuse sur Fregande	2017	Donzy-le-National (rattachée à 71582)
38001	38001	Les Abrets en Dauphiné	2015	Les Abrets en Dauphiné
68012	68012	Aspach-Michelbach	2015	Aspach-Michelbach
38022	38022	Les Avenières Veyrins-Thuellin	2015	Les Avenières Veyrins-Thuellin
12020	12090	Druelle Balsac	2017	Balsac (rattachée à 12090)
88029	88029	La Voge-les-Bains	2017	La Voge-les-Bains
88475	88475	Tollaincourt	2017	Tollaincourt
27011	27011	Amfreville-Saint-Amand	2015	Amfreville-Saint-Amand
25147	25147	Chemaudin et Vaux	2017	Chemaudin et Vaux
25156	25156	Pays de Clerval	2017	Pays de Clerval
25222	25222	Etalans	2017	Etalans
25434	25434	Ornans	2015	Ornans
25460	25460	Le Val	2017	Le Val
08114	08115	Chémery-Chéhéry	2015	Chéhéry (rattachée à 08115)
08261	08116	Bairon et ses environs	2015	Louvergny (rattachée à 08116)
08267	08145	Douzy	2015	Mairy (rattachée à 08145)
08007	08116	Bairon et ses environs	2015	Les Alleux (rattachée à 08116)
08441	08198	Grandpré	2015	Termes (rattachée à 08198)
08475	08053	Bazeilles	2017	Villers-Cernay (rattachée à 08053)
05118	05118	Val Buëch-Méouge	2015	Val Buëch-Méouge
46063	46063	Castelnau Montratier - Sainte Alauzie	2017	Castelnau Montratier - Sainte Alauzie
46156	46156	Bellefont - La Rauze	2017	Bellefont - La Rauze
25319	25334	Levier	2017	Labergement-du-Navois (rattachée à 25334)
25123	25222	Etalans	2017	Charbonnières-les-Sapins (rattachée à 25222)
12021	12021	Le Bas Ségala	2015	Le Bas Ségala
05175	05101	Vallouise-Pelvoux	2017	Vallouise (rattachée à 05101)
46327	46156	Bellefont - La Rauze	2017	Valroufié (rattachée à 46156)
46331	46268	Saint Gery - Vers	2017	Vers (rattachée à 46268)
15068	15108	Val d'Arcomie	2015	Faverolles (rattachée à 15108)
15197	15108	Val d'Arcomie	2015	Saint-Marc (rattachée à 15108)
15195	15108	Val d'Arcomie	2015	Saint-Just (rattachée à 15108)
15145	15142	Neuveglise-sur-Truyere	2017	Oradour (rattachée à 15142)
29003	29003	Audierne	2015	Audierne
15171	15141	Neussargues en Pinatelle	2016	Sainte-Anastasie (rattachée à 15141)
15227	15142	Neuveglise-sur-Truyere	2017	Sériers (rattachée à 15142)
15031	15141	Neussargues en Pinatelle	2016	Celles (rattachée à 15141)
15044	15138	Murat	2017	Chastel-sur-Murat (rattachée à 15138)
15071	15181	Saint-Constant-Fournoulès	2015	Fournoulès (rattachée à 15181)
15099	15142	Neuveglise-sur-Truyere	2017	Lavastrie (rattachée à 15142)
15150	15268	Le Rouget-Pers	2015	Pers (rattachée à 15268)
56144	56144	Évellys	2015	Évellys
15035	15141	Neussargues en Pinatelle	2016	Chalinargues (rattachée à 15141)
25610	25222	Etalans	2017	Verrières-du-Grosbois (rattachée à 25222)
79044	79063	Val en Vignes	2017	Bouillé-Saint-Paul (rattachée à 79063)
79072	79013	Argentonnay	2015	La Chapelle-Gaudin (rattachée à 79013)
79099	79013	Argentonnay	2015	La Coudre (rattachée à 79013)
79113	79280	Saint Maurice Étusson	2015	Étusson (rattachée à 79280)
25531	25156	Pays de Clerval	2017	Santoche (rattachée à 25156)
52262	52140	Colombey les Deux Eglises	2017	Lamothe-en-Blaisy (rattachée à 52140)
25128	25424	Les Premiers Sapins	2015	Chasnans (rattachée à 25424)
25302	25424	Les Premiers Sapins	2015	Hautepierre-le-Châtelet (rattachée à 25424)
25480	25424	Les Premiers Sapins	2015	Rantechaux (rattachée à 25424)
25509	25438	Osselle-Routelle	2015	Routelle (rattachée à 25438)
25530	25529	Sancey	2015	Sancey-le-Long (rattachée à 25529)
80447	80621	Hypercourt	2017	Hyencourt-le-Grand (rattachée à 80621)
80532	80295	Etinehem-Mericourt	2017	Méricourt-sur-Somme (rattachée à 80295)
28103	28103	Cloyes-les-Trois-Rivieres	2017	Cloyes-les-Trois-Rivieres
12076	12076	Conques-en-Rouergue	2015	Conques-en-Rouergue
71204	71204	Fragnes-La Loyère	2015	Fragnes-La Loyère
12090	12090	Druelle Balsac	2017	Druelle Balsac
71582	71582	La Vineuse sur Fregande	2017	La Vineuse sur Fregande
80608	80621	Hypercourt	2017	Omiécourt (rattachée à 80621)
88234	88029	La Voge-les-Bains	2017	Harsault (rattachée à 88029)
88235	88029	La Voge-les-Bains	2017	Hautmougey (rattachée à 88029)
59588	59588	Téteghem-Coudekerque-Village	2015	Téteghem-Coudekerque-Village
88392	88475	Tollaincourt	2017	Rocourt (rattachée à 88475)
29149	29076	Milizac-Guipronvel	2017	Milizac (rattachée à 29076)
88218	88218	Granges-Aumontzey	2015	Granges-Aumontzey
42114	42039	Chalmazel-Jeansagnière	2015	Jeansagnière (rattachée à 42039)
12120	12120	Laissac-Sévérac l'Eglise	2015	Laissac-Sévérac l'Eglise
27425	27425	Nassandres sur Risle	2017	Nassandres sur Risle
59260	59260	Ghyvelde	2015	Ghyvelde
51261	51075	Bourgogne-Fresne	2017	Fresne-lès-Reims (rattachée à 51075)
67495	67495	Truchtersheim	2015	Truchtersheim
05069	05053	Garde-Colombe	2015	Lagrand (rattachée à 05053)
68201	68201	Masevaux-Niederbruck	2015	Masevaux-Niederbruck
67539	67539	Wingersheim les quatre Bans	2015	Wingersheim les quatre Bans
10277	10003	Aix-Villemaur-Pâlis	2015	Palis (rattachée à 10003)
10415	10003	Aix-Villemaur-Pâlis	2015	Villemaur-sur-Vanne (rattachée à 10003)
52036	52449	Saints-Geosmes	2015	Balesmes-sur-Marne (rattachée à 52449)
52180	52411	Rives Dervoises	2015	Droyes (rattachée à 52411)
52239	52529	Villegusien-le-Lac	2015	Heuilley-Cotton (rattachée à 52529)
27090	27090	Bosroumois	2017	Bosroumois
27092	27062	Les Monts du Roumois	2017	Bosguérard-de-Marcouville (rattachée à 27062)
27093	27090	Bosroumois	2017	Bosnormand (rattachée à 27090)
52293	52411	Rives Dervoises	2015	Longeville-sur-la-Laines (rattachée à 52411)
52296	52411	Rives Dervoises	2015	Louze (rattachée à 52411)
52340	52405	Le Montsaugeonnais	2015	Montsaugeon (rattachée à 52405)
52351	52064	Nijon	2016	Nijon (rattachée à 52064)
67041	67004	Sommerau	2015	Birkenwald (rattachée à 67004)
52427	52331	La Porte du Der	2015	Robert-Magny (rattachée à 52331)
52509	52405	Le Montsaugeonnais	2015	Vaux-sous-Aubigny (rattachée à 52405)
22191	22046	Le Mené	2015	Plessala (rattachée à 22046)
22303	22046	Le Mené	2015	Saint-Jacut-du-Mené (rattachée à 22046)
22367	22251	Pordic	2015	Tréméloir (rattachée à 22251)
68219	68219	Le Haut Soultzbach	2015	Le Haut Soultzbach
60246	60088	Bornel	2015	Fosseuse (rattachée à 60088)
12177	12177	Palmas d'Aveyron	2015	Palmas d'Aveyron
74270	74123	Faverges-Seythenex	2015	Seythenex (rattachée à 74123)
44213	44213	Loireauxence	2015	Loireauxence
44163	44163	Vair-sur-Loire	2015	Vair-sur-Loire
44029	44029	Divatte-sur-Loire	2015	Divatte-sur-Loire
44005	44005	Chaumes-en-Retz	2015	Chaumes-en-Retz
81091	81062	Fontrieu	2015	Ferrières (rattachée à 81062)
74011	74010	Annecy	2017	Annecy-le-Vieux (rattachée à 74010)
25334	25334	Levier	2017	Levier
25529	25529	Sancey	2015	Sancey
77299	77316	Moret Loing et Orvanne	2015	Montarlot (rattachée à 77316)
27294	27294	Val d Orger	2017	Val d Orger
27679	27679	Verneuil d Avre et d Iton	2017	Verneuil d Avre et d Iton
27191	27191	Clef Vallée d'Eure	2015	Clef Vallée d'Eure
27157	27157	Marbois	2015	Marbois
27578	27578	Sainte-Marie-d'Attez	2015	Sainte-Marie-d'Attez
57021	57021	Ancy-Dornot	2015	Ancy-Dornot
57148	57148	Colligny	2016	Colligny
57482	57482	Ogy-Montoy-Flanville	2017	Ogy-Montoy-Flanville
51030	51030	Ay-Champagne	2015	Ay-Champagne
27638	27638	Le Thuit de l'Oison	2015	Le Thuit de l'Oison
27105	27105	Grand Bourgtheroulde	2015	Grand Bourgtheroulde
15108	15108	Val d'Arcomie	2015	Val d'Arcomie
15138	15138	Murat	2017	Murat
15142	15142	Neuveglise-sur-Truyere	2017	Neuveglise-sur-Truyere
15181	15181	Saint-Constant-Fournoulès	2015	Saint-Constant-Fournoulès
15268	15268	Le Rouget-Pers	2015	Le Rouget-Pers
39347	39273	Montlainsia	2017	Montagna-le-Templier (rattachée à 39273)
05005	05118	Val Buëch-Méouge	2015	Antonaves (rattachée à 05118)
05034	05118	Val Buëch-Méouge	2015	Châteauneuf-de-Chabre (rattachée à 05118)
39506	39290	Valzin en Petite Montagne	2017	Savigna (rattachée à 39290)
39564	39485	Val Suran	2017	Villechantria (rattachée à 39485)
39294	39368	Hauts de Bienne	2015	Lézat (rattachée à 39368)
05143	05053	Garde-Colombe	2015	Saint-Genis (rattachée à 05053)
39549	39576	Val-Sonnette	2017	Vercia (rattachée à 39576)
39123	39290	Valzin en Petite Montagne	2017	Chatonnay (rattachée à 39290)
39226	39209	Val d'Epy	2015	Florentia (rattachée à 39209)
39260	39177	Hauteroche	2015	Granges-sur-Baume (rattachée à 39177)
39371	39368	Hauts de Bienne	2015	La Mouille (rattachée à 39368)
39382	39209	Val d'Epy	2015	Nantey (rattachée à 39209)
26001	26001	Solaure en Diois	2015	Solaure en Diois
43081	43245	Thoras	2015	Croisances (rattachée à 43245)
27503	27198	Mesnils-sur-Iton	2015	Le Sacq (rattachée à 27198)
27574	27302	Le Bosc du Theil	2015	Saint-Nicolas-du-Bosc (rattachée à 27302)
27145	27157	Marbois	2015	Chanteloup (rattachée à 27157)
27566	27049	Mesnil-en-Ouche	2015	Sainte-Marguerite-en-Ouche (rattachée à 27049)
27007	27049	Mesnil-en-Ouche	2015	Ajou (rattachée à 27049)
27024	27198	Mesnils-sur-Iton	2015	Le Roncenay-Authenay (rattachée à 27198)
27041	27049	Mesnil-en-Ouche	2015	La Barre-en-Ouche (rattachée à 27049)
27060	27213	Vexin-sur-Epte	2015	Berthenonville (rattachée à 27213)
27084	27105	Grand Bourgtheroulde	2015	Bosc-Bénard-Commin (rattachée à 27105)
27088	27049	Mesnil-en-Ouche	2015	Bosc-Renoult-en-Ouche (rattachée à 27049)
27121	27213	Vexin-sur-Epte	2015	Bus-Saint-Rémy (rattachée à 27213)
27122	27213	Vexin-sur-Epte	2015	Cahaignes (rattachée à 27213)
27195	27578	Sainte-Marie-d'Attez	2015	Dame-Marie (rattachée à 27578)
27197	27213	Vexin-sur-Epte	2015	Dampsmesnil (rattachée à 27213)
27211	27191	Clef Vallée d'Eure	2015	Écardenville-sur-Eure (rattachée à 27191)
27221	27049	Mesnil-en-Ouche	2015	Épinay (rattachée à 27049)
27223	27085	Flancourt-Crescy-en-Roumois	2015	Épreville-en-Roumois (rattachée à 27085)
27225	27157	Marbois	2015	Les Essarts (rattachée à 27157)
27244	27085	Flancourt-Crescy-en-Roumois	2015	Flancourt-Catelon (rattachée à 27085)
27250	27191	Clef Vallée d'Eure	2015	Fontaine-Heudebourg (rattachée à 27191)
27255	27213	Vexin-sur-Epte	2015	Fontenay (rattachée à 27213)
27356	27049	Mesnil-en-Ouche	2015	Jonquerets-de-Livet (rattachée à 27049)
27362	27049	Mesnil-en-Ouche	2015	Landepéreuse (rattachée à 27049)
27387	27198	Mesnils-sur-Iton	2015	Manthelon (rattachée à 27198)
27499	27049	Mesnil-en-Ouche	2015	La Roussière (rattachée à 27049)
27506	27011	Amfreville-Saint-Amand	2015	Saint-Amand-des-Hautes-Terres (rattachée à 27011)
27596	27049	Mesnil-en-Ouche	2015	Saint-Pierre-du-Mesnil (rattachée à 27049)
27628	27049	Mesnil-en-Ouche	2015	Thevray (rattachée à 27049)
27636	27638	Le Thuit de l'Oison	2015	Le Thuit-Anger (rattachée à 27638)
27653	27213	Vexin-sur-Epte	2015	Tourny (rattachée à 27213)
27687	27022	Le Val d'Hazey	2015	Vieux-Villez (rattachée à 27022)
27688	27693	Sylvains-Lès-Moulins	2015	Villalet (rattachée à 27693)
27058	27676	Les Trois Lacs	2017	Bernières-sur-Seine (rattachée à 27676)
27128	27213	Vexin-sur-Epte	2015	Cantiers (rattachée à 27213)
27160	27213	Vexin-sur-Epte	2015	Civières (rattachée à 27213)
27166	27198	Mesnils-sur-Iton	2015	Condé-sur-Iton (rattachée à 27198)
27257	27213	Vexin-sur-Epte	2015	Forêt-la-Folie (rattachée à 27213)
27264	27213	Vexin-sur-Epte	2015	Fours-en-Vexin (rattachée à 27213)
27292	27049	Mesnil-en-Ouche	2015	Gouttières (rattachée à 27049)
27293	27198	Mesnils-sur-Iton	2015	Gouville (rattachée à 27198)
27296	27049	Mesnil-en-Ouche	2015	Granchain (rattachée à 27049)
27305	27112	Breteuil	2015	La Guéroulde (rattachée à 27112)
27308	27213	Vexin-sur-Epte	2015	Guitry (rattachée à 27213)
27449	27213	Vexin-sur-Epte	2015	Panilleuse (rattachée à 27213)
27513	27049	Mesnil-en-Ouche	2015	Saint-Aubin-des-Hayes (rattachée à 27049)
27515	27049	Mesnil-en-Ouche	2015	Saint-Aubin-le-Guichard (rattachée à 27049)
27519	27022	Le Val d'Hazey	2015	Sainte-Barbe-sur-Gaillon (rattachée à 27022)
27526	27107	Bourneville-Sainte-Croix	2015	Sainte-Croix-sur-Aizier (rattachée à 27107)
27274	27294	Val d Orger	2017	Gaillardbois-Cressenville (rattachée à 27294)
27626	27089	Thenouville	2017	Theillement (rattachée à 27089)
27253	27425	Nassandres sur Risle	2017	Fontaine-la-Soret (rattachée à 27425)
27344	27062	Les Monts du Roumois	2017	Houlbec-près-le-Gros-Theil (rattachée à 27062)
76258	76258	Terres-de-Caux	2017	Terres-de-Caux
27452	27425	Nassandres sur Risle	2017	Perriers-la-Campagne (rattachée à 27425)
27448	27448	Pacy-sur-Eure	2017	Pacy-sur-Eure
89138	89086	Charny Orée de Puisaye	2015	Dicy (rattachée à 89086)
89178	89086	Charny Orée de Puisaye	2015	Fontenouilles (rattachée à 89086)
89192	89086	Charny Orée de Puisaye	2015	Grandchamp (rattachée à 89086)
89213	89196	Valravillon	2015	Laduz (rattachée à 89196)
27277	27277	La Baronnie	2015	La Baronnie
27510	27448	Pacy-sur-Eure	2017	Saint-Aquilin-de-Pacy (rattachée à 27448)
27588	27554	La Chapelle-Longueville	2017	Saint-Pierre-d'Autils (rattachée à 27554)
27131	27425	Nassandres sur Risle	2017	Carsix (rattachée à 27425)
89243	89086	Charny Orée de Puisaye	2015	Marchais-Beton (rattachée à 89086)
89275	89196	Valravillon	2015	Neuilly (rattachée à 89196)
89294	89086	Charny Orée de Puisaye	2015	Perreux (rattachée à 89086)
89317	89086	Charny Orée de Puisaye	2015	Prunoy (rattachée à 89086)
89343	89086	Charny Orée de Puisaye	2015	Saint-Denis-sur-Ouanne (rattachée à 89086)
89356	89334	Le Val d'Ocre	2015	Saint-Martin-sur-Ocre (rattachée à 89334)
89358	89086	Charny Orée de Puisaye	2015	Saint-Martin-sur-Ouanne (rattachée à 89086)
89366	89388	Sépeaux-Saint Romain	2015	Saint-Romain-le-Preux (rattachée à 89388)
50600	50041	La Hague	2017	Tonneville (rattachée à 50041)
50386	50041	La Hague	2017	Omonville-la-Rogue (rattachée à 50041)
50020	50041	La Hague	2017	Auderville (rattachée à 50041)
50465	50095	Canisy	2017	Saint-Ébremond-de-Bonfossé (rattachée à 50095)
67372	67372	Val de Moder	2015	Val de Moder
67207	67539	Wingersheim les quatre Bans	2015	Hohatzenheim (rattachée à 67539)
67439	67202	Hochfelden	2017	Schaffhouse-sur-Zorn (rattachée à 67202)
76031	76476	Port-Jérôme-sur-Seine	2015	Auberville-la-Campagne (rattachée à 76476)
76301	76618	Petit-Caux	2015	Glicourt (rattachée à 76618)
76326	76618	Petit-Caux	2015	Greny (rattachée à 76618)
76376	76618	Petit-Caux	2015	Intraville (rattachée à 76618)
76496	76618	Petit-Caux	2015	Penly (rattachée à 76618)
76643	76618	Petit-Caux	2015	Saint-Quentin-au-Bosc (rattachée à 76618)
12223	12223	Argences en Aubrac	2015	Argences en Aubrac
12224	12224	Saint Geniez d'Olt et d'Aubrac	2015	Saint Geniez d'Olt et d'Aubrac
76607	76258	Terres-de-Caux	2017	Sainte-Marguerite-sur-Fauville (rattachée à 76258)
76080	76258	Terres-de-Caux	2017	Bermonville (rattachée à 76258)
76248	76146	Buchy	2017	Estouteville-Écalles (rattachée à 76146)
39158	39530	Thoirette-Coisia	2017	Coisia (rattachée à 39530)
76127	76146	Buchy	2017	Bosc-Roger-sur-Buchy (rattachée à 76146)
76277	76276	Forges-les-Eaux	2015	Le Fossé (rattachée à 76276)
76044	76258	Terres-de-Caux	2017	Auzouville-Auberbosc (rattachée à 76258)
76078	76258	Terres-de-Caux	2017	Bennetot (rattachée à 76258)
76525	76258	Terres-de-Caux	2017	Ricarville (rattachée à 76258)
76215	76618	Petit-Caux	2015	Derchigny (rattachée à 76618)
76639	76258	Terres-de-Caux	2017	Saint-Pierre-Lavis (rattachée à 76258)
76267	76289	Saint Martin de l'If	2015	La Folletière (rattachée à 76289)
76310	76618	Petit-Caux	2015	Gouchaupre (rattachée à 76618)
76337	76618	Petit-Caux	2015	Guilmécourt (rattachée à 76618)
76444	76289	Saint Martin de l'If	2015	Mont-de-l'If (rattachée à 76289)
76625	76401	Arelaune-en-Seine	2015	Saint-Nicolas-de-Bliquetuit (rattachée à 76401)
76659	76164	Rives-en-Seine	2015	Saint-Wandrille-Rançon (rattachée à 76164)
76696	76618	Petit-Caux	2015	Tocqueville-sur-Eu (rattachée à 76618)
76701	76476	Port-Jérôme-sur-Seine	2015	Touffreville-la-Cable (rattachée à 76476)
76704	76618	Petit-Caux	2015	Tourville-la-Chapelle (rattachée à 76618)
76713	76476	Port-Jérôme-sur-Seine	2015	Triquerville (rattachée à 76476)
76742	76164	Rives-en-Seine	2015	Villequier (rattachée à 76164)
77170	77316	Moret Loing et Orvanne	2015	Épisy (rattachée à 77316)
81153	81062	Fontrieu	2015	Le Margnès (rattachée à 81062)
81155	81026	Bellegarde-Marsal	2015	Marsal (rattachée à 81026)
77491	77316	Moret-Loing-et-Orvanne	2017	Veneux-les-Sablons (rattachée à 77316)
32168	32079	Castelnau d'Auzan Labarrère	2015	Labarrère (rattachée à 32079)
72025	72025	Bazouges Cre sur Loir	2017	Bazouges Cre sur Loir
48164	48027	Mont Lozere et Goulet	2017	Saint-Julien-du-Tournel (rattachée à 48027)
48162	48166	Cans et Cévennes	2015	Saint-Julien-d'Arpaon (rattachée à 48166)
48049	48099	Bourgs sur Colagne	2015	Chirac (rattachée à 48099)
48062	48105	Naussac-Fontanes	2015	Fontanes (rattachée à 48105)
48120	48087	Prinsuejols-Malbouzon	2017	Prinsuéjols (rattachée à 48087)
48195	48094	Massegros Causses Gorges	2017	Les Vignes (rattachée à 48094)
53194	53137	Loiron-Ruillé	2015	Ruillé-le-Gravelais (rattachée à 53137)
48154	48094	Massegros Causses Gorges	2017	Saint-Georges-de-Lévéjac (rattachée à 48094)
48076	48009	Peyre en Aubrac	2017	Javols (rattachée à 48009)
48084	48139	Saint Bonnet-Laval	2017	Laval-Atger (rattachée à 48139)
48180	48094	Massegros Causses Gorges	2017	Saint-Rome-de-Dolan (rattachée à 48094)
48183	48009	Peyre en Aubrac	2017	Saint-Sauveur-de-Peyre (rattachée à 48009)
48101	48146	Gorges du Tarn Causses	2017	Montbrun (rattachée à 48146)
48060	48009	Peyre en Aubrac	2017	Fau-de-Peyre (rattachée à 48009)
48093	48027	Mont Lozere et Goulet	2017	Mas-d'Orcières (rattachée à 48027)
48142	48009	Peyre en Aubrac	2017	Sainte-Colombe-de-Peyre (rattachée à 48009)
48014	48027	Mont Lozere et Goulet	2017	Bagnols-les-Bains (rattachée à 48027)
48023	48027	Mont Lozere et Goulet	2017	Belvezet (rattachée à 48027)
48040	48027	Mont Lozere et Goulet	2017	Chasseradès (rattachée à 48027)
48047	48009	Peyre en Aubrac	2017	La Chaze-de-Peyre (rattachée à 48009)
48122	48146	Gorges du Tarn Causses	2017	Quézac (rattachée à 48146)
48125	48094	Massegros Causses Gorges	2017	Le Recoux (rattachée à 48094)
48134	48152	Ventalon en Cévennes	2015	Saint-Andéol-de-Clerguemort (rattachée à 48152)
48066	48116	Pont de Montvert - Sud Mont Lozère	2015	Fraissinet-de-Lozère (rattachée à 48116)
48172	48116	Pont de Montvert - Sud Mont Lozère	2015	Saint-Maurice-de-Ventalon (rattachée à 48116)
48022	48050	Bedoues-Cocures	2015	Bédouès (rattachée à 48050)
48186	48061	Florac Trois Rivières	2015	La Salle-Prunet (rattachée à 48061)
48033	48017	Banassac-Canilhac	2015	Canilhac (rattachée à 48017)
04198	04033	Ubaye-Serre-Poncon	2017	Saint-Vincent-les-Forts (rattachée à 04033)
04100	04120	Val d'Oronaye	2015	Larche (rattachée à 04120)
28402	28254	Mittainvilliers-Vérigny	2015	Vérigny (rattachée à 28254)
12270	12270	Sévérac d'Aveyron	2015	Sévérac d'Aveyron
04033	04033	Ubaye-Serre-Poncon	2017	Ubaye-Serre-Poncon
09317	09062	Bordes-Uchentein	2017	Uchentein (rattachée à 09062)
49317	49050	Brissac Loire Aubance	2016	Saint-Rémy-la-Varenne (rattachée à 49050)
49258	49301	Sèvremoine	2015	La Renaudière (rattachée à 49301)
49263	49301	Sèvremoine	2015	Roussay (rattachée à 49301)
49265	49292	Val-du-Layon	2015	Saint-Aubin-de-Luigné (rattachée à 49292)
49268	49092	Chemillé-en-Anjou	2015	Sainte-Christine (rattachée à 49092)
49270	49069	Orée d'Anjou	2015	Saint-Christophe-la-Couperie (rattachée à 49069)
49273	49301	Sèvremoine	2015	Saint-Crespin-sur-Moine (rattachée à 49301)
49276	49244	Mauges-sur-Loire	2015	Saint-Florent-le-Vieil (rattachée à 49244)
49279	49149	Gennes-Val de Loire	2015	Saint-Georges-des-Sept-Voies (rattachée à 49149)
49280	49138	Les Bois d'Anjou	2015	Saint-Georges-du-Bois (rattachée à 49138)
49281	49092	Chemillé-en-Anjou	2015	Saint-Georges-des-Gardes (rattachée à 49092)
49285	49301	Sèvremoine	2015	Saint-Germain-sur-Moine (rattachée à 49301)
49295	49244	Mauges-sur-Loire	2015	Saint-Laurent-de-la-Plaine (rattachée à 49244)
49296	49069	Orée d'Anjou	2015	Saint-Laurent-des-Autels (rattachée à 49069)
49297	49244	Mauges-sur-Loire	2015	Saint-Laurent-du-Mottay (rattachée à 49244)
49300	49092	Chemillé-en-Anjou	2015	Saint-Lézin (rattachée à 49092)
49226	49248	Ombrée d'Anjou	2016	Noëllet (rattachée à 49248)
49077	49331	Segré-en-Anjou Bleu	2016	La Chapelle-sur-Oudon (rattachée à 49331)
49073	49248	Ombrée d'Anjou	2016	La Chapelle-Hullin (rattachée à 49248)
49062	49228	Noyant-Villages	2017	Chalonnes-sous-le-Lude (rattachée à 49228)
49047	49125	Doue-en-Anjou	2017	Brigné (rattachée à 49125)
49037	49331	Segré-en-Anjou Bleu	2016	Le Bourg-d'Iré (rattachée à 49331)
49042	49307	Loire-Authion	2015	Brain-sur-l'Authion (rattachée à 49307)
49043	49367	Erdre-en-Anjou	2015	Brain-sur-Longuenée (rattachée à 49367)
49049	49138	Les Bois d'Anjou	2015	Brion (rattachée à 49138)
49059	49373	Lys-Haut-Layon	2015	Les Cerqueux-sous-Passavant (rattachée à 49373)
49066	49345	Bellevigne-en-Layon	2015	Champ-sur-Layon (rattachée à 49345)
49071	49092	Chemillé-en-Anjou	2015	Chanzeaux (rattachée à 49092)
49072	49023	Beaupréau-en-Mauges	2015	La Chapelle-du-Genêt (rattachée à 49023)
49074	49092	Chemillé-en-Anjou	2015	La Chapelle-Rousselin (rattachée à 49092)
49075	49244	Mauges-sur-Loire	2015	La Chapelle-Saint-Florent (rattachée à 49244)
49079	49018	Baugé-en-Anjou	2015	Chartrené (rattachée à 49018)
49083	49218	Montrevault-sur-Èvre	2015	Chaudron-en-Mauges (rattachée à 49218)
49084	49163	Jarzé Villages	2015	Chaumont-d'Anjou (rattachée à 49163)
49085	49218	Montrevault-sur-Èvre	2015	La Chaussaire (rattachée à 49218)
49093	49220	Morannes-sur-Sarthe	2015	Chemiré-sur-Sarthe (rattachée à 49220)
49094	49149	Gennes-Val de Loire	2015	Chênehutte-Trèves-Cunault (rattachée à 49149)
49095	49067	Chenillé-Champteussé	2015	Chenillé-Changé (rattachée à 49067)
49097	49018	Baugé-en-Anjou	2015	Cheviré-le-Rouge (rattachée à 49018)
49101	49018	Baugé-en-Anjou	2015	Clefs-Val d'Anjou (rattachée à 49018)
49111	49092	Chemillé-en-Anjou	2015	Cossé-d'Anjou (rattachée à 49092)
49116	49018	Baugé-en-Anjou	2015	Cuon (rattachée à 49018)
49117	49307	Loire-Authion	2015	La Daguenière (rattachée à 49307)
49126	49069	Orée d'Anjou	2015	Drain (rattachée à 49069)
49128	49018	Baugé-en-Anjou	2015	Échemiré (rattachée à 49018)
49133	49345	Bellevigne-en-Layon	2015	Faveraye-Mâchelles (rattachée à 49345)
49134	49345	Bellevigne-en-Layon	2015	Faye-d'Anjou (rattachée à 49345)
49137	49218	Montrevault-sur-Èvre	2015	Le Fief-Sauvin (rattachée à 49218)
49142	49373	Lys-Haut-Layon	2015	La Fosse-de-Tigné (rattachée à 49373)
49143	49018	Baugé-en-Anjou	2015	Fougeré (rattachée à 49018)
49145	49218	Montrevault-sur-Èvre	2015	Le Fuilet (rattachée à 49218)
49147	49021	Beaufort-en-Anjou	2015	Gée (rattachée à 49021)
49148	49367	Erdre-en-Anjou	2015	Gené (rattachée à 49367)
49151	49023	Beaupréau-en-Mauges	2015	Gesté (rattachée à 49023)
49153	49092	Chemillé-en-Anjou	2015	Valanjou (rattachée à 49092)
49154	49149	Gennes-Val de Loire	2015	Grézillé (rattachée à 49149)
49157	49018	Baugé-en-Anjou	2015	Le Guédeniau (rattachée à 49018)
49162	49023	Beaupréau-en-Mauges	2015	Jallais (rattachée à 49023)
49165	49023	Beaupréau-en-Mauges	2015	La Jubaudière (rattachée à 49023)
49169	49092	Chemillé-en-Anjou	2015	La Jumellière (rattachée à 49092)
49172	49069	Orée d'Anjou	2015	Landemont (rattachée à 49069)
49177	49069	Orée d'Anjou	2015	Liré (rattachée à 49069)
49181	49003	Tuffalun	2015	Louerre (rattachée à 49003)
49185	49163	Jarzé Villages	2015	Lué-en-Baugeois (rattachée à 49163)
49190	49244	Mauges-sur-Loire	2015	Le Marillais (rattachée à 49244)
49196	49200	Longuenée-en-Anjou	2015	La Meignanne (rattachée à 49200)
49204	49244	Mauges-sur-Loire	2015	Le Mesnil-en-Vallée (rattachée à 49244)
49212	49244	Mauges-sur-Loire	2015	Montjean-sur-Loire (rattachée à 49244)
49225	49092	Chemillé-en-Anjou	2015	Neuvy-en-Mauges (rattachée à 49092)
49238	49323	Verrières-en-Anjou	2015	Pellouailles-les-Vignes (rattachée à 49323)
49239	49023	Beaupréau-en-Mauges	2015	Le Pin-en-Mauges (rattachée à 49023)
49249	49367	Erdre-en-Anjou	2015	La Pouëze (rattachée à 49367)
49252	49218	Montrevault-sur-Èvre	2015	Le Puiset-Doré (rattachée à 49218)
49256	49345	Bellevigne-en-Layon	2015	Rablay-sur-Layon (rattachée à 49345)
49250	49248	Ombrée d'Anjou	2016	La Prévière (rattachée à 49248)
49309	49248	Ombrée d'Anjou	2016	Saint-Michel-et-Chanveaux (rattachée à 49248)
49354	49248	Ombrée d'Anjou	2016	Le Tremblay (rattachée à 49248)
49366	49248	Ombrée d'Anjou	2016	Vergonnes (rattachée à 49248)
49081	49331	Segré-en-Anjou Bleu	2016	Châtelais (rattachée à 49331)
49136	49331	Segré-en-Anjou Bleu	2016	La Ferrière-de-Flée (rattachée à 49331)
49158	49331	Segré-en-Anjou Bleu	2016	L'Hôtellerie-de-Flée (rattachée à 49331)
49184	49331	Segré-en-Anjou Bleu	2016	Louvaines (rattachée à 49331)
49187	49331	Segré-en-Anjou Bleu	2016	Marans (rattachée à 49331)
49229	49331	Segré-en-Anjou Bleu	2016	Noyant-la-Gravoyère (rattachée à 49331)
49233	49331	Segré-en-Anjou Bleu	2016	Nyoiseau (rattachée à 49331)
49277	49331	Segré-en-Anjou Bleu	2016	Sainte-Gemmes-d'Andigné (rattachée à 49331)
49305	49331	Segré-en-Anjou Bleu	2016	Saint-Martin-du-Bois (rattachée à 49331)
48027	48027	Mont Lozere et Goulet	2017	Mont Lozere et Goulet
49319	49331	Segré-en-Anjou Bleu	2016	Saint-Sauveur-de-Flée (rattachée à 49331)
49365	49125	Doue-en-Anjou	2017	Les Verchers-sur-Layon (rattachée à 49125)
49282	49125	Doue-en-Anjou	2017	Saint-Georges-sur-Layon (rattachée à 49125)
49150	49228	Noyant-Villages	2017	Genneteil (rattachée à 49228)
49004	49307	Loire-Authion	2015	Andard (rattachée à 49307)
49005	49176	Le Lion-d'Angers	2015	Andigné (rattachée à 49176)
49006	49023	Beaupréau-en-Mauges	2015	Andrezé (rattachée à 49023)
49024	49244	Mauges-sur-Loire	2015	Beausse (rattachée à 49244)
49106	49307	Loire-Authion	2015	Corné (rattachée à 49307)
49207	49125	Doue-en-Anjou	2017	Montfort (rattachée à 49125)
49208	49331	Segré-en-Anjou Bleu	2016	Montguillon (rattachée à 49331)
49312	49023	Beaupréau-en-Mauges	2015	Saint-Philbert-en-Mauges (rattachée à 49023)
49313	49218	Montrevault-sur-Èvre	2015	Saint-Pierre-Montlimart (rattachée à 49218)
49314	49218	Montrevault-sur-Èvre	2015	Saint-Quentin-en-Mauges (rattachée à 49218)
49315	49018	Baugé-en-Anjou	2015	Saint-Quentin-lès-Beaurepaire (rattachée à 49018)
49316	49218	Montrevault-sur-Èvre	2015	Saint-Rémy-en-Mauges (rattachée à 49218)
49320	49069	Orée d'Anjou	2015	Saint-Sauveur-de-Landemont (rattachée à 49069)
49324	49218	Montrevault-sur-Èvre	2015	La Salle-et-Chapelle-Aubry (rattachée à 49218)
49325	49092	Chemillé-en-Anjou	2015	La Salle-de-Vihiers (rattachée à 49092)
49327	49050	Brissac Loire Aubance	2016	Saulgé-l'Hôpital (rattachée à 49050)
49342	49373	Lys-Haut-Layon	2015	Tancoigné (rattachée à 49373)
49349	49301	Sèvremoine	2015	Tillières (rattachée à 49301)
49242	49200	Longuenée-en-Anjou	2015	Le Plessis-Macé (rattachée à 49200)
49243	49023	Beaupréau-en-Mauges	2015	La Poitevinière (rattachée à 49023)
49350	49301	Sèvremoine	2015	Torfou (rattachée à 49301)
49351	49092	Chemillé-en-Anjou	2015	La Tourlandry (rattachée à 49092)
49051	49065	les Hauts d'Anjou	2016	Brissarthe (rattachée à 49065)
49078	49050	Brissac Loire Aubance	2016	Charcé-Saint-Ellier-sur-Aubance (rattachée à 49050)
49091	49050	Brissac Loire Aubance	2016	Chemellier (rattachée à 49050)
49115	49050	Brissac Loire Aubance	2016	Coutures (rattachée à 49050)
49096	49065	les Hauts d'Anjou	2016	Cherré (rattachée à 49065)
49335	49065	les Hauts d'Anjou	2016	Soeurdres (rattachée à 49065)
49254	49065	les Hauts d'Anjou	2016	Querré (rattachée à 49065)
49290	49167	Les Garennes sur Loire	2016	Saint-Jean-des-Mauvrets (rattachée à 49167)
49108	49183	Val d'Erdre-Auxence	2016	La Cornuaille (rattachée à 49183)
49376	49183	Val d'Erdre-Auxence	2016	Villemoisan (rattachée à 49183)
49264	49301	Sèvremoine	2015	Saint-André-de-la-Marche (rattachée à 49301)
49232	49373	Lys-Haut-Layon	2015	Nueil-sur-Layon (rattachée à 49373)
49251	49200	Longuenée-en-Anjou	2015	Pruillé (rattachée à 49200)
49322	49029	Blaison-Saint-Sulpice	2015	Saint-Sulpice (rattachée à 49029)
49202	49228	Noyant-Villages	2017	Méon (rattachée à 49228)
49198	49125	Doue-en-Anjou	2017	Meigné (rattachée à 49125)
49197	49228	Noyant-Villages	2017	Meigné-le-Vicomte (rattachée à 49228)
49001	49050	Brissac Loire Aubance	2016	Les Alleuds (rattachée à 49050)
49034	49244	Mauges-sur-Loire	2015	Botz-en-Mauges (rattachée à 49244)
49186	49050	Brissac Loire Aubance	2016	Luigné (rattachée à 49050)
49234	49228	Noyant-Villages	2017	Parçay-les-Pins (rattachée à 49228)
36151	36229	Val-Fouzon	2015	Parpeçay (rattachée à 36229)
36201	36093	Levroux	2015	Saint-Martin-de-Lamps (rattachée à 36093)
36245	36202	Saint-Maur	2015	Villers-les-Ormes (rattachée à 36202)
46103	46103	Saint-Paul - Flaugnac	2015	Saint-Paul - Flaugnac
36183	36229	Val-Fouzon	2015	Sainte-Cécile (rattachée à 36229)
49014	49331	Segré-en-Anjou Bleu	2016	Aviré (rattachée à 49331)
49348	49373	Lys-Haut-Layon	2015	Tigné (rattachée à 49373)
49105	49065	les Hauts d'Anjou	2016	Contigné (rattachée à 49065)
49052	49228	Noyant-Villages	2017	Broc (rattachée à 49228)
49179	49301	Sèvremoine	2015	Le Longeron (rattachée à 49301)
49230	49003	Tuffalun	2015	Noyant-la-Plaine (rattachée à 49003)
49346	49149	Gennes-Val de Loire	2015	Le Thoureil (rattachée à 49149)
49019	49307	Loire-Authion	2015	Bauné (rattachée à 49307)
49318	49050	Brissac Loire Aubance	2016	Saint-Saturnin-sur-Loire (rattachée à 49050)
49363	49050	Brissac Loire Aubance	2016	Vauchrétien (rattachée à 49050)
49189	49065	les Hauts d'Anjou	2016	Marigné (rattachée à 49065)
49175	49228	Noyant-Villages	2017	Linières-Bouton (rattachée à 49228)
49173	49228	Noyant-Villages	2017	Lasse (rattachée à 49228)
49141	49125	Doue-en-Anjou	2017	Forges (rattachée à 49125)
49122	49228	Noyant-Villages	2017	Dénezé-sous-le-Lude (rattachée à 49228)
49119	49220	Morannes sur Sarthe-Daumeray	2017	Daumeray (rattachée à 49220)
49044	49228	Noyant-Villages	2017	Breil (rattachée à 49228)
46252	46252	Les Pechs du Vers	2015	Les Pechs du Vers
49104	49125	Doue-en-Anjou	2017	Concourson-sur-Layon (rattachée à 49125)
49356	49373	Lys-Haut-Layon	2015	Trémont (rattachée à 49373)
49360	49069	Orée d'Anjou	2015	La Varenne (rattachée à 49069)
49375	49023	Beaupréau-en-Mauges	2015	Villedieu-la-Blouère (rattachée à 49023)
49088	49248	Ombrée d'Anjou	2016	Chazé-Henry (rattachée à 49248)
49103	49248	Ombrée d'Anjou	2016	Combrée (rattachée à 49248)
49156	49248	Ombrée d'Anjou	2016	Grugé-l'Hôpital (rattachée à 49248)
49227	49086	Terranjou	2017	Notre-Dame-d'Allençon (rattachée à 49086)
49191	49086	Terranjou	2017	Martigné-Briand (rattachée à 49086)
49098	49228	Noyant-Villages	2017	Chigné (rattachée à 49228)
49087	49228	Noyant-Villages	2017	Chavaignes (rattachée à 49228)
49025	49163	Jarzé Villages	2015	Beauvau (rattachée à 49163)
49031	49018	Baugé-en-Anjou	2015	Bocé (rattachée à 49018)
49032	49307	Loire-Authion	2015	La Bohalle (rattachée à 49307)
49033	49218	Montrevault-sur-Èvre	2015	La Boissière-sur-Èvre (rattachée à 49218)
49039	49244	Mauges-sur-Loire	2015	Bourgneuf-en-Mauges (rattachée à 49244)
49040	49069	Orée d'Anjou	2015	Bouzillé (rattachée à 49069)
49206	49301	Sèvremoine	2015	Montfaucon-Montigné (rattachée à 49301)
49013	49228	Noyant-Villages	2017	Auverse (rattachée à 49228)
49139	49194	Mazé-Milon	2015	Fontaine-Milon (rattachée à 49194)
53205	53161	Montsurs-Saint-Cenere	2017	Saint-Céneré (rattachée à 53161)
53032	53228	Blandouet-Saint-Jean	2017	Blandouet (rattachée à 53228)
53095	53017	Val-du-Maine	2017	Épineux-le-Seguin (rattachée à 53017)
46138	46138	Cur de Causse	2015	Cur de Causse
53050	53255	Sainte-Suzanne-et-Chammes	2015	Chammes (rattachée à 53255)
53252	53185	Pré-en-Pail-Saint-Samson	2015	Saint-Samson (rattachée à 53185)
46311	46311	Sousceyrac-en-Quercy	2015	Sousceyrac-en-Quercy
11050	11304	Quillan	2015	Brenac (rattachée à 11304)
11171	11080	Val de Lambronne	2015	Gueytes-et-Labastide (rattachée à 11080)
28083	28103	Cloyes-les-Trois-Rivieres	2017	Charray (rattachée à 28103)
28093	28012	Commune nouvelle d Arrou	2017	Châtillon-en-Dunois (rattachée à 28012)
28297	28383	Theuville	2015	Pézy (rattachée à 28383)
28320	28422	Les Villages Vovéens	2015	Rouvray-Saint-Florentin (rattachée à 28422)
28224	28330	Villemaury	2017	Lutz-en-Dunois (rattachée à 28330)
28241	28103	Cloyes-les-Trois-Rivieres	2017	Le Mée (rattachée à 28103)
28262	28103	Cloyes-les-Trois-Rivieres	2017	Montigny-le-Gannelon (rattachée à 28103)
28318	28103	Cloyes-les-Trois-Rivieres	2017	Romilly-sur-Aigre (rattachée à 28103)
28356	28012	Commune nouvelle d Arrou	2017	Saint-Pellerin (rattachée à 28012)
28017	28103	Cloyes-les-Trois-Rivieres	2017	Autheuil (rattachée à 28103)
28101	28330	Villemaury	2017	Civry (rattachée à 28330)
28115	28012	Commune nouvelle d Arrou	2017	Courtalain (rattachée à 28012)
28133	28103	Cloyes-les-Trois-Rivieres	2017	Douy (rattachée à 28103)
28295	28330	Villemaury	2017	Ozoir-le-Breuil (rattachée à 28330)
28044	28012	Commune nouvelle d Arrou	2017	Boisgasson (rattachée à 28012)
28416	28422	Les Villages Vovéens	2015	Villeneuve-Saint-Nicolas (rattachée à 28422)
28340	28103	Cloyes-les-Trois-Rivieres	2017	Saint-Hilaire-sur-Yerre (rattachée à 28103)
28150	28103	Cloyes-les-Trois-Rivieres	2017	La Ferté-Villeneuil (rattachée à 28103)
28204	28012	Commune nouvelle d Arrou	2017	Langey (rattachée à 28012)
28020	28406	Eole-en-Beauce	2015	Baignolet (rattachée à 28406)
28145	28406	Eole-en-Beauce	2015	Fains-la-Folie (rattachée à 28406)
28179	28406	Eole-en-Beauce	2015	Germignonville (rattachée à 28406)
28288	28183	Gommerville	2015	Orlu (rattachée à 28183)
28258	28422	Les Villages Vovéens	2015	Montainville (rattachée à 28422)
28361	28015	Auneau-Bleury-Saint-Symphorien	2015	Bleury-Saint-Symphorien (rattachée à 28015)
76289	76289	Saint Martin de l'If	2015	Saint Martin de l'If
09062	09062	Bordes-Uchentein	2017	Bordes-Uchentein
31412	31412	Peguilhan	2017	Peguilhan
35168	35168	Val d Anast	2017	Val d Anast
44021	44021	Villeneuve-en-Retz	2015	Villeneuve-en-Retz
14027	14027	Les Monts d Aunay	2017	Les Monts d Aunay
43221	43221	Saint-Privat-d Allier	2017	Saint-Privat-d Allier
43245	43245	Thoras	2015	Thoras
43090	43090	Esplantas-Vazeilles	2015	Esplantas-Vazeilles
11080	11080	Val de Lambronne	2015	Val de Lambronne
11304	11304	Quillan	2015	Quillan
60029	60029	Auneuil	2017	Auneuil
60088	60088	Bornel	2015	Bornel
53017	53017	Val-du-Maine	2017	Val-du-Maine
35257	35257	Maen Roch	2017	Maen Roch
80295	80295	Etinehem-Mericourt	2017	Etinehem-Mericourt
80621	80621	Hypercourt	2017	Hypercourt
89003	89003	Montholon	2017	Montholon
89086	89086	Charny Orée de Puisaye	2015	Charny Orée de Puisaye
19252	19252	Sarroux - Saint Julien	2017	Sarroux - Saint Julien
89130	89130	Deux Rivieres	2017	Deux Rivieres
89196	89196	Valravillon	2015	Valravillon
89334	89334	Le Val d'Ocre	2015	Le Val d'Ocre
89388	89388	Sépeaux-Saint Romain	2015	Sépeaux-Saint Romain
89405	89405	Les Hauts de Forterre	2017	Les Hauts de Forterre
89411	89411	Les Vallées de la Vanne	2015	Les Vallées de la Vanne
89441	89441	Vermenton	2015	Vermenton
44087	44087	Machecoul-Saint-Même	2015	Machecoul-Saint-Même
69066	69066	Cours	2015	Cours
01187	01187	Haut Valromey	2015	Haut Valromey
85008	85008	Aubigny-Les Clouzeaux	2015	Aubigny-Les Clouzeaux
72071	72071	Château-du-Loir	2016	Château-du-Loir
37021	37021	Beaumont-Louestault	2017	Beaumont-Louestault
35191	35191	Les Portes du Coglais	2017	Les Portes du Coglais
35069	35069	Chateaugiron	2017	Chateaugiron
54099	54099	Val de Briey	2017	Val de Briey
29076	29076	Milizac-Guipronvel	2017	Milizac-Guipronvel
14371	14371	Livarot-Pays-d'Auge	2015	Livarot-Pays-d'Auge
14143	14143	Caumont-sur-Aure	2017	Caumont-sur-Aure
14098	14098	Thue et Mue	2017	Thue et Mue
62691	62691	Saint-Augustin	2015	Saint-Augustin
14037	14037	Malherbe-sur-Ajon	2015	Malherbe-sur-Ajon
14174	14174	Condé-en-Normandie	2015	Condé-en-Normandie
62471	62471	Inghem	2016	Herbelles
14200	14200	Creully sur Seulles	2017	Creully sur Seulles
49176	49176	Le Lion-d'Angers	2015	Le Lion-d'Angers
14011	14011	Aurseulles	2017	Aurseulles
14061	14061	Souleuvre en Bocage	2015	Souleuvre en Bocage
14014	14014	Colomby-Anguerny	2015	Colomby-Anguerny
14035	14035	Balleroy-sur-Drôme	2015	Balleroy-sur-Drôme
32079	32079	Castelnau d'Auzan Labarrère	2015	Castelnau d'Auzan Labarrère
14431	14431	Mezidon Vallee d Auge	2017	Mezidon Vallee d Auge
14347	14347	Dialan sur Chaine	2017	Dialan sur Chaine
14349	14349	Laize-Clinchamps	2017	Laize-Clinchamps
14355	14355	Ponts sur Seulles	2017	Ponts sur Seulles
14357	14357	Terres de Druance	2017	Terres de Druance
14406	14406	Moulins en Bessin	2017	Moulins en Bessin
14475	14475	Noyers-Missy	2015	Val d Arry
14591	14591	Aure sur Mer	2017	Aure sur Mer
14689	14689	Le Hom	2015	Le Hom
14672	14672	Val de Drome	2017	Val de Drome
14726	14726	Valdalliere	2015	Valdalliere
03168	03168	Meaulne-Vitray	2017	Meaulne-Vitray
14762	14762	Vire Normandie	2015	Vire Normandie
14740	14740	La Vespière-Friardel	2015	La Vespière-Friardel
14712	14712	Saline	2017	Saline
14576	14576	Val-de-Vie	2015	Val-de-Vie
14570	14570	Valorbiquet	2015	Valorbiquet
14527	14527	Belle Vie en Auge	2017	Belle Vie en Auge
14456	14456	Moult-Chicheboville	2017	Moult-Chicheboville
14410	14410	Mery-Bissieres-en-Auge	2017	Mery-Bissieres-en-Auge
14005	14005	Valambray	2017	Valambray
79006	79136	Alloinay	2017	Les Alleuds (rattachée à 79136)
19183	19010	Argentat-sur-Dordogne	2017	Saint-Bazile-de-la-Roche (rattachée à 19010)
19218	19252	Sarroux - Saint Julien	2017	Saint-Julien-près-Bort (rattachée à 19252)
50623	50041	La Hague	2017	Vauville (rattachée à 50041)
50523	50523	Sainte-Mère-Eglise	2015	Sainte-Mère-Eglise
79327	79185	Mougon-Thorigne	2017	Thorigné (rattachée à 79185)
65027	65282	Loudenvielle	2015	Armenteule (rattachée à 65282)
65188	65192	Gavarnie-Gèdre	2015	Gavarnie (rattachée à 65192)
65312	65081	Benque-Molere	2017	Molère (rattachée à 65081)
50363	50363	Moyon Villages	2015	Moyon Villages
79185	79185	Mougon-Thorigne	2017	Mougon-Thorigne
74217	74010	Annecy	2017	Pringy (rattachée à 74010)
74245	74282	Filliere	2017	Saint-Martin-Bellevue (rattachée à 74282)
74084	74167	Val de Chaise	2015	Cons-Sainte-Colombe (rattachée à 74167)
74181	74112	Epagny Metz-Tessy	2015	Metz-Tessy (rattachée à 74112)
74187	74275	Talloires-Montmin	2015	Montmin (rattachée à 74275)
50037	50260	Juvigny les Vallees	2017	La Bazoge (rattachée à 50260)
50325	50431	Remilly Les Marais	2017	Le Mesnil-Vigot (rattachée à 50431)
50119	50431	Remilly Les Marais	2017	Les Champs-de-Losque (rattachée à 50431)
50154	50487	Saint-James	2017	La Croix-Avranchin (rattachée à 50487)
50171	50041	La Hague	2017	Éculleville (rattachée à 50041)
50116	50565	Sartilly-Baie-Bocage	2015	Champcey (rattachée à 50565)
50123	50239	Thèreval	2015	La Chapelle-en-Juger (rattachée à 50239)
50127	50523	Sainte-Mère-Eglise	2015	Chef-du-Pont (rattachée à 50523)
50128	50393	Percy-en-Normandie	2015	Le Chefresne (rattachée à 50393)
50440	50639	Villedieu-les-Poêles-Rouffigny	2015	Rouffigny (rattachée à 50639)
50441	50492	Saint-Jean-d'Elle	2015	Rouxeville (rattachée à 50492)
50557	50090	Buais-Les-Monts	2015	Saint-Symphorien-des-Monts (rattachée à 50090)
50545	50546	Bourgvallées	2015	Saint-Romphaire (rattachée à 50546)
50133	50391	Grandparigny	2015	Chèvreville (rattachée à 50391)
50001	50041	La Hague	2017	Acqueville (rattachée à 50041)
50179	50591	Le Teilleul	2015	Ferrières (rattachée à 50591)
50189	50436	Romagny Fontenay	2015	Fontenay (rattachée à 50436)
50191	50523	Sainte-Mère-Eglise	2015	Foucarville (rattachée à 50523)
50071	50535	Le Parc	2015	Braffais (rattachée à 50535)
50075	50601	Torigny-les-Villes	2015	Brectouville (rattachée à 50601)
50245	50591	Le Teilleul	2015	Heussé (rattachée à 50591)
50250	50400	Picauville	2015	Houtteville (rattachée à 50400)
50329	50391	Grandparigny	2015	Milly (rattachée à 50391)
50339	50388	Orval sur Sienne	2015	Montchaton (rattachée à 50388)
50432	50142	Vicq-sur-Mer	2015	Réthoville (rattachée à 50142)
50602	50129	Cherbourg-en-Cotentin	2015	Tourlaville (rattachée à 50129)
50625	50582	Sourdeval-Vengeons	2015	Vengeons (rattachée à 50582)
50642	50400	Picauville	2015	Vindefontaine (rattachée à 50400)
50043	50260	Juvigny les Vallees	2017	Bellefontaine (rattachée à 50260)
50057	50041	La Hague	2017	Biville (rattachée à 50041)
50080	50099	Carentan les Marais	2017	Brévands (rattachée à 50099)
50337	50487	Saint-James	2017	Montanel (rattachée à 50487)
50134	50363	Moyon Villages	2015	Chevry (rattachée à 50363)
50063	50236	La Haye	2015	Bolleville (rattachée à 50236)
50173	50129	Cherbourg-en-Cotentin	2015	Équeurdreville-Hainneville (rattachée à 50129)
50202	50601	Torigny-les-Villes	2015	Giéville (rattachée à 50601)
50212	50400	Picauville	2015	Gourbesville (rattachée à 50400)
50213	50546	Bourgvallées	2015	Gourfaleur (rattachée à 50546)
50544	50236	La Haye	2015	Saint-Rémy-des-Landes (rattachée à 50236)
50035	50236	La Haye	2015	Baudreville (rattachée à 50236)
50284	50410	Pontorson	2015	Macey (rattachée à 50410)
50287	50546	Bourgvallées	2015	La Mancellière-sur-Vire (rattachée à 50546)
50319	50139	Condé-sur-Vire	2015	Le Mesnil-Raoult (rattachée à 50139)
50343	50236	La Haye	2015	Montgardon (rattachée à 50236)
50355	50565	Sartilly-Baie-Bocage	2015	Montviron (rattachée à 50565)
50381	50359	Mortain-Bocage	2015	Notre-Dame-du-Touchet (rattachée à 50359)
50406	50535	Le Parc	2015	Plomb (rattachée à 50535)
50415	50273	Montsenelle	2015	Prétot-Sainte-Suzanne (rattachée à 50273)
50416	50129	Cherbourg-en-Cotentin	2015	Querqueville (rattachée à 50129)
50434	50565	Sartilly-Baie-Bocage	2015	La Rochelle-Normande (rattachée à 50565)
50497	50273	Montsenelle	2015	Saint-Jores (rattachée à 50273)
50586	50236	La Haye	2015	Surville (rattachée à 50236)
50595	50209	Gonneville-Le Theil	2015	Le Theil (rattachée à 50209)
50644	50484	Saint-Hilaire-du-Harcouët	2015	Virey (rattachée à 50484)
50646	50082	Bricquebec-en-Cotentin	2015	Le Vrétot (rattachée à 50082)
50073	50041	La Hague	2017	Branville-Hague (rattachée à 50041)
50100	50487	Saint-James	2017	Carnet (rattachée à 50487)
50187	50041	La Hague	2017	Flottemanville-Hague (rattachée à 50041)
50323	50260	Juvigny les Vallees	2017	Le Mesnil-Tôve (rattachée à 50260)
50404	50444	Saint-Amand-Villages	2017	Placy-Montaigu (rattachée à 50444)
50611	50041	La Hague	2017	Urville-Nacqueville (rattachée à 50041)
50136	50273	Montsenelle	2015	Coigny (rattachée à 50273)
50153	50400	Picauville	2015	Cretteville (rattachée à 50400)
50640	50487	Saint-James	2017	Villiers-le-Pré (rattachée à 50487)
50494	50359	Mortain-Bocage	2015	Saint-Jean-du-Corail (rattachée à 50359)
50170	50523	Sainte-Mère-Eglise	2015	Écoquenéauville (rattachée à 50523)
50204	50236	La Haye	2015	Glatigny (rattachée à 50236)
50061	50215	Gouville sur Mer	2015	Boisroger (rattachée à 50215)
50114	50115	Le Grippon	2015	Les Chambres (rattachée à 50115)
50249	50099	Carentan les Marais	2015	Houesville (rattachée à 50099)
50254	50591	Le Teilleul	2015	Husson (rattachée à 50591)
50255	50419	Quettreville-sur-Sienne	2015	Hyenville (rattachée à 50419)
50293	50391	Grandparigny	2015	Martigny (rattachée à 50391)
50396	50082	Bricquebec-en-Cotentin	2015	Les Perques (rattachée à 50082)
50414	50492	Saint-Jean-d'Elle	2015	Précorbin (rattachée à 50492)
50418	50082	Bricquebec-en-Cotentin	2015	Quettetot (rattachée à 50082)
50515	50484	Saint-Hilaire-du-Harcouët	2015	Saint-Martin-de-Landelles (rattachée à 50484)
50630	50410	Pontorson	2015	Vessey (rattachée à 50410)
50638	50359	Mortain-Bocage	2015	Villechien (rattachée à 50359)
50125	50260	Juvigny les Vallees	2017	Chasseguey (rattachée à 50260)
50131	50260	Juvigny les Vallees	2017	Chérencé-le-Roussel (rattachée à 50260)
50163	50041	La Hague	2017	Digulleville (rattachée à 50041)
50460	50041	La Hague	2017	Sainte-Croix-Hague (rattachée à 50041)
50180	50592	Tessy Bocage	2015	Fervaches (rattachée à 50592)
50203	50129	Cherbourg-en-Cotentin	2015	La Glacerie (rattachée à 50129)
50211	50142	Vicq-sur-Mer	2015	Gouberville (rattachée à 50142)
50224	50601	Torigny-les-Villes	2015	Guilberville (rattachée à 50601)
50458	50099	Carentan les Marais	2015	Saint-Côme-du-Mont (rattachée à 50099)
50051	50523	Sainte-Mère-Eglise	2015	Beuzeville-au-Plain (rattachée à 50523)
50056	50359	Mortain-Bocage	2015	Bion (rattachée à 50359)
50508	50591	Le Teilleul	2015	Sainte-Marie-du-Bois (rattachée à 50591)
50142	50142	Vicq-sur-Mer	2015	Vicq-sur-Mer
50388	50388	Orval sur Sienne	2015	Orval sur Sienne
19010	19010	Argentat-sur-Dordogne	2017	Argentat-sur-Dordogne
19123	19123	Malemort	2015	Malemort
50041	50041	La Hague	2017	La Hague
50082	50082	Bricquebec-en-Cotentin	2015	Bricquebec-en-Cotentin
50090	50090	Buais-Les-Monts	2015	Buais-Les-Monts
50099	50099	Carentan les Marais	2017	Carentan les Marais
50099	50099	Carentan les Marais	2015	Carentan les Marais
50139	50139	Condé-sur-Vire	2015	Conde-sur-Vire
50139	50139	Conde-sur-Vire	2017	Conde-sur-Vire
50129	50129	Cherbourg-en-Cotentin	2015	Cherbourg-en-Cotentin
50168	50168	Ducey-Les Chéris	2015	Ducey-Les Chéris
50215	50215	Gouville sur Mer	2015	Gouville sur Mer
50236	50236	La Haye	2015	La Haye
50239	50239	Thèreval	2015	Thèreval
50292	50292	Marigny-Le-Lozon	2015	Marigny-Le-Lozon
50260	50260	Juvigny les Vallees	2017	Juvigny les Vallees
50267	50267	Lessay	2015	Lessay
50273	50273	Montsenelle	2015	Montsenelle
50391	50391	Grandparigny	2015	Grandparigny
50359	50359	Mortain-Bocage	2015	Mortain-Bocage
50393	50393	Percy-en-Normandie	2015	Percy-en-Normandie
50400	50400	Picauville	2017	Picauville
50400	50400	Picauville	2015	Picauville
50410	50410	Pontorson	2015	Pontorson
50419	50419	Quettreville-sur-Sienne	2015	Quettreville-sur-Sienne
50431	50431	Remilly Les Marais	2017	Remilly Les Marais
50436	50436	Romagny Fontenay	2015	Romagny Fontenay
50444	50444	Saint-Amand-Villages	2017	Saint-Amand-Villages
50484	50484	Saint-Hilaire-du-Harcouët	2015	Saint-Hilaire-du-Harcouët
50487	50487	Saint-James	2017	Saint-James
50492	50492	Saint-Jean-d'Elle	2015	Saint-Jean-d'Elle
50535	50535	Le Parc	2015	Le Parc
50546	50546	Bourgvallées	2015	Bourgvallées
50564	50564	Terre-et-Marais	2015	Terre-et-Marais
50565	50565	Sartilly-Baie-Bocage	2015	Sartilly-Baie-Bocage
50582	50582	Sourdeval-Vengeons	2015	Sourdeval-Vengeons
50591	50591	Le Teilleul	2015	Le Teilleul
50592	50592	Tessy Bocage	2015	Tessy Bocage
50601	50601	Torigny-les-Villes	2015	Torigny-les-Villes
65081	65081	Benque-Molere	2017	Benque-Molere
65192	65192	Gavarnie-Gèdre	2015	Gavarnie-Gèdre
65282	65282	Loudenvielle	2015	Loudenvielle
74010	74010	Annecy	2017	Annecy
74112	74112	Epagny Metz-Tessy	2015	Epagny Metz-Tessy
74123	74123	Faverges-Seythenex	2015	Faverges-Seythenex
74282	74282	Filliere	2017	Filliere
79013	79013	Argentonnay	2015	Argentonnay
79063	79063	Val en Vignes	2017	Val en Vignes
79136	79136	Alloinay	2017	Alloinay
79280	79280	Saint Maurice Étusson	2015	Saint Maurice Étusson
\.


--
-- PostgreSQL database dump complete
--

