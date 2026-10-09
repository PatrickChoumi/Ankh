# DECISIONS — Journal des décisions d'Ankh

> Chaque entrée contient : **Statut**, **Contexte**, **Décision**, **Raisons**, **Alternatives rejetées**, **Vérification** (source ou test).
>
> **Statuts :**
> - `DÉCIDÉ` : choix acté.
> - `À DÉCIDER` : choix ouvert. Ce qui le débloque est indiqué.
> - `PROPOSÉE — À VALIDER` : proposition issue du brainstorming, pas encore acceptée.
>
> Dans une entrée, toute affirmation marquée `À VALIDER` n'est pas encore prouvée. Elle ne doit pas être traitée comme un fait.
> « Vérifié le 2026-10-07 » veut dire : consulté dans la source citée à cette date. Ça peut changer depuis.
>
> **Règle :** on ne supprime pas une entrée. On la remplace par une nouvelle qui la cite (« remplace D-00X »).
>
> Les besoins sont dans [ANKH-SPEC.md](ANKH-SPEC.md), la vue d'ensemble dans [README.md](README.md).

## Index

| ID | Décision | Statut |
|---|---|---|
| D-001 | Poste personnel, pas une distribution | DÉCIDÉ (« une seule machine » remplacé par D-021 ; « pas de branding » modifié par D-033) |
| D-002 | Une seule machine, un seul GPU en V1 | REMPLACÉE par D-021 |
| D-003 | Linux uniquement, pas de dual boot | DÉCIDÉ |
| D-004 | Système image-based : Fedora Atomic (Kinoite) + bootc | DÉCIDÉ (principe) |
| D-005 | Image de base exacte : `kinoite-main` + `kinoite-nvidia` (Fedora 44) | DÉCIDÉ |
| D-006 | Secure Boot activé | DÉCIDÉ |
| D-007 | Chiffrement LUKS | DÉCIDÉ |
| D-008 | Aucune sécurité désactivée pour faire marcher un outil | DÉCIDÉ |
| D-009 | Hôte reproductible : pas de `rpm-ostree install`, pas de `curl \| bash` | DÉCIDÉ |
| D-010 | Pas de redémarrage automatique | DÉCIDÉ |
| D-011 | Applications en Flatpak, gaming via Steam Flatpak | DÉCIDÉ |
| D-012 | Environnement dev en conteneur | DÉCIDÉ (précisé par D-032) |
| D-013 | Outils offensifs hors de l'hôte, Kali via Podman rootless | DÉCIDÉ |
| D-014 | Malware et labs dans des VMs isolées (libvirt/KVM) | DÉCIDÉ |
| D-015 | Recettes `just` plutôt qu'un CLI maison | DÉCIDÉ |
| D-016 | Le dépôt est la source de vérité, toute affirmation importante est prouvée | DÉCIDÉ (complétée par D-020) |
| D-017 | Version de Fedora figée, montée de version délibérée | DÉCIDÉ |
| D-018 | Construction, publication et signature de l'image | DÉCIDÉ (signature modifiée par D-022) |
| D-019 | Sauvegarde et récupération : OS / configuration / données / secrets | PROPOSÉE — À VALIDER |
| D-020 | CLAUDE.md, guide de travail du projet | DÉCIDÉ |
| D-021 | Image générique pour le maximum de PC (remplace D-002) | DÉCIDÉ (principe), couverture PROPOSÉE — À VALIDER |
| D-022 | Signature sans clé (keyless) dans GitHub Actions (modifie D-018) | DÉCIDÉ (vérification sur la machine À VALIDER) |
| D-023 | Chrome navigateur par défaut, installé dans l'image ; Firefox retiré | DÉCIDÉ |
| D-024 | Applications par défaut (VLC, OnlyOffice, Claude et GitHub via Chrome, VS Code) | DÉCIDÉ (mécanismes À VALIDER) |
| D-025 | Terminal : le quotidien se fait sans terminal (confort, pas de restriction) | DÉCIDÉ (interface des mises à jour : D-028) |
| D-026 | Protection contre le contenu pour adultes : safezone adapté et intégré | DÉCIDÉ (principe), conception À DÉCIDER ; variantes avec et sans : D-030 |
| D-027 | Connexion internet lente : tests dans le cloud, mises à jour au rythme que je choisis | DÉCIDÉ (2026-10-07, ajusté) |
| D-028 | Mises à jour du système dans Discover (complète D-025) | DÉCIDÉ (comportement dans l'interface À VALIDER) |
| D-029 | AVANCEMENT.md : état de tout ce qui est fait et de ce qui reste | DÉCIDÉ |
| D-030 | Variantes avec et sans protection safezone (complète D-026) | DÉCIDÉ (principe), conception À DÉCIDER en phase 4 |
| D-031 | Aucune mise à jour automatique : je décide quand tout se met à jour (complète D-010, D-027, D-028) | DÉCIDÉ |
| D-032 | Conteneur de dev : Fedora, langages fullstack, VS Code dans le conteneur (précise D-012 et D-024) | DÉCIDÉ (CI verte ; extensions VS Code PROPOSÉES — À VALIDER) |
| D-033 | Habillage Ankh sur le bureau : nom, logo, fonds d'écran (modifie D-001) | DÉCIDÉ (rendu à l'écran À VALIDER en VM) |

---

## D-001 — Poste personnel, pas une distribution

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : le premier brainstorming visait une distribution grand public : installateur, plusieurs variantes matérielles, support d'utilisateurs. C'est une charge de maintenance démesurée pour une seule personne.
- **Décision** : Ankh est l'OS d'une seule machine et d'un seul utilisateur. Pas de distribution publique, pas de branding, pas d'ISO custom en V1.
- **Raisons** : réduire le périmètre (matériel, tests, documentation, support) à ce qui sert réellement.
- **Alternatives rejetées** :
  - Distribution publique dérivée de Fedora Atomic.
  - Plusieurs variantes pour plusieurs profils d'utilisateurs.
- **Vérification** : décision de périmètre, pas technique. Critère d'application : tout ajout qui ne sert qu'à du matériel ou à des usages absents d'ANKH-SPEC.md est refusé.
- **Modifiée par** : D-021 (2026-10-07). « Une seule machine » est remplacé par « une image générique pour le maximum de PC ». Le caractère personnel et non public reste inchangé.
- **Modifiée par** : D-033 (2026-10-09). « Pas de branding » devient « habillage Ankh sur le bureau seulement » : nom, logo et fonds d'écran. Pas d'ISO custom, pas de changement au démarrage.

## D-002 — Une seule machine, un seul GPU en V1

- **Statut** : REMPLACÉE par D-021 (2026-10-07). Était : DÉCIDÉ (2026-10-07).
- **Contexte** : supporter plusieurs GPU demande une image par famille de pilotes, et autant de builds et de tests.
- **Décision** : la V1 cible uniquement mon PC et son GPU.
- **Raisons** : un seul artefact à construire, tester et maintenir, sur du matériel que je peux réellement tester.
- **Alternatives rejetées** : trois variantes dès la V1 (Mesa, NVIDIA récent, NVIDIA ancien). Rejetée parce que je ne peux pas tester sur du vrai matériel ce que je ne possède pas.
- **Vérification** : ANKH-SPEC Q1 à Q5 renseignées. Hypothèse : ajouter une variante plus tard resterait possible sans réinstallation (via `bootc switch`) — `À VALIDER`.

## D-003 — Linux uniquement, pas de dual boot

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : la machine est aujourd'hui entièrement sous Linux.
- **Décision** : aucun Windows installé en natif, pas de dual boot. Une VM Windows reste possible pour le lab (D-014).
- **Raisons** :
  - Simplicité du démarrage.
  - En dual boot, les mises à jour Windows ont déjà empêché Linux de démarrer : mise à jour SBAT de Microsoft, août 2024.
- **Alternatives rejetées** : dual boot Windows pour les jeux à anticheat incompatible.
- **Conséquence** : un jeu dont l'anticheat refuse Linux sera injouable. À contrôler pour chaque jeu (ANKH-SPEC Q6).
- **Vérification** :
  - Incident SBAT : <https://www.bleepingcomputer.com/news/microsoft/microsoft-confirms-august-updates-break-linux-boot-in-dual-boot-systems/>
  - Compatibilité anticheat : <https://areweanticheatyet.com>

## D-004 — Système image-based : Fedora Atomic (Kinoite) + bootc

- **Statut** : DÉCIDÉ (principe, 2026-10-07). L'image exacte relève de D-005.
- **Contexte** : je veux des mises à jour qui s'appliquent entièrement ou pas du tout, et un retour arrière simple.
- **Décision** : l'hôte est une image système immuable de la famille Fedora Atomic (Kinoite), gérée avec bootc. Le système de fichiers système reste en lecture seule. Les mises à jour et les retours arrière se font par image entière.
- **Raisons** :
  - Mises à jour atomiques.
  - Retour au déploiement précédent.
  - Image construite et testée avant d'arriver sur la machine.
- **Alternatives rejetées** :
  - Distribution classique à paquets (mises à jour en place, sans retour arrière natif).
  - NixOS (autre modèle, non retenu pour ce projet).
- **Vérification** :
  - Documentation officielle : <https://docs.fedoraproject.org/en-US/bootc/>
  - Test à faire en VM : `bootc status`, puis appliquer une mise à jour, puis `sudo bootc rollback` et redémarrer. Le déploiement précédent doit démarrer. **Exécuté en phase 2 et réussi** (voir « Mise en œuvre » ci-dessous).
- **Bureau** : KDE Plasma, fourni par Kinoite — confirmé le 2026-10-07.
- **Mise en œuvre (phase 2, 2026-10-07)** : test automatique `tests/vm/run.sh`, lancé par `.github/workflows/boot-test.yml` sur les machines de GitHub (D-027).
  - Le disque de la VM est créé par `bootc install to-disk --via-loopback`, la méthode officielle de bootc pour démarrer une image en VM : <https://github.com/bootc-dev/bootc/blob/main/docs/src/bootc-installation.7.md>. Aucun outil externe.
  - La VM démarre en UEFI avec Secure Boot actif et les clés Microsoft, comme un vrai PC.
  - L'accès SSH de test (clé de root et argument du noyau `systemd.wants=sshd.service`) est posé à l'installation. Ce sont des réglages locaux de la machine, conservés à chaque basculement d'image. Source : <https://github.com/bootc-dev/bootc/blob/main/docs/src/building/bootc-kernel-arguments.7.md>.
  - Étapes vérifiées :
    1. démarrage complet de l'image construite par la PR ;
    2. basculement vers une autre version (`ghcr.io/patrickchoumi/ankh:latest`) ;
    3. `bootc rollback`, qui doit redémarrer la version installée ;
    4. `bootc switch` vers l'image de base épinglée dans `bases.env` (D-005, D-018).
  - À chaque démarrage : Secure Boot actif (D-006), SELinux en mode enforcing et pare-feu actif (D-008). Sur les images Ankh, le timer de redémarrage automatique est masqué (D-010).
  - **Échecs tolérés dans la VM** : un état « degraded » n'est accepté que si chaque service en échec figure dans une liste du script, avec le message de journal qui prouve sa cause. Aujourd'hui, un seul service : `mcelog.service`.
    - mcelog s'arrête avec « CPU is unsupported » sur les processeurs AMD récents ([source](https://github.com/andikleen/mcelog/blob/master/mcelog.c)).
    - Sur un vrai PC AMD, son unité est ignorée quand le module `edac_mce_amd` est chargé ([unité](https://github.com/andikleen/mcelog/blob/master/mcelog.service)). Ce module ne se charge pas dans la VM.
    - Le comportement sur ma vraie machine reste À VALIDER en phase 9.
  - **Résultats** :
    - 1re exécution ([run 37684664588](https://github.com/PatrickChoumi/Ankh/actions/runs/37684664588), 2026-10-07), vérifié par le test :
      - l'installation sur le disque virtuel a réussi en 4 min 30 s ;
      - la VM a démarré en UEFI avec Secure Boot : le noyau signale le mode « Lockdown » ;
      - `sshd` et `firewalld` ont démarré.
    - Le test s'est arrêté à l'état « degraded », causé par `mcelog.service` seul. Ce cas est désormais toléré, comme décrit ci-dessus.
    - 2e exécution ([run 37688598157](https://github.com/PatrickChoumi/Ankh/actions/runs/37688598157), 2026-10-07) : **les 4 étapes ont réussi**. Vérifié par le test :
      1. Installation de l'image de la PR (`localhost/ankh:latest`, `sha256:8e97faea…`) en 6 min, puis démarrage complet.
      2. `bootc switch ghcr.io/patrickchoumi/ankh:latest` : seules 2 couches sur 261 étaient à télécharger (641 octets). Ankh n'ajoute aujourd'hui presque rien à sa base. Après le redémarrage, l'image démarrée est `ghcr.io/patrickchoumi/ankh:latest` (`sha256:48288525…`), soit une autre version.
      3. `bootc rollback` (« Next boot: rollback deployment ») : après le redémarrage, l'image démarrée est de nouveau `sha256:8e97faea…`.
      4. `bootc switch` vers la base épinglée : après le redémarrage, l'image démarrée est `ghcr.io/ublue-os/kinoite-main@sha256:01ea858a…`, avec exactement le digest de `bases.env`.
    - À chacun des 4 démarrages :
      - Secure Boot est actif (variable UEFI `SecureBoot` = 1) ;
      - SELinux est en mode enforcing ;
      - `firewalld` est actif ;
      - seul `mcelog.service` est en échec, avec le message « AMD Processor family 25: mcelog does not support this processor » : la cause attendue.
    - Durée : 12 minutes pour le test lui-même, 33 minutes pour tout le travail CI (construction comprise).
    - **Non vérifié par ce test** :
      - la session graphique ;
  - **Captures d'écran (ajout du 2026-10-08, à ma demande)** :
    - QEMU capture l'écran de la VM (`screendump`) :
      - au premier démarrage, l'écran de connexion ;
      - le bureau KDE d'un compte de test `ankhvm`, connecté automatiquement par le gestionnaire de connexion. Sur Fedora 44, c'est **Plasma Login** et non plus SDDM : `sddm.service` n'existe pas dans l'image (constaté en CI le 2026-10-09). Le test règle donc celui que systemd désigne (`display-manager.service`) ;
      - Discover ouvert sur les mises à jour ;
      - Chrome ouvert sur le dépôt ;
      - le bureau après chaque basculement.
    - Les images sont jointes au run GitHub, section « Artifacts » (`captures-ankh-vm`), et conservées 30 jours.
    - Le compte de test et la connexion automatique sont des réglages locaux de la VM de test, comme la clé SSH. Ils ne sont jamais dans l'image Ankh.
    - Le test échoue si le bureau Plasma ne démarre pas en 3 minutes, après avoir capturé l'écran pour montrer pourquoi.
    - **Résultat ([run 37887155044](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044), 2026-10-09)**, vérifié par le test :
      - le gestionnaire de connexion est `plasmalogin.service` ;
      - le bureau Plasma du compte de test démarre à chacun des 4 démarrages, y compris sur l'image de base ;
      - les 7 captures sont jointes au run (4,4 Mo).
      - L'aspect des captures elles-mêmes est à regarder par moi : l'environnement de Claude ne peut pas télécharger les artefacts.
      - l'imposition de la signature au basculement (aucun message de vérification de signature, À VALIDER, D-022) ;
      - le comportement sur du matériel réel (phase 9).

## D-005 — Image de base exacte

- **Statut** : DÉCIDÉ (2026-10-07). Était : À DÉCIDER.
- **Contexte** : l'image de base détermine le pilote GPU, les codecs, les services de mise à jour et la dépendance éventuelle à Universal Blue.
- **Faits vérifiés le 2026-10-07** :
  - `ghcr.io/ublue-os/kinoite-main:44` et `ghcr.io/ublue-os/kinoite-nvidia:44` sont publiées, en version `44.20261002.0`. Source : métadonnées du registre GHCR.
  - Le Containerfile d'Universal Blue construit à partir de `quay.io/fedora-ostree-desktops/kinoite`. Pour la variante NVIDIA, il installe le pilote depuis l'image `akmods-nvidia-open`. Source : <https://github.com/ublue-os/main/blob/main/Containerfile>
  - D'après Universal Blue, le pilote NVIDIA « open » couvre le matériel récent, et le pilote fermé est requis pour le matériel plus ancien. Une image `akmods-nvidia-lts` existe pour Fedora 44, mais je n'ai trouvé aucune image Kinoite prête à l'emploi qui l'utilise. Source : <https://github.com/ublue-os/akmods>
  - `kinoite-main` ajoute notamment des codecs (ffmpeg), `distrobox`, `just` et `tmux`. Elle active aussi des timers de mise à jour : `rpm-ostreed-automatic` en mode « staged » et les mises à jour Flatpak. Sources :
    - <https://github.com/ublue-os/main/blob/main/packages.json>
    - <https://github.com/ublue-os/main/blob/main/build_files/post-install.sh>
  - **Non vérifié** : la référence exacte de l'image officielle Fedora Kinoite sur quay.io (registre inaccessible depuis mon environnement de travail) — `À VALIDER`.
- **Options** :

  | Option | Image | Pour | Contre |
  |---|---|---|---|
  | A | Fedora Kinoite officiel (référence `À VALIDER`) | Aucune dépendance tierce | Codecs à gérer, pas de pilote NVIDIA |
  | B | `ghcr.io/ublue-os/kinoite-main:44` | Codecs et outils inclus | Dépendance à Universal Blue |
  | C | `ghcr.io/ublue-os/kinoite-nvidia:44` | Pilote NVIDIA open déjà intégré et signé | Matériel NVIDIA récent seulement, dépendance à Universal Blue |
  | D | Image NVIDIA ancien assemblée soi-même (`akmods-nvidia-lts`) | Couvre le matériel NVIDIA ancien | Partie la plus fragile du projet |

- **Décision (2026-10-07)** : options **B + C**.
  - Variante `ankh` (Mesa : AMD, Intel) : à partir de `ghcr.io/ublue-os/kinoite-main:44`.
  - Variante `ankh-nvidia` (NVIDIA récent) : à partir de `ghcr.io/ublue-os/kinoite-nvidia:44`.
  - Chaque base est épinglée par digest (D-017).
- **Contexte de la décision** : depuis D-021, le critère principal n'est plus mon GPU mais la couverture du maximum de PC.
- **Recommandation qui a mené à la décision** : options **B + C**.
  - `kinoite-main` pour la variante Mesa (AMD, Intel), `kinoite-nvidia` pour la variante NVIDIA récent.
  - Les deux viennent de la même lignée Universal Blue. Les variantes ne diffèrent donc que par le pilote.
  - L'option A seule ne permet pas de variante NVIDIA sans compiler le pilote soi-même.
  - Prix : dépendance à Universal Blue.
- **Vérification** : la référence choisie existe et démarre en VM (test non exécuté).

## D-006 — Secure Boot activé

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : Secure Boot n'autorise au démarrage que des composants signés.
- **Décision** : Secure Boot reste activé, quel que soit le GPU.
- **Raisons** : protection de la chaîne de démarrage. Cohérent avec D-008.
- **Alternatives rejetées** : désactiver Secure Boot pour simplifier l'usage d'un pilote tiers.
- **Conséquences selon le GPU (Q3)** :
  - Pilotes intégrés au noyau (AMD, Intel) : aucune clé supplémentaire attendue — `À VALIDER`.
  - NVIDIA via une image Universal Blue : leur clé de signature est à enregistrer une fois par la procédure MOK (`/etc/pki/akmods/certs/akmods-ublue.der`). Source : <https://universal-blue.discourse.group/t/secure-boot-key-mok-management/4310>
- **Vérification** : test `mokutil --sb-state` → « SecureBoot enabled ». Ensuite, session graphique avec accélération GPU fonctionnelle (non exécuté).
- **Vérifié en VM (phase 2, 2026-10-07)**, sur la variante Mesa : démarrage avec Secure Boot actif, sur un micrologiciel UEFI qui a les clés Microsoft (OVMF), sans clé supplémentaire. Même résultat après un basculement, un retour arrière et le retour à la base (D-004). Sur du matériel réel : À VALIDER en phase 9.

## D-007 — Chiffrement LUKS

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : la machine contiendra des données personnelles, des secrets et des données de cybersécurité.
- **Décision** : disque système chiffré avec LUKS, activé à l'installation.
- **Raisons** : protection des données en cas de perte ou de vol.
- **Alternatives rejetées** : pas de chiffrement.
- **Question ouverte** : déverrouillage par TPM2 en plus de la phrase de passe (ANKH-SPEC 4.6).
- **Vérification** : test `lsblk -f` → partition de type `crypto_LUKS` (non exécuté). L'option de chiffrement dans l'installateur Fedora est `À VALIDER` au moment de l'installation.

## D-008 — Aucune sécurité désactivée pour faire marcher un outil

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : certains outils (pilotes, outils réseau, jeux) poussent à désactiver une protection.
- **Décision** : on ne désactive jamais Secure Boot, le pare-feu, le chiffrement ni SELinux pour contourner un problème. On cherche une autre façon d'intégrer l'outil : conteneur, VM, signature, règle de pare-feu ciblée et temporaire. Sinon, on renonce à l'outil.
- **Raisons** : une architecture affaiblie pour un outil l'est pour tout le reste.
- **Alternatives rejetées** : exceptions au cas par cas sans trace.
- **Vérification** : tests à exécuter sur la machine installée :

  ```bash
  mokutil --sb-state      # SecureBoot enabled
  firewall-cmd --state    # running
  getenforce              # Enforcing
  lsblk -f                # crypto_LUKS
  ```

- **Vérifié en VM (phase 2, 2026-10-07)** : par défaut, sans réglage d'Ankh, SELinux est en mode enforcing et `firewalld` est actif à chaque démarrage (D-004). LUKS n'est pas testé en VM.

## D-009 — Hôte reproductible : pas de `rpm-ostree install`, pas de `curl | bash`

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : sur un système image-based, l'ajout local de paquets (`rpm-ostree install`) fait diverger la machine de son image. Exécuter des scripts téléchargés fait tourner du code non relu sur l'hôte.
- **Décision** : rien ne s'installe sur l'hôte en dehors de l'image. Un logiciel va :
  - dans l'image, via une modification relue dans ce dépôt ;
  - ou en Flatpak ;
  - ou dans un conteneur ou une VM.
- **Raisons** : la machine reste égale à son image, donc reconstructible. Tout code système passe par une relecture.
- **Alternatives rejetées** :
  - Ajout local de paquets.
  - Scripts d'installation téléchargés et exécutés sur l'hôte.
- **Vérification** : test `rpm-ostree status` → aucune ligne `LayeredPackages` ni `LocalPackages` (non exécuté).

## D-010 — Pas de redémarrage automatique

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : selon la documentation Fedora bootc, le timer `bootc-fetch-apply-updates.timer` peut télécharger, appliquer et **redémarrer** automatiquement. Il peut être masqué. Source : <https://docs.fedoraproject.org/en-US/bootc/auto-updates/>
- **Décision** : une mise à jour peut être téléchargée et préparée, mais elle ne s'applique qu'au redémarrage que je choisis.
- **Raisons** : ne pas perdre une session de jeu ou de travail.
- **Alternatives rejetées** : mises à jour appliquées avec redémarrage automatique.
- **À VALIDER** : quels services de mise à jour sont réellement actifs sur l'image de base choisie (D-005). Par exemple, `kinoite-main` active `rpm-ostreed-automatic.timer` en mode « staged » (voir sources de D-005).
- **Vérification** : test `systemctl list-timers --all` sur l'image construite. Aucun timer de mise à jour ne doit déclencher de redémarrage (non exécuté).
- **Mise en œuvre (phase 1)** : `build_files/build.sh` masque `bootc-fetch-apply-updates.timer`, comme le recommande la documentation Fedora bootc. Le test `just test` vérifie ce masquage dans chaque image. Le comportement réel de `rpm-ostreed-automatic` (téléchargement sans redémarrage) reste À VALIDER en VM (phase 2).

## D-011 — Applications en Flatpak, gaming via Steam Flatpak

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : les applications évoluent plus vite que le système et n'ont pas besoin d'être dans l'image.
- **Décision** : les applications de bureau (Steam, navigateur, communication, …) sont installées en Flatpak. Le gaming passe principalement par Steam en Flatpak (`com.valvesoftware.Steam`).
- **Raisons** : applications mises à jour indépendamment de l'image, image plus petite.
- **Alternatives rejetées** : Steam installé dans l'image (paquet natif).
- **À VALIDER** :
  - Mes jeux (Q6) fonctionnent avec Steam Flatpak.
  - Aucune bibliothèque 32 bits n'est nécessaire sur l'hôte.
  - Les manettes sont reconnues (des règles udev sur l'hôte pourraient être nécessaires).
- **Vérification** : test réel sur la machine avec la liste de jeux de Q6 (non exécuté).

## D-012 — Environnement dev en conteneur

- **Statut** : DÉCIDÉ (principe, 2026-10-07). L'outil exact est À DÉCIDER : distrobox, toolbx ou Podman seul.
- **Contexte** : les dépendances des projets ne doivent pas polluer l'hôte.
- **Décision** : langages, SDK et outils de développement vivent dans un ou plusieurs conteneurs. Leur définition est versionnée dans ce dépôt pour être recréée à l'identique.
- **Raisons** : hôte propre, environnement jetable et reconstructible.
- **Alternatives rejetées** : installation des outils de dev sur l'hôte (contraire à D-009).
- **Note** : distrobox privilégie l'intégration avec l'hôte, pas l'isolation. C'est acceptable pour le dev, pas pour la cybersécurité (D-013).
- **Vérification** : test futur. Supprimer le conteneur, le recréer depuis sa définition, retrouver un environnement fonctionnel (non exécuté).

## D-013 — Outils offensifs hors de l'hôte, Kali via Podman rootless

- **Statut** : DÉCIDÉ (2026-10-07). La solution pour les besoins réseau bas niveau est À DÉCIDER.
- **Contexte** : les outils offensifs ne doivent pas tourner directement sur la machine où je joue et stocke mes données. Distrobox indique que l'isolation et le sandboxing ne sont pas ses objectifs : il partage le dossier personnel et d'autres ressources de l'hôte.
- **Décision** :
  - Aucun outil offensif dans l'image ni sur l'hôte.
  - Kali tourne dans un conteneur Podman **rootless**, lancé directement avec Podman (pas via distrobox ni toolbx).
  - Seul un dossier de travail dédié est monté dans ce conteneur.
- **Raisons** : limiter ce que les outils et le code exécuté peuvent atteindre sur l'hôte (clés SSH, données personnelles).
- **Alternatives rejetées** :
  - Kali installé sur l'hôte.
  - Kali dans distrobox ou toolbx (intégration, pas isolation).
- **À VALIDER** : les opérations réseau bas niveau (scan SYN, ARP, mode monitor) ne fonctionnent probablement pas en rootless. Solution `À DÉCIDER` : VM (D-014) ou conteneur rootful éphémère.
- **Vérification** :
  - Distrobox : <https://distrobox.it/> et <https://wiki.archlinux.org/title/Distrobox>
  - Comportements de Kali sans root : <https://www.kali.org/docs/general-use/nonroot-behavioral-differences-in-packages/>
  - Tests à écrire (non exécutés) :
    1. Depuis le conteneur, le `~/.ssh` de l'hôte est inaccessible.
    2. `nmap -sS` en rootless : résultat à constater.

## D-014 — Malware et labs dans des VMs isolées (libvirt/KVM)

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : un conteneur partage le noyau de l'hôte. Le code malveillant et les labs offensifs demandent une frontière plus forte.
- **Décision** :
  - Toute analyse de malware et tout lab cyber se font dans des VMs libvirt/KVM.
  - Les réseaux de lab sont isolés de l'hôte et du réseau local.
  - Pas de dossier ni de presse-papier partagé avec une VM d'analyse de malware.
  - Snapshot avant chaque analyse.
- **Raisons** : une VM est une frontière d'isolation plus forte qu'un conteneur.
- **Alternatives rejetées** : analyse de malware dans un conteneur ou sur l'hôte.
- **À VALIDER** :
  - Virtualisation matérielle disponible et activée (Q2).
  - Passthrough USB d'un adaptateur Wi-Fi vers une VM, si Q9 = oui.
  - Sur Fedora Atomic, l'ajout de l'utilisateur au groupe `libvirt` demande de copier la ligne du groupe depuis `/usr/lib/group` vers `/etc/group`. Source : <https://discussion.fedoraproject.org/t/how-can-i-add-myself-to-the-libvirt-group-in-fedora-silverblue/1412>
- **Vérification** : tests futurs (non exécutés). Depuis une VM de lab, l'hôte et le réseau local sont injoignables. La restauration d'un snapshot fonctionne.

## D-015 — Recettes `just` plutôt qu'un CLI maison

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : le brainstorming envisageait une commande `ankh` riche. Un vrai programme serait un projet logiciel de plus à maintenir.
- **Décision** : les automatisations sont des recettes `just`, versionnées dans ce dépôt. Un programme dédié ne sera envisagé que si une recette devient difficile à lire ou à tester.
- **Raisons** : maintenance minimale, rien à compiler.
- **Alternatives rejetées** : CLI dédié (Python, Go, Rust) dès la V1.
- **Vérification** : revue à chaque ajout de recette.

## D-016 — Le dépôt est la source de vérité, toute affirmation importante est prouvée

- **Statut** : DÉCIDÉ (2026-10-07)
- **Contexte** : le brainstorming s'est fait avec plusieurs assistants. Plusieurs affirmations techniques se sont révélées fausses et ont dû être corrigées.
- **Décision** :
  - La documentation tient en trois fichiers : `ANKH-SPEC.md` (besoins), `DECISIONS.md` (choix), `README.md` (vue d'ensemble et récupération).
  - Chaque affirmation technique importante est appuyée par une documentation officielle, un test reproductible ou une expérience réelle sur ma machine.
  - Sinon, elle est marquée `À VALIDER`.
- **Raisons** : éviter de bâtir sur une erreur. Éviter les informations contradictoires dans plusieurs fichiers.
- **Alternatives rejetées** : documentation éclatée (architecture, feuille de route, etc. dans des fichiers séparés).
- **Vérification** : revue de chaque modification de ces fichiers.
- **Complétée par** : D-020 (ajout de CLAUDE.md).

## D-017 — Version de Fedora figée, montée de version délibérée

- **Statut** : DÉCIDÉ (2026-10-07). Était : PROPOSÉE.
- **Contexte** : Fedora sort une version majeure environ tous les six mois. Fedora 45 est annoncée par la presse pour fin octobre 2026 (`À VALIDER` sur le calendrier officiel Fedora).
- **Décision** :
  - Ankh démarre sur **Fedora 44**.
  - L'image de base est référencée par sa version majeure et par son empreinte (digest) exacte.
  - Une nouvelle version de Fedora n'arrive que par une modification délibérée de ce dépôt, testée d'abord en VM.
  - Le passage à Fedora 45 se fera après sa publication par Universal Blue (D-005) et quelques semaines de rodage.
- **Raisons** : aucun changement majeur sans décision de ma part.
- **Alternatives rejetées** : suivre automatiquement la dernière version (`latest`).
- **Vérification** : la référence de base dans le dépôt contient une version et un digest. Aucun changement de version majeure sans modification relue.
- **Mise en œuvre (phase 1)** :
  - Les deux références (tag `44` + digest) sont dans `bases.env`.
  - Renovate (`renovate.json`) propose les nouveaux digests dans une seule PR, et n'a pas le droit de changer de version de Fedora.
  - Renovate ne fonctionne qu'une fois son application GitHub installée sur le dépôt (action à faire par moi).
- **État de Renovate (2026-10-08)** : l'application est installée, et le tableau de bord Mend montre des exécutions terminées (« DONE »). Pourtant, aucune PR ni aucun ticket n'a été créé.
  - Cause probable, d'après la documentation officielle : une installation sur « All repositories » met l'application en mode **Silent** (`dryRun=lookup`), donc sans PR ni ticket. Il faut passer le dépôt ou l'organisation en mode **Interactive** dans le tableau de bord Mend.
  - Source : <https://github.com/renovatebot/renovate/blob/main/docs/usage/mend-hosted/hosted-apps-config.md>. À confirmer en cherchant `dryRun` dans le journal d'une exécution.
- **Procédure prévue pour passer à Fedora 45** (réponse à ma question du 2026-10-08) :
  1. Universal Blue publie `kinoite-main:45` et `kinoite-nvidia:45`. On attend quelques semaines de rodage (décision ci-dessus).
  2. Une PR change seulement la référence des deux bases dans `bases.env` (tag `45` et nouveau digest). Toutes les personnalisations d'Ankh sont dans `build_files/build.sh` et se réappliquent telles quelles sur la nouvelle base.
  3. La CI fait le vrai travail de vérification : construction des deux variantes, `just test` et le test en VM (démarrage, basculement, retour arrière). Ce qui casse apparaît là : un paquet renommé, un fichier de réglage apparu dans la base, un pilote. On corrige dans la même PR, jusqu'au vert.
  4. Je fusionne quand je le décide. Sur ma machine, le passage à 45 arrive comme une mise à jour normale, en plus gros, puisque presque toute la base change. Le retour arrière vers la version 44 reste possible au redémarrage suivant.
  - **Coût attendu** : faible, parce que chaque ajout d'Ankh est une ligne courte qui cite sa décision et a son test. Le point le plus sensible sera la variante NVIDIA (pilote), qui ne se teste pas en VM.

## D-018 — Construction, publication et signature de l'image

- **Statut** : DÉCIDÉ (2026-10-07). Était : PROPOSÉE. La méthode d'imposition de la signature reste À VALIDER.
- **Contexte** : l'image doit être construite et testée avant d'arriver sur la machine. La machine doit pouvoir vérifier qu'elle vient bien de moi.
- **Faits vérifiés le 2026-10-07** :
  - Le dépôt `PatrickChoumi/Ankh` est public. Source : API GitHub.
  - GitHub Actions est gratuit pour les dépôts publics avec les runners standards. Source : <https://github.com/resources/insights/2026-pricing-changes-for-github-actions>
- **Décision** :
  - Construction par GitHub Actions.
  - Publication sur GHCR (registre d'images de GitHub).
  - Signature avec cosign. La paire de clés est générée par moi, sur ma machine. La clé privée est stockée uniquement dans le secret GitHub `SIGNING_SECRET` et dans ma sauvegarde de secrets. La clé publique `cosign.pub` est commitée dans le dépôt.
  - Politique de vérification de signature configurée sur la machine.
- **Raisons** : image testée avant le déploiement, provenance vérifiable.
- **Alternatives rejetées** : construire l'image localement sur la machine elle-même.
- **À VALIDER** : la façon exacte d'imposer la vérification de signature avec bootc (option et fichiers de politique), à confirmer dans la documentation officielle.
- **Vérification** : à définir avec le premier pipeline.
- **Modifiée par** : D-022 (2026-10-07). La signature se fait sans paire de clés, donc il n'y a plus de `cosign.key` ni de secret `SIGNING_SECRET`.
- **Mise en œuvre (phase 1)** : `.github/workflows/build.yml`.
  - Sur une PR : construction et tests des deux variantes, sans publication.
  - Sur `main` : construction, tests, publication de `ghcr.io/patrickchoumi/ankh` et `ghcr.io/patrickchoumi/ankh-nvidia` (tags `latest` et `AAAAMMJJ`), signature sans clé, puis `cosign verify`.
  - Les recettes de construction et de test (`just build`, `just test`) sont les mêmes en local et en CI.
  - Pas de « rechunk » tant que l'image n'ajoute presque rien à sa base : les couches de la base sont conservées telles quelles. À réévaluer quand on ajoutera des paquets.
- **Vérifié en VM (phase 2, 2026-10-07)** : `bootc switch` depuis Ankh vers l'image publiée, puis vers l'image de base épinglée, fonctionne (D-004).

## D-019 — Sauvegarde et récupération : OS / configuration / données / secrets

- **Statut** : PROPOSÉE — À VALIDER
- **Contexte** : objectif « disque détruit → réinstallation → récupération complète ».
- **Proposition** :

  | Élément | Où il vit | Comment le récupérer |
  |---|---|---|
  | OS | Reconstructible depuis ce dépôt et le registre d'images | Réinstallation, puis basculement sur l'image |
  | Configuration | Git (ce dépôt) | Clone du dépôt |
  | Données | Sauvegarde | Restauration |
  | Secrets | Sauvegarde chiffrée, séparée | Restaurés **avant** de cloner des dépôts privés |

  - Une copie de la dernière image saine est conservée hors de GitHub (sur le support de sauvegarde), au cas où le compte serait inaccessible — `À VALIDER`.
  - Outil de sauvegarde : `À DÉCIDER`. Destination : TODO (ANKH-SPEC 4.6).
- **Raisons** : la machine peut mourir sans que mon environnement meure avec elle.
- **Alternatives rejetées** : sauvegarde du disque entier comme seul mécanisme.
- **Vérification** : un exercice complet de récupération en VM avant de considérer la procédure comme valide (non exécuté).

## D-020 — CLAUDE.md, guide de travail du projet

- **Statut** : DÉCIDÉ (2026-10-07, à ma demande). Complète D-016.
- **Contexte** : il faut un guide unique pour tout le projet, que Claude Code lit automatiquement au début de chaque session. D-016 limitait la documentation à trois fichiers, et la feuille de route n'y avait pas de place.
- **Décision** : un quatrième fichier, `CLAUDE.md`, contient :
  - les règles non négociables ;
  - les règles de travail pour Claude Code ;
  - la feuille de route par phases ;
  - l'état actuel du projet.

  Il résume et renvoie (`D-xxx`, sections de ANKH-SPEC.md), sans recopier le détail des besoins ni des choix.
- **Raisons** : les règles et la méthode s'appliquent à chaque session sans avoir à les répéter. La feuille de route a une place unique.
- **Alternatives rejetées** :
  - Fichier `ROADMAP.md` séparé (contraire à D-016).
  - Guide conservé hors du dépôt (contraire à « le dépôt est la source de vérité »).
- **Vérification** : à chaque modification, le détail d'un besoin ou d'un choix reste dans son fichier de référence. CLAUDE.md n'en contient qu'un résumé et un renvoi.

## D-021 — Image générique pour le maximum de PC (remplace D-002)

- **Statut** :
  - Principe : DÉCIDÉ (2026-10-07, à ma demande).
  - Couverture matérielle : PROPOSÉE — À VALIDER.
- **Remplace** : D-002. **Modifie** : D-001 sur le point « une seule machine ».
- **Contexte** : je préfère commencer par une version d'Ankh qui fonctionne sur le maximum de PC, plutôt que sur ma seule machine.
- **Décision (principe)** :
  - L'image ne contient rien de propre à une machine particulière.
  - Ankh doit fonctionner sur le maximum de PC x86_64.
  - Il reste personnel, et ce n'est pas une distribution publique (D-001).
- **Couverture proposée pour la V1** :

  | Matériel | Variante | Statut |
  |---|---|---|
  | AMD (GCN et plus récent) | `ankh` (Mesa) | Inclus — À VALIDER sur matériel réel |
  | Intel (iGPU, Arc) | `ankh` (Mesa) | Inclus — À VALIDER sur matériel réel |
  | NVIDIA récent (pilote « open ») | `ankh-nvidia` | Inclus — À VALIDER sur matériel réel |
  | Portables hybrides (iGPU + NVIDIA) | `ankh-nvidia` | À VALIDER |
  | NVIDIA ancien (GTX 900/1000, pilote fermé) | — | Hors V1 : aucune image prête, assemblage fragile (D-005, option D) |
  | NVIDIA antérieur (avant GTX 900) | `ankh`, pilote libre, bureau seulement | Au mieux — À VALIDER |

- **Raisons** :
  - Une image générique ne dépend pas de réponses matérielles pour démarrer la phase 1.
  - Deux variantes de la même lignée couvrent AMD, Intel et NVIDIA récent avec un seul Containerfile.
- **Coûts acceptés** :
  - Deux images à construire et à tester.
  - La variante NVIDIA ne se teste pas en VM : seulement des contrôles statiques en CI.
  - Une variante non possédée reste « non testée sur matériel réel ».
- **Alternatives rejetées** :
  - Une seule machine et un seul GPU (D-002).
  - Trois variantes incluant le NVIDIA ancien dès la V1.
- **Vérification** :
  - Les anciennes AMD GCN 1.0/1.1 passent par défaut au pilote `amdgpu` depuis Linux 6.19 : <https://phoronix.com/news/Linux-6.19-AMDGPU-GCN-1.0-1.1>
  - Matériel couvert par le pilote NVIDIA open : liste officielle <https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus> — À VALIDER.
  - Tests réels : un test de démarrage par variante en CI (Mesa), des contrôles statiques pour NVIDIA, et des tests sur chaque matériel réel disponible.

## D-022 — Signature sans clé (keyless) dans GitHub Actions

- **Statut** : DÉCIDÉ (2026-10-07, choix délégué à Claude). Modifie D-018.
- **Contexte** :
  - Ma connexion internet ne me permet pas d'installer cosign et de générer la paire de clés sur ma machine.
  - Je délègue la signature au cloud.
  - Générer la clé privée dans la session de Claude l'aurait fait transiter par la conversation, puisque Claude n'a aucun outil pour écrire un secret GitHub. C'est contraire à CLAUDE.md §4.
- **Décision** :
  - Les images sont signées par cosign en mode « keyless », directement dans GitHub Actions.
  - Le workflow s'authentifie auprès de Sigstore avec l'identité OIDC que GitHub lui fournit. La signature est rattachée à l'identité du workflow de ce dépôt.
  - Il n'existe **aucune clé privée** à générer, stocker ou sauvegarder.
- **Raisons** :
  - Rien à installer ni à télécharger de mon côté.
  - Aucun secret à gérer, donc aucun secret à perdre ou à faire fuiter.
- **Alternatives rejetées** :
  - Paire de clés générée par moi (D-018 initiale) : impossible avec ma connexion actuelle.
  - Paire de clés générée par Claude : la clé privée transiterait par la conversation.
  - Pas de signature du tout : on perd la preuve de provenance.
- **À VALIDER** : imposer cette signature **sur la machine**, via `/etc/containers/policy.json` et le type `sigstoreSigned` avec Fulcio. Le dépôt de test d'un mainteneur Fedora Atomic indiquait que la vérification keyless d'une identité GitHub Actions par podman/containers-image « ne fonctionne pas encore ». Il renvoie à containers/image#2235, dont l'état en 2026 reste à vérifier. Source : <https://github.com/travier/cosign-test>
  - En attendant, la vérification se fait avec `cosign verify` (identité du workflow + émetteur `https://token.actions.githubusercontent.com`).
  - Si l'imposition sur la machine s'avère impossible, on rouvrira une décision : retour à une paire de clés quand ma connexion le permettra.
- **Vérification** : `cosign verify` réussit sur chaque image publiée (test à ajouter dans la CI, en phase 1).

## D-023 — Chrome navigateur par défaut, installé dans l'image ; Firefox retiré

- **Statut** : DÉCIDÉ (2026-10-07).
- **Contexte** :
  - ANKH-SPEC exige Chrome comme navigateur par défaut.
  - La protection de D-026 s'appuie sur les politiques de Chrome, que Chrome lit dans `/etc/opt/chrome/policies/managed/`. Source : <https://chromium.googlesource.com/chromium/src/+/HEAD/docs/enterprise/policies.md>
  - Je n'ai pas pu vérifier que Chrome en Flatpak lit ces politiques système.
  - D'après la documentation de safezone, Firefox n'a aucun équivalent au filtrage d'URL de Chrome (`SafeSitesFilterBehavior`).
- **Décision** :
  - Google Chrome (paquet officiel de Google) est installé **dans l'image** et devient le navigateur par défaut.
  - Firefox est **retiré** de l'image.
- **Raisons** :
  - Politiques de filtrage appliquées de façon fiable.
  - Un seul navigateur, donc une seule porte d'entrée à protéger.
- **Alternatives rejetées** :
  - Chrome en Flatpak : lecture des politiques non vérifiée.
  - Garder Firefox à côté : porte de sortie du filtrage.
- **Conséquence** : Chrome ne se met à jour qu'avec l'image. Une reconstruction automatique périodique de l'image est donc nécessaire pour ses correctifs de sécurité (fréquence : voir D-027).
- **À VALIDER** :
  - L'installation de Chrome dans `/opt` d'une image bootc. Le modèle Universal Blue signale que `/opt` pointe vers `/var/opt` et cite Chrome en exemple.
  - L'association « navigateur par défaut » dans KDE.
  - Le retrait propre de Firefox.
- **Vérification** : tests CI à écrire — Chrome présent, Firefox absent, politiques présentes.
- **Mise en œuvre (phase 3, 2026-10-08)**, dans `build_files/build.sh` :
  - **`/opt`** devient un vrai dossier de l'image (`rm /opt && mkdir /opt`). C'est la méthode du modèle officiel Universal Blue, qui cite Chrome en exemple : <https://github.com/ublue-os/image-template> (`Containerfile`, section « [IM]MUTABLE /opt »). La documentation bootc confirme que `/opt` suit alors le cycle de vie de l'image : <https://github.com/bootc-dev/bootc/blob/main/docs/src/bootc-filesystem.7.md>.
  - **Chrome** vient du dépôt officiel de Google (`dl.google.com/linux/chrome/rpm/stable/x86_64`), avec vérification des signatures.
    - La clé de Google est refusée si son empreinte n'est pas `EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796`.
    - Cette empreinte est celle publiée dans les sources de Chromium : <https://github.com/chromium/chromium/blob/main/chrome/installer/linux/common/key.include>.
  - **Firefox** est retiré par `dnf5 remove firefox`.
  - **Navigateur par défaut** :
    - `/etc/xdg/mimeapps.list` déclare Chrome pour les pages web, selon la spécification XDG des applications par défaut ;
    - `/etc/xdg/kdeglobals` déclare Chrome dans `BrowserApplication` ;
    - la construction échoue si l'un de ces fichiers existe déjà dans la base, pour ne jamais écraser un réglage sans le voir.
  - **Tests** :
    - `just test` vérifie que `/opt` est un dossier, que Chrome démarre (`google-chrome --version`), que Firefox est absent, et que Chrome est l'application par défaut pour `text/html`, `http` et `https` (`gio mime`, avec `XDG_CURRENT_DESKTOP=KDE`) ;
    - `tests/vm/run.sh` vérifie, sur le système démarré, que Chrome démarre et que Firefox est absent.
  - **Vérifié en VM** ([run 37887155044](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044)) : sur le système démarré, Chrome démarre (`Google Chrome 155.0.8059.39`) et Firefox est absent, au premier démarrage comme après le retour arrière.
  - **Encore À VALIDER** :
    - le choix « Navigateur web » affiché dans les réglages de KDE, et l'icône du panneau (à l'écran, voir les captures) ;
    - ~~la fréquence de reconstruction~~ : tranchée, voir ci-dessous.
- **Résultats de construction (2026-10-09, [PR #5](https://github.com/PatrickChoumi/Ankh/pull/5))**, vérifiés par la CI :
  - `google-chrome-stable 155.0.8059.39` s'installe avec une seule dépendance (`liberation-fonts-all`) : **140 Mio à télécharger**, 440 Mio une fois installé.
  - `dnf5 remove firefox` retire `firefox` et `firefox-langpacks` (337 Mio).
  - **Erreurs sans conséquence** : le script `%post` du paquet de Chrome essaie d'importer lui-même la clé de Google. Il échoue (« can't create transaction lock … key 1 import failed »), parce que `dnf` tient déjà la base RPM. La clé est déjà importée par notre `rpm --import`, juste avant, après vérification de son empreinte. Rien ne manque.
  - Les deux variantes passent `just test` : Chrome démarre (`Google Chrome 155.0.8059.39`), Firefox est absent, et Chrome est l'application par défaut pour le web.
- **Reconstruction hebdomadaire** (mon choix du 2026-10-09 : chaque semaine, environ 140 Mio) :
  - `build.yml` reconstruit et publie l'image **chaque lundi** (`cron: '17 3 * * 1'`), et `boot-test.yml` la teste en VM le même jour.
  - L'image publiée est seulement **proposée** : elle n'arrive sur ma machine que quand je lance la mise à jour (D-031).
  - Note : GitHub désactive les tâches planifiées d'un dépôt public sans activité pendant 60 jours (À VALIDER sur la documentation GitHub).

## D-024 — Applications par défaut

- **Statut** : DÉCIDÉ (2026-10-07). Les mécanismes d'installation restent À VALIDER.
- **Contexte** : ANKH-SPEC exige VLC, VS Code, OnlyOffice, Claude et un client GitHub installés par défaut.
- **Décision** :

  | Application | Forme |
  |---|---|
  | VLC | Flatpak `org.videolan.VLC`, préinstallé |
  | OnlyOffice | Flatpak `org.onlyoffice.desktopeditors`, préinstallé |
  | Claude | Application web claude.ai installée dans Chrome (fenêtre dédiée et icône) |
  | GitHub | Application web github.com installée dans Chrome, plus l'intégration Git de VS Code |
  | VS Code | Préinstallé ; forme exacte décidée en phase 3 avec l'environnement de dev (D-012) |

- **Raisons** :
  - Des applications officielles ou du code des éditeurs eux-mêmes.
  - Aucun paquet tiers qui manipulerait mes comptes.
- **Alternatives rejetées** :
  - Paquets Claude Desktop non officiels pour Fedora : l'application officielle Linux n'est qu'en bêta pour Ubuntu/Debian. Source : <https://code.claude.com/docs/en/desktop-linux>
  - Fork communautaire de GitHub Desktop sur Flathub, marqué non vérifié. Source : <https://flathub.org/en/apps/io.github.shiftey.Desktop>
- **À VALIDER** :
  - La préinstallation des Flatpaks (`/usr/share/flatpak/preinstall.d/`) demande une version récente de Flatpak dans la base. Source : <https://www.mankier.com/1/flatpak-preinstall>
  - L'installation automatique des applications web par la politique Chrome `WebAppInstallForceList`.
  - Le volume téléchargé au premier démarrage (contrainte D-027).
- **Vérification** : tests CI pour les fichiers de préinstallation et la politique ; test réel au premier démarrage.

## D-025 — Terminal : le quotidien se fait sans terminal

- **Statut** : DÉCIDÉ (2026-10-07).
- **Contexte** : ANKH-SPEC exige de limiter le terminal au strict nécessaire. J'ai choisi le sens « confort » (option a).
- **Décision** :
  - Tout le quotidien doit se faire par l'interface graphique : mises à jour, installation d'applications, réglages, état du système.
  - Le terminal reste réservé au dev et au hacking.
  - Son accès n'est **pas** restreint, et les droits administrateur restent sur mon compte.
- **Raisons** : confort, sans complexité supplémentaire.
- **Alternatives rejetées** : restreindre l'accès au terminal ou aux droits administrateur (option b).
- **Conséquences** :
  - Il faut une interface pour les mises à jour du système : `kinoite-main` retire le module de mise à jour système de Discover (voir les sources de D-005). La solution est tranchée par D-028.
  - La protection de D-026 reste une protection par friction, pas une impossibilité.
- **Vérification** : à chaque phase, liste des actions quotidiennes faisables sans terminal (test réel).

## D-026 — Protection contre le contenu pour adultes : safezone adapté et intégré

- **Statut** : DÉCIDÉ (principe, 2026-10-07). La conception détaillée est À DÉCIDER au début de la phase concernée.
- **Contexte** :
  - ANKH-SPEC exige un accès au contenu pour adultes extrêmement difficile.
  - Mon projet safezone (<https://github.com/PatrickChoumi/safezone>) fait ce travail sur les distributions classiques, avec huit composants testés et une philosophie de friction assumée.
  - safezone ne gère pas ostree/bootc.
- **Décision** :
  - safezone est adapté aux systèmes image-based et intégré à l'image Ankh, à une version figée, comme les images de base.
  - safezone reste un projet séparé, avec ses propres tests.
- **Ce qu'apporte le modèle image-based** :
  - Composants en lecture seule dans `/usr`, ce qui réduit le besoin de `chattr +i` et d'auto-réparation.
  - Initramfs construit dans la CI.
  - Tout retrait passe par une modification visible de ce dépôt.
- **Nouvelles portes de sortie à traiter** :
  - `bootc switch` vers une autre image, ou retour à une image sans filtre. Parades : filtre présent dans toutes les images Ankh, et imposition de la signature sur la machine (À VALIDER, D-022).
  - Modifications locales de `/etc`.
  - Droits administrateur conservés (D-025) : on garde le modèle « friction contre l'impulsion » de safezone.
- **Alternatives rejetées** :
  - Installer safezone après coup avec son `install.sh` : impossible sur un système image-based (D-009).
  - Réécrire un filtre de zéro.
- **Vérification** : à définir avec la phase dédiée ; reprendre la suite de tests de safezone (`tests/run_all.sh`).

## D-027 — Connexion internet limitée : tests dans le cloud, mises à jour rares et légères

- **Statut** : DÉCIDÉ (2026-10-07), ajusté selon ma réponse. Ma connexion est **lente**, mais je peux faire les mises à jour. En conséquence :
  - Point 1 (phase 2 dans le cloud) : **retenu**.
  - Points 2 et 3 : pas de calendrier imposé. Les mises à jour de la base arrivent par des PR Renovate, que je fusionne au rythme que je choisis. Je les espace pour limiter le volume (environ 2 Go chacune).
  - Point 4 (ISO d'installation hors ligne) : **abandonné**. L'installation se fera en ligne, même lentement. D-001 reste inchangée.
- **Proposition initiale** (conservée pour l'historique) : voir ci-dessous.
- **Contexte** :
  - Télécharger 4,3 Go chez moi n'est « pas vraiment possible ». Le débit, la limite de données et la stabilité sont TODO (ANKH-SPEC Q12).
  - **Mesures du 2026-10-07 sur GHCR** :
    - L'image `ankh` pèse 4,28 Go compressés, `ankh-nvidia` 5,19 Go.
    - Entre deux versions de la base `kinoite-main:44`, il faut retélécharger 1,7 Go pour 1 jour d'écart (46 couches sur 259), 2,2 Go pour 3 jours et 2,3 Go pour une semaine.
- **Proposition** :
  1. **Phase 2 dans le cloud** : les tests de démarrage et de retour arrière se font dans une VM sur les machines de GitHub. Rien n'est téléchargé chez moi.
  2. **Mises à jour de la base rares** : les PR Renovate sur `bases.env` ne sont fusionnées qu'une fois par mois environ, sauf correctif de sécurité urgent. Chacune coûte environ 2 Go.
  3. **Mises à jour légères fréquentes** : la reconstruction périodique pour Chrome (D-023) garde la base identique. Seules les couches propres à Ankh changent, ce qui devrait représenter quelques centaines de Mo au plus (À VALIDER par mesure).
  4. **Installation hors ligne** : l'installation sur ma machine se fait depuis une clé USB préparée là où la connexion le permet, à partir d'une ISO d'installation qui contient l'image. Cela **modifierait D-001** (« pas d'ISO custom en V1 ») : une ISO technique, sans branding.
- **Raisons** : rendre Ankh utilisable avec ma connexion sans renoncer aux mises à jour.
- **Alternatives rejetées** :
  - Mises à jour quotidiennes de la base : environ 1,7 Go à chaque fois.
- **À VALIDER** :
  - Les points 2 à 4 (mes réponses).
  - La taille réelle des mises à jour légères.
  - Une réduction possible du volume par un découpage plus stable des couches (« rechunk »).
- **Vérification** : mesurer la taille téléchargée à chaque mise à jour pendant la phase 10.
- **Première mesure (phase 2, 2026-10-07, en VM)** : passer d'une image Ankh à une autre bâtie sur la même base a demandé 2 couches sur 261, soit 641 octets (D-004). Cela confirme le principe du point 3. La taille réelle viendra quand Ankh ajoutera Chrome et les applications (phase 3).
- **Deuxième mesure (2026-10-09, en VM, [run 37887155044](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044))** :
  - Passer à l'image publiée qui contient le module Discover (D-028) a demandé 2 couches, soit **38,7 Mo**.
  - Le module ne pèse que 256 Kio. Le reste vient probablement de la base de données RPM, réécrite dès qu'on installe un paquet (supposé, À VALIDER).
  - Avec Chrome (140 Mio), une mise à jour d'Ankh sur la même base devrait donc coûter de l'ordre de 180 Mo. À mesurer après la fusion de Chrome.

## D-028 — Mises à jour du système dans Discover (complète D-025)

- **Statut** : DÉCIDÉ (2026-10-08). J'ai choisi l'option A. Le comportement dans l'interface reste À VALIDER (voir « Vérification »).
- **Contexte** :
  - D-025 exige que les mises à jour du système se fassent sans terminal.
  - `kinoite-main` retire le module `plasma-discover-rpm-ostree`. Discover ne montre donc plus les mises à jour du système, seulement celles des applications Flatpak.
  - Le téléchargement automatique reste actif : `rpm-ostreed-automatic` en mode « stage » télécharge la mise à jour et la prépare pour le prochain démarrage, sans redémarrer.
    - Source : <https://github.com/coreos/rpm-ostree/blob/main/man/rpm-ostreed.conf.xml> : « The "stage" policy downloads and unpacks the update, queuing it for the next boot. This leaves initiating a reboot to other automation tools. »
- **Décision** :
  - L'image réinstalle `plasma-discover-rpm-ostree`. Discover affiche les mises à jour du système, et une notification signale qu'un redémarrage est nécessaire. Je choisis quand redémarrer (D-010).
  - L'image porte son propre numéro de version, qui augmente à chaque construction : `<version de Fedora>.<AAAAMMJJ>.<HHMM>`, en UTC. Il est inscrit dans les labels `org.opencontainers.image.version` et `version`.
    - Discover compare ce numéro avec celui du système démarré pour savoir qu'une mise à jour existe.
    - Sans ce numéro, une image Ankh reconstruite sur la même base garderait le numéro de la base.
- **Raisons** :
  - C'est la seule option qui donne une vraie interface, sans terminal, avec un redémarrage que je choisis.
  - Elle s'appuie sur le comportement prévu par KDE, pas sur un outil maison.
  - **Vérifié dans les sources** :
    - Universal Blue a retiré ce module en 2023, parce que Discover ne s'ouvrait pas sur les images signées : <https://github.com/ublue-os/main/pull/282>.
    - KDE a corrigé ce problème : <https://github.com/KDE/discover/commit/8cb842115c1cc0a6224454fbe66b1edf586c6911>. La prise en charge de `ostree-image-signed` est absente de `OstreeFormat.cpp` dans Discover 5.27.10, et présente depuis la 5.27.11.
    - Quand l'origine est un tag `latest`, Discover ignore volontairement les changements de version majeure de Fedora (`RpmOstreeResource.cpp`, `setNewMajorVersion`). C'est cohérent avec D-017.
    - Le module surveille `/ostree/deploy` et signale qu'un redémarrage est nécessaire quand une mise à jour est prête (`RpmOstreeNotifier.cpp`).
- **Alternatives rejetées** :
  - **B — `uupd`** (outil d'Universal Blue, utilisé par Aurora et Bazzite) :
    - le lanceur « System Update » d'Aurora ouvre un terminal (`Terminal=true`, `Exec=/usr/bin/ujust update`) ;
    - uupd ne notifie pas quand une mise à jour est prête, seulement en cas d'échec ou si le système a plus d'un mois.
    - Sources : <https://github.com/ublue-os/uupd>, <https://github.com/ublue-os/aurora/issues/259>.
  - **C — une notification maison** : outil maison sans documentation officielle, et aucune interface pour voir les mises à jour.
- **À VALIDER** :
  - Universal Blue n'a jamais remis ce module. Aucune raison plus récente n'a été trouvée.
  - ~~Le module doit correspondre exactement à la version de Discover de la base.~~ Vérifié le 2026-10-08 (voir « Résultats »).
  - Discover ne doit pas gêner le téléchargement automatique en arrière-plan.
  - Le choix « Après la mise à jour : redémarrer » de Discover ne doit jamais être actif par défaut (D-010).
- **Vérification** :
  - Test en CI (`just test`) : le module est installé, à la même version que Discover, et l'image porte son numéro de version.
  - Test en VM cloud (`tests/vm/run.sh`) : le système démarré affiche ce numéro de version.
  - L'affichage dans Discover et la notification ne se testent pas automatiquement. À vérifier à l'écran, au plus tard en phase 9.
- **Résultats (2026-10-08, CI de la [PR #4](https://github.com/PatrickChoumi/Ankh/pull/4))**, vérifiés par un test :
  - **Construction** ([run 37828419910](https://github.com/PatrickChoumi/Ankh/actions/runs/37828419910)), sur les deux variantes :
    - `dnf` installe un seul paquet, `plasma-discover-rpm-ostree 0:6.7.5-1.fc44` (dépôt `updates`, 256 Kio) ;
    - il ne met à jour, n'ajoute et ne remplace aucun autre paquet ;
    - `just test` confirme que le module a la même version que Discover ;
    - l'image porte la version `44.20261008.1859`.
  - **`bootc container lint`** passe avec 2 avertissements : des restes de `dnf` dans `/run/dnf` et `/var/lib/dnf/repos`. Ce sont des avertissements, pas des erreurs ; le Containerfile de construction est le même que celui du modèle Universal Blue.
  - **VM cloud** ([run 37828419997](https://github.com/PatrickChoumi/Ankh/actions/runs/37828419997)) :
    - les 4 étapes réussissent ;
    - le système démarré porte la version de l'image installée (`44.20261008.1900`), au premier démarrage et après le retour arrière.

## D-029 — AVANCEMENT.md : état de tout ce qui est fait et de ce qui reste

- **Statut** : DÉCIDÉ (2026-10-08), à ma demande.
- **Contexte** : je veux, à chaque compte rendu, un document qui fait l'état de tout ce qui a été fait depuis le début et de ce qui reste à faire.
- **Décision** :
  - Le fichier [AVANCEMENT.md](AVANCEMENT.md) tient cet état, phase par phase.
  - Claude le met à jour à chaque compte rendu et me l'envoie.
  - Il résume et renvoie aux décisions (D-xxx) sans recopier leurs détails, pour respecter la règle « une information dans un seul fichier » (CLAUDE.md §3, règle 11).
  - L'état courant court reste dans CLAUDE.md §2. AVANCEMENT.md contient l'historique et la liste de ce qui reste.
- **Raisons** : suivre le projet d'un coup d'œil, sans relire tout le dépôt.
- **Alternatives rejetées** : un compte rendu seulement dans la conversation (rien n'est conservé dans le dépôt).
- **Vérification** : chaque compte rendu de Claude contient AVANCEMENT.md à jour.

## D-030 — Variantes avec et sans protection safezone (complète D-026)

- **Statut** : DÉCIDÉ (principe, 2026-10-09), à ma demande. La conception est À DÉCIDER en phase 4.
- **Contexte** : D-026 prévoyait safezone dans toutes les images Ankh. Je veux des versions avec cette protection et des versions sans.
- **Décision** :
  - Chaque variante matérielle (D-021 : Mesa, NVIDIA) existe en deux versions : **avec** safezone et **sans**.
  - Toutes sont construites, testées et signées par la même CI, à partir du même `build_files/build.sh`. La protection s'ajoute à la fin, par une étape distincte.
  - Les noms des images sont à choisir en phase 4.
- **Conséquence à traiter en phase 4** :
  - Une image sans protection est une porte de sortie toute trouvée : depuis une machine protégée, `bootc switch` vers la version sans protection suffirait.
  - D-026 prévoyait comme parade un filtre dans toutes les images. Cette parade ne vaut plus.
  - Piste à étudier : sur une machine protégée, n'accepter que les images protégées. Par exemple, une politique de signature qui limite les images autorisées, plus de la friction sur la modification de cette politique.
  - Le niveau de difficulté reste celui de safezone : de la friction contre l'impulsion, pas une impossibilité, puisque je garde les droits administrateur (D-025).
- **Raisons** : pouvoir installer Ankh avec ou sans protection, selon la machine ou l'usage.
- **Vérification** : en phase 4, tests de safezone sur les versions protégées, et test de la parade contre le basculement vers une version sans protection.

## D-031 — Aucune mise à jour automatique : je décide quand tout se met à jour

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Complète D-010 (pas de redémarrage automatique), D-027 (rythme choisi par moi) et D-028 (Discover).
- **Contexte** : `kinoite-main` active trois mises à jour automatiques. Source : `build_files/post-install.sh` de <https://github.com/ublue-os/main> :
  - le téléchargement du système en arrière-plan (`rpm-ostreed-automatic.timer`, politique `stage`) ;
  - les mises à jour Flatpak du système (`flatpak-system-update.timer`) ;
  - les mises à jour Flatpak de chaque utilisateur (`flatpak-user-update.timer`).
- **Décision** :
  - Sur la machine, **rien ne se télécharge ni ne s'installe sans moi** : ni le système, ni les applications Flatpak, ni le conteneur de dev.
  - Les trois timers sont masqués dans l'image. La politique de rpm-ostree passe à `none` (`man rpm-ostreed.conf` : « "none" disables automatic updates »).
  - Discover me **prévient** qu'une mise à jour existe (D-028), et je la lance quand je le décide.
  - Le conteneur de dev se met à jour seulement quand je le lance, par un raccourci du menu (à faire avec le conteneur de dev, D-012). Ce choix remplace ma réponse du 2026-10-09, qui demandait une mise à jour automatique chaque semaine.
  - Côté CI, rien ne change pour moi : la reconstruction hebdomadaire de l'image (D-023) et les PR de Renovate (D-017) **préparent** des mises à jour. Rien n'arrive sur la machine tant que je ne l'ai pas demandé.
- **Raisons** : garder la main sur ma connexion lente (D-027) et sur le moment où le système change.
- **Conséquence assumée** : si je tarde à mettre à jour, les correctifs de sécurité attendent, ceux de Chrome compris. La notification de Discover est là pour me le rappeler.
- **Vérification** :
  - `just test` : les trois timers sont masqués et la politique est `none` ;
  - `tests/vm/run.sh` : sur le système démarré, `rpm-ostreed-automatic.timer` est masqué. **Vérifié en VM** le 2026-10-09 ([run 37887155044](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044)) ;
  - la notification de Discover reste À VALIDER à l'écran.

## D-032 — Conteneur de dev : Fedora, langages fullstack, VS Code dans le conteneur

- **Statut** : DÉCIDÉ (2026-10-09), d'après mes réponses. Précise D-012 (outil et contenu) et D-024 (VS Code). La liste d'extensions VS Code est PROPOSÉE — À VALIDER par moi.
- **Mes choix (2026-10-09)** :
  - Le dev se fait dans un conteneur, comme prévu par D-012, avec des outils **à la pointe**.
  - **Base : Fedora**, de la même famille que le système. VS Code est la version officielle de Microsoft.
  - **Langages et outils** :
    - Java ;
    - Python ;
    - JavaScript et TypeScript ;
    - C et C++ ;
    - les bases de données ;
    - « tout le nécessaire pour un fullstack ».
  - **VS Code est installé dans le conteneur.** Il voit directement les outils et apparaît dans le menu de KDE.
  - **Mises à jour** : quand je le décide (D-031).
- **Mise en œuvre prévue** (prochaine PR, après celle de Chrome) :
  - **Outil** : distrobox, déjà fourni par `kinoite-main`. Un fichier `distrobox assemble` crée le conteneur à ma première connexion et ajoute VS Code au menu (`exported_apps`). Source : <https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-assemble.md>.
  - **Image** `ghcr.io/patrickchoumi/ankh-dev` :
    - construite, testée et signée par notre CI, à partir de l'image officielle `quay.io/fedora/fedora-toolbox:44` ;
    - reconstruite chaque semaine, pour que la création ou la recréation du conteneur parte de versions récentes.
  - **Contenu prévu** :
    - outils communs : git, GitHub CLI (`gh`), make, CMake, Ninja ;
    - C/C++ : GCC, Clang, GDB ;
    - Python : python3, pip, pipx, uv ;
    - JavaScript/TypeScript : Node.js, npm ;
    - Java : la dernière version d'OpenJDK fournie par Fedora (`java-latest-openjdk`), Maven ;
    - clients de bases de données : PostgreSQL, MariaDB, SQLite, Valkey/Redis ;
    - VS Code.
    - Les serveurs de bases de données d'un projet tournent dans des conteneurs Podman. Leur mise en place est à préciser.
  - **VS Code de Microsoft** :
    - son dépôt est signé par l'ancienne clé de Microsoft (`BC52 8686 B50D 79E3 39D3 721C EB3E 94AD BE12 29CF`), qui contient des signatures SHA1. Source : <https://learn.microsoft.com/linux/packages> et <https://packages.microsoft.com/keys/README> ;
    - si la version de RPM de Fedora 44 la refuse, on n'affaiblit **pas** la politique de sécurité de Fedora. On installe alors l'archive officielle de VS Code, vérifiée par son empreinte publiée. À VALIDER à la construction.
- **Extensions VS Code proposées** (préinstallées à la création du conteneur, À VALIDER par moi) :
  - interface en français ;
  - Java : « Extension Pack for Java » ;
  - Python : « Python » (avec Pylance) ;
  - C/C++ : « C/C++ Extension Pack » ;
  - JavaScript/TypeScript : ESLint, Prettier ;
  - bases de données : SQLTools, avec les pilotes PostgreSQL, MySQL/MariaDB et SQLite ;
  - Git et GitHub : GitLens, « GitHub Pull Requests » ;
  - fichiers de configuration : YAML ;
  - conteneurs : l'extension Docker/Podman de Microsoft ;
  - API : REST Client.
  - Leurs mises à jour automatiques seront désactivées : VS Code me prévient, et je décide (D-031).
- **Vérification** :
  - en CI, chaque outil répond (`java -version`, `python3 --version`, `node --version`, `gcc --version`, `psql --version`, `code --version`) et chaque extension s'installe ;
  - en VM, VS Code apparaît dans le menu une fois le conteneur créé ;
  - suppression puis recréation du conteneur à l'identique (D-012).
- **Mise en œuvre (2026-10-09)** :
  - **Changement par rapport au plan** : le conteneur n'est **pas** créé automatiquement à la première connexion. Sa création est un gros téléchargement, et D-031 veut que rien ne se télécharge sans moi. Deux raccourcis du menu « Développement » le **créent** et le **mettent à jour** quand je le décide :
    - « Créer l'environnement de dev » ;
    - « Mettre à jour l'environnement de dev ».
    - Ils lancent `/usr/libexec/ankh-dev` dans Konsole, qui reste ouvert pour montrer le résultat. Le terminal est accepté pour le dev (D-025).
  - **Image `ankh-dev`** (`dev/`) :
    - construite par la même CI que le système (`just build ankh-dev`), à partir de `quay.io/fedora/fedora-toolbox:44` ;
    - suivie par son tag dans `bases.env`, sans digest, pour partir d'outils récents à chaque reconstruction hebdomadaire ;
    - paquets dans `dev/packages.txt` ;
    - VS Code vient du dépôt de Microsoft, et la clé est refusée si son empreinte n'est pas `BC52…29CF`.
  - **Extensions** : la liste est dans `dev/vscode-extensions.txt`, modifiable ligne à ligne. Elles s'installent à la création du conteneur (`/usr/libexec/ankh-dev-setup`), donc dans leur dernière version. Le même script règle VS Code pour qu'il ne se mette pas à jour tout seul (D-031) ; un réglage existant n'est jamais écrasé.
  - **Bases de données et fullstack** :
    - `podman` (podman-remote) et `podman-compose` du conteneur pilotent le Podman du système, par le socket de l'utilisateur, activé dans l'image Ankh ;
    - les serveurs (PostgreSQL, MariaDB…) tournent donc dans des conteneurs du système. À VALIDER en VM ou sur la machine.
  - **Tests** :
    - `just test ankh-dev` : chaque outil répond, VS Code démarre, chaque extension de la liste s'installe et le réglage est écrit ;
    - `just test ankh` : les raccourcis, distrobox, Konsole et le socket Podman sont présents ;
    - en VM, les raccourcis sont présents. Le conteneur lui-même n'est pas créé dans la VM, à cause de la taille du téléchargement.
  - **À faire par moi après la première publication** : rendre public le paquet `ankh-dev` sur GHCR, comme `ankh` et `ankh-nvidia`. Sinon distrobox ne peut pas le télécharger.
- **Résultats de la CI ([PR #6](https://github.com/PatrickChoumi/Ankh/pull/6), 2026-10-09)** : tout est vert.
  - **Construction de `ankh-dev`** : environ 2 minutes. La clé de VS Code est acceptée par RPM de Fedora 44 : son autosignature est en SHA-256, pas en SHA1 (vérifié avec `gpg --list-packets`). L'archive de secours n'est donc pas nécessaire.
  - **Versions installées** ([journal](https://github.com/PatrickChoumi/Ankh/actions/runs/37895079755/job/113704494907)) :
    - Java : OpenJDK 25.0.4.1, Maven 3.9.11 ;
    - Python 3.14.8, pip 26.0.1, pipx 1.15.0, uv 0.12.19 ;
    - Node.js 22.23.1, npm 10.9.8 ;
    - GCC 16.2.1, Clang 22.1.8, GDB 17.2, CMake 4.3.0 ;
    - git 2.55.0, gh 2.97.0 ;
    - clients PostgreSQL 18.6, MariaDB 11.8.8, SQLite 3.51.2, Valkey 9.0.6 ;
    - Podman 5.8.7 (podman-remote), podman-compose 1.6.0 ;
    - VS Code 1.141.0.
  - **Extensions** : les 15 extensions de la liste s'installent à la création, avec leurs dépendances (Pylance, débogueurs Java et Python, CMake Tools…). Le réglage « pas de mise à jour automatique » est écrit.
  - **Test en VM** ([run 37895079821](https://github.com/PatrickChoumi/Ankh/actions/runs/37895079821)) : les 4 étapes réussissent et les raccourcis du conteneur sont présents sur le système démarré.
  - **À VALIDER** :
    - `java -version` affiche la 25, alors que `java-latest-openjdk` est demandé. Il faut vérifier s'il installe une version plus récente à côté, que Maven ne choisit pas par défaut ;
    - Node.js 22 est la version par défaut de Fedora 44. Une version LTS plus récente existe peut-être dans un paquet séparé : à vérifier, puis à me proposer si je veux des outils à la pointe ;
    - la création réelle du conteneur et VS Code dans le menu, en VM ou sur la machine.

## D-033 — Habillage Ankh sur le bureau : nom, logo, fonds d'écran (modifie D-001)

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Modifie D-001 (« pas de branding »). Le rendu à l'écran est À VALIDER sur les captures de la VM.
- **Contexte** : je veux voir « Ankh » à la place de Fedora, avec un logo et des fonds d'écran à moi. D-001 interdisait le branding pour éviter la charge d'une distribution publique ; un habillage limité au bureau reste léger.
- **Trois niveaux étudiés** :
  1. **Bureau** : nom affiché, logo, fonds d'écran, écran de connexion, icône du menu. Facile, aucun risque pour le démarrage.
  2. **Écran de démarrage** (Plymouth, où se tape le mot de passe LUKS) : il faudrait régénérer l'initramfs dans l'image, donc toucher au démarrage et au déverrouillage. Écarté pour l'instant.
  3. **Le reste** : noms des paquets et des dépôts, « fc44 » dans la version du noyau, entrée « Fedora » du BIOS et fichiers EFI signés par Fedora pour Secure Boot. On n'y touche pas : les modifier imposerait de re-signer le démarrage (règle 7 de CLAUDE.md).
- **Mes choix (2026-10-09)** :
  - **Niveau 1 seulement**, le bureau.
  - « Ankh » est juste le nom. Le design doit être **épuré**, évoquer **le dev, le hacking, le gaming et le minimalisme**, et rester **élégant**.
  - Claude dessine une première version. Sur trois pistes proposées (curseur, pixel, trait), j'ai choisi **« Curseur »** avec un accent **violet**.
- **Le design** :
  - **Logo** : un A sans barre (Λ), dont la barre devient un **curseur de terminal** violet, sur une **touche de clavier** graphite. Il évoque l'invite de commande (dev, hacking) et le λ de Half-Life (gaming).
  - **Fonds d'écran** : un clair et un sombre, que Plasma choisit selon le thème de couleurs. Un dégradé graphite (ou gris clair), une grille de points très discrète, le A et une lueur violette.
  - Couleurs : blanc `#e6edf3`, graphite `#1b212b`, violet `#a78bfa` (`#7c3aed` sur fond clair, pour le contraste).
  - Sources : `build_files/artwork/generer.py`, qui dessine le logo (`ankh-logo.svg`) et les fonds. Les images produites sont versionnées dans `build_files/files/`.
- **Mise en œuvre** (`build_files/build.sh`) :
  - **Nom** : dans `/usr/lib/os-release`, `NAME` et `PRETTY_NAME` deviennent « Ankh ». Le nom apparaît alors dans « À propos de ce système » (KInfoCenter lit `NAME`, `LOGO` et `HOME_URL`) et dans le menu de démarrage. ostree écrit le titre de chaque entrée à partir de `PRETTY_NAME`, suivi de la version (source : `src/libostree/ostree-sysroot-deploy.c` de <https://github.com/ostreedev/ostree>) : « Ankh 44.AAAAMMJJ.HHMM (ostree:0) ».
  - `LOGO=ankh-logo`, `HOME_URL` pointe vers le dépôt, `ANSI_COLOR` passe au violet.
  - `DEFAULT_HOSTNAME=ankh` : le nom de la machine par défaut, affiché dans le terminal, devient « ankh » au lieu de « fedora ». C'est un nom générique, pas propre à une machine (D-021).
  - **`ID` reste `fedora`**. Des outils s'en servent pour reconnaître le système. Exemple : Aurora (Universal Blue), qui a changé `ID`, doit en retour corriger `grub2-switch-to-blscfg` (source : `build_scripts/base/18-image-info.sh` de <https://github.com/ublue-os/aurora>).
  - **Logo** dans le thème d'icônes `hicolor`, avec son cache refait : ostree met la même date à tous les fichiers, donc un cache périmé paraîtrait encore valide.
  - **Fond d'écran par défaut** : Plasma prend le fond indiqué par `[Wallpaper] Image=` dans le fichier `defaults` du thème global (source : `wallpapers/defaultwallpaper.cpp` de plasma-workspace). D'après le code de Plasma et de Plasma Login, le bureau, l'écran de verrouillage et l'écran de connexion le reprennent, sauf réglage contraire de Fedora : À VALIDER sur les captures. Chaque thème global de l'image est réglé sur « Ankh ».
  - **Icône du menu des applications** : un script de mise à jour de Plasma (`ankh-lanceur.js`) la règle sur le logo d'Ankh. Plasma l'exécute une seule fois par utilisateur, après la création du bureau. Si je change l'icône ensuite, mon choix est respecté.
- **Ce qui reste Fedora** : l'écran de démarrage, les fichiers EFI et l'entrée du BIOS, les noms de paquets et de dépôts, et les commandes du terminal (`rpm`, `dnf`, `uname`). Ankh reste construit sur Fedora.
- **Conséquences assumées** :
  - À chaque nouvelle version de Fedora, l'emplacement des réglages peut changer. Les tests de la CI le détectent.
  - Après un retour à l'image de base Fedora, l'icône du menu reste réglée sur le logo d'Ankh, qui n'existe plus : l'icône apparaît vide jusqu'à ce que je la change.
- **Alternatives rejetées** :
  - Remplacer `ID=fedora` (comme Aurora) : risque de casser des outils pour un gain invisible.
  - Remplacer le paquet `fedora-logos` (comme Aurora) : plus lourd, et inutile pour le niveau 1.
  - Le symbole égyptien ☥ (première ébauche) : je veux un design qui évoque le dev, le hacking et le gaming.
- **Vérification** :
  - `just test ankh`, Test 10 : `NAME` et `PRETTY_NAME` valent « Ankh », `ID` vaut `fedora`, le logo est dans le cache d'icônes, et le fond d'écran, son paquet et le script du lanceur sont présents. Chaque thème global pointe vers « Ankh » ;
  - `tests/vm/run.sh` : sur le système démarré, le nom est « Ankh », et le menu de démarrage affiche « Ankh ». Les captures montrent l'écran de connexion, le bureau, l'icône du menu et « À propos de ce système » ;
  - le rendu à l'écran est À VALIDER par moi, sur ces captures.
