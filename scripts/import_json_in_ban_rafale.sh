# But : importer dans la ban via l'api l'ensemble des fichiers json sur
# tous les départementa
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les json
################################################################################
# ENTREE : les jsons par départements
##############################################################################
# SORTIE : la ban chargée + les fichiers de compte rendu 
#############################################################################
# REMARQUE :
# - si ce n'est pas les variables par defaut penser à exporter les variables
#   DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
# - avant de lancer le traitement, activer l'environnement virtuel python
#   source <xxxx>/bin/activate
##############################################################################

json_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : import_json_in_ban_rafale.sh <JsonPath>"
	exit 1
fi

# Vérification du répertoire
if [ ! -d ${json_path} ] ; then
   echo "ERREUR : le répertoire ${json_path} n'existe pas"
   exit 1
fi

# on boucle par departement
#deps="01 02 03 04 05 07 08 09 10 11 12 13 15 16 17 18 19 2A 2B 21 23 24 25 26 28 30 31 32 34 36 37 39 40 41 42 43 44 45 46 47 48 49 51 52 53 54 55 57 58 59 60 62 63 64 65 66 69 70 71 72 73 74 75 77 79 80 81 82 83 84 86 87 88 89 92 93 94 95 971 972 973 974 975 976"
deps="06 14 22 27 29 33 35 38 50 56 61 67 68 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 975 976"

for dep in ${deps}
do

   # vérification de l'exitence du répertoire	
   if [ ! -d ${json_path}/${dep} ] ; then
      echo "ERREUR : le répertoire ${json_path}/${dep} n'existe pas"
      exit 1
   fi


   /home/bduni/ban/ban-code/donnees-initiales/scripts/import_json_in_ban.sh ${json_path}/${dep} > import${dep}.log

done

echo "Traitement terminé avec succès"
