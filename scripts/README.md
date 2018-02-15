# Initialisation de la BAN

Les programmes contenus dans ce répertoire "scripts" permettent d'initialiser la BAN. Ce readme décrit les données utilisées, puis les grands principes/règles de l'initilisation et enfin comment faire fonctionner les programmes d'initialisation.

## Données en entrée 

Les producteurs de données nous fournissent des données en entrée, les plus récentes possibles:

- COG (INSEE): les données sont téléchargées par le programme sur le site de l'INSEE 
- FANTOIR (DGFiP): les données sont téléchargées par le programme sur www.data.gouv.fr
- DGFiP/BANO : 
  - fichier noms_cadastre.csv des noms de voies/lieux-dits 
  - fichier cadastre.csv des adresses (housenumber + position)
- La Poste :  
  - fichier ran_postcode.csv des codes postaux
  - fichier ran_group.csv des voies/lieux-dits
  - fichier ran_housenumber.csv des adresses
- IGN : (découpage par départements)
  - fichier ban.group.csv des voies/lieux-dits
  - fichier ban.house_number.csv des points adresses (housenumber + position)
- Divers :
 - le fichier abbre.csv avec le dictionnaire (abbréviation, type de groupes ...)
 - le fichier fusion_commune.sql avec les fusions de commune (insee_new , insee_old ...)

## Règles d'import

### Municipality

Ces objets proviennent de l'import du fichier du COG donc d'une seule source.

### Postcode

Ces objets proviennent de l'import du fichier de la Poste donc d'une seule source.
Si un postcode ne pointe pas vers l'insee du cog et pointe vers un insee_old de la table de fusion de commmune, on met préalablement à jour l'insee du postcode.

### Group

Pour Group, nous utilisons 4 sources: les fichiers fantoir de la DGFiP, noms_cadatre.csv de la DGFiP/BANO, ran_group.csv de La Poste et ban.group.csv de l'IGN.
Si un groupe ne pointe pas vers l'insee du cog et pointe vers un insee_old de la table de fusion de commmune, on met préalablement à jour l'insee du groupe.

Les premières étapes de l'initialisation sont les suivantes :
- chargement de tous les groupes du FANTOIR
- chargement de tous les groupes IGN (appariement au préalable avec les groupes fantoir : pour les groupes appariés, on complète l'identifiant ign et on garde le nom IGN (mis en majuscules désaccentuées). On ajoute les groupes non appariés.
- chargement de tous les groupes La Poste (appariement au préalable avec les groupes fantoir/IGN : pour les groupes appariés, on complète l'identifiant La poste et on garde le nom La Poste. On ajoute les groupes non appariés.
- on essaye ensuite d'apparier les noms cadastre (minuscules accentuées capitalisés) après normalistion avec les groupes déjà chargés. Pour les groupes appariés, on conserve les noms du cadastre.


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


Le champ attributes contient la source du nom retenu (dans la clé init_source_name). Exemple : "attributes":{"init_source_name"=>"fantoir"}


On notera que la graphie des noms diffèrent suivant les sources:
- les noms provenant uniquement de l'IGN et le fantoir sont en majuscules déssaccentuées abbrégées.
- les noms fantoir et la poste sont en majuscule déssaccentuées non abbrégées.
- les noms provenant du cadastre sont en minuscules accentuées capitalisées

Le kind des groupes (way ou area) est calculé à partir du nom retenu et de la liste des abbréviations du fichier abbre.csv qui donne le types des groupes en fonction du premier mot du groupe.  
Exemples: RUE, BOULEVARD, AVENUE ont un kind="way"; LOTISSEMENT, ZONE COMMERCIALE, CENTRE ont un kind="area"


L'appariement des groupes entre les différentes sources suit globalement les règles suivantes:
- vérification des appariements en place dans les données IGN : 
    - même noms majuscules (passages en majuscules désaccentuées)
    - même noms courts (passage en majuscules désaccentuées, suppression des articles, abbréviations des types de voies et autres mots clés, normalisation des chiffres ...)
  - même noms courts (restreints au type de voie et au mot directeur)
- même noms majuscules (+ pas d'autres candidats sur la commune)
- même noms courts (+ pas d'autres candidats sur la commune)
- vérification des appariements en place dans les données IGN :
  - même noms courts (au E, S, X final)
  - trigram = 0 sur les noms courts
  - même noms courts au type de voie près et pas d'autres candidats sur la commune
  - trigram < 0.15 sur les noms courts
  - trigram < 0.4 sur les noms courts et pas d'autres candidats sur la commune
  - levenshtein <= 2 sur les noms courts et longueur > 10
- trigram < 0.15 sur les noms courts et pas d'autres candidats sur la commune
- levenshtein <= 2 sur les noms courts et longueur > 10 et pas d'autres candidats sur la commune



### Housenumber

Pour Housenumber, nous utilisons 3 sources: cadastre.csv de la DGFiP/BANO, ran_housenumber.csv de La Poste et ban.house_number<Dep>.csv de l'IGN

Les étapes de l'initialisation sont les suivantes :
- chargement de toutes les données DGFIP/BANO
- ajout des données IGN manquantes (numéro non présents). On complète aussi l'identifiant ign si le hn est déjà présent.
- ajout des données La Poste manquantes (numéro non présents). On complète aussi l'identifiant La Poste si le hn est déjà présent.

Puis des housenumber sans numéro sont créés pour chaque groupe "La Poste" pour stocker le cea du groupe La Poste.

On met ensuite entre le lien entre les hns et les postcodes en utilisant les données de La Poste (dont les lignes 5). Si La Poste ne fournit pas l'info, on va chercher le code postal dans les données IGN.

Le champ attributes (dans la clé "source_init") contient les sources du housenumber. Exemple pour un hn contenu dans les 3 sources : attributes = "source_init"=>"DGFIP|IGN|LAPOSTE"


### Position

Pour Position, nous utilisons 2 sources : cadastre.csv de la DGFiP/BANO et ban.house_numbe.csv de l'IGN.

Toutes les positions des 2 sources sont conservés (sauf les centres communes IGN).

La source est précisée dans les champs :
- source =>  valeurs possibles = "DGFIP/BANO (12/2016)" et "IGN (12/2017)"
- source_kind => valeurs possibles = "dgfip" et "ign"

Toutes les positions DGFIP/BANO sont montées en kind "entrance".

Pour les positions IGN, le champ IGN type_de_localisation est utilisé pour remplir le kind ban suivant les règles suivantes :
"à la plaque" => entrance
"projetée du centre parcelle" => segment
"interpolée" => segment
"A la zone d'adressage" => area
"Au centre commune" => non chargée dans la BAN

## Comment faire fonctionner les programmes d'initialisation

### Généralité sur le processus d'initialisation 
Le processus d'initialisation comprend les étapes suivantes:
- récupération des données utiles (COG, FANTOIR, Codes postaux, DGFIP-BANO, IGN, RAN)
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

Si besoin exporter, les variables d'environnement PGUSER, PGPORT, PGPASSWORD ...

Lancer le script, preparation_base_temp.sh : il importe :
- le fichier des abbréviations dans la table abbrev 
- le fichier des abbréviations de type de voie dans la table abbrev_type_voie 
- le fichier des fusions de communes dans la table fusion_commune
 
### Importation des données dans l'environnement de travail
Les données sont importées dans la base PostgreSQL <basetemp> --> Bien initialiser les variables d'environnement
Lancer les shells :
- import_cog.sh : importe les communes du COG dans la table insee_cog
- import_dgfip_fantoir.sh : importe les groupes fantoir dans la table dgfip_fantoir
- import_dgfip_bano.sh : importe les groupes dgfip bano dans la table dgfip_noms_cadastre et les adresses dans dgfip_housenumbers
- import_ign.sh : importe les données IGN dans les tables ign_municipality, ign_group, ign_housenumber
- import_la_poste.sh : importe les données La Poste dans les tables poste_cp, ran_group, ran_housenumber

### Préparation des données
Lancer le shell preparation.sh. Celui-ci enchaine les fichiers sql suivant :
- preparation_01_generalites.sql : ajoute des champs supplémentaires dans les données initiales et normalisation de certains champs
- preparation_02_libelles.sql : prépare la table des libellés courts des groupes des différentes sources (passage en majuscules désaccentuées, abbréviations, suppression des articles, normalisation des nombres ...)
- preparation_03_app_group.sql : apparie les groupes des différentes sources et rassemble les groupes des différentes sources dans une même table.
- preparation_04_hn_position.sql : apparie et regroupe les hn et positions des différentes sources dans une même table. Supprime les doublons IGN. Met en forme les champs pour la BAN à partir des champs sources (kind, source_init)

### export en json 
Pour chaque département, Lancer le shell export_json.sh <OutputPath> <dep>

### Intégration des jsons dans la ban
Activer le banenv (pour avoir accès aux commandes de l'API).
Pour chaque département, lancer le shell import_json_in_ban.sh <JsonPathDep>
