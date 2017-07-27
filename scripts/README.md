# Les programmes contenus dans ce répertoire permettent d'initialiser de la BAN.

## Données en entrée 

- COG : les données sont téléchargées par le programme sur le site de l'INSEE 
- FANTOIR : les données sont téléchargées par le programme sur www.data.gouv.fr
- DGFIP/BANO : 
  - fichier noms_cadastre.csv des noms de voies/lieux-dits 
  - fichier cadastre.csv des adresses (housenumber + position)
- La Poste :  
  - fichier ran_postcode.csv des codes postaux
  - fichier ran_group.csv des voies/lieux-dits
  - fichier ran_housenumber.csv des adresses
- IGN : (avec "<Dep>" de 01 à 976 = département)
  - fichier ban.group"<Dep>".csv des voies/lieux-dits
  - fichier ban.house_number"<dep>".csv des points adresses (housenumber + position)
- Divers :
 - le fichier abbre.csv avec le dictionnaire (abbréviation, type de groupes ...)
 - le fichier fusion_commune.sql avec les fusions de commune (insee_new , insee_old ...)



## Règles d'import

### Municipality et Postcode

Ces classes proviennent d'une seule source chacune: le COG pour Municipality et le ran_postcode.csv pour Postcode.
Les fusions de communes sont actualisés grâce au fichier fusion_commune.sql.

### Group

Pour Group, nous utilisons les fichiers noms_cadatre.csv de la DGFiP, ran_group.csv de La Poste et ban.group<Dep>.csv de l'IGN.

Le fichier abbre.csv permet de désabbrévier les types de voies.

### Housenumber

Pour Housenumber, nous utilisons cadastre.csv de la DGFiP, ran_housenumber.csv de La Poste et ban.house_number<Dep>.csv de l'IGN.

### Position

Pour Poition, nous utilisons cadastre.csv de la DGFiP et ban.house_number<Dep>.csv de l'IGN.

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
