#!/bin/bash

#
# Paquets en dépendances:
#   rsync
#   mediainfo
#   ytdl
# Les script suivants doivent être executables et trouvables par ce script.
#   ytdl.sh
#   tracknumber.sh
#

# Les différentes variables déclarées ici
source mm.vars.sh

ERROR=0

sanitize() {
  # Supprime les caractères invalides pour dossiers/fichiers
  local s="$1"
  # Remplace : * ? " < > | \ par _
  s="${s//[\*\?\"<>\|\\]/_}"
  # Supprime les espaces au début et à la fin
  s="$(echo "$s" | sed 's/^[[:space:]]\+//;s/[[:space:]]\+$//')"
  echo "$s"
}

clear
# Ca c'est juste pour le fun
echo -e "${YELLOW}      ###             ###${RESET}"
echo -e "${YELLOW}      #                 #${RESET}"
echo -e "${YELLOW}      #  ${RESET}MUSICMAKER.SH  ${YELLOW}#${RESET}"
echo -e "${YELLOW}    ###                 ###${RESET}"
echo -e "${YELLOW}    ###                 ###${RESET}"
echo ""
echo -e "${YELLOW}Appel du script ytdl.sh en mode automatique à partir de ${RESET}${LIST}"

# Appel du script ytdl.sh avec les arguments nécéssaires
bash ytdl.sh list auto

echo -e "${YELLOW}Nombre de fichiers dans le dossier temporaire :${RESET} ${GREEN}${#files[@]}${RESET}"
echo ""
echo -e "${YELLOW}Création des dossiers...${RESET}"
echo -e "${LocalMusicPath}/${GREEN}ARTISTE${RESET}/${GREEN}ALBUM${RESET}/${GREEN}N° - TITRE${RESET}"

# Permet d'éviter les ennuis si un répertoire ou fichier est vide pour les appels du type *.flac
shopt -s nullglob

# met tous les .flac dans un tableau
files=("$temppath"*.flac)


# Cette boucle permet de récupérer les métadonnées dans chaque fichier (Titre, Album, Artiste, N° de piste)
# La boucle va alors créer les dossiers et sous-dossiers correspondants pour y copier les musiques
for file in "$temppath"/*; do
  [ -f "$file" ] || continue

  EXT="${file##*.}"

  ARTISTE=$(mediainfo --Inform="General;%Performer%" "$file")
  ALBUM=$(mediainfo --Inform="General;%Album%" "$file")
  TITRE=$(mediainfo --Inform="General;%Title%" "$file")

  ARTISTE=$(sanitize "$ARTISTE")
  ALBUM=$(sanitize "$ALBUM")
  TITRE=$(sanitize "$TITRE")

# Si métadonnées manquantes, les dossiers suivants sont créés
  [ -z "$ARTISTE" ] && ARTISTE="Artiste inconnu"
  [ -z "$ALBUM" ] && ALBUM="Album inconnu"
  [ -z "$TITRE" ] && TITRE="$(basename "$file" ."$EXT")"

  DEST_DIR="${LocalMusicPath}/${ARTISTE}/${ALBUM}"
  DEST_FILE="${DEST_DIR}/${TITRE}.${EXT}"

  mkdir -p "$DEST_DIR"

# En cas de dossier déjà existant, on le notifie et on enregistre l' "erreur"
  if [ -e "$DEST_FILE" ]; then
    echo -e "${RED}Fichier déjà existant : $DEST_FILE${RESET}"
    ERROR=1
    continue
  fi

  cp -n "$file" "$DEST_FILE"

# Vérification que le fichier a bien été copié
  if [ ! -f "$DEST_FILE" ]; then
    echo -e "${RED}Échec de copie : ${RESET}${file}"
    ERROR=1
  else
    echo -e "${GREEN}Copié :${RESET} $file -> $DEST_FILE"
  fi
done


# Si aucune erreur n'a été notée, alors on supprime les fichiers temporaires et on vide la liste
# des téléchargements
if [ "$ERROR" -eq 0 ]; then
  echo -e "${GREEN}Copie réussie${RESET}"
  echo -e "${YELLOW}Suppression du dossier temporaire${RESET} ${temppath}"
  rm -rf "$temppath"/*
  echo -e "${YELLOW}Suppression du contenu de${RESET} ${LIST}"
  echo "" > $LIST
else
  echo -e "${RED}Erreurs détectées, aucune suppression effectuée${RESET}"
fi

# Syncronisation vers le serveur configuré
# --info-progress2 permet de ne pas avoir une progression pour chaque fichier
# Changez cette valeur à "--info-progress1" est l'équivalent de --show-progress
echo -e "${YELLOW}Syncronisation vers le serveur ${RESET}${ServerIP}"
rsync -rt --info=progress2 --ignore-existing "${LocalMusicPath}/" "${USER}@${ServerIP}:${ServerPath}/"
echo -e "${GREEN}Transfert terminé !${RESET}"
