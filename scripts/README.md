# Les programmes contenus dans ce répertoire permettent d'initialiser de la BAN.

## Données en entrée 

- COG : les données sont téléchargées par le programme sur le site de l'INSEE 
- FANTOIR : les données sont téléchargées par le programme sur www.data.gouv.fr
- DGFIP/BANO : 
  - fichier noms_cadastre.csv des noms de voies/lieux-dits 
  - fichier cadastre.csv des adresses 
- La Poste :  
  - fichier ran_postcode.csv des codes postaux
  - fichier ran_group.csv des voies/lieux-dits
  - fichier ran_housenumber.csv des adresses
- IGN : (avec <dep> de 01 à 976 = département)
  - fichier ban.municipality<dep>  des communes
  - fichier ban.postcode<dep> des codes postaux
  - fichier ban.group<dep> des voies/lieux-dits
  - fichier ban.house_number<dep> des points adresses (housenumber + position)
- Divers :
 - le fichier abbre.csv avec le dictionnaire (abbréviation, type de groupes ...)
 - le fichier fusion_commune.sql avec les fusions de commune (insee_new , insee_old ...)



## Règles d'import

## Comment initialiser la BAN

### Le processus d'import est le suivant :
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
