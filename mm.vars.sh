#!/bin/bash

# Les dossiers de téléchargement par défaut.
audiopath="/home/$USER/mdl/"
videopath="/home/$USER/vdl/"

# Ce fichier est un fichier texte simple.
# Chaque ligne correspond à un téléchargement à effectuer
# Doit commencer par http:// ou https://
LIST="/home/$USER/urls.txt"

# Le dossier du répertoire musical
LocalMusicPath="/home/$USER/music"

# Adresse et chemin du serveur distant sur lequel on peut sauvegarder une copie de la musique
ServerIP=""
ServerPath="/data/music"

# Dossier permettant de temporiser lors de l'utilisation de MusicMaker.sh entre le téléchargement et le
# rangement des fichiers
temppath="/home/$USER/temp"

# Excplicite
LOGS="/tmp/tri_musique.log"

#Celui ci est spécifique à tracknumber.sh:
logfile="/tmp/conversions.logs"

# Pour les jolies couleurs
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'
