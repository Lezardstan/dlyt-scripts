# Made with Claude's help
from flask import Flask, request, abort
import subprocess, os

app = Flask(__name__)
SECRET = os.environ.get("DL_TOKEN", "")

@app.route("/apiytdl")
def download():
    if not SECRET or request.args.get("token") != SECRET:
        abort(403)
    url = request.args.get("url", "").strip()
    if not url.startswith("https://music.youtube.com/") and \
       not url.startswith("https://www.youtube.com/"):
        abort(400)
    subprocess.Popen(["autodl.sh", url])
    return "Téléchargement lancé", 202

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5055)
