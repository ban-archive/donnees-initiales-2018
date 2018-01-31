import sys
import requests
import json
import secret # contient les identifiants de connexion à l'API
import csv
import psycopg2
import psycopg2.extras

api = 'https://api-ban.ign.fr'
auth_token = None

def getAuthToken():
    payload={
        'grant_type': 'client_credentials',
        'client_id': secret.id,
        'client_secret': secret.secret,
        'email': 'bano@openstreetmap.fr'
        }
    (status,token) = call_api('POST','/token/', payload)
    return token['access_token']


def call_api(method, endpoint, payload=None, retry=False):
    # header si on est authentifié
    if auth_token is not None:
        headers={'Authorization':'Bearer '+auth_token}
    else:
        headers={}
    if method == 'GET':
        result = requests.get(api+endpoint, headers=headers)
    elif method == 'POST':
        result = requests.post(api+endpoint, headers=headers, json=payload)
    elif method == 'PUT':
        result = requests.put(api+endpoint, headers=headers, json=payload)
    elif method == 'PATCH':
        result = requests.patch(api+endpoint, headers=headers, json=payload)
    elif method == 'DELETE':
        result = requests.delete(api+endpoint, headers=headers, json=payload)
    if result.status_code == 401 and not retry: # token expiré ?
        getAuthToken()
        print("TOKEN renouvelé")
        return call_api(method, endpoint, payload, True)
    elif result.status_code > 299:
        print(result.status_code, result.text)
        exit
    if result.text != '':
        try:
            return(result.status_code, json.loads(result.text))
        except:
            print(method,endpoint,payload,result.text)
    else:
        return(result.status_code)


# on récupère le token d'authentification pour les appels suivants
auth_token = getAuthToken()

# connexion à la base postgresql locale
conn = psycopg2.connect("dbname=cquest user=cquest", cursor_factory=psycopg2.extras.DictCursor)
cur = conn.cursor()

# recherche des FANTOIR d'une même commune, annulés et remplacés à la même date
# par un autre comportant le même mot directeur encore valide (non annulé)
cur.execute("""SELECT o.code_insee as code_insee, replace(o.fantoir,'_','') as fantoir_old, replace(n.fantoir,'_','') as fantoir_new, trim(format('%s %s', o.nature_voie, o.libelle_voie)) as fantoir_old_name, trim(format('%s %s', n.nature_voie, n.libelle_voie)) as fantoir_new_name, o.date_annul
FROM dgfip_fantoir o
JOIN dgfip_fantoir n ON (o.code_insee=n.code_insee and n.date_annul='0000000' and o.date_annul=n.date_creation and n.libelle_voie ~ o.dernier_mot)
ORDER BY 1,2;""")

groups = cur.fetchall()
print(len(groups),' groupes changés dans FANTOIR')
for group in groups:
            print('%s -> %s' % (group[1], group[2]))
            err = call_api('PUT','/group/fantoir:%s/redirects/fantoir:%s' % (group[2], group[1]))
            if err in [201,404]:
                continue
            print(err, group)
