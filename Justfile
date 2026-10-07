# Recettes du projet Ankh (D-015). `just` sans argument liste les recettes.
# Variantes (D-021) : ankh (Mesa : AMD, Intel) et ankh-nvidia (NVIDIA récent).

# Liste les recettes disponibles
default:
    @just --list

# Construit l'image d'une variante : just build ankh
build variant:
    #!/usr/bin/env bash
    set -euo pipefail
    base="$({{ just_executable() }} _base {{ variant }})"
    echo "Construction de {{ variant }} à partir de ${base}"
    podman build \
        --pull=missing \
        --build-arg "BASE_IMAGE=${base}" \
        --label "org.opencontainers.image.title={{ variant }}" \
        --label "org.opencontainers.image.description=Ankh, OS personnel image-based (variante {{ variant }})" \
        --label "org.opencontainers.image.source=https://github.com/PatrickChoumi/Ankh" \
        --label "org.opencontainers.image.licenses=Apache-2.0" \
        --tag "localhost/{{ variant }}:latest" \
        --file Containerfile \
        .

# Vérifie une image construite : just test ankh
test variant:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ just_executable() }} _base {{ variant }} > /dev/null
    image="localhost/{{ variant }}:latest"
    run() { podman run --rm --network=none "${image}" bash -c "$1"; }

    echo "Test 1 : un seul noyau dans l'image"
    kernels="$(run 'ls /usr/lib/modules | wc -l')"
    if [[ "${kernels}" != "1" ]]; then
        echo "ÉCHEC : ${kernels} noyaux trouvés" >&2
        exit 1
    fi

    echo "Test 2 : le timer de redémarrage automatique est masqué (D-010)"
    run '[[ "$(readlink /etc/systemd/system/bootc-fetch-apply-updates.timer)" == /dev/null ]]'

    if [[ "{{ variant }}" == "ankh-nvidia" ]]; then
        echo "Test 3 : module NVIDIA présent pour le noyau de l'image, et signé"
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
        *)
            echo "Variante inconnue : {{ variant }} (attendu : ankh ou ankh-nvidia)" >&2
            exit 1
            ;;
    esac
    ref="$(sed -n "s/^${key}=//p" bases.env)"
    if [[ -z "${ref}" ]]; then
        echo "${key} est absent de bases.env" >&2
        exit 1
    fi
    echo "${ref}"
