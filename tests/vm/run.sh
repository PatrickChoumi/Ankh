#!/usr/bin/bash
# Phase 2 (D-004, D-027) : prouve le modèle image-based dans une VM.
#
# Usage, en root avec KVM, QEMU et OVMF : tests/vm/run.sh [IMAGE]
#   IMAGE : image à installer, présente dans le stockage podman de root.
#           Défaut : localhost/ankh:latest (« sudo just build ankh »).
#
# Étapes, toutes vérifiées automatiquement :
#   1. installation de IMAGE sur un disque virtuel, puis démarrage complet ;
#   2. basculement vers une autre version (ghcr.io/patrickchoumi/ankh:latest) ;
#   3. retour arrière (bootc rollback) vers IMAGE ;
#   4. retour à l'image de base épinglée dans bases.env (D-005, D-018).
# À chaque démarrage : Secure Boot actif (D-006), SELinux en mode enforcing
# et pare-feu actif (D-008). Sur IMAGE : numéro de version d'Ankh (D-028),
# Chrome qui démarre et Firefox absent (D-023).
#
# Captures d'écran de la VM à chaque étape, dans $work/captures : écran de
# connexion, bureau KDE (compte de test « ankhvm » connecté automatiquement
# par le gestionnaire de connexion),
# Discover, Chrome, VLC, OnlyOffice et VS Code (premier clic).
#
# Variables facultatives : ANKH_VM_OTHER (image de l'étape 2),
# ANKH_VM_WORKDIR (dossier de travail), ANKH_VM_SSH_PORT (port local).
set -euo pipefail

image=${1:-localhost/ankh:latest}
other=${ANKH_VM_OTHER:-ghcr.io/patrickchoumi/ankh:latest}
repo=$(cd "$(dirname "$0")/../.." && pwd)
work=${ANKH_VM_WORKDIR:-$(mktemp -d)}
port=${ANKH_VM_SSH_PORT:-2222}
ovmf=/usr/share/OVMF
qemu_pid=
boot_id=

# Échecs de services propres à la VM de test, avec le message qui les prouve.
# Tout autre service en échec fait échouer le test.
# - mcelog s'arrête sur les processeurs AMD récents (« CPU is unsupported »,
#   https://github.com/andikleen/mcelog/blob/master/mcelog.c). Sur un vrai
#   PC AMD, son unité est ignorée car le module edac_mce_amd est chargé
#   (https://github.com/andikleen/mcelog/blob/master/mcelog.service) ; ce
#   module ne se charge pas dans la VM, dont le processeur est celui de la
#   machine GitHub.
declare -A known_failures=(
    [mcelog.service]='CPU is unsupported'
)

log() { printf '\n==> %s\n' "$*"; }
die() {
    printf '\nÉCHEC : %s\n' "$*" >&2
    exit 1
}

cleanup() {
    local rc=$?
    if [[ -n $qemu_pid ]] && kill -0 "$qemu_pid" 2> /dev/null; then
        kill "$qemu_pid"
    fi
    if ((rc != 0)) && [[ -f $work/serial.log ]]; then
        log "Fin du journal série de la VM ($work/serial.log)"
        tail -n 200 "$work/serial.log"
    fi
}
trap cleanup EXIT

# Commande dans la VM, en root, par SSH.
vm() {
    ssh -n -i "$work/id_ed25519" -p "$port" \
        -o BatchMode=yes -o ConnectTimeout=5 -o LogLevel=ERROR \
        -o ServerAliveInterval=10 -o ServerAliveCountMax=6 \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@127.0.0.1 "$@"
}

# Attend que la VM réponde en SSH après un nouveau démarrage.
wait_boot() {
    local old=$boot_id deadline=$((SECONDS + 900)) id
    while :; do
        kill -0 "$qemu_pid" 2> /dev/null || die "QEMU s'est arrêté"
        # Les échecs de connexion sont attendus tant que la VM démarre.
        if id=$(vm cat /proc/sys/kernel/random/boot_id 2> /dev/null) && [[ $id != "$old" ]]; then
            boot_id=$id
            return
        fi
        ((SECONDS < deadline)) || die "pas de réponse SSH 15 minutes après le démarrage"
        sleep 10
    done
}

# Capture l'écran de la VM en PNG par le moniteur de QEMU (commande screendump).
screenshot() {
    local file="$work/captures/$1.png"
    python3 - "$work/monitor.sock" "screendump $file -f png" << 'PY'
import socket, sys
sock = socket.socket(socket.AF_UNIX)
sock.settimeout(30)
sock.connect(sys.argv[1])

def until_prompt():
    data = b""
    while b"(qemu)" not in data:
        chunk = sock.recv(4096)
        if not chunk:
            sys.exit("moniteur QEMU fermé")
        data += chunk

until_prompt()  # bannière, puis invite « (qemu) »
sock.sendall(sys.argv[2].encode() + b"\n")
until_prompt()  # nouvelle invite : la commande est terminée
sock.close()
PY
    [[ -s $file ]] || die "capture d'écran impossible : $file"
    echo "Capture : $file"
}

# Attend le bureau Plasma du compte de test, puis le capture.
wait_desktop() {
    local name=$1 deadline=$((SECONDS + 180))
    until vm pgrep -u ankhvm -x plasmashell > /dev/null; do
        if ((SECONDS >= deadline)); then
            screenshot "$name-echec"
            die "le bureau Plasma ne démarre pas pour le compte de test"
        fi
        sleep 5
    done
    sleep 20 # le temps que le bureau finisse de s'afficher
    screenshot "$name"
}

# Connexion automatique du compte de test, pour le gestionnaire de connexion
# actif : Plasma Login (Fedora 44 KDE) ou SDDM. Plasma Login, dérivé de SDDM,
# lit la même section [Autologin] dans /etc/plasmalogin.conf ou
# /etc/plasmalogin.conf.d/ (https://wiki.archlinux.org/title/Plasma_Login_Manager).
configure_autologin() {
    local dm dir
    dm=$(vm systemctl show -p Id --value display-manager.service)
    echo "Gestionnaire de connexion : $dm"
    case $dm in
        plasmalogin.service) dir=/etc/plasmalogin.conf.d ;;
        sddm.service) dir=/etc/sddm.conf.d ;;
        *) die "gestionnaire de connexion inattendu : $dm" ;;
    esac
    vm "mkdir -p $dir && printf '[Autologin]\nUser=ankhvm\nSession=plasma.desktop\n' > $dir/ankh-vmtest.conf"
    if [[ $dm == plasmalogin.service ]]; then
        # Le dossier .conf.d est parfois ignoré (https://bugs.kde.org/show_bug.cgi?id=522006) :
        # le fichier principal est écrit aussi s'il n'existe pas.
        vm "test -e /etc/plasmalogin.conf || cp $dir/ankh-vmtest.conf /etc/plasmalogin.conf"
    fi
    vm systemctl restart display-manager.service
}

# État de /boot avant un redémarrage qui doit appliquer une version préparée :
# montages empilés sur /boot, et unités qui le montent ou le gardent ouvert
# pour la finalisation par ostree à l'arrêt.
show_boot_state() {
    local cmd
    for cmd in \
        'rpm -q ostree systemd' \
        'findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /boot' \
        'systemctl show -p Id,ActiveState,UnitFileState,FragmentPath boot.automount boot.mount ostree-finalize-staged.service ostree-finalize-staged-hold.service'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

reboot_vm() {
    vm systemd-run --on-active=2 systemctl reboot
    wait_boot
}

# Quand la version attendue n'a pas démarré : finalisation du déploiement
# préparé par ostree (faite à l'arrêt précédent), état des déploiements et
# place dans /boot, pour trouver la cause dans le journal de la CI.
explain_deployment() {
    local cmd
    log "Diagnostic : la version attendue n'a pas démarré"
    for cmd in \
        'journalctl -b -1 -o short-monotonic -u ostree-finalize-staged.service -u ostree-finalize-staged-hold.service -u boot.mount -u boot.automount --no-pager' \
        'journalctl -b -1 -n 60 --no-pager' \
        'bootc status' \
        'df -h /boot /sysroot' \
        'ls -la /boot/loader/entries /boot/ostree' \
        'du -sh /boot/ostree/*'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# Champ de l'image démarrée dans « bootc status » (image.image ou imageDigest).
booted() {
    vm bootc status --format=json | jq -er ".status.booted.image.$1"
}

# Accepte un état « degraded » seulement si chaque service en échec est un
# échec connu de la VM, prouvé par son journal.
check_failed_units() {
    local units line unit journal
    local -a names=()
    units=$(vm systemctl list-units --state=failed --plain --no-legend)
    while read -r line; do
        if [[ -n ${line} ]]; then names+=("${line%% *}"); fi
    done <<< "${units}"
    for unit in "${names[@]}"; do
        journal=$(vm journalctl -b -u "${unit}" --no-pager -n 50)
        printf 'Service en échec : %s\n%s\n' "${unit}" "${journal}"
        [[ -n ${known_failures[${unit}]:-} && ${journal} == *"${known_failures[${unit}]}"* ]] ||
            die "service en échec non expliqué : ${unit}"
        echo "Échec connu, propre à la VM de test : ${unit}"
    done
}

check_boot() {
    local state ref digest
    if ! state=$(vm timeout 900 systemctl is-system-running --wait); then
        [[ ${state} == degraded ]] || die "démarrage incomplet (état : ${state:-inconnu})"
        check_failed_units
    fi
    [[ $(vm od -An -t u1 -j 4 -N 1 /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c) =~ ^[[:space:]]*1$ ]] ||
        die "Secure Boot inactif"
    [[ $(vm cat /sys/fs/selinux/enforce) == 1 ]] || die "SELinux n'est pas en mode enforcing"
    [[ $(vm systemctl is-active firewalld) == active ]] || die "pare-feu (firewalld) inactif"
    ref=$(booted image.image)
    digest=$(booted imageDigest)
    echo "Démarrage complet ; Secure Boot, SELinux et pare-feu actifs."
    # Place dans /boot, où chaque version d'Ankh garde son noyau et son
    # initramfs (ici sur la partition btrfs du système, sans partition à lui).
    echo "/boot (utilisé, taille, %) : $(vm df -h --output=used,size,pcent /boot | tail -n 1)"
    echo "Image démarrée : $ref ($digest)"
}

# Vérifie que le système démarré contient bien les réglages d'Ankh.
check_ankh() {
    [[ $(vm readlink /etc/systemd/system/bootc-fetch-apply-updates.timer) == /dev/null ]] ||
        die "le timer de redémarrage automatique n'est pas masqué (D-010)"
}

# Vérifie le contenu propre à l'image installée (absent de l'image publiée
# tant que la PR n'est pas fusionnée) : version (D-028), Chrome et Firefox (D-023),
# pas de mise à jour automatique (D-031), habillage (D-033).
check_installed() {
    local chrome
    [[ $(booted version) == "$image_version" ]] || die "le système démarré ne porte pas la version $image_version (D-028)"
    chrome=$(vm google-chrome --version)
    [[ $chrome == "Google Chrome "* ]] || die "Chrome ne démarre pas : $chrome"
    echo "Chrome : $chrome"
    # rpm -q renvoie 1 quand le paquet est absent ; tout autre code est un échec.
    [[ $(vm 'rpm -q firefox > /dev/null; echo $?') == 1 ]] || die "Firefox est présent, ou son état est inconnu"
    # D-031 : rien ne se télécharge ni ne s'installe sans moi.
    [[ $(vm systemctl is-enabled rpm-ostreed-automatic.timer) == masked ]] ||
        die "le téléchargement automatique du système n'est pas désactivé (D-031)"
    # D-036 : VS Code dans le menu dès l'installation (le premier clic est
    # testé une fois, dans la session de test, par check_vscode).
    vm test -x /usr/libexec/ankh-vscode -a -f /usr/share/applications/ankh-vscode.desktop ||
        die "VS Code absent du menu (D-036)"
    # D-033 : le système s'appelle Ankh, jusque dans le menu de démarrage
    # (titre écrit par ostree à partir de PRETTY_NAME).
    # shellcheck disable=SC2016 # variables lues dans la VM
    [[ $(vm '. /etc/os-release && echo "$NAME $ID"') == "Ankh fedora" ]] ||
        die "le système ne s'appelle pas Ankh, ou son ID n'est plus fedora (D-033)"
    vm "grep -q '^title Ankh ' /boot/loader/entries/*.conf" ||
        die "le menu de démarrage n'affiche pas Ankh (D-033)"
    [[ $(vm cat /proc/sys/kernel/hostname) == ankh ]] || die "la machine ne s'appelle pas « ankh » (D-033)"
    # D-034 : écran de démarrage graphique (« rhgb », donné par l'image).
    vm grep -qw rhgb /proc/cmdline || die "le noyau n'a pas reçu « rhgb » : pas d'écran de démarrage (D-034)"
    # D-004 : /boot n'est pas monté automatiquement par-dessus le montage d'ostree.
    [[ $(vm systemctl is-enabled boot.automount) == masked ]] ||
        die "le montage automatique de /boot n'est pas masqué (D-004)"
    # D-035 : VLC et OnlyOffice présents dès l'installation, LibreOffice absent.
    vm rpm -q vlc onlyoffice-desktopeditors || die "VLC ou OnlyOffice absent (D-035)"
    [[ -z $(vm "rpm -qa 'libreoffice*'") ]] || die "LibreOffice est présent (D-035)"
}

# Lance une application dans la session du compte de test, par la commande
# de son lanceur principal (qui porte son nom), puis la capture.
capture_app() {
    local name=$1 app=$2 desktop exe
    desktop=/usr/share/applications/$app.desktop
    exe=$(vm "sed -n 's/^Exec=\([^ ]*\).*/\1/p' $desktop | head -n 1")
    echo "$name : $desktop ($exe)"
    vm systemd-run --machine=ankhvm@ --user --collect --quiet "$exe"
    sleep 30
    screenshot "$name"
}

# D-036 : premier lancement de VS Code depuis le menu, comme un clic : une
# fenêtre montre la préparation de l'environnement de dev (téléchargement du
# conteneur, extensions), puis VS Code s'ouvre. Captures des deux moments.
check_vscode() {
    local deadline=$((SECONDS + 2400)) next=$((SECONDS + 300)) journal=/home/ankhvm/.cache/ankh/preparation-dev.log
    vm systemd-run --machine=ankhvm@ --user --unit=ankh-vscode-premier-clic --quiet /usr/libexec/ankh-vscode
    sleep 60
    screenshot 1-vscode-preparation
    until vm pgrep -u ankhvm -f /usr/share/code/code > /dev/null; do
        if ((SECONDS >= deadline)); then
            screenshot 1-vscode-echec
            explain_vscode "$journal"
            die "VS Code ne s'est pas ouvert 40 minutes après le premier clic (D-036)"
        fi
        if ((SECONDS >= next)); then
            next=$((SECONDS + 300))
            echo "Préparation en cours, fin du journal :"
            if ! vm "tail -n 3 $journal"; then
                echo "(journal de préparation absent)"
            fi
        fi
        sleep 15
    done
    sleep 45
    screenshot 1-vscode
    echo "VS Code ouvert au premier clic, environnement de dev préparé"
}

# Quand VS Code ne s'ouvre pas : journal de la préparation, sortie du
# lanceur, et conteneurs du compte de test.
explain_vscode() {
    local cmd
    log "Diagnostic : VS Code ne s'est pas ouvert"
    for cmd in \
        "tail -n 60 $1" \
        'journalctl --no-pager -n 60 _SYSTEMD_USER_UNIT=ankh-vscode-premier-clic.service' \
        'systemd-run --machine=ankhvm@ --user --wait --pipe --quiet podman ps -a'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# D-024, D-035 : Chrome installe lui-même les applications web Claude et
# GitHub (politique WebAppInstallForceList) et leur crée un lanceur dans le
# menu. Chrome doit avoir été ouvert une fois, avec internet.
check_web_apps() {
    local dir=/home/ankhvm/.local/share/applications deadline=$((SECONDS + 300)) app
    for app in Claude GitHub; do
        until vm "grep -lsx 'Name=$app' $dir/chrome-*.desktop"; do
            if ((SECONDS >= deadline)); then
                if ! vm "grep -H '^Name=' $dir/*.desktop"; then
                    echo "Aucun lanceur dans $dir"
                fi
                die "Chrome n'a pas installé l'application web $app (D-024)"
            fi
            sleep 10
        done
    done
    echo "Applications web installées par Chrome : Claude et GitHub"
}

((EUID == 0)) || die "à lancer en root (podman de root, disque en boucle, KVM)"
[[ -e /dev/kvm ]] || die "/dev/kvm absent : KVM est nécessaire"
for f in OVMF_CODE_4M.secboot.fd OVMF_VARS_4M.ms.fd; do
    [[ -f $ovmf/$f ]] || die "$ovmf/$f absent (paquet ovmf)"
done
base=$(sed -n 's/^ANKH_BASE=//p' "$repo/bases.env")
[[ $base == *@sha256:* ]] || die "ANKH_BASE absent de bases.env ou sans digest"
base_ref="${base%%:*}@${base##*@}"
base_digest=${base##*@}
# D-028 : numéro de version d'Ankh, que Discover compare pour proposer une mise à jour.
image_version=$(podman image inspect --format '{{ index .Labels "org.opencontainers.image.version" }}' "$image")
[[ -n $image_version ]] || die "$image n'a pas de label org.opencontainers.image.version"

log "Préparation dans $work"
mkdir -p "$work/captures"
ssh-keygen -q -t ed25519 -N '' -C ankh-vmtest -f "$work/id_ed25519"
rm -f "$work/disk.raw"
truncate -s 40G "$work/disk.raw"
# Variables UEFI avec les clés Microsoft : le shim signé de Fedora démarre
# avec Secure Boot actif, comme sur un vrai PC.
cp "$ovmf/OVMF_VARS_4M.ms.fd" "$work/vars.fd"

log "Installation de $image sur le disque virtuel"
# Méthode officielle : https://github.com/bootc-dev/bootc/blob/main/docs/src/bootc-installation.7.md
# Les arguments du noyau et la clé SSH de root deviennent l'état local de la
# machine : ils restent valables après chaque basculement d'image.
podman run --rm --privileged --pid=host --ipc=host \
    --security-opt label=type:unconfined_t \
    -v /dev:/dev -v /var/lib/containers:/var/lib/containers -v "$work:/output" \
    "$image" \
    bootc install to-disk --generic-image --via-loopback --filesystem btrfs \
    --skip-fetch-check \
    --root-ssh-authorized-keys /output/id_ed25519.pub \
    --karg console=tty0 --karg console=ttyS0,115200n8 \
    --karg plymouth.ignore-serial-consoles \
    --karg systemd.wants=sshd.service \
    /output/disk.raw

log "Démarrage de la VM (UEFI, Secure Boot)"
qemu-system-x86_64 \
    -name ankh-vmtest \
    -machine q35,smm=on,accel=kvm -cpu host -smp 4 -m 8192 \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,readonly=on,file="$ovmf/OVMF_CODE_4M.secboot.fd" \
    -drive if=pflash,format=raw,unit=1,file="$work/vars.fd" \
    -drive if=virtio,format=raw,file="$work/disk.raw" \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$port-:22" \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-rng-pci \
    -device virtio-vga -display none \
    -serial "file:$work/serial.log" \
    -monitor "unix:$work/monitor.sock,server=on,wait=off" &
qemu_pid=$!

log "1/4 Premier démarrage de $image"
# D-034 : l'écran de démarrage, capturé pendant le démarrage. Son moment
# exact dépend de la vitesse de la VM, d'où plusieurs captures.
for n in 1 2 3 4; do
    sleep 5
    screenshot "0-demarrage-$n"
done
wait_boot
check_boot
check_ankh
installed=$(booted imageDigest)
check_installed
screenshot 1-ecran-de-connexion

log "Bureau de test : compte « ankhvm » connecté automatiquement, Discover, Chrome et « À propos »"
# Réglages locaux de la VM de test seulement (comme la clé SSH) : ils restent
# valables après chaque basculement, pour capturer le bureau de chaque image.
# ssh recolle les arguments : la commande est passée en une seule chaîne.
vm "useradd -m -c 'Compte de test Ankh' ankhvm"
# Ni verrouillage ni écran éteint pendant le test (sinon les captures montrent
# l'écran de verrouillage, puis un écran noir) : réglages du compte de test.
vm "install -d -o ankhvm -g ankhvm /home/ankhvm/.config &&
    printf '[Daemon]\nAutolock=false\nLockOnResume=false\n' > /home/ankhvm/.config/kscreenlockerrc &&
    printf '[AC][Display]\nDimDisplayWhenIdle=false\nTurnOffDisplayWhenIdle=false\n' > /home/ankhvm/.config/powerdevilrc &&
    chown ankhvm:ankhvm /home/ankhvm/.config/kscreenlockerrc /home/ankhvm/.config/powerdevilrc"
configure_autologin
wait_desktop 1-bureau
vm systemd-run --machine=ankhvm@ --user --collect --quiet plasma-discover --mode update
sleep 30
screenshot 1-discover-mises-a-jour
vm systemd-run --machine=ankhvm@ --user --collect --quiet \
    google-chrome --no-first-run --no-default-browser-check https://github.com/PatrickChoumi/Ankh
sleep 30
screenshot 1-chrome
check_web_apps
capture_app 1-vlc vlc
capture_app 1-onlyoffice onlyoffice-desktopeditors
vm systemd-run --machine=ankhvm@ --user --collect --quiet systemsettings kcm_about-distro
sleep 20
screenshot 1-a-propos
check_vscode

log "2/4 Basculement vers une autre version : $other"
vm bootc switch "$other"
show_boot_state
reboot_vm
check_boot
check_ankh
wait_desktop 2-bureau-ankh-publiee
# D-028 : Discover cherche les mises à jour dans le vrai registre (l'image
# installée à l'étape 1 vient du stockage local de la CI, sans registre).
vm systemd-run --machine=ankhvm@ --user --collect --quiet plasma-discover --mode update
sleep 30
screenshot 2-discover-mises-a-jour
[[ $(booted image.image) == "$other" ]] || { explain_deployment; die "l'image démarrée n'est pas $other"; }
[[ $(booted imageDigest) != "$installed" ]] || { explain_deployment; die "le basculement n'a pas changé de version"; }

log "3/4 Retour arrière (bootc rollback)"
vm bootc rollback
reboot_vm
check_boot
check_ankh
[[ $(booted imageDigest) == "$installed" ]] || { explain_deployment; die "le retour arrière n'a pas redémarré la version installée"; }
check_installed
wait_desktop 3-bureau-apres-retour-arriere

log "4/4 Retour à l'image de base : $base_ref"
vm bootc switch "$base_ref"
show_boot_state
reboot_vm
check_boot
[[ $(booted imageDigest) == "$base_digest" ]] || { explain_deployment; die "l'image démarrée n'est pas la base $base_digest"; }
wait_desktop 4-bureau-image-de-base

log "Réussi : démarrage, basculement, retour arrière et retour à la base."
