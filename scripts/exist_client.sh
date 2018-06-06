#/!bin/sh


# Ce fichier renvoie 1 si le client de l'api n'existe pas
#                    0 si il existe
# Une autre valeur en cas d erreur.

# la commande ban auth:listclients de l'api est utilisée

#set -x

# On verifie qu il y a bien un parametre

if [ $# -ne 1 ]
then
    echo "Usage : exist_client.sh <client>"
    exit -1
fi

nomClient=$1

count=`ban auth:listclients | awk '{print " " $2 " "}' | grep " ${nomClient} " | wc -l`

if [ $? -ne 0 ]
then
    echo "La recherche de l existence du client a échoué"
    exit -1
fi

if [ ${count} -eq 1 ]
then
    exit 0
fi

exit 1

