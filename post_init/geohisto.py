import sys
import requests
import json
import secret # contient les identifiants de connexion à l'API
import csv

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
        return(result.status_code, json.loads(result.text))
    else:
        return(result.status_code)


# on récupère le token d'authentification pour les appels suivants
auth_token = getAuthToken()

with open('geohisto/exports/communes/communes.csv') as geohisto:
    communes = csv.DictReader(geohisto)
    for commune in communes:
        if commune['successors'] != '':
            nouvel_insee = commune['successors'][11:16]
            if nouvel_insee != commune['insee_code']:
                err = call_api('PUT','/municipality/insee:%s/redirects/insee:%s' % (nouvel_insee, commune['insee_code']))
                if err in [201,404]:
                    continue
                print(err, commune['insee_code'], nouvel_insee)
