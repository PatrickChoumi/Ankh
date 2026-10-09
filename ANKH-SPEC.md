# ANKH-SPEC — Spécification de mon poste personnel

> Version 0.2 (brouillon) — 2026-10-07
>
> Ce document décrit **ce que je fais avec ma machine**. C'est lui qui dicte l'architecture.
> Les choix et leurs justifications sont dans [DECISIONS.md](DECISIONS.md) (référencés `D-xxx`).
> La vue d'ensemble et la récupération après panne sont dans [README.md](README.md). Les règles et la feuille de route sont dans [CLAUDE.md](CLAUDE.md).

## Légende

| Marqueur | Signification |
|---|---|
| `DÉCIDÉ` | Choix acté, justifié dans DECISIONS.md |
| `TODO` | Réponse que je dois fournir |
| `UNKNOWN` | Information à mesurer sur la machine |
| `À VALIDER` | Hypothèse à prouver par une documentation officielle, un test reproductible ou une expérience réelle sur ma machine |
| `À DÉCIDER` | Choix ouvert, dépend d'une réponse de ce document |
| `EXIGÉ` | Besoin que j'ai formulé. La façon de le réaliser reste à décider (DECISIONS.md) |

---

## Exigences générales

- **Incassable et extrêmement stable, mais à la pointe** — EXIGÉ.
  - Ce qui touche au démarrage du système avance prudemment.
  - Les applications restent à jour.
- **Usage du terminal limité au strict nécessaire** (dev et hacking) — EXIGÉ, sens « confort » (D-025), voir 4.7.
- **Accès au contenu pour adultes extrêmement difficile** — EXIGÉ, voir 4.8.

---

## 1. Questions prioritaires

Ces réponses peuvent modifier l'architecture. Depuis D-021 (image générique), elles ne bloquent plus la phase 1. Elles restent nécessaires avant les phases indiquées au §6.

| # | Question | Réponse | Ce que la réponse peut changer |
|---|---|---|---|
| 1 | Desktop ou laptop ? | TODO | Veille/réveil, GPU hybride, batterie, Wi-Fi interne |
| 2 | CPU (modèle exact) ? | UNKNOWN | Virtualisation matérielle et IOMMU, nombre de VMs simultanées |
| 3 | GPU (modèle exact) ? | UNKNOWN | Variante d'Ankh que j'installerai (D-021), Secure Boot avec un pilote tiers (D-006), CUDA/ROCm |
| 4 | RAM ? | UNKNOWN | Nombre de VMs et de conteneurs en parallèle d'un jeu |
| 5 | Stockage disponible (disques, tailles, espace libre) ? | UNKNOWN | Place pour les VMs, images de conteneurs, jeux, sauvegardes locales |
| 6 | Jeux principaux + anticheat de chacun ? | TODO | Un jeu dont l'anticheat refuse Linux est injouable : ni Windows ni dual boot (D-003) |
| 7 | Besoin d'IA locale / CUDA / ROCm ? | TODO | Calcul GPU dans les conteneurs, choix de l'image de base (D-005) |
| 8 | Analyse de malware : sous Windows, sous Linux, ou aucune ? | TODO | VM Windows (licence), isolation réseau du lab, outils de reverse (D-014) |
| 9 | Wi-Fi offensif : oui/non ? Adaptateur USB déjà possédé (modèle) ? | TODO | Achat d'un adaptateur, passthrough USB vers une VM (D-014) |
| 10 | Distro actuelle, et ce qu'il faut conserver (outils, données, comportements) ? | Distro : UNKNOWN — Outils : TODO — Données : TODO — Comportements : TODO | Liste de migration, volume à sauvegarder avant l'installation |
| 11 | Temps disponible pour le projet chaque semaine ? | TODO | Périmètre de la V1 |
| 12 | Connexion internet : débit, limite de données, stabilité ? | Connexion **lente**, mais les mises à jour sont faisables (2026-10-07). Débit exact : UNKNOWN | Où et comment installer, fréquence des mises à jour (D-027) |

### Comment trouver les réponses `UNKNOWN`

Commandes à lancer sur la machine actuelle. Elles ne font que lire, elles ne modifient rien.

```bash
lscpu                                    # Q2 : modèle du CPU, ligne "Virtualization"
lspci -nn | grep -Ei 'vga|3d|display'    # Q3 : GPU exact
free -h                                  # Q4 : RAM
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL   # Q5 : disques
df -h                                    # Q5 : espace libre
cat /etc/os-release                      # Q10 : distro actuelle
```

Pour Q6, vérifier chaque jeu sur <https://areweanticheatyet.com> et <https://www.protondb.com>.

---

## 2. Déjà décidé

| Décision | Référence |
|---|---|
| Ankh est strictement personnel. Pas de distribution publique | D-001 |
| Pas d'ISO custom en V1. À l'écran, plus rien de Fedora ; sous le capot, Fedora reste | D-001, D-033, D-034 |
| Image générique, pour le maximum de PC (couverture matérielle proposée dans D-021) | D-021 |
| Linux uniquement, pas de dual boot | D-003 |
| Système immuable / image-based | D-004 |
| Secure Boot activé | D-006 |
| Chiffrement LUKS | D-007 |
| Pas de désactivation de sécurité pour faire fonctionner un outil | D-008 |
| Pas de `rpm-ostree install` sur la machine, pas de `curl \| bash` sur l'hôte | D-009 |
| Pas de redémarrage automatique | D-010 |
| Gaming principalement via Flatpak/Steam | D-011 |
| Outils offensifs hors de l'hôte | D-013 |
| Malware hors de l'hôte | D-014 |

---

## 3. Architecture envisagée (`À VALIDER`)

Le schéma d'ensemble est dans [README.md](README.md#architecture-générale-envisagée).

Points ouverts dans cette architecture :

- **Image de base exacte** : DÉCIDÉ. `kinoite-main` (Mesa) et `kinoite-nvidia` (NVIDIA récent), Fedora 44 (D-005).
- **Bureau** : KDE Plasma — DÉCIDÉ (D-004).
- **Outil du conteneur dev** (distrobox, toolbx ou Podman seul) : `À DÉCIDER` (D-012).
- **Besoins réseau bas niveau** (scan SYN, ARP, mode monitor) : probablement impossibles en conteneur rootless (`À VALIDER`). Solution (VM ou conteneur rootful éphémère) : `À DÉCIDER` (D-013).
- **Version de Fedora** (D-017) et **construction et publication de l'image** (D-018) : DÉCIDÉ. **Sauvegarde et récupération** (D-019) : `PROPOSÉE`, à valider.

---

## 4. Questionnaire détaillé

### 4.1 Matériel

- **CPU** : voir Q2
- **GPU** : voir Q3
- **RAM** : voir Q4
- **Stockage** : voir Q5
- **Wi-Fi (puce interne)** : UNKNOWN
- **Bluetooth** : UNKNOWN
- **Écrans** (nombre, résolution, fréquence, VRR, HDR) : TODO
- **Périphériques** (clavier et disposition, souris, manettes, casque, webcam, imprimante, clé de sécurité matérielle) : TODO
- **TPM2 présent** : UNKNOWN
- **Virtualisation activée dans le firmware** : UNKNOWN
- **État actuel de Secure Boot** : UNKNOWN

### 4.2 Dev

- **Langages** : TODO
- **IDE / éditeur** : Visual Studio Code, installé par défaut — EXIGÉ. Mode d'installation (Flatpak, image ou conteneur dev) : À DÉCIDER en phase 3
- **Git / GitHub** (comptes, clés SSH, signature des commits) : TODO
- **Client GitHub installé par défaut** — EXIGÉ. Application web github.com dans Chrome, plus Git dans VS Code — DÉCIDÉ (D-024)
- **IA / CLI** (assistants, outils en ligne de commande) : TODO
- **Claude installé par défaut** — EXIGÉ. Application web claude.ai dans Chrome — DÉCIDÉ (D-024)
- **Conteneurs** : besoin d'une compatibilité Docker (socket, compose) ? TODO
- **Bases de données** : TODO
- **Autres outils** : TODO

### 4.3 Gaming

- **Steam** : DÉCIDÉ, en Flatpak (D-011)
- **Autres launchers** (Heroic, Lutris, …) : TODO
- **Jeux principaux** : voir Q6
- **Proton** : besoin d'une version particulière ? TODO
- **Manettes** (modèles, filaire ou sans fil) : TODO
- **VRR / HDR / multi-écran** : TODO
- **Streaming / enregistrement** (OBS, …) : TODO
- **Mode console** (Steam plein écran) : TODO

### 4.4 Cyber

> Cadre : uniquement sur des systèmes que je possède ou pour lesquels j'ai une autorisation écrite.

- **CTF / plateformes d'entraînement** : TODO
- **Pentest** : usage personnel uniquement, ou missions avec des données de tiers ? TODO (impact sur le chiffrement, la sauvegarde et la conservation des données)
- **Réseau bas niveau** (scan SYN, ARP, captures) : TODO
- **Wireshark** : TODO
- **Kali** : liste des outils réellement utilisés : TODO
- **VMs nécessaires** (systèmes, nombre, simultanées) : TODO
- **Malware / reverse engineering** : voir Q8. Outils : TODO
- **Wi-Fi offensif** : voir Q9

### 4.5 Vie quotidienne

- **Navigateur** : Google Chrome, navigateur par défaut, installé dans l'image ; Firefox retiré — DÉCIDÉ (D-023)
- **Communication** : TODO
- **Musique** : TODO
- **Cloud / synchronisation** : TODO
- **Multimédia** (vidéo, photo) : VLC en Flatpak préinstallé — DÉCIDÉ (D-024). Photo : TODO
- **Bureautique** : OnlyOffice en Flatpak préinstallé — DÉCIDÉ (D-024)

### 4.6 Sécurité, sauvegarde et secrets

- **Déverrouillage LUKS par TPM2** (en plus de la phrase de passe) : TODO
- **Destination des sauvegardes** (disque externe, réseau, cloud) : TODO
- **Fréquence des sauvegardes** : TODO
- **Gestion des secrets** (gestionnaire de mots de passe, clés SSH/GPG) : TODO
- **Volume de données à sauvegarder** : UNKNOWN

### 4.7 Système

- **Langue et disposition du clavier** : TODO
- **Bureau** : KDE Plasma (via Kinoite) — DÉCIDÉ (D-004)
- **Terminal limité au strict nécessaire** (dev et hacking) — DÉCIDÉ (D-025). Sens « confort » : tout le quotidien se fait sans terminal, et l'accès au terminal n'est pas restreint.

### 4.8 Protection contre le contenu pour adultes

- **Exigence** : accès au contenu pour adultes extrêmement difficile — EXIGÉ.
- **Référence** : mon projet safezone, <https://github.com/PatrickChoumi/safezone> (« blocker-adulte »). Il comporte huit composants : résolveur DNS filtrant avec SafeSearch forcé, pare-feu nftables, politiques navigateur, hook initramfs, surveillance croisée, auto-réparation, auditd.
- **Adaptation à un système image-based** : safezone adapté et intégré à l'image — DÉCIDÉ (principe, D-026). Conception détaillée : À DÉCIDER en phase 4. safezone est conçu pour des distributions classiques (`install.sh`, `chattr +i`, regénération locale de l'initramfs) et ne gère pas encore ostree/bootc.

---

## 5. Ce que je ne veux PAS

- Pas de distribution publique.
- Pas d'ISO custom en V1.
- Pas de nom ni de logo de Fedora à l'écran (D-034). Sous le capot, Fedora ne me dérange pas.
- Pas de réglage propre à une seule machine dans l'image (D-021).
- Pas de dual boot ni de Windows installé en natif (une VM Windows reste possible, voir Q8).
- Pas d'outils offensifs sur l'hôte.
- Pas de malware sur l'hôte.
- Pas de `rpm-ostree install` manuel.
- Pas de `curl | bash` sur l'hôte.
- Pas de redémarrage automatique.
- Pas de désactivation de Secure Boot, du pare-feu ou du chiffrement pour contourner un problème.
- Pas de gros CLI maison tant qu'une recette `just` suffit.
- Pas de duplication inutile de documentation : chaque information vit dans un seul fichier.
- Mes ajouts : TODO

---

## 6. Prêt à avancer quand

Avant la phase 1 (base et chaîne de build) :
- [x] Bureau confirmé (4.7)
- [x] Image de base choisie (D-005)
- [x] D-017 et D-018 validées

Avant les phases 5 à 7 (gaming, cyber, labs) :
- [ ] Questions 6 à 9 remplies

Avant la phase 9 (bascule sur ma machine) :
- [ ] Questions 1 à 5 et 10 à 12 remplies
