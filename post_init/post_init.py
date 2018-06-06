import requests
import json
from datetime import timedelta
from progressbar import ProgressBar
import re
import csv
import sys


def replace(gr, batch, old_name, new_name):
    if re.match(r"^{}".format(old_name), gr["name"]) is not None:
        batch.append({"method":"PATCH",
            "path":"/group/{}".format(gr["id"]),
            "body":{"name":"{}".format(
                re.sub(r"{}".format(old_name),
                    r"{}".format(new_name),
                    gr["name"]).strip()
                ),
                "version": "{}".format(int(gr["version"])+1)}})
        return True
    return False

def post_init(dep):
    tab=[]
    batch=[]
    muns=[]
    with open('test_replace.csv', newline="") as file:
        rows=csv.reader(file, delimiter=';')
        for row in rows:
            tab.append(row)
    headers = {'Authorization': 'Bearer plop'}
    response_count_mun = requests.get('http://sidt-ban.ign.fr:5959/municipality?&count=1', headers=headers)
    total_mun = response_count_mun.json()["total"]
    for i in range(0, total_mun, 100):
        response_mun = requests.get('http://sidt-ban.ign.fr:5959/municipality?limit=100&offset={}'.format(i), headers=headers)
        collection_mun = response_mun.json()["collection"]
        for mun in collection_mun:
            if re.match(r"^{}".format(dep),mun["insee"]) is not None:
                muns.append(mun["id"])
    bar = ProgressBar(total = len(muns), throttle = timedelta(seconds=1))
    for i in bar(range(0, len(muns))):
        response_count_gr = requests.get('http://sidt-ban.ign.fr:5959/group?municipality={}&count=1'.format(muns[i]), headers=headers)
        total_gr = response_count_gr.json()["total"]
        for j in range(0, total_gr, 100):
            response_gr = requests.get('http://sidt-ban.ign.fr:5959/group?municipality={}&limit=100&offset={}'.format(muns[i],j), headers=headers)
            collection_gr = response_gr.json()["collection"]
            for gr in collection_gr:
                for row in tab:
                    done = replace(gr, batch, row[0],row[1])
                    if done:
                        break
    bar.finish()
    with open("post_init{}.json".format(dep), "w") as f_write:
        json.dump(batch, f_write)
    print("\n"+str(len(batch))+" groups modifies")

post_init(sys.argv[1])
