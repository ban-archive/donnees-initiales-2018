json_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : export_json.sh <JsonPath>"
	exit 1
fi

BinPath=`dirname $0`

# Vérification de l'existence des clients d'init
for client in init_cog init_laposte init_dgfip init_ign init
do
	echo "Test de l'existence du client ${client}"
	${BinPath}/exist_client.sh ${client}
	if [ $? -ne 0 ]
	then
		echo "Le client ${client} n'existe pas ou erreur lors de la recherche de ce client"
		exit 1
	fi
	

done

ban import:init init_cog insee ${json_path}/01_municipalities.json
ban import:init init_laposte laposte ${json_path}/02_postcodes.json
ban import:init init_dgfip dgfip ${json_path}/03_A_groups.json 
ban import:init init_ign ign ${json_path}/03_B_groups.json -vv
ban import:init init_laposte laposte ${json_path}/03_C_groups.json -vv
ban import:init init_dgfip dgfip ${json_path}/03_D_groups.json -vv
ban import:init init admin ${json_path}/04_housenumbers.json
ban import:init init admin ${json_path}/05_housenumbers.json --workers 1
ban import:init init admin ${json_path}/06_housenumbers.json
ban import:init init_dgfip dgfip ${json_path}/07_positions.json
ban import:init init_ign ign ${json_path}/08_positions.json

exit

echo "FIN"
