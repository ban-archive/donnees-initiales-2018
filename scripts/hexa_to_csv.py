# coding: utf-8

import csv
import sys
import os
import codecs
import csv
import progressbar

if __name__ == "__main__":
    comment='''
    Usage : hexa_to_csv.py <chemin hexa>
    Remarques : 
        - les fichiers hexavia (hsv7aaaa.txt) et hexacle (hsw4aaaa.txt) doivent se trouver à l'emplacement <chemin hexa>
        - les fichiers en sortie sont générés d'où a été lancé le programme. Ces fichiers sont :
            - ran_group.csv (fichier des groupes)
            - ran_housenumber.csv (fichier des housenumbers)
            - ran_localite.csv (fichier des localités)
            - ran_voie_synonyme.csv (fichier des voies synonymes) 
    '''

    try:
        chemin = sys.argv[1]
    except:
        print (comment)
        sys.exit()

    encoding='''cp1252'''

    # Vérification de l'existence des fichiers hexa
    if not os.path.isdir(chemin):
        print('Erreur : le répertoire ' + chemin + ' n\'existe pas')
        sys.exit()

    hexaviaFile = chemin + '/hsv7aaaa.txt';
    if not os.path.isfile(hexaviaFile):
        print('Erreur : le fichier ' + hexaviaFile + ' n\'existe pas')
        sys.exit()

    hexacleFile = chemin + '/hsw4aaaa.txt';
    if not os.path.isfile(hexacleFile):
        print('Erreur : le fichier ' + hexacleFile + ' n\'existe pas')
        sys.exit()

    # Ouverture des 3 fichiers en écriture (voie, voie synomyne et postcode) 
    csvPostCode = csv.writer(
                open('ran_postcode.csv', 'w'),
                delimiter=';',
                lineterminator='\n'
    )
    csvPostCode.writerow(['co_insee','lb_l5_nn','co_insee_anc','co_postal','lb_l6'])

    csvGroup = csv.writer(
                open('ran_group.csv', 'w'),
                delimiter=';',
                lineterminator='\n'
    )
    csvGroup.writerow(['co_insee','co_voie','co_postal','lb_type_voie','lb_voie','cea','lb_l5','co_insee_l5'])

    csvHn = csv.writer(
                open('ran_housenumber.csv', 'w'),
                delimiter=';',
                lineterminator='\n'
    )
    csvHn.writerow(['co_insee','co_voie','co_postal','no_voie','lb_ext','co_cea'])


    # Dictionnaire pour stocker en RAM les localités -> utile pour compléter certains champs des voies
    localities = {}

    # Dictionnaire pour stocker en RAM l'association matricule voie -> cea voie  (lue depuis le fichier des adresses sur les lignes sans numéro)
    ceaVoie = {}

    # Dictionnaire pour stocker en RAM l'association matricule voie -> insee, code postal
    inseeVoie = {}

    # Decodage des codes postaux (localités) dans le fichier hexavia
    print('Decodage des localités du fichier hexavia');
    numLinesHexavia = sum(1 for line in codecs.open(hexaviaFile,"r",encoding=encoding))
    bar = progressbar.ProgressBar(maxval=numLinesHexavia).start()
    count = 0
    with codecs.open(hexaviaFile,"r",encoding=encoding) as f:
        next(f)
        for line in f:
            count += 1
            bar.update(count)
            token = line[0:1]

            if (token == 'L'):

                # Stockage de l'objet localite en RAM
                co_locality = line[1:7].strip();
                locality = {}
                locality['co_insee'] = line[7:12].strip()
                locality['lb_l5_nn'] = line[72:110].strip()
                locality['co_insee_anc'] = line[148:153].strip()
                locality['co_postal'] = line[111:116].strip()
                locality['lb_l6'] = line[116:148].strip()
                localities[co_locality] = locality;

                # Ecriture de l'objet dans le fichier des codes postaux
                csvPostCode.writerow([locality['co_insee'],locality['lb_l5_nn'],locality['co_insee_anc'],locality['co_postal'],locality['lb_l6']])
    bar.finish()

    # Stockage du lien entre matricule voie et commune/code postal
    print('Recherche du lien entre matricule voie et commune/code postal');
    bar = progressbar.ProgressBar(maxval=numLinesHexavia).start()
    count = 0
    with codecs.open(hexaviaFile,"r",encoding=encoding) as f:
        next(f)
        for line in f:
            count += 1
            bar.update(count)
            if (line[0:1]  == 'V'):
                # Stockage du lien entre matricule voie et insee/code postal
                inseeCodePost = {}
                inseeCodePost['co_insee'] = line[7:12].strip()
                inseeCodePost['co_postal'] = line[109:114].strip()
                inseeVoie[line[12:20].strip()] = inseeCodePost;    
    bar.finish()

    # Decodage du fichier hexacle 
    print('Decodage des hn du fichier hexacle');
    numLines = sum(1 for line in codecs.open(hexacleFile,"r",encoding=encoding))
    bar = progressbar.ProgressBar(maxval=numLines).start()
    count = 0
    with codecs.open(hexacleFile,"r",encoding=encoding) as f:
        next(f)
        for line in f:
            count += 1
            bar.update(count)
            
            # on recupere les caracteristiques du hn
            co_voie = line[0:8].strip()
            no_voie = line[8:12].strip()
            lb_ext = line[13:23].strip()
            co_cea = line[23:33].strip()
            
            # si le numero est vide, on ne transfere pas ce numéro, par contre on recupere le cea de la voie
            if not no_voie:
                ceaVoie[co_voie]=co_cea
            else:

                # Recherche de l'insee/code postal pointé par la voie
                inseeCodePost = inseeVoie.get(co_voie, None);

                # Ecriture du hn dans le fichier
                csvHn.writerow([
                    inseeCodePost['co_insee'] if inseeCodePost is not None else '',
                    co_voie,
                    inseeCodePost['co_postal'] if inseeCodePost is not None else '',
                    no_voie,
                    lb_ext,
                    co_cea])
    bar.finish()
    

    # Decodage du fichier des voies (on le casse en 3 fichiers groupes, voies synonymes et localites)
    print('Decodage des voies du fichier hexavia');
    bar = progressbar.ProgressBar(maxval=numLinesHexavia).start()
    count = 0
    with codecs.open(hexaviaFile,"r",encoding=encoding) as f:
        next(f)
        for line in f:
            count += 1
            bar.update(count)
            token = line[0:1]

            if (token == 'V'): 

                # Recherche de la localité pointée par la voie
                co_locality = line[1:7].strip();
                locality = localities.get(co_locality, None);

                # ecriture de la voie dans le fichier 
                csvGroup.writerow([
                    # insee
                    line[7:12].strip(),
                    # matricule voie
                    line[12:20].strip(),
                    # code postal
                    line[109:114].strip(),
                    # type de voie
                    line[92:96].strip(),
                    # libellé voie
                    line[60:92].strip(),
                    # cea
                    ceaVoie.get(line[12:20].strip()),
                    # libellé ligne 5
                    locality['lb_l5_nn'],
                    # ancien code insee ligne 5
                    locality['co_insee_anc']])
    bar.finish()
    
    print ('Traitement terminé')
        
    
