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

Ces données sont déjà formatées en fonction du modèle de données BAN. 

Voir avec les producteurs de données pour plus de détail sur ces données.


## Règles d'import

### Municipality et Postcode

Ces classes proviennent d'une seule source chacune: le COG pour Municipality et le postocode de La Postepour Postcode, extraits par départements.


### Group

Pour Group, nous utilisons 4 sources: les fichiers fantoir de la DGFiP, noms_cadatre.csv de la DGFiP/BANO, ran_group.csv de La Poste et ban.group<dep>.csv de l'IGN, extraits par départements.

En entrée, on prend tous les groups du fantoir qu'on compare avec
1 - les groups de la DGFiP/BANO par l'identifiant fantoir. S'il y a appariement, le nom du group est celui de la DGFiP/BANO: minuscule, accentué et capitalisé. Sinon, on ajoute le group DGFiP/BANO manquant et le group fantoir conserve son nom en majuscule.

2 - les groups IGN et La Poste par le lien d'appariement de group issu de l'IGN. Les groups manquants sont ajoutés. On conserve de toute façon le nom du group fantoir et/ou l'IGN/La Poste en majuscule.

Dans une seconde étape, on calcule le kind des groups (type de group, soit way, soit area). Pour cela, on utilise le fichier abbre.csv donne le types de voies et le type de regroupements. Ce fichier permet également de désabbrévier les types de groupes

Exemples: RUE, BOULEVARD, AVENUE ont un kind="way"; LOTISSEMENT, ZONE COMMERCIALE, CENTRE ont un kind="area"



### Housenumber

Pour Housenumber, la classe sémantique d'adresses, nous utilisons 3 sources: cadastre.csv de la DGFiP/BANO, ran_housenumber.csv de La Poste et ban.house_number<Dep>.csv de l'IGN, extraits par départements.

Ici, la source principale est IGN. Nous conservons donc tous les housenumbers IGN, dont on étudie l'appariement avec les données DGFiP/BANO et La Poste par les codes CIA et les identifiants de La Poste (lien d'appariement de l'IGN). Si les housenumber ne sont pas retrouvés, on les ajoute.

Des housenumber null sont créés pour stocker les groups de La Poste qui ne portent pas d'adresses.


### Position

Cette classe est géométrique. Il faut donc des sources localisant les adresses. Seules 2 sources sont donc utilisées: cadastre.csv de la DGFiP/BANO et ban.house_number<Dep>.csv de l'IGN, extraits par départements.

On calcule d'abord les attributs des positions, notamment le kind, de chacune des sources.
On estime que les positions BANO sont toutes de kind "entrance", tandis que les kind des positions IGN sont fournis:
- les types de localisation des adresses IGN = "à la plaque" deviennent des kind = "entrance"
- les types de localisation des adresses IGN = "projetée du centre parcelle" deviennent des kind = "segment" avec positioning = "projection"
- les types de localisation des adresses IGN = "interpolée" deviennent des kind = "segment" avec positioning = "interpolation"
- les types de localisation des adresses IGN = "A la zone d'adressage" deviennent des kind = "area"
Notez qu'il n'y a pas de position en cas de types de localisation des adresses IGN = "Au centre commune". Dans ce cas, il y a seulement des Housenumbers.

(voir les spécifications des données IGN)

Concernant le positioning, il est toujours à positioning="other" sauf:
- les types de localisation des adresses IGN = "projetée du centre parcelle" deviennent positioning = "projection"
- les types de localisation des adresses IGN = "interpolée" deviennent  positioning = "interpolation"


La comparaison des positions des sources consiste ensuite à rapprocher ou non les sources.

Il y a 0, 1 ou 2 positions par housenumber.

On conserve les 2 positions sur une adresse:
- si elles existent toutes les deux
- sinon si elles sont toutes les deux au même endroit et de même kind (= type d'entrée)
- sinon si elles sont distantes de plus de 5 mètres

On ne garde qu'une seule adresse:
- si d'après les sources, il n'existe qu'une seule position sur l'adresse
- sinon si une des deux positions est de kind Entrance, et l'autre d'un autre kind (Segment, Interpolated...), ce qui est considéré comme moins précis => on ne garde que la position de kind Entrance
- sinon si elles sont de même type et à moins de 5 mètres.
Donc il existe un ordre dans les kind de position: Entrance > autres types.

Il n'y a aucune position si le housenumber ne provient ni de la DGFiP/BANO, ni de l'IGN.

### Cas des fusions de communes

Dans l'initialisation de fin juin 2017, nous n'avons pas réalisé de fusion de communes.

Dans la future initialisation, le script consistera à conserver le nom des anciennes communes dans des groupes secondaires.


## Comment initialiser la BAN

### Processus d'import 
Le processus d'import de données se compose de 5 étapes:
- récupération des données utiles (COG, FANTOIR, Codes postaux, DGFIP-BANO, IGN, RAN)
- importation de ces données dans une base temporaire
- préparation sql de ces données 
- export en json
- import des json dans la ban

### Création de la base temporaire
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
 
### Import des données dans des tables PG
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
