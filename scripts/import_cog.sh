#!/bin/sh
# But : importer le fichier cog de l'insee dans une base postgresql de travail
################################################################################
# ARGUMENT :* $1 : le repertoire dans lequel sera enregistré le fichier
##############################################################################
# SORTIE : 
# - le fichier cog
# - la table insee_cog
#############################################################################
# REMARQUE : la base PostgreSQL, le port doivent être passés dans les variables d'environnement
# PGDATABASE et PGUSER

data_path=$1
set -x
if [ $# -ne 1 ]; then
        echo "Usage : import_cog.sh <DataPath> "
        exit 1
fi

mkdir ${data_path}

rm ${data_path}/comsimp2017-txt.zip
rm ${data_path}/comsimp2017.txt
rm ${data_path}/comsimp2017.csv

# COG 2017 de l'INSEE
wget -nc  https://www.insee.fr/fr/statistiques/fichier/2666684/comsimp2017-txt.zip -O ${data_path}/comsimp2017-txt.zip
if [ $? -ne 0 ]
then
   echo "Erreur lors du telechargement du fichier COG"
   exit 1
fi

unzip -o ${data_path}/comsimp2017-txt.zip -d ${data_path}
# conversion en CSV UTF-8
cat ${data_path}/comsimp2017.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > ${data_path}/comsimp2017.csv


echo  "drop table if exists insee_cog;" > commandeTemp.sql
echo  "create table insee_cog (CDC text,CHEFLIEU text,REG text,DEP text,COM text,AR text,CT text,TNCC text,ARTMAJ text,NCC text,ARTMIN text,NCCENR text);" >>commandeTemp.sql
echo  "\COPY insee_cog from '${data_path}/comsimp2017.csv' WITH CSV HEADER DELIMITER ','" >> commandeTemp.sql
echo  "alter table insee_cog add column insee text;" >> commandeTemp.sql
echo  "update insee_cog set insee=dep||com;" >> commandeTemp.sql
echo  "create index idx_insee_cog_insee on insee_cog (insee);" >> commandeTemp.sql

# Ajout des arrondissements municipaux de Paris, Lyon et Marseille
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13201','MARSEILLE-1ER-ARRONDISSEMENT','Marseille 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13202','MARSEILLE-2E-ARRONDISSEMENT','Marseille 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13203','MARSEILLE-3E-ARRONDISSEMENT','Marseille 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13204','MARSEILLE-4E-ARRONDISSEMENT','Marseille 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13205','MARSEILLE-5E-ARRONDISSEMENT','Marseille 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13206','MARSEILLE-6E-ARRONDISSEMENT','Marseille 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13207','MARSEILLE-7E-ARRONDISSEMENT','Marseille 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13208','MARSEILLE-8E-ARRONDISSEMENT','Marseille 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13209','MARSEILLE-9E-ARRONDISSEMENT','Marseille 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13210','MARSEILLE-10E-ARRONDISSEMENT','Marseille 10e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13211','MARSEILLE-11E-ARRONDISSEMENT','Marseille 11e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13212','MARSEILLE-12E-ARRONDISSEMENT','Marseille 12e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13213','MARSEILLE-13E-ARRONDISSEMENT','Marseille 13e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13214','MARSEILLE-14E-ARRONDISSEMENT','Marseille 14e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13215','MARSEILLE-15E-ARRONDISSEMENT','Marseille 15e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('13216','MARSEILLE-16E-ARRONDISSEMENT','Marseille 16e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69381','LYON-1ER-ARRONDISSEMENT','Lyon 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69382','LYON-2E-ARRONDISSEMENT','Lyon 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69383','LYON-3E-ARRONDISSEMENT','Lyon 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69384','LYON-4E-ARRONDISSEMENT','Lyon 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69385','LYON-5E-ARRONDISSEMENT','Lyon 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69386','LYON-6E-ARRONDISSEMENT','Lyon 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69387','LYON-7E-ARRONDISSEMENT','Lyon 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69388','LYON-8E-ARRONDISSEMENT','Lyon 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('69389','LYON-9E-ARRONDISSEMENT','Lyon 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75101','PARIS-1ER-ARRONDISSEMENT','Paris 1er Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75102','PARIS-2E-ARRONDISSEMENT','Paris 2e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75103','PARIS-3E-ARRONDISSEMENT','Paris 3e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75104','PARIS-4E-ARRONDISSEMENT','Paris 4e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75105','PARIS-5E-ARRONDISSEMENT','Paris 5e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75106','PARIS-6E-ARRONDISSEMENT','Paris 6e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75107','PARIS-7E-ARRONDISSEMENT','Paris 7e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75108','PARIS-8E-ARRONDISSEMENT','Paris 8e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75109','PARIS-9E-ARRONDISSEMENT','Paris 9e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75110','PARIS-10E-ARRONDISSEMENT','Paris 10e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75111','PARIS-11E-ARRONDISSEMENT','Paris 11e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75112','PARIS-12E-ARRONDISSEMENT','Paris 12e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75113','PARIS-13E-ARRONDISSEMENT','Paris 13e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75114','PARIS-14E-ARRONDISSEMENT','Paris 14e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75115','PARIS-15E-ARRONDISSEMENT','Paris 15e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75116','PARIS-16E-ARRONDISSEMENT','Paris 16e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75117','PARIS-17E-ARRONDISSEMENT','Paris 17e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75118','PARIS-18E-ARRONDISSEMENT','Paris 18e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75119','PARIS-19E-ARRONDISSEMENT','Paris 19e Arrondissement');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('75120','PARIS-20E-ARRONDISSEMENT','Paris 20e Arrondissement');" >> commandeTemp.sql

#Ajout des communes de saint-pierre et miquelon
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97501','MIQUELON-LANGLADE','Miquelon-Langlade');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97502','SAINT-PIERRE','Saint-Pierre');" >> commandeTemp.sql

#Ajout de Saint-Barthélémy et Saint Martin
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97701','SAINT-BARTHELEMY','Saint-Barthélemy');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('97801','SAINT-MARTIN','Saint-Martin');" >> commandeTemp.sql

# Ajout de Wallis et Futuna
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98611','ALO','Alo');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98612','SIGAVE','Sigave');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98613','UVEA','Uvea');" >> commandeTemp.sql

# Polynésie Française
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98711','ANAA','Anaa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98712','ARUE','Arue');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98713','ARUTUA','Arutua');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98714','BORA-BORA','Bora-Bora');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98715','FAAA','Faaa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98716','FAKARAVA','Fakarava');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98717','FANGATAU','Fangatau');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98718','FATU-HIVA','Fatu-Hiva');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98719','GAMBIER','Gambier');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98720','HAO','Hao');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98721','HIKUERU','Hikueru');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98722','HITIAA O TE RA','Hitiaa O Te Ra');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98723','HIVA-OA','Hiva-Oa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98724','HUAHINE','Huahine');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98725','MAHINA','Mahina');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98726','MAKEMO','Makemo');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98727','NANIHI','Nanihi');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98728','MAUPITI','Maupiti');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98729','MOOREA-MAIAO','Moorea-Maiao');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98730','NAPUKA','Napuka');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98731','NUKU-HIVA','Nuku-Hiva');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98732','NUKUTAVAKE','Nukutavake');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98733','PAEA','Paea');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98734','PAPARA','Papara');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98735','PAPEETE','Papeete');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98736','PIRAE','Pirae');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98737','PUKAPUKA','Pukapuka');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98738','PUNAAUIA','Punaauia');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98739','RAIVAVAE','Raivavae');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98740','RANGIROA','Rangiroa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98741','RAPA','Rapa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98742','REAO','Reao');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98743','RIMATARA','Rimatara');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98744','RURUTU','Rurutu');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98745','TAHAA','Tahaa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98746','TAHUATA','Tahuata');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98747','TAIARAPU-EST','Taiarapu-Est');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98748','TAIARAPU-OUEST','Taiarapu-Ouest');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98749','TAKAROA','Takaroa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98750','TAPUTAPUATEA','Taputapuatea');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98751','TATAKOTO','Tatakoto');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98752','TEVA I UTA','Teva I Uta');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98753','TUBUAI','Tubuai');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98754','TUMARAA','Tumaraa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98755','TUREIA','Tureia');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98756','UA-HUKA','Ua-Huka');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98757','UA-POU','Ua-Pou');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98758','UTUROA','Uturoa');" >> commandeTemp.sql

# Nouvelles Calédonie
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98801','BELEP','Belep');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98802','BOULOUPARI','Bouloupari');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98803','BOURAIL','Bourail');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98804','CANALA','Canala');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98805','DUMBEA','Dumbéa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98806','FARINO','Farino');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98807','HIENGHENE','Hienghène');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98808','HOUAILOU','Houaïlou');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98809','L''ILE-DES-PINS','L''Île-des-Pins');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98810','KAALA-GOMEN','Kaala-Gomen');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98811','KONE','Koné');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98812','KOUMAC','Koumac');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98813','LA FOA','La Foa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98814','LIFOU','Lifou');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98815','MARE','Maré');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98816','MOINDOU','Moindou');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98817','LE MONT-DORE','Le Mont-Dore');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98818','NOUMEA','Nouméa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98819','OUEGOA','Ouégoa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98820','OUVEA','Ouvéa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98821','PAITA','Païta');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98822','POINDIMIE','Poindimié');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98823','PONERIHOUEN','Ponérihouen');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98824','POUEBO','Pouébo');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98825','POUEMBOUT','Pouembout');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98826','POUM','Poum');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98827','POYA','Poya');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98828','SARRAMEA','Sarraméa');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98829','THIO','Thio');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98830','TOUHO','Touho');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98831','VOH','Voh');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98832','YATE','Yaté');" >> commandeTemp.sql
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98833','KOUAOUA','Kouaoua');" >> commandeTemp.sql


# Clipperton
echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('98901','ILE DE CLIPPERTON','Île de Clipperton');" >> commandeTemp.sql

# Moncao
#echo "INSERT INTO insee_cog(insee,ncc,nccenr) VALUES ('99138','MONACO','Monaco');" >> commandeTemp.sql


psql -f commandeTemp.sql

if [ $? -ne 0 ]
then
   echo "Erreur lors de l import du fichier COG"
   exit 1
fi

rm commandeTemp.sql


echo "FIN"


