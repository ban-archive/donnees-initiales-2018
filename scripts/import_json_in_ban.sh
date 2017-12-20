json_path=$1

if [ $# -ne 1 ]; then
        echo "Usage : export_json.sh <JsonPath>"
	exit 1
fi

ban import:init ${json_path}/01_municipalities.json
ban import:init ${json_path}/02_postcodes.json
ban import:init ${json_path}/03_A_groups.json 
ban import:init ${json_path}/03_B_groups.json
ban import:init ${json_path}/03_C_groups.json
ban import:init ${json_path}/03_D_groups.json
ban import:init ${json_path}/04_housenumbers.json
ban import:init ${json_path}/05_housenumbers.json --workers 1
ban import:init ${json_path}/06_housenumbers.json
ban import:init ${json_path}/07_positions.json
ban import:init ${json_path}/08_positions.json

exit

echo "FIN"
