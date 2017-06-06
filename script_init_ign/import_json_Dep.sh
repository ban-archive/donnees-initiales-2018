#!/bin/sh
# But :  importer les 5 json dans la ban par Dep
################################################################################
# ARGUMENT :* $1 : repertoire dans lequel sont les json
#           * $2 : departement à traiter
################################################################################
data_path=$1
dep=$2

if [ $# -ne 2 ]; then
        echo "Usage : sur banenv: import_json_Dep.sh <outPath> <dep>"
        echo "Exemple : sur banenv import_json_Dep.sh /home/ban/travail/initIGN 90"
        exit 1
fi

dbname=ban_init
user=ban


echo "Import des json du département " ${dep}


# ban:init
ban import:init ${data_path}/${dep}_municipality.json
if [ $? -ne 0 ]
then
        echo "Erreur dans l'import du fichier ${dep}_municipality.json "  
        exit 1
fi

ban import:init ${data_path}/${dep}_group.json
if [ $? -ne 0 ]
then
        echo "Erreur dans l'import du fichier json de ${dep}_group.json"
        exit 1
fi

ban import:init ${data_path}/${dep}_postcode.json
if [ $? -ne 0 ]
then
        echo "Erreur dans l'import du fichier json de ${dep}_postcode "
        exit 1
fi

ban import:init ${data_path}/${dep}_housenumber.json
if [ $? -ne 0 ]
then
        echo "Erreur dans l'import du fichier json de ${dep}_housenumber"
        exit 1
fi

ban import:init ${data_path}/${dep}_position.json
if [ $? -ne 0 ]
then
        echo "Erreur dans l'import du fichier json de ${dep}_position "
        exit 1
fi


