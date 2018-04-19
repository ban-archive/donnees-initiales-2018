# Initialisation de la BAN

Les programmes contenus dans ce répertoire "scripts" permettent d'initialiser la BAN. Ce readme décrit les données utilisées, puis les grands principes/règles de l'initilisation et enfin comment faire fonctionner les programmes d'initialisation.

## Données en entrée 

Ces données sont:

- COG (INSEE 2017): les données sont téléchargées par le programme sur le site de l'INSEE. 
- FANTOIR (DGFIP janvier 2018): les données sont téléchargées par le programme sur www.data.gouv.fr
- DGFiP/Etalab (mars 2018):  adresses-dgfip-etalab-full.csv 
- La Poste (mars 2018): fichiers hexavia et hexacle. Ces fichiers doivent être transformés en ran_postcode.csv, ran_group.csv et ran_housenumber.csv. Pour cela, on utilisera le script hexa_to_csv.py
- IGN (mars 2018): (découpage par départements)
  - fichier ban.group.csv des voies/lieux-dits
  - fichier ban.house_number.csv des points adresses (housenumber + position)
- Divers :
 - le fichier abbre.sql avec les abbréviations les plus courantes, reggex comprise
 - fichier abbrev_type_voie.csv avec les abbréviations des types de voie. Ce fichier précise aussi si le type est "way" ou "area"
 - le fichier fusion_commune.sql avec les fusions de commune (insee_new , insee_old ...)

## Règles d'import

### Municipality

Ces objets proviennent de l'import du fichier du COG donc d'une seule source. 

### Postcode

Ces objets proviennent de l'import du fichier de la Poste donc d'une seule source.
Si un postcode ne pointe pas vers l'insee du COG et pointe vers un insee_old de la table de fusion de commmune, on met préalablement à jour l'insee du postcode.

### Group

Pour Group, nous utilisons 4 sources: les fichiers fantoir de la DGFiP, noms_cadastre.csv de la DGFiP/Etalab, ran_group.csv de La Poste et ban.group.csv de l'IGN.
Si un groupe ne pointe pas vers l'insee du COG et pointe vers un insee_old de la table de fusion de commmune, on met préalablement à jour l'insee du groupe.

Les premières étapes de l'initialisation sont les suivantes :
- chargement de tous les groupes du FANTOIR
- chargement de tous les groupes IGN (appariement au préalable avec les groupes fantoir : pour les groupes appariés, on complète l'identifiant IGN et on garde le nom IGN (mis en majuscules désaccentuées)). On ajoute les groupes non appariés.
- chargement de tous les groupes La Poste (appariement au préalable avec les groupes fantoir/IGN : pour les groupes appariés, on complète l'identifiant La Poste et on garde le nom La Poste. On ajoute les groupes non appariés).
- on essaye ensuite d'apparier les noms du cadastre (minuscules accentuées capitalisés) après normalisation des libellés avec les groupes déjà chargés. Pour les groupes appariés, on conserve les noms du cadastre.


Le nom conservé sur les groupes appariés est par ordre de priorité décroissante :
- nom du cadastre
- le libellé de La Poste
- le nom IGN
- le nom fantoir


Les données sont versionnées : c'est à dire que si un groupe est présent dans les 4 sources et que l'appariement s'est bien fait, il y aura 4 versions du groupe:
- version 1 = groupe fantoir
- version 2 = groupe IGN
- version 3 = groupe La Poste
- version 4 (version courante) = groupe nom cadastre.


Le champ attributes contient la source du nom retenu (dans la clé source_init_name). Exemple : "attributes":{"source_init_name"=>"FANTOIR"}


On notera que la graphie des noms diffère suivant les sources:
- les noms provenant uniquement de l'IGN et le fantoir sont en général en majuscules désaccentuées abrégées.
- les noms La Poste sont en majuscules désaccentuées non abrégées.
- les noms provenant du cadastre sont en minuscules accentuées capitalisées.

Le kind des groupes (way ou area) est calculé à partir du nom retenu et de la liste des abbréviations du fichier abbre_type_voie.csv qui donne le types des groupes en fonction du premier mot du groupe.  
Exemples: RUE, BOULEVARD, AVENUE ont un kind="way"; LOTISSEMENT, ZONE COMMERCIALE, CENTRE ont un kind="area"


L'appariement des groupes entre les différentes sources suit les règles suivantes:
- vérification des appariements en place dans les données IGN : 
    - même noms majuscules (passages en majuscules désaccentuées)
    - même noms courts (passage en majuscules désaccentuées, suppression des articles, abbréviations des types de voies et autres mots clés, normalisation des chiffres ...)
    - même noms courts (restreints au type de voie et au mot directeur)
- même noms majuscules (+ pas d'autres candidats sur la commune)
- même noms courts (+ pas d'autres candidats sur la commune)
- vérification des appariements en place dans les données IGN :
  - même noms courts (au E, S, X final près)
  - trigram = 0 sur les noms courts
  - même noms courts au type de voie près et pas d'autres candidats sur la commune
  - trigram < 0.15 sur les noms courts
  - trigram < 0.4 sur les noms courts et pas d'autres candidats sur la commune
  - levenshtein <= 2 sur les noms courts et longueur > 10
  - même nom courts (après concaténation avec le nom de commune sur l'une des 2 sources)
  - même nom courts (ign,fantoir) (après concaténation de NORD, SUD, EST ou OUEST sur la source IGN) 
- trigram < 0.15 sur les noms courts et pas d'autres candidats sur la commune
- levenshtein <= 2 sur les noms courts et longueur > 10 et pas d'autres candidats sur la commune




### Housenumber

Pour Housenumber, nous utilisons 3 sources: cadastre.csv de la DGFiP/Etalab, ran_housenumber.csv de La Poste et ban.house_number.csv de l'IGN.

Les étapes de l'initialisation sont les suivantes :
- chargement de toutes les données DGFIP/Etalab
- ajout des données IGN manquantes (numéro non présents). On complète aussi l'identifiant ign si le hn est déjà présent.
- ajout des données La Poste manquantes (numéro non présents). On complète aussi l'identifiant La Poste si le hn est déjà présent.

Puis des housenumber sans numéro sont créés pour chaque groupe "La Poste" pour stocker le cea du groupe La Poste.

On met ensuite entre le lien entre les hns et les postcodes en utilisant les données de La Poste (dont les lignes 5). Si La Poste ne fournit pas l'info, on va chercher le code postal dans les données IGN.

Le champ attributes (dans la clé "source_init") contient les sources du housenumber. Exemple pour un hn contenu dans les 3 sources : attributes = "source_init"=>"DGFIP|IGN|LAPOSTE"


### Position

Pour Position, nous utilisons 2 sources : cadastre.csv de la DGFiP/Etalab et ban.house_number.csv de l'IGN.

Toutes les positions des 2 sources sont conservées (sauf les centres communes IGN).

La source est précisée dans les champs suivants :
- source =>  valeurs possibles = "DGFIP/ETALAB (2018)" et "IGN (2018)"
- source_kind => valeurs possibles = "dgfip" et "ign"

Toutes les positions DGFIP/ETALAB sont montées en kind "entrance".

Pour les positions IGN, le champ IGN type_de_localisation est utilisé pour remplir le kind ban suivant les règles suivantes :
"à la plaque" => entrance
"projetée du centre parcelle" => segment
"interpolée" => segment
"A la zone d'adressage" => area
"Au centre commune" => non chargée dans la BAN

## Comment faire fonctionner les programmes d'initialisation

### Environnement / Machine
Pour la dernière phase (import json dans la ban)
- la base PG ban et l'instance de l'API doivent être sur la même machine pour des raisons de perfomances
- prendre une machine avec au moins 20 Go de Ram et 8 coeurs

### Généralité sur le processus d'initialisation 
Le processus d'initialisation comprend les étapes suivantes:
- récupération des données utiles (COG, FANTOIR, Codes postaux, DGFIP/ETALAB, IGN, RAN)
- préparation de l'environnement de travail
- importation de ces données dans l'environnement de travail
- préparation sql de ces données 
- export en json
- import des json dans la ban

### Préparation de l'environnement de travail
Créer la base temporaire <base_temp>

Dans <base_temp> :
- create extension postgis;
- create extension hstore;
- create extension unaccent;
- create extension fuzzystrmatch;
- create extension pg_trgm;

Exporter les variables d'environnement :
- export PGDATABASE=<base_temp>

Si besoin exporter les variables d'environnement PGUSER, PGPORT, PGPASSWORD ...

Lancer le script, preparation_base_temp.sh : il importe :
- le fichier des abbréviations dans la table abbrev 
- le fichier des abbréviations de type de voie dans la table abbrev_type_voie 
- le fichier des fusions de communes dans la table fusion_commune
 
### Importation des données dans l'environnement de travail
Les données sont importées dans la base PostgreSQL <basetemp> --> Bien initialiser les variables d'environnement
Lancer les shells :
- import_cog.sh : importe les communes du COG dans la table insee_cog
- import_dgfip_fantoir.sh : importe les groupes fantoir dans la table dgfip_fantoir
- import_dgfip_etalab.sh : importe les groupes dgfip etalab dans la table dgfip_noms_cadastre et les adresses dans dgfip_housenumbers
- import_ign.sh : importe les données IGN dans les tables ign_municipality, ign_group, ign_housenumber
- import_la_poste.sh : importe les données La Poste dans les tables poste_cp, ran_group, ran_housenumber

### Préparation des données
Lancer le shell preparation.sh (compter environ 2-3 h de traitement). Celui-ci ajoute des champs et normalise/corrige les données initiales.
Il enchaine les fichiers sql suivant :
- preparation_01_municipality_cp_group.sql : traitement des municipalities, groupes et codes postaux
- preparation_02_libelles.sql : prépare la table des libellés courts des groupes des différentes sources (passage en majuscules désaccentuées, abbréviations, suppression des articles, normalisation des nombres ...)
- preparation_03_hn_position.sql : traitement des hns et positions. Supprime les doublons IGN. Met en forme les champs pour la BAN à partir des champs sources (kind, source_init)

On peut aussi lancer à la main chaque fichier sql. On peut relancer le fichier n plusieurs fois. Il faut alors relancer le n+1, n +2 ...

### Finalisation des données
Cette partie consiste au regroupement/appariement des données des différentes sources. Compter environ 2-3 heures de traitement (sans compter la phase interactive)
- Se placer dans un répertoire temporaire de travail xxx
- finalisation_01_app_group_ign.sh xxx 0 0 : création de la table des appariements interactifs ign-fantoir. 
 Remarque : si vous avez un fichier d'appariement resultant de l'appariement interactif ign_group_non_app_with_fantoir_app.csv, placer ce fichier dans xxx et lancer plutôt finalisation_01_app_group_ign.sh xxx 1 0. 
- psql -f finalisation_00_app_group_ign.sql : appariement automatique des groupes fantoir -ign
- Eventuellement traitement interactif des appariements ign-fantoir : 
	- récupérer le fichier xxx/ign_group_non_app_with_fantoir.csv. 
	- Renommer le ign_group_non_app_with_fantoir_app.csv. 
	- L'ouvrir sous un tableur (attention à importer des différentes colonnes en texte). 
	- Mettre en place les appariements jugés sûrs en mettant 1 dans la colonne app. 
	- Replacer le fichier dans xxx
	- l'importer dans les données déjà appariées : finalisation_01_app_group_ign.sh xxx 0 1
- Finalisation_02_app_group_laposte.sql : appariement groupes la poste, appariement nom cadastre et mise en forme de la table group_fnal qui regroupe tous les groupes appariés ou non des différentes sources 
- Finalisation_03_hn_position.sql : appariement/regroupement des hns et positions des différentes sources

### Export des anomalies 
Lancer export_anomalies.sh OutPath. 
Ceci génère les fichiers d'anomalies suivants dans OutPath:
- anomalies_cp_insee.csv: incohérences insee/cp/l5. Le hn BAN n'a pas pu être raccroché à un cp (en général souci d'insee ou de ligne 5)

### Export en json 
Lancer le shell export_json_rafale.sh qui exporte par département les données préalablement préparées en json (compter environ 5-6 h de traitement).  
Vous pouvez utiliser export_json.sh pour exporter un seul département.

### Préparation de la base ban
Créer la base ban tel que décrit dans https://github.com/BaseAdresseNationale/api-gestion
Supprimer les indexes inutiles psql -d ban -f drop_index.sql
Créer les clients d'init avec la commande ban::createclient : init_cog init_laposte init_dgfip init_ign init

### Intégration des jsons dans la ban
Activer le banenv (pour avoir accès aux commandes de l'API).
Lancer le shell import_json_in_ban_rafale.sh pour importer tous les jsons départementaux dans la BAN.
Pour charger uniquement un département lancé : import_json_in_ban.sh.
