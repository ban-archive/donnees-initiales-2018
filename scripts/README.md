# Initialisation de la BAN

Les programmes contenus dans ce répertoire "scripts" permettent d'initialiser la BAN. Avant de le faire, expliquons le principe de l'initialisation.

## Données en entrée 

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

### Municipality et Postcode

Ces classes proviennent d'une seule source chacune: le COG pour Municipality et le ran_postcode.csv pour Postcode, extraits par départements.
Les fusions de communes sont actualisés grâce au fichier fusion_commune.sql.

### Group

Pour Group, nous utilisons 4 sources: les fichiers fantoir de la DGFiP, noms_cadatre.csv de la DGFiP/BANO, ran_group.csv de La Poste et ban.group<Dep>.csv de l'IGN, extraits par départements.
On utilise l'appariement de l'IGN entre les group, en utilisant l'identifiant fantoir. Si les group ne sont pas retrouvés dans les groups IGN, on les ajoute.
Les noms conservés sont ceux du fantoir.
Les anciens groups issus d'une fusion de communes sont intégrés dans un group secondaire

Le fichier abbre.csv permet enfin de désabbrévier les types de voies.

### Housenumber

Pour Housenumber, la classe sémantique d'adresses, nous utilisons 3 sources: cadastre.csv de la DGFiP/BANO, ran_housenumber.csv de La Poste et ban.house_number<Dep>.csv de l'IGN, extraits par départements.
Les housenumbers sont appariés en utilisant les codes CIA des adresses et après suppression des doublons (cas des piles d'adresses IGN). Si les housenumber ne sont pas retrouvés, on les ajoute. 
Des housenumber null sont créés pour stocker les group de La Poste qui ne portent pas d'adresses.


### Position

Cette classe est géométrique. Il faut donc des sources localisant les adresses. Seules 2 sources sont donc utilisées: cadastre.csv de la DGFiP/BANO et ban.house_number<Dep>.csv de l'IGN, extraits par départements.
On conserve les 2 positions sur une adresse:
- si elles existent toutes les deux
- sinon si elles sont toutes les deux au même endroit et de même kind (= type d'entrée)
- sinon si elles sont distantes de plus de 5 mètres
On ne garde qu'une seule adresse:
- si d'après les sources, il n'existe qu'une seule position sur l'adresse
- si une des deux positions est de kind Entrance, et l'autre d'un autre kind (Segment, Interpolated...), ce qui est considéré comme moins précis => on ne garde que la position de kind Entrance
- si elles sont de même type et à moins de 5 mètres.
Donc il existe un ordre dans les kind de position: Entrance > autres types.
On estime que les positions BANO sont toutes de kind Entrance.
Les kind des positions IGN sont fournies:
- les types de localisation des adresses IGN = "à la plaque" deviennent des kind = "Entrance"
- 

## Comment initialiser la BAN

### Processus d'import 
Il se compose de 5 étapes:
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
 
### Importation des données
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
