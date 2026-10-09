# shellcheck shell=sh
# D-032 : podman (podman-remote) pilote le Podman du système, par le socket
# de l'utilisateur.
CONTAINER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
export CONTAINER_HOST
