# Scripts d'import, préparation et export pour l'init BAN

## Liste des tables utilisées

insee_cog_2015		COG 2015 de l'INSEE
dgfip_fantoir		fichier FANTOIR DGFiP

ign_housenumber		points adresses exportés du SGA IGN
ign_group		voies/lieux-dits exportés du SGA IGN

ran_postcode		codes postaux provenant du RAN La Poste
ran_group		voies/lieux-dits provenant du RAN La Poste
ran_housenumber		adresses (non géo) provenant du RAN La Poste

dgfip_noms_cadastre	voies/lieux-dits du cadastre extraits par les scripts BANO (non ODbL)
dgfip_housenumbers	points adresses du cadastre extraits par les scripts BANO (non ODbL)


banodbl			points adresses provenant de la BANv0
banodbl_group		voies/lieux-dits de la BANv0 après traitement pour diffusion ODbL (non ODbL)

aitf_housenumber	points adresse provenant des collectivités au format AITF

abbrev			liste d'abbréviations courantes
libelles		table intermédiaire pour les rapprochements de noms de voies et ld


## Scripts

01_charge_sources.sh : Charge les différents fichiers sources dans les tables postgresql

02_prepare.sql : requêtes SQL préparant les données pour l'export

03_export_json.sql : requêtes SQL d'export des fichiers json destinés à l'init BAN


## Utilisation

```
sh 01_charge_sources.sh
psql -c < 02_prepare.sql
psql -c < 03_export_json.sql
```
