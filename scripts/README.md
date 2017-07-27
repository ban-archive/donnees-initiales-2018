# Initialisation de la BAN

Les programmes contenus dans ce répertoire "scripts" permettent d'initialiser la BAN. Avant de le faire, expliquons le principe de l'initialisation.

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
- IGN : (avec <dep> de 01 à 976 = département)
  - fichier ban.group<dep>.csv des voies/lieux-dits
  - fichier ban.house_number<dep>.csv des points adresses (housenumber + position)
- Divers :
 - le fichier abbre.csv avec le dictionnaire (abbréviation, type de groupes ...)
 - le fichier fusion_commune.sql avec les fusions de commune (insee_new , insee_old ...)

## Règles d'import

### Municipality

Ces objets proviennent de l'import du fichier du COG donc d'une seule source.

### Postcode

Ces objets proviennent de l'import du fichier de la Poste donc d'une seule source.

### Group

Pour Group, nous utilisons 4 sources: les fichiers fantoir de la DGFiP, noms_cadatre.csv de la DGFiP/BANO, ran_group.csv de La Poste et ban.group.csv de l'IGN.

Les premières étapes de l'initialisation sont les suivantes :
- chargement de tous les groupes du FANTOIR
- ajout des groupes IGN non trouvés (en utilisant l'identifiant FANTOIR)
- ajout des groupes Poste non trouvés (en utilisant l'identifiant Poste contenu dans les données IGN)
- Remplacement des noms de groupes par les noms DGFIP/BANO (clé d'appariement = identifiant FANTOIR) (fait sur certains départements mais tous)

A ce stade, les noms des groupes sont issus majoritairement du fantoir et sont donc en majuscules sans accent.
Les groupes provenant uniquement de l'IGN sont souvent en minuscules accentuées.
Les groupes appariés avec les données DGFIP/BANO sont en minuscules accentuées capitaliseés (fait sur certains départements mais tous)

Dans une seconde étape, on calcule le kind des groupes (way ou area). Pour cela, on utilise le fichier abbre.csv qui donne le types des groupes en fonction du premier mot du groupe.  
Exemples: RUE, BOULEVARD, AVENUE ont un kind="way"; LOTISSEMENT, ZONE COMMERCIALE, CENTRE ont un kind="area"


### Housenumber

Pour Housenumber, nous utilisons 3 sources: cadastre.csv de la DGFiP/BANO, ran_housenumber.csv de La Poste et ban.house_number<Dep>.csv de l'IGN

Les étapes de l'initialisation sont les suivantes :
- chargement de toutes les données DGFIP/BANO
- ajout des données IGN manquantes (utilisation du CIA = concaténation du fantoir, du numéro et de l'indice de répétition)
- ajout des données La Poste manquantes (utilisation du CIA et de l'identifiant La Poste contenu dans les données IGN)

Puis des housenumber sans numéro sont créés pour chaque groupe "La Poste" pour stocker le cea.


### Position

Pour Position, nous utilisons 2 sources : cadastre.csv de la DGFiP/BANO et ban.house_numbe.csv de l'IGN.

Au préalable, on notera que les positions provenant de l'IGN ont un champ indiquant leur qualité géométrique qui peut prendre les valeurs suivantes:
- "à la plaque"
- "projetée du centre parcelle"
- "interpolée"
- "A la zone d'adressage"
- "Au centre commune"

La première étape de l'inialisation consiste à sélectionner ou non les positions des différentes sources. Les règles sont les suivantes :
- Les positions IGN "Au centre commune" ne sont pas retenues.
- Les positions IGN "à la plaque" sont systèmatiquement retenues.
- Les positions IGN "projetée du centre parcelle", "interpolée" et "A la zone d'adressage" sont retenues pour un housenumber uniquement si il n'y a pas de positions DFIPG/BANO pour ce housenumber. 
- Les positions DFIPG/BANO sont donc retenues pour un housenumber s'il n'y a pas de position IGN "à la plaque" pour ce housenumber ou celle-ci est située à plus de 5 mètres.

Un housenumber peut donc avoir 0, 1 ou n positions si l'on se réfère à ces règles.

Par exemple :
- O position s'il n'y a pas de position pour ce housenumber dans les données IGN et DGFIP/BANO ou s'il y a uniquement une position IGN "au centre commune"
- une position si une seule source référence ce hn ou si la position IGN "à la plaque" et DGFIP/BANO sont distances de moins de 5 mètres ...
- plusieurs positions si c'est aussi le cas dans les 2 sources ou si la position IGN "à la plaque" et DGFIP/BANO sont distances de plus de 5 mètres ...

Les positions provenant de DGFIP/BANO sont toutes complétées avec kind "entrance", tandis pour les positions provenant de l'IGN, les règles suivantes sont appliquées : 
- les types de localisation des adresses IGN = "à la plaque" deviennent des kind = "entrance"
- les types de localisation des adresses IGN = "projetée du centre parcelle" deviennent des kind = "segment" avec positioning = "projection"
- les types de localisation des adresses IGN = "interpolée" deviennent des kind = "segment" avec positioning = "interpolation"
- les types de localisation des adresses IGN = "A la zone d'adressage" deviennent des kind = "area"

Concernant le positioning, il est toujours à positioning="other" sauf normalement (point en cours de correction):
- les types de localisation des adresses IGN = "projetée du centre parcelle" deviennent positioning = "projection"
- les types de localisation des adresses IGN = "interpolée" deviennent  positioning = "interpolation"


### Note sur les fusions de communes

Les sources utilisées dans l'initialisation sont d'actualité différentes et toutes n'ont pas impactées les fusions de communes de l'année dernière.

Dans l'initialisation de fin juin 2017, le programme n'a pas tenu compte de cette hétérogéniété et cela est source d'incohérences et de données non chargées dans la BAN.

Dans la future initialisation, le script prendra en compte cette hétérogéniété notamment en utilisant la liste des fusions de commune et la correspondance entre les anciens codes insee et les nouveaux. Il conservera aussi le nom des anciennes communes dans les groupes secondaires.


## Comment utiliser les programmes d'inialisation de la BAN

### Généralité sur le processus d'import 
Le processus d'import de données se compose de 5 étapes:
- récupération des données utiles (COG, FANTOIR, Codes postaux, DGFIP-BANO, IGN, RAN)
- préparation de l'environnement
- importation de ces données dans une base temporaire
- préparation sql de ces données 
- export en json
- import des json dans la ban

### Préparation de l'environnement
Créer la base temporaire <base_temp>

Dans <base_temp> :
- create extension postgis;
- create extension hstore;
- create extension unaccent;

Exporter les variables d'environnement :
- export PGDATABASE=<base_temp>

Si besoin exporter, les variables d'environnement PGUSER, PGPORT, PGPASSWORD ...

Lancer le script, preparation_base_temp.sh : il importe :
- le fichier des abbréviations dans la table abbrev 
- le fichier des fusions de communes dans la table fusion_commune
 
### Importation des données dans la base temporaire
Les données sont importées dans la base PostgreSQL <basetemp> --> Bien initialiser les variables d'environnement
Lancer les shells :
- import_cog.sh : importe les communes du COG dans la table insee_cog
- import_dgfip_fantoir.sh : importe les groupes fantoir dans la table dgfip_fantoir
- import_dgfip_bano.sh : importe les groupes dgfip bano dans la table dgfip_noms_cadastre et les adresses dans dgfip_housenumbers
- import_ign.sh : importe les données IGN dans les tables ign_municipality, ign_group, ign_housenumber
- import_la_poste.sh : importe les données La Poste dans les tables poste_cp, ran_group, ran_housenumber

### Préparation des données et export en json
Lancer le shell export_json.sh

### Intégration des jsons dans la ban
Dans un répertoire qui a accès aux commandes de l'API (avec le banenv activé), lancer le shell import_json_in_ban.sh
