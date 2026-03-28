# dlyt-scripts


#### autodl.sh
Script de téléchargement, conversion et organisation des fichiers sur le serveur.


#### webhook.py
Service HTTP minimal qui reçoit les requêtes et déclenche le script de téléchargement.


#### webhook-yt-dl.service
Service systemd pour faire tourner le webhook en permanence.


#### MusicMaker.sh
Script pour télécharger en local avec copie sur serveur de Musique


#### mm.vars.sh
Script pour sourcer les variables de MusicMaker.sh


#### tracknumbers.sh
Utilise les deux premiers chiffres du titre d'une musique en .flac et rajoute le numéro de la piste dans les métadonnées


#### ytdl.sh
Script simple pour téléchargement de vidéos et musiques Youtube/Youtube Music 
Paramétré pour la meilleure qualité disponible (en .flac)

### notifications.sh
Contient des fonctions pour créer des appels via cURL vers le serveur ntfy

--- 

# Stacks manuel depuis Desktop
tydl.sh + tracknumber.sh + mmvar.sh + MusicMaker.sh + notifications.sh

Voir scripts individuels

---

# Stack Automatique
autodl.sh + notifications.sh + webhook.py + webhook-yt-dl.service sur le serveur Navidrome:

**Flux d'une requête :**
```
Téléphone (HTTP Shortcuts)
  → Reverse proxy (music.mysite.com/apiytdl)
    → Webhook Flask ([SERVER]:5055)
      → autodl.sh (yt-dlp + ffmpeg + mediainfo)
        → ~/navidrome/music (surveillé par Navidrome)
```
## Dépendances:
python3 python3-flask mediainfo ffmpeg

yt-dlp (version à jour, hors dépôts Debian)

```bash
sudo apt remove yt-dlp  
sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
sudo chmod +x /usr/local/bin/yt-dlp
```

Activation du service systemd:
```bash
sudo systemctl enable --now webhook-yt-dl.service
```


## Application mobile — HTTP Shortcuts (Android)

1. Installer **HTTP Shortcuts** 
2. Appuyer sur **+** → **Créer à partir de zéro**
3. **Onglet Basic Request**
   - Method : `GET`
   - URL : `https://music.mysite.com/apiytdl?token=TOKEN&url={url}`
4. **Variables** : créer une variable `url` de type `Share Text`
5. **Trigger & Execution** : activer **"Include in share menu"**
6. Sauvegarder

**Utilisation :** depuis YT Music, Partager -> HTTP Shortcuts -> sélectionner le raccourci.

## Reverse Proxy:
```nginx
location /apiytdl {
    proxy_pass http://[SERVER_IP]:5055;
}
```

## Maintenance:
Suivre les logs en temps réel :
```bash
tail -f /var/log/autodl.log
journalctl -u webhook-yt-dl -f
```
- **Le verrou `/tmp/autodl.lock`** empêche deux téléchargements simultanés. S'il reste bloqué après un crash : `rm /tmp/autodl.lock`.

Update yt-dl:
```bash
sudo yt-dlp -U
```
