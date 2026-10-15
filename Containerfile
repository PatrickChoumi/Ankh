# Image système d'Ankh (D-004).
# L'image de base n'a pas de valeur par défaut : elle est fournie par
# `just build <variante>`, qui la lit dans bases.env (D-005, D-017).
ARG BASE_IMAGE

# Les scripts de construction restent hors de l'image finale.
FROM scratch AS ctx
COPY build_files /

# D-052, lot 1 : la police Selawik et les curseurs d'Ankh, compilés depuis
# leurs sources (build_files/outils.sh). Leurs outils de compilation restent
# dans cette étape : seul le résultat, /sortie, entre dans l'image.
FROM ${BASE_IMAGE} AS outils

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y --setopt=install_weak_deps=False install fontmake xcursorgen librsvg2-tools git-core && \
    /ctx/outils.sh /sortie

FROM ${BASE_IMAGE}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=outils,source=/sortie,target=/outils \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Vérification de conformité de l'image bootc.
RUN bootc container lint
