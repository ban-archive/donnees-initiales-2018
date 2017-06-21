# Chargement des données sources pour l'initialisation de la BAN
# - INSEE: COG (insee_xxx)
# - IGN: export SGA (ign_xxx)
# - La Poste: export RAN (ran_xxx)
# - DGFiP: FANTOIR et export BANO (dgfip_xxx)
# - Données BANv0 (ban_xxx)
# - Données AITF (aitf_xxx)

cd init
./init_cog.sh
./init_dgfip_fantoir.sh
./init_ign.sh # import_csv_ign.sh est le script fourni par l'IGN, non utilisé actuellement

exit

à compléter !
