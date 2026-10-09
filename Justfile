# Recettes du projet Ankh (D-015). `just` sans argument liste les recettes.
# Variantes (D-021) : ankh (Mesa : AMD, Intel) et ankh-nvidia (NVIDIA récent).
# Conteneur de dev (D-032) : ankh-dev.

# Liste les recettes disponibles
default:
    @just --list

# Construit l'image d'une variante : just build ankh
build variant:
    #!/usr/bin/env bash
    set -euo pipefail
    base="$({{ just_executable() }} _base {{ variant }})"
    # D-028 : numéro de version propre à Ankh, croissant à chaque construction
    # (version de Fedora de la base, puis date et heure UTC). Discover s'en
    # sert pour savoir qu'une mise à jour existe.
    fedora="${base%@*}"
    fedora="${fedora##*:}"
    version="${fedora}.$(date -u +%Y%m%d.%H%M)"
    file=Containerfile
    context=.
    description="Ankh, OS personnel image-based (variante {{ variant }})"
    if [[ "{{ variant }}" == ankh-dev ]]; then
        file=dev/Containerfile
        context=dev
        description="Ankh, conteneur de dev (D-032)"
    fi
    echo "Construction de {{ variant }} ${version} à partir de ${base}"
    podman build \
        --pull=missing \
        --build-arg "BASE_IMAGE=${base}" \
        --label "org.opencontainers.image.version=${version}" \
        --label "version=${version}" \
        --label "org.opencontainers.image.title={{ variant }}" \
        --label "org.opencontainers.image.description=${description}" \
        --label "org.opencontainers.image.source=https://github.com/PatrickChoumi/Ankh" \
        --label "org.opencontainers.image.licenses=Apache-2.0" \
        --tag "localhost/{{ variant }}:latest" \
        --file "${file}" \
        "${context}"

# Vérifie une image construite : just test ankh
test variant:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ just_executable() }} _base {{ variant }} > /dev/null
    image="localhost/{{ variant }}:latest"
    if [[ "{{ variant }}" == ankh-dev ]]; then
        {{ just_executable() }} _test-dev
        exit 0
    fi
    run() { podman run --rm --network=none "${image}" bash -c "$1"; }

    echo "Test 1 : un seul noyau dans l'image"
    kernels="$(run 'ls /usr/lib/modules | wc -l')"
    if [[ "${kernels}" != "1" ]]; then
        echo "ÉCHEC : ${kernels} noyaux trouvés" >&2
        exit 1
    fi

    echo "Test 2 : le timer de redémarrage automatique est masqué (D-010)"
    run '[[ "$(readlink /etc/systemd/system/bootc-fetch-apply-updates.timer)" == /dev/null ]]'

    echo "Test 3 : module Discover des mises à jour système, à la version de Discover (D-028)"
    run 'q() { rpm -q --qf "%{VERSION}-%{RELEASE}" "$1"; }; [[ "$(q plasma-discover-rpm-ostree)" == "$(q plasma-discover)" ]]'

    echo "Test 4 : numéro de version propre à Ankh (D-028)"
    label() { podman image inspect --format "{{{{ index .Labels \"$1\" }}" "${image}"; }
    version="$(label org.opencontainers.image.version)"
    if [[ ! "${version}" =~ ^[0-9]+\.[0-9]{8}\.[0-9]{4}$ || "$(label version)" != "${version}" ]]; then
        echo "ÉCHEC : version « ${version} » absente, mal formée ou différente du label version" >&2
        exit 1
    fi

    echo "Test 5 : Chrome installé dans /opt, dossier de l'image, et il démarre (D-023)"
    run '[[ -d /opt && ! -L /opt ]] && google-chrome --version'

    echo "Test 6 : Firefox absent (D-023)"
    run '! rpm -q firefox && [[ ! -e /usr/share/applications/firefox.desktop ]]'

    echo "Test 7 : Chrome est l'application par défaut pour le web (D-023)"
    run 'for t in text/html x-scheme-handler/http x-scheme-handler/https; do
        XDG_CURRENT_DESKTOP=KDE gio mime "${t}" | grep -q "^Default application.*: google-chrome.desktop$" || exit 1
    done'

    echo "Test 8 : aucune mise à jour automatique (D-031)"
    run 'for u in rpm-ostreed-automatic.timer flatpak-system-update.timer; do
        [[ "$(readlink "/etc/systemd/system/${u}")" == /dev/null ]] || exit 1
    done
    [[ "$(readlink /etc/systemd/user/flatpak-user-update.timer)" == /dev/null ]] &&
        grep -qx "AutomaticUpdatePolicy=none" /etc/rpm-ostreed.conf'

    echo "Test 9 : raccourcis du conteneur de dev, et socket Podman de l'utilisateur (D-032)"
    run 'test -x /usr/libexec/ankh-dev && test -f /usr/share/ankh/distrobox.ini &&
        command -v distrobox konsole > /dev/null &&
        desktop-file-validate /usr/share/applications/ankh-dev-creer.desktop /usr/share/applications/ankh-dev-mettre-a-jour.desktop &&
        test -L /etc/systemd/user/sockets.target.wants/podman.socket'

    echo "Test 10 : habillage Ankh sur le bureau, ID de Fedora conservé (D-033)"
    run '. /etc/os-release && [[ "${NAME}" == Ankh && "${PRETTY_NAME}" == Ankh && "${ID}" == fedora && "${LOGO}" == ankh-logo ]] &&
        grep -aq ankh-logo /usr/share/icons/hicolor/icon-theme.cache &&
        test -f /usr/share/wallpapers/Ankh/metadata.json -a -f /usr/share/wallpapers/Ankh/contents/images/3840x2160.jpg -a -f /usr/share/wallpapers/Ankh/contents/images_dark/3840x2160.jpg &&
        test -f /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/ankh-lanceur.js &&
        for f in /usr/share/plasma/look-and-feel/*/contents/defaults; do
            grep -q "^\[Wallpaper\]" "${f}" || continue
            [[ "$(sed -n "/^\[Wallpaper\]/,/^\[/ s/^Image=//p" "${f}")" == Ankh ]] || { echo "Fond par défaut inchangé : ${f}" >&2; exit 1; }
        done'

    if [[ "{{ variant }}" == "ankh-nvidia" ]]; then
        echo "Test 11 : module NVIDIA présent pour le noyau de l'image, et signé"
        run 'k="$(ls /usr/lib/modules)"; modinfo -k "${k}" nvidia > /dev/null && [[ -n "$(modinfo -k "${k}" -F signer nvidia)" ]]'
    fi

    echo "Tous les tests de {{ variant }} sont passés."

# Affiche l'image de base (tag + digest) d'une variante, lue dans bases.env
_base variant:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{ variant }}" in
        ankh) key=ANKH_BASE ;;
        ankh-nvidia) key=ANKH_NVIDIA_BASE ;;
        ankh-dev) key=ANKH_DEV_BASE ;;
        *)
            echo "Variante inconnue : {{ variant }} (attendu : ankh, ankh-nvidia ou ankh-dev)" >&2
            exit 1
            ;;
    esac
    ref="$(sed -n "s/^${key}=//p" bases.env)"
    if [[ -z "${ref}" ]]; then
        echo "${key} est absent de bases.env" >&2
        exit 1
    fi
    echo "${ref}"

# Vérifie l'image du conteneur de dev (D-032), appelée par « just test ankh-dev »
_test-dev:
    #!/usr/bin/env bash
    set -euo pipefail
    image="localhost/ankh-dev:latest"
    # Avec un vrai compte ordinaire et un shell de connexion, comme dans
    # distrobox : VS Code refuse root, et /etc/profile.d est lu.
    run() { podman run --rm "${image}" bash -c "useradd -m testeur && runuser -u testeur -- bash -lc $(printf %q "$1")"; }

    echo "Test 1 : chaque outil répond (D-032)"
    run 'set -e
        java -version; javac -version; mvn -v
        python3 --version; pip --version; pipx --version; uv --version
        node --version; npm --version
        gcc --version; g++ --version; clang --version; gdb --version; cmake --version
        git --version; gh --version
        psql --version; mariadb --version; sqlite3 --version; valkey-cli --version
        podman --version; podman-compose --version'

    echo "Test 2 : VS Code officiel de Microsoft"
    run 'code --version'

    echo "Test 3 : la création installe chaque extension et règle VS Code (D-031)"
    run 'set -e
        /usr/libexec/ankh-dev-setup
        attendues=$(grep -Evc "^[[:space:]]*(#|$)" /usr/share/ankh-dev/vscode-extensions.txt)
        installees=$(code --list-extensions | tr "[:upper:]" "[:lower:]")
        for e in $(grep -Ev "^[[:space:]]*(#|$)" /usr/share/ankh-dev/vscode-extensions.txt); do
            grep -qx "$(echo "${e}" | tr "[:upper:]" "[:lower:]")" <<< "${installees}" || { echo "Extension absente : ${e}" >&2; exit 1; }
        done
        echo "${attendues} extensions installées"
        grep -q "\"extensions.autoUpdate\": false" "${HOME}/.config/Code/User/settings.json"'

    echo "Tous les tests de ankh-dev sont passés."
