# Prototype d'initialisation réalisé par l'IGN à partir de ses données en avril 2017

Les programmes fournis dans ce répertoire permettent d'initialiser la BAN à partir des exports csv de la BDUni et du SGA fournis par l'IGN par departements.

## Principes
Les principes sont les suivants :
- import des fichiers csv dans une base PostgreSQL temporaire
- pré-traitement des données PostgreSQL dans la base temporaire
- export des données temporaires en json
- import des json dans la ban

## Etapes/programmes
Les différentes étapes/programmes sont les suivants :
- créer la base PostgreSQL temporaire ban_init et l'utilisateur PostgreSQL ban (ces noms sont paramétrés en dur dans les programmes)
- lancer le shell preparation.sh pour créer la table des abbréviations/types de voies dans la base temporaire
- lancer le shell import_csv_ign.sh pour importer les données csv dans la base PostgreSQL temporaire pour chaque département
- lancer le shell export_json.sh pour pre-traiter et exporter les données au format ban. Liste des principaux traitements effectués :
	- suppression des objets marqués comme détruits
	- désabbréviations des noms de groupes
	- remplissage du champ kind et type d'adressage sur les groupes
	- remplissage du kind et positionning sur les positions
	- export en json
- lancer le shell import_json_Dep.sh pour importer les json précédemment obtenus dans la ban. Cette dernière commande doit être lancée dans l'environnement de l'API de gestion car elle appelle la commande import de l'API

