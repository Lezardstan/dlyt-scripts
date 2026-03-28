#!/bin/bash
# autodl.sh — reçoit une URL en $1, dépose directement dans Navidrome

source notifications.sh
TOPIC="music"

url="$1"
MusicPath="$MUSIC_PATH"   # dossier surveillé par Navidrome
temppath="/tmp/autodl_$$"      # dossier temporaire unique par exécution
LOG="/var/log/autodl.log"
LOCKFILE="/tmp/autodl.lock"

if [ -f "$LOCKFILE" ]; then
    echo "[$(date)] Déjà en cours, abandon : $url" >> "$LOG"
    exit 1
fi

touch "$LOCKFILE"
notify_custom "Verrouillage..."
trap "rm -f $LOCKFILE" EXIT   # supprime le verrou quoi qu'il arrive (succès ou erreur)


mkdir -p "$temppath"

echo "[$(date)] Téléchargement : $url" >> "$LOG"

yt-dlp \
    --output "${temppath}/%(playlist_index)02d - %(title)s.%(ext)s" \
    --parse-metadata "%(uploader|)s:%(album_artist)s" \
    --embed-metadata --add-metadata \
    --extract-audio --audio-format flac --audio-quality 0 \
    "$url" >> "$LOG" 2>&1

notify_success_music_dl

# Ajout des numéros de piste dans les métadonnées
for f in "${temppath}"/*.flac; do
    [ -f "$f" ] || continue
    TRACK_NUM=$(basename "$f" | cut -d' ' -f1)
    ffmpeg -i "$f" -loglevel error -hide_banner -c copy \
        -metadata track="$TRACK_NUM" "${f%.flac}_tmp.flac" >> "$LOG" 2>&1
    mv "${f%.flac}_tmp.flac" "$f"
done

notify_custom "Metadonnées ajoutées"
for file in "$temppath"/*.flac; do
    [ -f "$file" ] || continue
    ARTISTE=$(mediainfo --Inform="General;%Album/Performer%" "$file")
    ALBUM=$(mediainfo --Inform="General;%Album%" "$file")
    [ -z "$ARTISTE" ] && ARTISTE="Artiste inconnu"
    [ -z "$ALBUM" ]   && ALBUM="Album inconnu"
    DEST="${MusicPath}/${ARTISTE}/${ALBUM}"
    mkdir -p "$DEST"
    cp -n "$file" "$DEST/" && echo "[$(date)] Copié : $file -> $DEST" >> "$LOG"

done

rm -rf "$temppath"
notify_success_music_finish
echo "[$(date)] Terminé." >> "$LOG"
