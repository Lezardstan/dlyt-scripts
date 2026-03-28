#!/bin/bash

NTFY_SERVER="https://[NTFY_SERVER]"
NTFY_USER="[NTFY_USER]:[NTFY_PASSWORD]"


# Ces fonctions sont appelées par le.s script.s pour envoyer des notifications sur Android/Desktop
# Chaque script sourcant ce script DOIVENT avoir une variable déclarée $TOPIC qui permet d'appeler le bon topic pour ntfy. 
# Idéalement, un topic par application, associé à un abonnement utilisateur

# Ces premières sont préconfigurées pour le script d'automation yt-dl


function notify_success_music_dl() {
    curl -s -u "$NTFY_USER" -X POST "${NTFY_SERVER}${TOPIC}" \
        -H "Title: Album téléchargé !" \
        -H "Priority: default"
        -H "Tags: downloaded, music" \
        -d "$1" > /dev/null
}

function notify_success_music_finish() {
    curl -s -u "$NTFY_USER" -X POST "${NTFY_SERVER}${TOPIC}" \
        -H "Title: Album en ligne !" \
        -H "Priority: high"
        -H "Tags: downloaded, music" \
        -d "$1" > /dev/null
}

function notify_error() {
    curl -s -u "$NTFY_USER" -X POST "$NTFY_SERVER${TOPIC}" \
        -H "Title: Échec du téléchargement" \
        -H "Priority: high" \
        -H "Tags: warning" \
        -d "$1" > /dev/null

}

# Cette dernière permet d'envoyer une notification avec l'argument d'appel
function notify_custom() {
    curl -s -u "$NTFY_USER" -X POST "$NTFY_SERVER${TOPIC}" \
        -H "Title: $1" \
        -H "Priority: default" \
        -d "$1" > /dev/null

}

