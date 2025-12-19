#!/bin/bash

# Script simple pour téléchargement de vidéos et musiques Youtube/Youtube Music (playlist possibles)
#
# Paramétré pour la meilleure qualité disponible (en .flac)
#
# Made by LezardStan

source mm.var.sh

function enter_url() {
    while [ -z "$url" ]; do
        echo -e "${RED}Merci de renseigner l'adresse de la vidéo à télécharger:${RESET} "
        read url
    done
}

function download_single() {
    local url="$1"
    local video_choice="$2"

# On a ici les deux parametrages pour ty-dl
# Ils peuvent être modifiés à volonté grace à la documentation spécifique:
# https://github.com/yt-dlp/yt-dlp
# 0=meilleure qualité // 10=pire qualité
# Formats: # https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#format-selection

    if [ "$video_choice" = "n" ] || [ "$video_choice" = "N" ]; then
        yt-dlp \
            --output "${audiopath}%(playlist_index)02d - %(title)s.%(ext)s" \
            --embed-metadata \
            --add-metadata \
            --extract-audio \
            --audio-format flac \
            --audio-quality 0 \ # 0=meilleure qualité
            "$url" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Échec du téléchargement audio pour : ${url}${RESET}"
        else
            echo -e "${GREEN}Téléchargement terminé : ${RESET}${url}"
            echo -e "${GREEN}Fichier enregistré dans ${RESET}${audiopath}"
        fi
    else
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
            --merge-output-format mp4 \
            --output "${videopath}%(title)s.%(ext)s" \
            --no-overwrites \
            "$url" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Échec du téléchargement vidéo pour : $url${RESET}"
        else
            echo -e "${GREEN}Téléchargement terminé !${RESET}"
            echo -e "${GREEN}Fichier enregistré dans ${RESET}${videopath}"
        fi
    fi
}

# Cette fonction va rérifier si le fichier de liste existe /est correctement localisé
# Passer les lignes du fichier une à une et executer download_single pour chaque
function download_list() {
    local file="${1:-urls.txt}"
    local video_choice="$2"

    if [ ! -f "$file" ]; then
        echo -e "${RED}Fichier '$file' introuvable.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Lecture du fichier :${RESET} $file"

# Compter les lignes non vides et non commentées
    total=$(grep -v -E '^[[:space:]]*$|^[[:space:]]*#' "$file" | wc -l)
    count=0

    while IFS= read -r url; do
# Ignorer les lignes vides ou commentées
        [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue
        ((count++))
        echo -e "${YELLOW}[$count/$total] Téléchargement : ${RESET}${url}"
        download_single "$url" "$video_choice"
    done < "$file"

# On teste si le dossier temporaire est vide. Si il ne l'est pas, on va executer le script tracknumber.sh
    numberoffiles=$(ls -1 $audiopath | wc -l)
    if [ "$numberoffiles" != 0 ];then
        echo -e "${YELLOW}Appel de tracknumbers.sh sur ${RESET}${audiopath}${YELLOW}...${RESET}"
        tracknumbers.sh "${audiopath}"
        echo -e "${YELLOW}Fin du script tracknumbers.sh${RESET}"
    else
        echo -e "${RED}Aucun fichier dans le dossier ${RESET}${audiopath} ${RED}!${RESET}"
    fi
}

# Vérification que yt-dlp est installé
command -v yt-dlp >/dev/null 2>&1 || { echo -e "${RED}yt-dlp n'est pas installé.${RESET}"; exit 1; }

# Gestion des arguments
# Ici le lien avec le script MusicMaker.sh
# Si $1 = list  alors la fonction permettant de télécharger une playlist est lançée
if [ "$1" = "list" ]; then

# Si combiinée à la liste, l'argument auto est donné, alors on considère qu'il s'agit de musique
    if [ "$2" = "auto" ];then
        video_choice="n"
    else
        echo "Faut t-il conserver la vidéo pour toute la liste ? (Any/n)"
        read video_choice
    fi
# Envoi à la fonction download_list
    download_list "$LIST" "$video_choice"
    echo -e "${YELLOW}Script tydl.sh terminé !${RESET}"
    exit 0
fi
# Mode unique URL
# Si pas d'aguments, on demande une lien de téléchargement, sinon on utilise la variable rensiegnée lors de l'appel
if [ -z "$1" ]; then
    enter_url
    url="$url"
else
    url="$1"
fi

# Vérification basique de l'URL
if [[ ! "$url" =~ ^https?:// ]]; then
    echo -e "${RED}URL invalide. Doit commencer par http:// ou https://${RESET}"
    exit 1
fi

# Demander si on garde la vidéo. n pour non, toutes les autres touches pour oui
echo -e "${RED}Faut t-il conserver la vidéo ?${RESET}${YELLOW} (Any/n)${RESET}"
read video_choice
echo -e "${YELLOW}Téléchargement en cours de${RESET} ${url}"
# Lancement de la fonction principale
download_single "$url" "$video_choice"

