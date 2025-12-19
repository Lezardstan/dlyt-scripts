#!/bin/bash
# Utilise les deux premiers chiffres du titre d'une musique en .flac et rajoute l'info dans les métadonnées
# Fait avec amour par ChatGPT
source mm.var.sh
audiopath=$1


for f in "${audiopath}"*.flac; do
    TRACK_NUM=$(basename "$f" | cut -d' ' -f1)  # récupère "01" depuis "01 - Titre.flac"
    ffmpeg -i "$f" -loglevel error -hide_banner -c copy -metadata track="$TRACK_NUM" "${f%.flac}_tmp.flac" >> "$logfile" 2>&1
    mv "${f%.flac}_tmp.flac" "$f"
done

