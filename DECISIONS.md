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
| D-001 | Poste personnel, pas une distribution | DÉCIDÉ (« une seule machine » remplacé par D-021 ; « pas de branding » modifié par D-033 ; « pas d'ISO » modifié par D-046) |
| D-002 | Une seule machine, un seul GPU en V1 | REMPLACÉE par D-021 |
| D-003 | Linux uniquement, pas de dual boot | DÉCIDÉ |
| D-004 | Système image-based : Fedora Atomic (Kinoite) + bootc | DÉCIDÉ (principe ; mise à jour non appliquée corrigée le 2026-10-09 ; étape 2 du test en VM devenue une mise à jour le 2026-10-09) |
| D-005 | Image de base exacte : `kinoite-main` + `kinoite-nvidia` (Fedora 44) | DÉCIDÉ |
| D-006 | Secure Boot activé | DÉCIDÉ |
| D-007 | Chiffrement LUKS | DÉCIDÉ |
| D-008 | Aucune sécurité désactivée pour faire marcher un outil | DÉCIDÉ |
| D-009 | Hôte reproductible : pas de `rpm-ostree install`, pas de `curl \| bash` | DÉCIDÉ |
| D-010 | Pas de redémarrage automatique | DÉCIDÉ |
| D-011 | Applications en Flatpak, gaming via Steam Flatpak | DÉCIDÉ (applications du quotidien dans l'image : D-035 ; Steam dans le menu : D-036) |
| D-012 | Environnement dev en conteneur | DÉCIDÉ (précisé par D-032 et D-036) |
| D-013 | Outils offensifs hors de l'hôte, Kali via Podman rootless | DÉCIDÉ (outils dans le menu : D-036) |
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
| D-024 | Applications par défaut (VLC, OnlyOffice, Claude et GitHub via Chrome, VS Code) | DÉCIDÉ (VLC et OnlyOffice dans l'image : D-035 ; Claude et GitHub retirés : D-047 ; OnlyOffice remplacé par D-053) |
| D-025 | Terminal : le quotidien se fait sans terminal (confort, pas de restriction) | DÉCIDÉ (interface des mises à jour : D-028) |
| D-026 | Protection contre le contenu pour adultes : safezone adapté et intégré | DÉCIDÉ (principe), conception À DÉCIDER ; variantes avec et sans : D-030 |
| D-027 | Connexion internet lente : tests dans le cloud, mises à jour au rythme que je choisis | DÉCIDÉ (2026-10-07, ajusté ; réduction de la taille des mises à jour en phase 10 ; ISO hors ligne reprise par D-046) |
| D-028 | Mises à jour du système dans Discover (complète D-025) | DÉCIDÉ (comportement dans l'interface À VALIDER ; « Update Issue » : causes trouvées ; option A choisie pour les micrologiciels, défaut suivi chez KDE) |
| D-029 | AVANCEMENT.md : état de tout ce qui est fait et de ce qui reste | DÉCIDÉ |
| D-030 | Variantes avec et sans protection safezone (complète D-026) | DÉCIDÉ (principe), conception À DÉCIDER en phase 4 |
| D-031 | Aucune mise à jour automatique : je décide quand tout se met à jour (complète D-010, D-027, D-028) | DÉCIDÉ |
| D-032 | Conteneur de dev : Fedora, langages fullstack, VS Code dans le conteneur (précise D-012 et D-024) | DÉCIDÉ (CI verte ; extensions validées le 2026-10-09 ; versions de Node.js et Java : D-035 ; un seul Ankh, sans « ankh-dev » à gérer : D-036) |
| D-033 | Habillage Ankh sur le bureau : nom, logo, fonds d'écran (modifie D-001) | DÉCIDÉ (complété par D-034) |
| D-034 | Plus rien de Fedora à l'écran, démarrage compris ; collection de fonds d'écran (complète D-033) | DÉCIDÉ (corrigé le 2026-10-09 après lecture des captures : « À propos » et écran de démarrage ; écran de démarrage entièrement d'Ankh : D-043) |
| D-035 | VLC et OnlyOffice dans l'image, LibreOffice retiré ; Node.js et Java les plus récents dans le conteneur de dev (modifie D-011 et D-024) | DÉCIDÉ (CI et VM vertes ; versions du conteneur de dev remplacées par D-038 ; codecs et taille des mises à jour À VALIDER ; OnlyOffice remplacé par D-053) |
| D-036 | Un seul Ankh : outils de dev, de hacking et de gaming dans le menu, isolés dessous (précise D-011, D-012, D-013 et D-032) | DÉCIDÉ (dev fait, vérifié en VM ; une seule version avec des options choisies à l'installation : D-046) |
| D-037 | Identité visuelle d'Ankh : sombre partout, graphite et violet, barre flottante, icônes KDE à dossiers violets (complète D-033 et D-034) | DÉCIDÉ (aperçus validés le 2026-10-09 ; intégré dans l'image avec D-039 ; barre collée et curseur blanc : D-052) |
| D-038 | Conteneur de dev : dernières versions LTS de Node.js et de Java (modifie D-035) | DÉCIDÉ (CI verte : Node.js 24, Java 25) |
| D-039 | Interface douce, au niveau de Windows 11 et de macOS (complète D-037) | DÉCIDÉ (ma demande ; réglages choisis par Claude, à valider sur les captures en VM avant fusion ; barre flottante et règle « réglages de KDE seulement » modifiées par D-052) |
| D-040 | La protection (phase 4, safezone) passe à la fin du plan (modifie la feuille de route) | DÉCIDÉ (2026-10-09, mon choix) |
| D-041 | Gaming : le plus d'outils possible, réglages sûrs, noyau de Fedora (précise D-011 et D-036) | DÉCIDÉ (2026-10-10, mon choix ; précisé le 2026-10-12 : Discord et OBS dans Gaming, session console ; précisé par D-050 et D-051 ; mise en œuvre en phase 5) |
| D-042 | Interface, deuxième passe : finitions au niveau de macOS et de Windows 11, écran de connexion d'Ankh (complète D-039) | DÉCIDÉ (2026-10-10, ma demande ; vérifié en VM et fusionné, PR #12 ; écran de connexion et icône de VS Code modifiés par D-043 ; nos propres thèmes : D-052) |
| D-043 | Démarrage et connexion entièrement d'Ankh : Plymouth « ankh » et SDDM ; logo officiel de VS Code ; vouvoiement (modifie D-034 et D-042) | DÉCIDÉ (2026-10-10, mes demandes ; à valider sur les captures en VM avant fusion ; touche au démarrage et à LUKS : à relire) |
| D-044 | Quatre éditions d'Ankh : Dev, Gaming, Hacking, et Complète qui les réunit (modifie D-036) | REMPLACÉE par D-046 (2026-10-11) |
| D-045 | VISION.md : le portrait d'Ankh à la fin, pour vérifier qu'on ne dévie pas | DÉCIDÉ (2026-10-11, ma demande) |
| D-046 | Une seule version d'Ankh, avec des options choisies à l'installation ; ISO d'installation hors ligne (remplace D-044 ; modifie D-001, D-027 et D-036) | DÉCIDÉ (2026-10-11, mes choix : choix au premier démarrage, pour toute la machine) ; choix des options mis en œuvre et vérifié en VM le 2026-10-12 (Simple et Dev) ; « Options d'Ankh » redessinée et vérifiée en VM le 2026-10-12 ; fabrication de l'ISO : D-048 ; Simple avec la bureautique Craft, option « Création » : D-053 |
| D-047 | Plus de fenêtres Claude ni GitHub installées par Chrome (modifie D-024 et D-035) | DÉCIDÉ (2026-10-11, mon choix) |
| D-048 | ISO d'installation : une seule pour toutes les cartes graphiques, construite et hébergée par GitHub (précise D-046) | DÉCIDÉ (2026-10-12, mon choix ; contenu allégé par D-049 ; mise en œuvre au début de la phase 9) |
| D-049 | ISO légère : le système seul ; options et version NVIDIA téléchargées si besoin (modifie D-046 et D-048) | DÉCIDÉ (2026-10-12, mes choix ; mise en œuvre au début de la phase 9) |
| D-050 | Phase 5 : l'option Gaming, avec les outils du jeu en Flatpak et la session « Ankh Console » (précise D-041 et D-046) | DÉCIDÉ (2026-10-13, mes choix ; précisé par D-051 ; vérifié en VM le 2026-10-13) |
| D-051 | Réglages du système pour le jeu : ntsync avec l'option Gaming (précise D-041 et D-050) | DÉCIDÉ (2026-10-13, mon choix ; vérifié en VM le 2026-10-13) |
| D-052 | Interface au pixel près, au niveau de Windows 11 : nos propres thèmes, dérivés du code de KDE (modifie D-037, D-039 et D-042) | DÉCIDÉ (2026-10-14, mes choix ; police Selawik et icônes Fluent au violet d'Ankh choisies le 2026-10-15 ; inspiration AnduinOS le 2026-10-15 : curseurs Fluent blancs à l'anneau violet, thème GTK Fluent violet, polices en niveaux de gris ; mise en œuvre en onze lots, en parallèle de la phase 5 ; lot 0 fusionné, PR #17 ; lot 1 vérifié en VM le 2026-10-20 ; accent qui suit le fond : D-054) |
| D-053 | La suite Craft d'ArtCraft remplace OnlyOffice : bureautique dans Simple, clones d'Adobe dans une option « Création » (modifie D-024, D-035 et D-046) | DÉCIDÉ (2026-10-15, mes choix : bureautique Craft dans Simple, clones d'Adobe dans « Création ») ; mise en œuvre le 2026-10-15 ; CI verte, dix applications vérifiées en VM ; nouvelles versions proposées à l'ouverture de la session ; correctifs du premier passage vérifiés en VM ; fusionnée le 2026-10-16 (PR #18) |
| D-054 | La couleur d'accent suit le fond d'écran ; les fonds d'Ankh gardent le violet d'Ankh (modifie D-037 et D-052) | DÉCIDÉ (2026-10-16, à ma demande) ; mis en œuvre avec le lot 1 de D-052, vérifié par la CI et en VM le 2026-10-20 |

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
- **Modifiée par** : D-046 (2026-10-11). Une ISO d'installation d'Ankh est faite pour la V1, avant la bascule sur ma machine. Ankh reste personnel : pas de distribution publique.

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
- **Mise à jour non appliquée, corrigée (2026-10-09, [PR #9](https://github.com/PatrickChoumi/Ankh/pull/9))** : à signaler pour relecture, car cela touche aux mises à jour.
  - **Vu deux fois en VM, sur l'image de la PR #9** : après `bootc switch` et le redémarrage, l'ancienne version a redémarré. À l'arrêt, `ostree-finalize-staged.service` a échoué avec `error: Remounting /boot read-write: Invalid argument`. La nouvelle version n'a donc jamais été écrite dans le menu de démarrage. Sur ma machine, cela voudrait dire : je lance la mise à jour, je redémarre, et rien ne change.
  - **Cause probable** :
    - avec `bootc install to-disk` en btrfs, `/boot` n'a pas de partition à lui. ostree y lie `/sysroot/boot` (`boot.mount`, créé par `ostree-system-generator`, `src/libostree/ostree-impl-system-generator.c` de <https://github.com/ostreedev/ostree>) ;
    - `/boot` paraît vide quand `systemd-gpt-auto-generator` passe. Celui-ci y ajoute donc un montage automatique de la partition EFI (`boot.automount`, « EFI System Partition Automount », vu dans le journal série), qui se démonte après 2 minutes d'inactivité (`add_partition_esp`, `src/gpt-auto-generator/gpt-auto-generator.c` de <https://github.com/systemd/systemd>) ;
    - à l'arrêt, ostree n'a plus trouvé son `/boot`. La documentation de bootc décrit ce risque pour un `/boot` monté automatiquement (`docs/src/man/bootc-composefs-finalize-staged.8.md` de <https://github.com/bootc-dev/bootc>).
    - À VALIDER : pourquoi le même test passait sur `main` juste avant. La PR ajoute du temps et des applications dans la session de test avant le basculement.
  - **Correctif** : `boot.automount` est masqué dans l'image (`build_files/build.sh`). `/boot` reste celui d'ostree. Quand `/boot` a sa propre partition, systemd ne crée pas ce montage automatique, et le masque est sans effet.
  - **Vérification** :
    - `just test`, Test 2 bis : le masque est dans l'image ;
    - `tests/vm/run.sh` vérifie le masque sur le système installé et relève l'état de `/boot` (montages, unités) avant chaque redémarrage qui doit appliquer une version préparée. En cas d'échec, il affiche le journal de la finalisation et de `/boot` ;
    - **résultat en VM ([run 37934589711](https://github.com/PatrickChoumi/Ankh/actions/runs/37934589711), 2026-10-09)** : les 4 étapes réussissent. Avant chaque redémarrage qui applique une version préparée, `boot.automount` est masqué et inactif, `boot.mount` est celui d'ostree (`/run/systemd/generator/boot.mount`, actif), `/boot` est le lien btrfs d'ostree (`/dev/vda3[/boot]`, en lecture seule), et `ostree-finalize-staged.service` et `ostree-finalize-staged-hold.service` sont actifs. Versions : `ostree-2026.4-1.fc44`, `systemd-259.9-1.fc44`.
- **Étape 2 du test en VM : une mise à jour au lieu d'un basculement (2026-10-09, [PR #11](https://github.com/PatrickChoumi/Ankh/pull/11))** : à signaler pour relecture, car cela touche au test des mises à jour.
  - Le système de test est installé avec `--target-imgref ghcr.io/patrickchoumi/ankh:latest`. Il suit le registre d'Ankh, comme ma machine installée depuis ce registre (D-027), au lieu du stockage local de la CI. Raison : Discover cherchait les mises à jour dans un registre « localhost » inexistant (D-028).
  - L'étape 2 fait donc `bootc upgrade` vers la version publiée, comme une mise à jour que je lance, au lieu de `bootc switch`. Le basculement reste testé à l'étape 4 (retour à l'image de base). Le retour arrière (étape 3) est inchangé.

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
- **Modifiée par D-035 (2026-10-09)** : les applications du quotidien (VLC, OnlyOffice) sont dans l'image, comme Chrome. Les autres applications restent en Flatpak.

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
- **Modifiée par D-035 (2026-10-09)** : VLC et OnlyOffice deviennent des paquets de l'image, et non des Flatpaks préinstallés. Claude et GitHub restent des applications web de Chrome, installées par la politique `WebAppInstallForceList`.
- **Modifiée par D-047 (2026-10-11)** : Chrome n'installe plus Claude ni GitHub. Je les installe moi-même si je les veux ; GitHub reste accessible dans VS Code par Git.
- **Modifiée par D-053 (2026-10-15)** : OnlyOffice est retiré ; les documents de bureau passent à WordCraft, GridCraft et DeckCraft, toujours dans le menu (Simple).

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
- **Réduction de la taille des mises à jour : en phase 10** (mon choix du 2026-10-09). Mesurée à 1,2 Go depuis VLC et OnlyOffice (D-035). La piste (découper l'image en couches qui ne changent pas à chaque fois) attend la phase 10, comme le veut la règle « on optimise après avoir vécu avec le système ».
- **Modifiée par D-046 (2026-10-11)** : le point 4 revient. L'installation se fait depuis une ISO d'Ankh qui contient le système et tous les outils des options, sans internet.

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
- **« Update Issue » : causes trouvées (2026-10-09, [PR #11](https://github.com/PatrickChoumi/Ankh/pull/11), [run 37975438997](https://github.com/PatrickChoumi/Ankh/actions/runs/37975438997))**. Ce message de Discover ne dit pas quelle source a échoué. Le test en VM affiche maintenant le journal de Discover après chaque capture. Deux causes, vérifiées par ce journal et dans le code de Discover (<https://invent.kde.org/plasma/discover>, branche master du 2026-10-09) :
  1. **Propre au test, à l'étape 1** :
     - Le système installé depuis le stockage local de la CI suivait `ostree-unverified-registry:localhost/ankh:latest`.
     - Pour chercher une mise à jour, Discover lance `skopeo inspect --no-tags docker://localhost/ankh:latest` (`RpmOstreeTransaction.cpp`), qui échoue (`connection refused`).
     - Discover n'ignore que les transports locaux (`containers-storage`, `oci`…), pas un registre local (`OstreeFormat::isLocalOCI`).
     - Ma machine, installée depuis `ghcr.io` (D-027), n'est pas concernée.
     - **Correctif du test** : `bootc install --target-imgref ghcr.io/patrickchoumi/ankh:latest`, option documentée (« Specify the image to fetch for subsequent updates », `docs/src/man/bootc-install-to-disk.8.md` de <https://github.com/bootc-dev/bootc>). Le système de test suit alors le registre d'Ankh, comme ma machine. L'étape 2 devient une mise à jour (`bootc upgrade`) au lieu d'un basculement (voir D-004).
  2. **Un défaut de Discover, sur un système venu du registre (étape 2)** :
     - La recherche pour le système réussit : `skopeo` lit la version publiée, et Discover conclut « No new version found ».
     - La source « micrologiciels » (fwupd) échoue : `Fwupd Error 21 Failed to download metadata for lvfs: attempted previous download of https://cdn.fwupd.org/downloads/firmware.xml.zst.jcat from process just 68ms ago`.
     - Mécanisme, d'après le code :
       - à l'ouverture, cette source lit les appareils, puis télécharge le catalogue des micrologiciels (LVFS) (`FwupdBackend::checkForUpdates`, `setRemotes`) ;
       - elle se déclare prête dès que les appareils sont lus, avant la fin du téléchargement (`m_fetching = false` dans `setDevices`) ;
       - elle relance tout à chaque fin de tâche de Discover (`lastTransactionFinished`). La recherche pour le système est une tâche : quand elle finit pendant ce téléchargement, le catalogue est redemandé ;
       - fwupd refuse de télécharger deux fois la même adresse en moins de 1,5 seconde, avec l'erreur `FWUPD_ERROR_NOT_REACHABLE` (`FWUPD_CLIENT_DOWNLOAD_URI_DELTA`, `libfwupd/fwupd-client.c` de <https://github.com/fwupd/fwupd>) ;
       - Discover affiche toute erreur de fwupd, sauf « fichier invalide », « non pris en charge » et « rien à faire » (`FwupdBackend::handleError`).
     - **Conséquence** : le premier téléchargement réussit ; seul le message est faux. Son apparition dépend du minutage : sur ma machine, À VALIDER.
     - **À DÉCIDER (mon choix)** :
       - **A** (recommandée) : garder les micrologiciels dans Discover et signaler le défaut à KDE (<https://bugs.kde.org>) avec cette analyse. La correction arrivera avec une future version de Discover, par la reconstruction hebdomadaire. D'ici là, le message peut apparaître, sans effet.
       - **B** : retirer la source « micrologiciels » de Discover dans l'image. Plus de message, mais les mises à jour de micrologiciels (BIOS/UEFI, liste de révocation de Secure Boot, SSD) ne seraient plus proposées dans l'interface. Il faudrait une entrée de menu dédiée. Le paquet qui fournit cette source est À VALIDER.
       - **C** (déconseillée) : livrer dans l'image un Discover corrigé par Ankh. Il faudrait reconstruire et suivre un paquet de KDE.
     - **Décision (2026-10-09, mon choix) : option A.** Les micrologiciels restent dans Discover.
       - Le défaut est déjà signalé et confirmé chez KDE : [bug 523258](https://bugs.kde.org/show_bug.cgi?id=523258), « Discover shows a false "Update Issue" error dialog when fwupd declines a redundant LVFS metadata refresh » (Fedora 44 Kinoite, Discover 6.7.3 et 6.7.4). Il est aussi suivi chez Fedora : [bug 2502629](https://bugzilla.redhat.com/show_bug.cgi?id=2502629). Inutile d'en ouvrir un autre. Ses commentaires décrivent la limite de fwupd, pas encore pourquoi Discover redemande le catalogue. Notre analyse (relance à la fin de la recherche pour le système) pourrait y être ajoutée, avec un compte KDE.
       - La correction arrivera avec une version de Discover qui la contient, par la reconstruction hebdomadaire de l'image. À surveiller : le statut de ce bug.
     - **Vérifié en VM le 2026-10-09** ([run 37986772808](https://github.com/PatrickChoumi/Ankh/actions/runs/37986772808)) : à l'étape 1, le système de test suit maintenant le registre d'Ankh ; Discover lit la version publiée et affiche « Up to date », sans « Update Issue ». À l'étape 2, le défaut de Discover (cause 2) se produit encore, comme prévu.

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
  - **Confirmé le 2026-10-09** : je ne veux pas de mise à jour hebdomadaire sur ma machine ; c'est moi qui la lance. La préparation du lundi sur GitHub est gardée (mon choix « Garder la préparation »), car elle n'installe rien.
- **Raisons** : garder la main sur ma connexion lente (D-027) et sur le moment où le système change.
- **Conséquence assumée** : si je tarde à mettre à jour, les correctifs de sécurité attendent, ceux de Chrome compris. La notification de Discover est là pour me le rappeler.
- **Vérification** :
  - `just test` : les trois timers sont masqués et la politique est `none` ;
  - `tests/vm/run.sh` : sur le système démarré, `rpm-ostreed-automatic.timer` est masqué. **Vérifié en VM** le 2026-10-09 ([run 37887155044](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044)) ;
  - la notification de Discover reste À VALIDER à l'écran.

## D-032 — Conteneur de dev : Fedora, langages fullstack, VS Code dans le conteneur

- **Statut** : DÉCIDÉ (2026-10-09), d'après mes réponses. Précise D-012 (outil et contenu) et D-024 (VS Code). La liste d'extensions VS Code est validée par moi le 2026-10-09.
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
- **Extensions VS Code** (préinstallées à la création du conteneur ; liste validée par moi le 2026-10-09) :
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
  - **À faire par moi après la première publication** : rendre public le paquet `ankh-dev` sur GHCR, comme `ankh` et `ankh-nvidia`. Sinon distrobox ne peut pas le télécharger. **Fait le 2026-10-09.**
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
    - → Java et Node.js : traités par D-035 (les versions les plus récentes de Fedora, à ma demande) ;
    - la création réelle du conteneur et VS Code dans le menu, en VM ou sur la machine.

## D-033 — Habillage Ankh sur le bureau : nom, logo, fonds d'écran (modifie D-001)

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Modifie D-001 (« pas de branding »). Le rendu à l'écran est À VALIDER sur les captures de la VM.
- **Complétée par** : D-034 (2026-10-09) : plus rien de Fedora à l'écran, écran de démarrage compris, et une collection de fonds d'écran.
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
  - **Nom de la machine** : « ankh » au lieu de « fedora », affiché dans le terminal. C'est un nom générique, le même pour toutes les machines (D-021). Je peux le changer avec `hostnamectl`, et ce choix reste local, comme tout réglage de `/etc`.
    - `DEFAULT_HOSTNAME=ankh` dans `os-release` ne suffit pas : l'initramfs de Fedora nomme déjà la machine « fedora », et systemd garde un nom existant si `/etc/hostname` est absent (source : `hostname_setup` dans `src/shared/hostname-setup.c` de <https://github.com/systemd/systemd>). Vu en VM : le journal du système démarré affichait encore « fedora » ([run 37897946381](https://github.com/PatrickChoumi/Ankh/actions/runs/37897946381)).
    - L'image fournit donc `/etc/hostname` avec « ankh ».
    - Pendant la construction, podman fournit son propre `/etc/hostname` à chaque étape (« By default, Buildah manages the /etc/hostname file », `podman-build`, option `--no-hostname`). `just build` passe donc `--no-hostname` pour que le fichier écrit reste dans l'image. `podman run` fait de même, et le Test 10 lit ce fichier par un montage de l'image.
  - **`ID` reste `fedora`**. Des outils s'en servent pour reconnaître le système. Exemple : Aurora (Universal Blue), qui a changé `ID`, doit en retour corriger `grub2-switch-to-blscfg` (source : `build_scripts/base/18-image-info.sh` de <https://github.com/ublue-os/aurora>).
  - **Logo** dans le thème d'icônes `hicolor`, avec son cache refait : ostree met la même date à tous les fichiers, donc un cache périmé paraîtrait encore valide.
  - **Fond d'écran par défaut** : Plasma prend le fond indiqué par `[Wallpaper] Image=` dans le fichier `defaults` du thème global (source : `wallpapers/defaultwallpaper.cpp` de plasma-workspace). Chaque thème global de l'image est réglé sur « Ankh ». **Correction (D-034)** : sur Fedora, l'écran de verrouillage et l'écran de connexion désignent explicitement le fond de Fedora, et ne reprenaient donc pas celui d'Ankh. D-034 les corrige.
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
  - `just test ankh`, Test 10 : `NAME` et `PRETTY_NAME` valent « Ankh », `ID` vaut `fedora`, `/etc/hostname` vaut « ankh », le logo est dans le cache d'icônes, et le fond d'écran, son paquet et le script du lanceur sont présents. Chaque thème global pointe vers « Ankh » ;
  - `tests/vm/run.sh` : sur le système démarré, le nom est « Ankh », la machine s'appelle « ankh », et le menu de démarrage affiche « Ankh ». Les captures montrent l'écran de connexion, le bureau, l'icône du menu et « À propos de ce système » ;
  - le rendu à l'écran est À VALIDER par moi, sur ces captures.
- **Résultats de la CI ([PR #7](https://github.com/PatrickChoumi/Ankh/pull/7), 2026-10-09)** :
  - **Construction** : six thèmes globaux réglaient le fond par défaut, et tous pointent maintenant vers « Ankh ». Les trois thèmes de Fedora (`org.fedoraproject.fedora`, `fedoradark`, `fedoralight`) indiquaient « Fedora », les trois de Breeze « Next ».
  - **Test en VM** ([run 37897946381](https://github.com/PatrickChoumi/Ankh/actions/runs/37897946381), captures dans l'artefact `captures-ankh-vm`) : le système démarré s'appelle « Ankh », avec `ID=fedora`, et le menu de démarrage affiche « Ankh ».
  - **Après correction** ([run 37901076405](https://github.com/PatrickChoumi/Ankh/actions/runs/37901076405)) : tout est vert, et la machine démarrée s'appelle « ankh ».
  - **Correction** : le nom de machine restait « fedora ». `/etc/hostname` est ajouté, et le test en VM vérifie désormais que la machine s'appelle « ankh ». Le premier essai a échoué sur la garde « /etc/hostname existe déjà » : c'était le fichier fourni par podman pendant la construction, d'où `--no-hostname`.

## D-034 — Plus rien de Fedora à l'écran, démarrage compris ; collection de fonds d'écran (complète D-033)

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Complète D-033 : son niveau 2 (l'écran de démarrage) est maintenant retenu. CI et VM vertes ; le rendu à l'écran est À VALIDER sur les captures.
- **Mes choix (2026-10-09)** :
  - **Visuellement, plus rien en rapport avec Fedora** : ni logo ni nom. Sous le capot, Fedora ne me dérange pas.
  - **Écran de démarrage compris**, là où se tape le mot de passe LUKS : « Oui, testé en VM ».
  - **Des fonds d'écran travaillés**, du style de ceux de Kali. Sur six pistes proposées, je les garde toutes, avec le fond épuré de D-033. **« Signal » est le fond par défaut.**
- **Ce qui reste Fedora, sous le capot** : les paquets et leurs dépôts, le noyau (« fc44 »), l'identifiant `ID=fedora` (D-033), les commandes du terminal, et les fichiers EFI signés pour Secure Boot. L'entrée du menu du BIOS, visible seulement dans le menu de démarrage de la carte mère, est à étudier à part.
- **Fonds d'écran** (`build_files/artwork/fonds.py`, appelé par `generer.py`), tous sombres, graphite et violet, autour du logo :
  - **Signal** : rubans de lumière violet et cyan ;
  - **Circuit** : pistes de circuit imprimé qui partent du logo ;
  - **Topographie** : courbes de niveau ;
  - **Glitch** : le logo décalé comme un signal vidéo abîmé ;
  - **Horizon** : grille rétro qui file vers l'horizon, le logo en soleil ;
  - **Code** : colonnes de code et l'invite `ankh ~ $`.
- **Mise en œuvre** (`build_files/build.sh`) :
  - **Logos** : `fedora-logos` est remplacé par `generic-logos`, le paquet que Fedora fournit à ses dérivés, comme le fait Aurora (`build_scripts/base/01-packages.sh` de <https://github.com/ublue-os/aurora>).
  - **Écran de démarrage** : le thème de Plymouth reste celui de Fedora. Seule son image de filigrane, en bas de l'écran, devient le logo d'Ankh.
  - **Initramfs** : l'écran de démarrage vit dans l'initramfs, qui est donc reconstruit. La commande est celle qu'Universal Blue utilise pour cette même base : `dracut --no-hostonly --reproducible --add ostree` (`build_files/initramfs.sh` de <https://github.com/ublue-os/main>). Secure Boot n'est pas concerné : l'initramfs n'est pas signé.
  - **Ce que l'inventaire du Test 11 a trouvé, et son traitement** ([PR #8](https://github.com/PatrickChoumi/Ankh/pull/8)) :
    - **Trois thèmes globaux** « Fedora », « Fedora Dark » et « Fedora Light » (paquet `plasma-lookandfeel-fedora`). Ce ne sont que Breeze avec le fond et les aperçus de Fedora ; leur écran de démarrage de session n'affiche que les logos de KDE. `kde-settings-plasma` en dépend et en règle un par défaut (`LookAndFeelPackage`). Ils restent donc, et deviennent « Ankh », « Ankh Sombre » et « Ankh Clair » : toute mention de Fedora est retirée de leur fiche, sauf l'identifiant, invisible. Leurs aperçus sont tirés du fond « Ankh Signal ».
    - **Les fonds de Fedora** (`F44`, et les liens `Default` et `Fedora`). L'écran de verrouillage (`kscreenlockerrc` de kde-settings) et l'écran de connexion (`/usr/lib/plasmalogin/defaults.conf`) les désignent explicitement. Ces deux réglages désignent maintenant « Ankh Signal », puis les fonds de Fedora sont retirés. Leur paquet reste installé, sans images, car kde-settings-plasma en dépend.
    - **Le dépôt « Fedora Flatpaks »**, ajouté au premier démarrage par `flatpak-add-fedora-repos.service` : le service est masqué. Les applications viennent de Flathub (D-011).
    - Le thème de Plymouth est `bgrt`, avec ses images dans `/usr/share/plymouth/themes/spinner` (écrit `//spinner` par Fedora).
- **Risque assumé** : un initramfs cassé empêcherait le démarrage. Parades : le test en VM démarre l'image avec Secure Boot, et le retour arrière reste possible depuis le menu de démarrage. Le test en VM n'a pas de LUKS : l'écran du mot de passe est À VALIDER sur ma machine.
- **Vérification** :
  - `just test`, Test 11 (`tests/sans-fedora.sh`, lancé dans l'image) : il échoue s'il reste un élément visible au nom de Fedora, et l'affiche avec le paquet qui le fournit. Il couvre les paquets de logos, le nom du système, les entrées du menu, les thèmes et les fonds d'écran, les schémas de couleurs, le dépôt Flatpak de Fedora, et le filigrane de l'écran de démarrage, dans le thème et dans l'initramfs. Il servira aussi au passage à Fedora 45 ;
  - `just test`, Test 10 : les sept fonds sont présents, et « Ankh Signal » est le fond par défaut de chaque thème global ;
  - test en VM : le démarrage réussit avec l'initramfs reconstruit, et des captures sont prises pendant le démarrage (`0-demarrage-*`).
- **Résultats de la CI ([PR #8](https://github.com/PatrickChoumi/Ankh/pull/8), 2026-10-09)** : tout est vert au quatrième passage, après trois passages qui ont servi d'inventaire.
  - **Test 11** : « Rien de Fedora à l'écran », sur les images Mesa et NVIDIA.
  - **Changement de logos** : seul `fedora-logos` est retiré, remplacé par `generic-logos` ; le garde-fou n'a rien trouvé d'autre.
  - **Initramfs reconstruit** pour les deux images. dracut affiche `dracut-install: ERROR: installing '/root'` : `/root` pointe vers `/var/roothome`, absent pendant la construction (même cause que l'erreur de gpg contournée pour la clé de Google, voir build.sh). Le message est sans effet : la VM démarre.
  - **Test en VM** ([run 37915307956](https://github.com/PatrickChoumi/Ankh/actions/runs/37915307956)) :
    - les 4 étapes réussissent avec l'initramfs reconstruit, Secure Boot, SELinux et le pare-feu actifs ;
    - la machine s'appelle « ankh » dès les premiers messages du démarrage, car l'initramfs contient maintenant le nom d'Ankh ;
    - 12 captures dans l'artefact `captures-ankh-vm`, dont 4 pendant le démarrage (`0-demarrage-1` à `-4`).
  - **Taille mesurée** : passer de cette image à l'image publiée a téléchargé 252,7 Mo (2 couches). La couche d'Ankh contient Chrome, les fonds, les logos et l'initramfs ; toute reconstruction la renouvelle en entier. La part de chacun est À MESURER (D-027).
  - **À VALIDER par moi** : le rendu à l'écran sur les captures (démarrage, connexion, verrouillage, bureau, « À propos »), et l'écran du mot de passe LUKS sur ma machine.
- **Correction après lecture des captures (2026-10-09, [run 37938577307](https://github.com/PatrickChoumi/Ankh/actions/runs/37938577307))** : les captures, enfin récupérées par Claude, montrent deux défauts que les tests ne voyaient pas.
  - **« À propos de ce système » affichait un hot-dog et « Kinoite »**.
    - Cause : KDE lit le logo, la variante et le site de cette page dans `kcm-about-distrorc` avant `os-release` (`kcms/about-distro/src/main.cpp` de <https://invent.kde.org/plasma/kinfocenter>). Le réglage de Fedora y désigne l'image de `generic-logos`, un hot-dog, et la variante « Kinoite ».
    - Correctif : chaque `kcm-about-distrorc` désigne le logo d'Ankh, sans variante, avec le site d'Ankh (`build_files/regler-a-propos.py`). `os-release` perd `VARIANT`, et `VERSION` ne garde que le numéro (`44`). `VARIANT_ID`, lu par des outils, reste.
    - Le journal de construction liste maintenant les images de `generic-logos`, pour les remplacer avec l'identité visuelle (D-037).
  - **Le démarrage affichait les messages du noyau, pas l'écran d'Ankh**.
    - Cause : Plymouth n'affiche son écran graphique (logo d'Ankh, saisie du mot de passe LUKS) qu'avec l'argument `rhgb`. L'installateur de Fedora l'ajoute ; avec `bootc install`, les arguments viennent de `/usr/lib/bootc/kargs.d`, et l'image ne le donnait pas.
    - Correctif, **à relire car il touche au démarrage** : `/usr/lib/bootc/kargs.d/10-ankh-ecran-de-demarrage.toml` donne `rhgb quiet`, sauf si la base les donne déjà. D'après la documentation de bootc, un changement de `kargs.d` s'applique aussi aux machines déjà installées, à la mise à jour suivante (`docs/src/building/bootc-kernel-arguments.7.md` de <https://github.com/bootc-dev/bootc>).
    - En VM, l'argument `plymouth.ignore-serial-consoles` (propre au test) laisse Plymouth afficher son écran malgré la console série, pour que les captures du démarrage le montrent.
  - **Tests** : le Test 11 vérifie maintenant le nom, la version et la variante du système (ni Fedora ni Kinoite), le logo de « À propos » et la présence de `rhgb`. Le test en VM vérifie que le noyau a reçu `rhgb`.
  - **Vu aussi sur les captures, sans correctif pour l'instant** :
    - Discover affiche « Update Issue » sur le système installé depuis le stockage local de la CI, qui n'est pas un registre. Le test capture maintenant Discover après le basculement, quand le système vient du vrai registre (D-028) ;
    - au premier lancement de Chrome, KDE demande de créer un portefeuille (KDE Wallet). Sur la VM, la connexion est automatique, sans mot de passe ; sur ma machine, le portefeuille s'ouvre peut-être avec le mot de passe de session. À VALIDER sur ma machine ;
    - le premier écran (« Welcome to Plasma Desktop », réglage du premier compte) est gris, et l'interface est en anglais dans la VM. La langue se choisit dans ce premier écran.
  - **Vérifié en VM ([PR #10](https://github.com/PatrickChoumi/Ankh/pull/10), [run 37961330515](https://github.com/PatrickChoumi/Ankh/actions/runs/37961330515))** :
    - « À propos » affiche le logo d'Ankh, « Ankh 44 » et le site d'Ankh, sans hot-dog ni « Kinoite » (capture `1-a-propos`) ;
    - l'écran de démarrage graphique s'affiche, avec le logo « ankh » en bas et la roue de chargement (captures `0-demarrage-3` et `-4`). Au centre, le thème `bgrt` montre le logo du firmware : TianoCore dans la VM, celui de la carte mère sur un vrai PC ;
    - l'écran de verrouillage montre « Ankh Signal ».
  - **Discover affiche toujours « Update Issue »**, même après le basculement vers l'image du vrai registre (capture `2-discover-mises-a-jour`). Ce n'était donc pas dû au stockage local de la CI. Cause À TROUVER (D-028) : le test devra relever le journal de Discover.

## D-035 — VLC et OnlyOffice dans l'image, LibreOffice retiré ; Node.js et Java les plus récents (modifie D-011 et D-024)

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Modifie D-011 et D-024 ; précise D-032. CI et VM vertes ([PR #9](https://github.com/PatrickChoumi/Ankh/pull/9)), résultats ci-dessous.
- **Mes choix (2026-10-09)** :
  - « Je veux que l'OS ait déjà le nécessaire » : VLC, OnlyOffice, Claude et GitHub sont disponibles dès l'installation de l'image.
  - Forme retenue : **« A. Paquets système, comme Chrome »**, c'est-à-dire des paquets RPM dans l'image, plutôt que des Flatpaks préinstallés.
  - **LibreOffice est retiré de l'image**, comme Firefox : une seule suite bureautique, OnlyOffice.
  - « Si Fedora a de nouvelles versions d'outils de dev, ce serait bien de les avoir dans Ankh » : le conteneur de dev prend les versions les plus récentes que Fedora propose.
- **Ce qui change** :
  - **D-011** : les applications restent en Flatpak, sauf celles du quotidien listées ici, dans l'image comme Chrome.
  - **D-024** : VLC et OnlyOffice passent de « Flatpak préinstallé » à « paquet de l'image ». Claude et GitHub ne changent pas (applications web de Chrome) ; leur mécanisme est mis en place ici.
- **Raisons** :
  - Tout est là au premier démarrage, sans téléchargement. Un Flatpak préinstallé, lui, se télécharge au premier démarrage, alors que D-027 et D-031 veulent éviter les téléchargements que je n'ai pas lancés.
  - VLC et OnlyOffice suivent l'image, reconstruite chaque semaine (D-023).
- **Alternatives rejetées** :
  - Flatpaks préinstallés (D-024 d'origine) : téléchargement au premier démarrage, et version de Flatpak de la base à vérifier.
  - Garder LibreOffice à côté d'OnlyOffice : deux suites pour le même usage.
- **Conséquences** :
  - **Taille** : l'image grossit d'OnlyOffice et de VLC. Toute reconstruction renouvelle la couche d'Ankh en entier (252,7 Mo avant ce changement, D-034), donc chaque mise à jour que je lance retélécharge aussi OnlyOffice et VLC. Taille À MESURER par la CI (D-027).
  - **Chrome affiche « Géré par votre organisation »**, à cause de la politique qui installe Claude et GitHub. C'est normal, et la protection de D-026 ajoutera d'autres politiques. Ces deux applications ne se désinstallent pas depuis Chrome.
  - **Claude et GitHub apparaissent dans le menu après la première ouverture de Chrome**, avec internet : c'est Chrome qui les installe.
  - **Node.js** : la version la plus récente peut être une version impaire, sans support long (environ 6 mois). La reconstruction hebdomadaire suit les versions proposées par Fedora.
- **Mise en œuvre** :
  - **LibreOffice** (`build_files/build.sh`) : tous les paquets `libreoffice*` de la base sont retirés, et la liste de ce qui part est affichée dans le journal de construction. S'il n'y en a aucun, la construction le dit.
  - **VLC** : paquet `vlc`, depuis les dépôts de la base. `kinoite-main` active en priorité le dépôt multimédia de negativo17, aux codecs complets (`build_files/install.sh` de <https://github.com/ublue-os/main>). Le dépôt utilisé s'affiche dans le journal.
  - **OnlyOffice** : paquet `onlyoffice-desktopeditors`, depuis le dépôt officiel d'OnlyOffice pour Red Hat et dérivés (`download.onlyoffice.com/repo/centos/main/noarch/`, <https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-rhel.aspx>), installé dans `/opt` comme Chrome, avec vérification des signatures :
    - la clé est refusée si son empreinte n'est pas `E09CA29F6E178040EF22B4098320CA65CB2DE8E5` ;
    - la documentation d'OnlyOffice pour Ubuntu désigne la clé par son identifiant court `CB2DE8E5` sur `keyserver.ubuntu.com` (<https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx>, vue par une recherche : le site n'est pas accessible depuis l'environnement de Claude) ;
    - ce serveur donne cette empreinte complète, une clé RSA 4096 de 2016 au nom d'« Ascensio System Limited (ONLYOFFICE) » (vérifié le 2026-10-09). La construction prend la clé sur ce même serveur.
  - **Applications par défaut** (`/etc/xdg/mimeapps.list`, comme Chrome dans D-023) :
    - VLC pour chaque format vidéo et audio qu'il déclare dans son lanceur ;
    - OnlyOffice pour les documents de bureau qu'il déclare : Word, Excel, PowerPoint, OpenDocument, RTF et CSV. Il déclare aussi le PDF et le texte brut, qui ne lui sont **pas** confiés : le PDF reste à Chrome, le texte à l'éditeur de texte ;
    - le nom des lanceurs est lu dans les paquets, et la construction échoue s'il n'y en a pas exactement un.
  - **Claude et GitHub** : fichier `/etc/opt/chrome/policies/managed/ankh-applications.json`, politique `WebAppInstallForceList` de Chrome. Chaque application s'ouvre dans sa propre fenêtre, sous le nom « Claude » ou « GitHub » (`custom_name`). La politique existe sous Linux depuis Chrome 75, `custom_name` depuis Chrome 112. Source : `components/policy/resources/templates/policy_definitions/Miscellaneous/WebAppInstallForceList.yaml` de <https://github.com/chromium/chromium>.
  - **Conteneur de dev** (`dev/build.sh`) :
    - **Node.js** : Fedora fournit chaque version majeure dans ses propres paquets (`nodejs22`, `nodejs24`…), et leurs sous-paquets `-bin` et `-npm-bin` donnent les commandes `node`, `npm` et `npx` sans numéro. Source : le fichier `nodejsNN.spec`, repris par CentOS Stream (<https://gitlab.com/redhat/centos-stream/rpms/nodejs26>), car le site des paquets de Fedora n'est pas accessible depuis l'environnement de Claude. La construction prend le plus grand numéro proposé par Fedora ;
    - **Java** : `java-latest-openjdk` devient la version des commandes `java` et `javac` (`alternatives --set`). Maven reste sur la version de référence de Fedora, qu'il installe pour lui-même (la 25 dans D-032). À VALIDER : si un projet Maven a besoin de la dernière version de Java.
  - **À faire quand Fedora 45 sortira** : passer le conteneur de dev à Fedora 45, ma demande du 2026-10-09, en suivant la procédure de D-017.
- **Vérification** :
  - `just test`, Test 12 (`tests/applications.sh`, lancé dans l'image) :
    - aucun paquet ni lanceur de LibreOffice ;
    - VLC démarre (`vlc --version`, sous un compte ordinaire, car VLC refuse root) ;
    - OnlyOffice est dans `/opt`, et toutes ses bibliothèques sont trouvées (`ldd`) ;
    - VLC et OnlyOffice sont les applications par défaut de formats courants (MP4, MKV, MP3, FLAC ; DOCX, XLSX, PPTX, ODT), et Chrome reste celle du web (`gio mime`, avec `XDG_CURRENT_DESKTOP=KDE`) ;
    - la politique de Chrome liste Claude et GitHub ;
  - `just test ankh-dev`, Test 4 : `node` est le plus grand numéro proposé par Fedora, et `java` et `javac` sont ceux de `java-latest-openjdk` ;
  - en VM : VLC et OnlyOffice présents et LibreOffice absent, à chaque étape ; Chrome, une fois ouvert, crée les lanceurs de Claude et de GitHub dans le menu ; captures de VLC et d'OnlyOffice ouverts (`1-vlc`, `1-onlyoffice`).
- **À VALIDER** :
  - si la base contenait LibreOffice (le journal de construction le dira) ;
  - le dépôt d'où vient VLC, et la lecture des formats courants sur ma machine ;
  - l'acceptation des signatures d'OnlyOffice par RPM de Fedora 44 ;
  - l'installation de Claude et de GitHub par Chrome (test en VM) ;
  - la taille ajoutée à chaque mise à jour (D-027).
- **Résultats de la CI ([PR #9](https://github.com/PatrickChoumi/Ankh/pull/9), 2026-10-09)** : tout est vert au cinquième passage. Les passages précédents ont corrigé deux erreurs de mes scripts (VLC a cinq lanceurs ; `gio mime` répond sur plusieurs lignes) et une vraie panne des mises à jour (voir D-004).
  - **LibreOffice n'était pas dans la base** : le journal de construction affiche « LibreOffice absent de la base : rien à retirer ». Le Test 12 garantit qu'il reste absent.
  - **VLC 3.0.24** (`vlc-3.0.24-1.fc44`) vient du dépôt de Fedora (`updates`, « Fedora Project »), pas de celui de negativo17 : 37 paquets, 10 Mio à télécharger, 26 Mio une fois installé. VLC lit avec les bibliothèques ffmpeg du système, que `kinoite-main` prend chez negativo17 (codecs complets). La lecture des formats courants (H.264, H.265…) reste À VALIDER sur ma machine.
  - **OnlyOffice 9.4.0** (`onlyoffice-desktopeditors-9.4.0-129.el7`) : la clé est acceptée et les signatures sont vérifiées par RPM de Fedora 44, sans erreur. 366 Mio à télécharger, **1,3 Gio une fois installé**, avec 6 dépendances de Fedora (boost, polices DejaVu et Liberation Narrow).
  - **Applications par défaut** : `vlc.desktop` et `onlyoffice-desktopeditors.desktop` sont celles des formats testés (MP4, MKV, MP3, FLAC ; DOCX, XLSX, PPTX, ODT), et Chrome reste celle du web.
  - **En VM** ([run 37934589711](https://github.com/PatrickChoumi/Ankh/actions/runs/37934589711)) :
    - VLC et OnlyOffice sont présents à chaque étape et LibreOffice absent ;
    - **Chrome installe lui-même Claude et GitHub** dès sa première ouverture : deux lanceurs `chrome-…-Default.desktop` apparaissent dans le menu du compte de test ;
    - VLC et OnlyOffice s'ouvrent dans la session : captures `1-vlc` et `1-onlyoffice` (15 captures jointes au run).
  - **Conteneur de dev** :
    - **Node.js 24.18.0** (`nodejs24`), la version la plus récente que Fedora 44 propose, au lieu de la 22. C'est une version à support long (LTS) ;
    - **Java 27** par défaut (`java-latest-openjdk 27.0.0.0.35`), au lieu de la 25. Fedora la marque encore « early access » (`27-ea`). Mon choix du 2026-10-09 : les dernières versions LTS (D-038) ;
    - Maven 3.9.11 reste sur Java 25.
  - **Taille** :
    - l'image installée passe de 9,9 Go à 11,3 Go (taille décompressée affichée par `bootc install`) ;
    - la couche d'Ankh publiée sur `main` (sans OnlyOffice) se télécharge en 501,1 Mo. Avec OnlyOffice, une mise à jour devrait approcher 870 Mo (501 + 366, estimation). À MESURER après la fusion (D-027).
    - **Mesuré le 2026-10-09** ([run 37961330515](https://github.com/PatrickChoumi/Ankh/actions/runs/37961330515)) : passer à l'image publiée sur `main`, avec OnlyOffice et VLC, a téléchargé **1,2 Go** (2 couches), contre 501,1 Mo avant D-035. Comme toute reconstruction renouvelle la couche d'Ankh en entier, c'est la taille de chaque mise à jour que je lance. Réduire cette taille (découper l'image en couches qui ne changent pas à chaque fois) est une piste pour la phase 10 (D-027), ou plus tôt si je le décide.
- **Modifiée par D-047 (2026-10-11)** : plus d'applications web Claude et GitHub installées par Chrome.
- **Modifiée par D-053 (2026-10-15)** : OnlyOffice est retiré de l'image, remplacé par WordCraft, GridCraft et DeckCraft, préparés au premier clic (Simple). VLC reste dans l'image ; LibreOffice reste absent.

## D-036 — Un seul Ankh : outils de dev, de hacking et de gaming dans le menu, isolés dessous (précise D-011, D-012, D-013 et D-032)

- **Statut** : DÉCIDÉ (2026-10-09), mon choix. Mise en œuvre : le dev à la prochaine PR, le gaming en phase 5, le hacking en phase 6.
- **Contexte** : « Je ne comprends pas pourquoi il y a une version ankh-dev. De base, Ankh doit intégrer les outils de dev, de hacking et de gaming, les trois en même temps. »
  - `ankh-dev` n'est pas une autre version d'Ankh : c'est l'image du conteneur de dev (D-032), qui tourne dans Ankh. Aujourd'hui, il faut le créer depuis le menu (« Créer l'environnement de dev ») avant d'avoir VS Code.
  - Il n'y a qu'un système, Ankh, et sa variante pour NVIDIA (D-021).
- **Options présentées** :
  1. **Un seul Ankh, outils isolés dessous** (recommandée) : tout apparaît dans le menu comme des applications ordinaires ; dev et hacking tournent isolés en dessous ;
  2. dev dans l'image, hacking isolé : image et mises à jour plus lourdes (1 à 2 Go de plus, à mesurer) ;
  3. tout dans l'image : remplace la règle 8 et D-013 ; un outil de hacking piégé aurait accès à tout le système et à mes fichiers (déconseillée).
- **Décision : option 1.**
  - Les outils apparaissent dans le menu d'Ankh comme des applications ordinaires : VS Code et les outils de dev, les outils de hacking (Kali), Steam. Je n'ai pas de « ankh-dev » à gérer.
  - En dessous, le placement ne change pas (règle 5) : dev dans un conteneur (D-012, D-032), hacking dans Kali en Podman rootless (D-013), jeux par Steam en Flatpak (D-011).
- **Raisons** :
  - Un outil de hacking piégé ne touche ni le système ni mes fichiers (règle 8, D-013).
  - L'image reste légère pour ma connexion (D-027).
- **Avec D-031** (rien ne se télécharge sans moi) : préparer un outil télécharge beaucoup (le conteneur de dev, Steam, Kali). Mise en œuvre prévue : le premier clic sur l'outil dans le menu le prépare, en montrant la progression, puis l'ouvre ; les fois suivantes, il s'ouvre directement. À VALIDER en VM.
- **Mise en œuvre prévue** :
  - **dev** (prochaine PR) : « VS Code » dans le menu dès l'installation. Il crée le conteneur au premier clic, puis s'ouvre. Les raccourcis « Créer l'environnement de dev » et « Mettre à jour l'environnement de dev » disparaissent du menu au profit d'une seule entrée de mise à jour des outils, sans le mot « ankh-dev ». Test en VM avec captures : VS Code présent dans le menu, conteneur créé au premier clic, VS Code ouvert ;
  - **gaming** (phase 5) : Steam dans le menu dès l'installation, sur le même principe ;
  - **hacking** (phase 6) : les outils de Kali dans le menu, lancés dans le conteneur Kali isolé. Les questions de la phase 6 (ANKH-SPEC.md) restent à répondre.
- **Mise en œuvre du dev (2026-10-09)** :
  - **« Visual Studio Code »** est dans le menu dès l'installation (`ankh-vscode.desktop`, catégorie Développement). Il lance `/usr/libexec/ankh-vscode` :
    - si l'environnement de dev n'existe pas, une fenêtre Konsole montre sa préparation : téléchargement du conteneur `ankh-dev` (D-032), puis installation des extensions VS Code. En cas d'échec, la fenêtre reste ouverte pour montrer pourquoi ;
    - ensuite, VS Code s'ouvre dans le conteneur ;
    - les fois suivantes, VS Code s'ouvre directement.
  - **« Créer l'environnement de dev » disparaît**. L'entrée de mise à jour devient « Mettre à jour les outils de dev ». Le nom `ankh-dev` reste celui du conteneur, en coulisse.
  - **distrobox n'exporte plus VS Code** (`exported_apps` retiré de `distrobox.ini`), pour éviter une deuxième entrée « Visual Studio Code (on ankh-dev) ».
  - **Icône** : celle de KDE pour le développement (`applications-development`). Breeze n'a pas d'icône VS Code (vérifié dans <https://invent.kde.org/frameworks/breeze-icons>, `icons/apps`). Une icône dans le style d'Ankh viendra avec l'identité visuelle (D-037).
  - **Tests** :
    - `just test`, Test 9 : les deux entrées sont valides, l'icône existe, l'ancienne entrée a disparu ;
    - en VM : le premier clic est joué dans la session de test. Captures `1-vscode-preparation` (la fenêtre de préparation) et `1-vscode` (VS Code ouvert).
  - **Résultat en VM ([run 37961330515](https://github.com/PatrickChoumi/Ankh/actions/runs/37961330515), 2026-10-09)** : au premier clic, la fenêtre de préparation s'ouvre (messages en français), le conteneur se télécharge et les 15 extensions s'installent, puis **VS Code s'ouvre** sur son écran d'accueil. Environ 3 minutes dans la VM des machines de GitHub ; plus long sur ma connexion (D-027).
  - **Deux corrections du test en chemin** :
    - la session de test se verrouillait puis éteignait l'écran : le compte de test ne le fait plus (réglage de la VM, pas de l'image) ;
    - le test lançait le raccourci comme un service systemd ordinaire, que systemd arrête avec tout ce qu'il a démarré quand le lanceur se termine : le conteneur et VS Code mouraient deux secondes après leur démarrage. Le menu de KDE lance ses applications comme des services avec `ExitType=cgroup` (`src/gui/systemd/systemdprocessrunner.cpp` de <https://invent.kde.org/frameworks/kio>), et le test fait maintenant de même. Le raccourci n'a pas changé.
  - La préparation garde son journal dans `~/.cache/ankh/preparation-dev.log`.
- **Modifiée par D-044 puis par D-046 (2026-10-11)** : une seule version d'Ankh, avec des options choisies à l'installation (Simple, Dev, Gaming, Hacking, Complète). Le principe reste : chaque outil dans le menu, isolé dessous.

## D-037 — Identité visuelle d'Ankh : sombre partout, graphite et violet, barre flottante, icônes KDE à dossiers violets (complète D-033 et D-034)

- **Statut** : DÉCIDÉ (2026-10-09), mes choix. Aperçus en VM réussis et validés par moi le 2026-10-09 (« le style me convient »). Intégré dans l'image avec D-039 ([PR #11](https://github.com/PatrickChoumi/Ankh/pull/11)).
- **Contexte** : « J'aimerais que visuellement les apps qui étaient stylisées selon Fedora aient une vibe Ankh, et non Fedora, parce que là c'est comme si tu avais juste modifié les noms. »
  - D-033 et D-034 ont changé le nom, le logo, les fonds et l'écran de démarrage. Les applications gardent l'apparence de KDE par défaut : thème clair, accent bleu, barre collée au bord (vu sur les captures de la VM).
  - La liste de tout ce qui donne une identité visuelle m'a été présentée, en six familles : couleurs, polices, icônes et curseurs, moments clés (démarrage, connexion, verrouillage), applications (Konsole, Chrome, VS Code), bureau.
- **Options présentées et choix** :
  - **Ambiance** : **sombre partout**, graphite et violet comme les fonds d'écran, avec une variante claire dans les réglages (recommandée, choisie) ; ou sombre et clair au choix, clair le jour.
  - **Disposition** : **barre flottante en bas**, détachée du bord (recommandée, choisie) ; ou dock et barre en haut ; ou barre en haut seule ; ou la barre actuelle.
  - **Icônes** : **celles de KDE (Breeze), dossiers violets**, rien à ajouter à l'image (recommandée, choisie) ; ou Papirus sombre.
- **Mise en œuvre prévue** : deux PR, avec des aperçus montrés avant chacune.
  1. Couleurs, polices, icônes, Konsole, Chrome, VS Code et disposition du bureau.
  2. Écrans de démarrage, de connexion, de chargement de la session et de verrouillage.
- **Comment, d'après le code de KDE** (vérifié le 2026-10-09) :
  - **couleurs** : un jeu de couleurs « Ankh », dérivé de Breeze sombre (`colors/BreezeDark.colors` de <https://invent.kde.org/plasma/breeze>). Le style Plasma Breeze et les décorations de fenêtres suivent le jeu de couleurs. Chrome et les applications GTK suivent le mode sombre annoncé par le bureau (vérifié pour Chrome sur les aperçus ; OnlyOffice et VLC À VALIDER) ;
  - **dossiers violets** : les dossiers de Breeze prennent la couleur d'accent du jeu de couleurs (classe `ColorScheme-Accent` de `icons/places/64/folder.svg`, <https://invent.kde.org/frameworks/breeze-icons> ; couleur fournie par `src/kiconcolors.cpp` de <https://invent.kde.org/frameworks/kiconthemes>). Aucun thème d'icônes à ajouter ;
  - **barre flottante** : propriété `floating` des panneaux (`shell/scripting/panel.h` et `shell/panelview.cpp` de <https://invent.kde.org/plasma/plasma-workspace>). Plasma la met par défaut. ~~La barre est collée au bord sur les captures : un réglage de la base la retire.~~ Corrigé le 2026-10-09 : sur les captures, la barre est déjà flottante, détachée du bord et arrondie, avant comme après l'aperçu (`1-bureau`, `1-apercu-avant`, `1-apercu-bureau`). Rien à changer ;
  - **appliqué à chaque compte** : à chaque ouverture de session, Plasma applique les réglages par défaut du thème global choisi dans l'image (`startkde/startplasma.cpp` de plasma-workspace). Les comptes existants les reçoivent donc aussi, sauf ce que j'ai changé moi-même. Piste pour l'intégration, À VALIDER.
- **Palette de l'aperçu** (`tests/vm/apercus/Ankh.colors`, dans l'image depuis le 2026-10-09 : `build_files/files/usr/share/color-schemes/Ankh.colors`) : fonds graphite bleuté du logo (`#0d1117`, `#232a35`), texte `#e6edf3`, sélections violet `#8455f0` (texte blanc lisible dessus : contraste 4,6), liens et focus au violet du logo (`#a78bfa`). Konsole : fond du logo et violet d'Ankh (`tests/vm/apercus/Ankh.colorscheme`, aujourd'hui dans `build_files/files/usr/share/konsole`).
- **Aperçus (2026-10-09)** : le test en VM applique ces réglages à un compte à part, « ankhapercu », avec les outils de Plasma (`plasma-apply-colorscheme`, `plasma-changeicons`, script de Plasma pour la barre). Ni l'image ni le compte de test ne changent. Captures : bureau avant et après, menu des applications, Dolphin, Konsole, Discover, réglages des couleurs, Chrome.
- **Résultats des aperçus ([run 37975438997](https://github.com/PatrickChoumi/Ankh/actions/runs/37975438997), 2026-10-09)**, vus sur les captures :
  - le jeu de couleurs s'applique (« Successfully applied the color scheme Ankh ») : bureau, menu des applications, Dolphin, Konsole, Discover et réglages sont sombres, graphite et violet ;
  - les dossiers de Dolphin sont violets ;
  - Chrome passe en sombre de lui-même ;
  - « Ankh » apparaît dans la liste des jeux de couleurs, à côté de Breeze.
- **Vu sur les captures, à traiter à l'intégration** :
  - **message de bienvenue de Konsole** : « Welcome to Ankh. This terminal is running on the host system. You may want to try out the Toolbx for a directly mutable environment that allows package installation with DNF. » Il pousse vers Toolbx et DNF, ce qui va contre D-009 et D-036. Il vient de Fedora (fichier exact À VALIDER) ; à remplacer par un message d'Ankh, ou à retirer ;
  - **KDE Wallet** : au premier lancement de Chrome, KDE demande de créer un portefeuille. Le compte de test n'a pas de mot de passe. Avec un mot de passe à la connexion, ce portefeuille s'ouvre peut-être tout seul : À VALIDER sur ma machine ;
  - le centre d'accueil de KDE (Konqi) s'ouvre à la première connexion, en clair : il suivra les couleurs d'Ankh une fois intégrées ;
  - la VM est en anglais : les comptes de test n'ont pas de langue réglée. La langue de ma machine se choisit à l'installation.
- **Intégration (2026-10-09, avec D-039)** : le jeu de couleurs `Ankh.colors` va dans `/usr/share/color-schemes`, et les couleurs et le profil Konsole dans `/usr/share/konsole`. Le thème global par défaut devient « Ankh Sombre », avec le jeu de couleurs Ankh. Le message de bienvenue de Konsole, qui conseille Toolbx et DNF, n'est plus affiché aux nouveaux comptes. Détails et tests : D-039.
- **Deuxième partie : moments clés (commencée le 2026-10-09, [PR #11](https://github.com/PatrickChoumi/Ankh/pull/11))** :
  - **Écran de chargement de la session**, après la connexion : celui d'Ankh, adapté de celui de KDE, avec le fond et le logo d'Ankh, sans le logo ni le texte de Plasma (`build_files/plasma/ankh-splash.qml`). Chaque thème global d'Ankh le désigne ; Fedora désignait celui de KDE. Vérifié par le Test 14 ; capturé en VM, rejoué en mode test (`ksplashqml --test`).
  - **Écrans de connexion et de verrouillage** : le test en VM les capture maintenant. Leur style sera revu sur ces captures.
  - **Assistant de premier démarrage de KDE** (`plasma-setup`), vu sur la première capture de la VM : sans compte, c'est lui qui s'affiche (« Welcome to Plasma Desktop », bouton « Begin Setup »), et il crée le compte. D'après son code (<https://invent.kde.org/plasma/plasma-setup>, vérifié le 2026-10-09) :
    - le titre « Plasma Desktop » est écrit en dur (`src/qml/LandingComponent.qml`) ; « Powered by » affiche le nom du système, donc « Ankh » ;
    - son image de fond est cherchée dans le fond d'écran « Next » de KDE ; absent de l'image, il laisse un fond gris uni ;
    - son choix clair/sombre applique les thèmes globaux Breeze de KDE (`modules/prepareutil/prepareutil.cpp`), puis les réglages de l'assistant sont copiés dans le nouveau compte (`src/auth/authhelper.cpp`). Toucher ce choix remplacerait donc le thème d'Ankh par celui de KDE ;
    - à traiter : options à présenter, après les captures avec le nouveau thème par défaut.
    - **Options présentées le 2026-10-10** : retouches et page Ankh (recommandée) ; retouches seulement ; laisser tel quel ; reconstruire l'assistant (déconseillé : notre propre version du programme de KDE à suivre). Vérifié dans le code : le titre est compilé dans le programme (`src/qml`, `ecm_add_qml_module`) ; les pages de l'assistant sont des paquets KPackage chargés au démarrage, et une distribution peut ajouter les siennes (`docs/CUSTOM_MODULES.md`) ; le compte créé est administrateur (groupe `wheel`, `src/accountcontroller.cpp`).
    - **Décision (mon choix du 2026-10-10) : retouches et page Ankh.** Le fond d'Ankh derrière l'assistant ; le bouton « Dark Theme » garde les couleurs d'Ankh ; une page « Bienvenue dans Ankh ». Le titre « Welcome to Plasma Desktop » reste.
    - **Mise en œuvre (2026-10-10)**, vérifiée dans le code de `plasma-setup` 6.6.4, la version de Fedora 44 :
      - **fond** : l'image d'« Ankh Signal », aux noms que l'assistant cherche (`wallpapers/Next/contents/images/5120x2880.png` et `1080x1920.png`, `src/qml/LandingComponent.qml`). Les images sont dans `/usr/share/ankh/assistant` (faites par `build_files/artwork/generer.py`) et liées depuis `/usr/share/wallpapers/Next`. Ce dossier n'est pas proposé comme fond d'écran : pas de fichier de description, et images sous `contents/images` (`packagefinder.cpp`, `imagefinder.cpp` de plasma-workspace) ;
      - **« Dark Theme »** applique le thème global « Breeze sombre » de KDE (`modules/prepareutil/prepareutil.cpp`). Il prend le jeu de couleurs d'Ankh. Tous les thèmes globaux, de Fedora comme de KDE, ont maintenant la barre et l'écran de chargement d'Ankh : toucher à ce choix ne fait plus perdre l'apparence d'Ankh. Seul « clair » donne des couleurs claires (Breeze clair) ;
      - **page « Bienvenue dans Ankh »** : module `org.ankh.plasmasetup.bienvenue` (`/usr/share/plasma/packages`), chargé par l'assistant avec ses propres pages (`src/pagesmodel.cpp`). Elle vient en premier, juste après « Begin Setup » (poids -1 ; langue : 0) : le logo d'Ankh, et trois points sur les mises à jour, VS Code et le retour à la version précédente. Texte en français ;
      - **vérification** : Test 14 (thèmes globaux, « Breeze sombre », fond de l'assistant, page installée) ; en VM, un clic sur « Begin Setup » (tablette USB virtuelle et commande QMP `input-send-event` de QEMU), puis capture de la page.
      - **Correction du 2026-10-10** ([PR #12](https://github.com/PatrickChoumi/Ankh/pull/12)) : la première construction s'est arrêtée sur la vérification prévue, car le fond « Next » de KDE est maintenant dans la base (paquet `plasma-breeze-common` de Fedora 44, vérifié dans <https://mdapi.fedoraproject.org>). Le dossier est retiré quand il vient de ce paquet, comme les fonds de Fedora (D-034) : aucun thème global ne le désigne (fond « Ankh Signal »), et les fonds proposés restent ceux d'Ankh. S'il vient d'un autre paquet, la construction s'arrête toujours.
- **Pas encore traité** : polices (Inter, JetBrains Mono : présence dans Fedora À VALIDER), icône de VS Code dans le style d'Ankh, images de `generic-logos` (voir D-034), curseurs, effets.
- **Modifiée par D-052 (2026-10-14)** : la barre n'est plus flottante mais collée en bas, pleine largeur, comme celle de Windows 11 ; le curseur devient blanc. Les couleurs graphite et violet restent. Icônes et police : À DÉCIDER dans D-052.
- **Modifiée par D-054 (2026-10-16)** : la couleur d'accent suit le fond d'écran. Les fonds d'Ankh désignent le violet d'Ankh, qui reste donc l'accent par défaut ; avec une autre image, l'accent prend sa couleur. Le graphite reste.

## D-038 — Conteneur de dev : dernières versions LTS de Node.js et de Java (modifie D-035)

- **Statut** : DÉCIDÉ (2026-10-09), à ma demande. Modifie D-035 pour les versions du conteneur de dev. Résultats de la CI À VENIR.
- **Contexte** : D-035 prenait la version la plus récente que Fedora propose. Pour Java, c'était la 27, que Fedora marque encore « early access » (`27-ea`). Ma réponse : « garde les dernières versions LTS ».
- **Décision** : pour Node.js et Java, le conteneur de dev prend la **dernière version LTS** (support long) que Fedora propose, et la règle s'applique à chaque reconstruction, sans intervention.
  - **Node.js** : une version proposée par Fedora (paquets `nodejsNN`) est retenue si elle est déjà entrée en LTS et pas encore en fin de vie, d'après le calendrier officiel de Node.js (`schedule.json` de <https://github.com/nodejs/Release>). La plus récente est installée. Aujourd'hui : **Node.js 24** (LTS depuis le 2025-10-28). Node.js 26 deviendra LTS le 2026-10-28, et sera pris quand Fedora 44 le proposera.
  - **Java** : depuis Java 17, une version LTS sort tous les deux ans, soit une version sur quatre : 17, 21, 25, 29… (Java SE Support Roadmap d'Oracle, <https://www.oracle.com/fr/java/technologies/java-se-support-roadmap.html> : versions LTS 8, 11, 17, 21 et 25, une LTS tous les deux ans, prochaine LTS Java 29 en septembre 2027 ; vu le 2026-10-09 dans les résultats d'une recherche, la page elle-même refusant l'accès à l'environnement de Claude). La plus récente de ces versions proposée par Fedora (`java-NN-openjdk`) est installée, et `java` et `javac` pointent vers elle. Aujourd'hui : **Java 25**. `java-latest-openjdk` n'est plus installé.
  - Les autres outils (Python, GCC, Clang…) n'ont pas de version LTS : ils restent dans la version de Fedora 44.
- **Raisons** : des versions stables et suivies longtemps, plutôt que les toutes dernières.
- **Mise en œuvre** :
  - `dev/lts.py` choisit la version : `python3 lts.py node calendrier.json 22 24 …` ou `python3 lts.py java 21 25 …`. Il échoue s'il n'y a aucune version LTS parmi celles de Fedora : la construction s'arrête au lieu de prendre une autre version ;
  - `dev/build.sh` interroge les dépôts de Fedora, télécharge le calendrier de Node.js, puis installe les versions choisies ;
  - testé en local le 2026-10-09 avec le vrai calendrier : 24 parmi « 20 22 24 25 », 24 parmi « 22 24 26 27 » (la 26 n'est pas encore LTS), 25 parmi « 21 25 27 », 29 parmi « 25 26 27 29 », échec parmi « 25 27 » et « 26 27 ».
- **Vérification** : `just test ankh-dev`, Test 4. Il refait le choix à partir des dépôts et du calendrier, puis vérifie que `node`, `java` et `javac` sont bien ces versions.
- **Résultat de la CI ([PR #10](https://github.com/PatrickChoumi/Ankh/pull/10), 2026-10-09)** : « Construire ankh-dev » est vert, Test 4 compris, au deuxième passage. Le premier a montré que le paquet de Java 25 déclare aussi le lien `/usr/bin/java` géré par `alternatives` : seuls les chemins sous `/usr/lib/jvm` sont maintenant retenus.

## D-039 — Interface douce, au niveau de Windows 11 et de macOS (complète D-037)

- **Statut** : DÉCIDÉ (2026-10-09), ma demande. Les réglages sont choisis par Claude, sur les sources ci-dessous. Vérifié en VM le 2026-10-09 ; je les valide sur les captures avant de fusionner.
- **Contexte** : après les aperçus de D-037 : « Le style me convient. J'aimerais que visuellement l'interface soit bien plus belle et soft, du même niveau que du Windows 11 ou du macOS. »
- **Décision** : garder les couleurs validées (D-037) et adoucir le reste, uniquement avec des paquets de Fedora et des réglages de KDE. Pas de thème tiers, rien à maintenir hors de Fedora et de KDE.
  1. **Polices** : Inter pour l'interface, JetBrains Mono pour le terminal et le code (paquets `rsms-inter-fonts` et `jetbrains-mono-fonts` de Fedora 44, vérifiés dans <https://mdapi.fedoraproject.org>). Elles remplacent Noto Sans, la police de Fedora.
  2. **Thème global par défaut** : « Ankh Sombre », avec le jeu de couleurs Ankh (D-037).
  3. **Barre** : flottante en bas, plus haute (2,75 unités au lieu de 2,5), le menu et les applications au centre comme sous Windows 11, la zone de notification et l'horloge à droite. Le sélecteur de bureaux virtuels est retiré. Mêmes réglages dans les trois thèmes globaux d'Ankh.
  4. **Breeze plus doux** : menus translucides (85 %) et floutés, ombres des fenêtres plus grandes et plus légères.
  5. **Konsole** : profil Ankh, avec la police JetBrains Mono 11, une marge de 12 pixels autour du texte et un fond légèrement translucide et flouté (92 %), comme le terminal de macOS.
- **Comment, d'après les sources** (vérifié le 2026-10-09) :
  - **réglages appliqués à chaque compte** : à chaque ouverture de session, Plasma écrit dans `~/.config/kdedefaults` les réglages du thème global choisi, si ce thème a changé (`startkde/startplasma.cpp` de <https://invent.kde.org/plasma/plasma-workspace>). Ce thème est lu dans `/etc/xdg/kdeglobals`, qui passe avant les réglages de Fedora : `XDG_CONFIG_DIRS=/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg` (`plasma-workspace/env/env.sh` du paquet `kde-settings-plasma` 44.0) ;
  - **thèmes globaux de Fedora** (paquet `plasma-lookandfeel-fedora` 6.7.5) : « Ankh » (D-034) avait des applications claires et une barre sombre ; « Ankh Sombre » avait Breeze sombre. Leur barre venait du modèle de KDE (`loadTemplate("org.kde.plasma.desktop.defaultPanel")`) ;
  - **polices** : les réglages de Fedora (`kde-profile/default/xdg/kdeglobals`) donnent Noto Sans. Les polices d'Ankh sont dans `/etc/xdg/kdeglobals`, au même format ;
  - **barre** : propriétés `height`, `floating` et `alignment` des panneaux (`shell/scripting/panel.h` de plasma-workspace). Deux espaceurs extensibles centrent sur la barre ce qui est entre eux (`optimalSize`, `applets/panelspacer/main.qml`). Le reste suit le modèle de KDE (`layout-templates/org.kde.plasma.desktop.defaultPanel` de <https://invent.kde.org/plasma/plasma-desktop>). Le logo d'Ankh sur le bouton du menu reste posé par `ankh-lanceur.js` (D-033) ;
  - **Breeze** : `MenuOpacity` (groupe `Style`) ; sous 100, Breeze demande le flou derrière les menus (`kstyle/breezestyle.cpp`, `breezeblurhelper.cpp`). `ShadowSize` et `ShadowStrength` (groupe `Common`, `kdecoration/breezesettingsdata.kcfg`). Sources : <https://invent.kde.org/plasma/breeze>, branche Plasma/6.7 ;
  - **Konsole** : `Font`, `ColorScheme`, `TerminalMargin` (`src/profile/Profile.cpp`), `Opacity` et `Blur` (`src/colorscheme/ColorScheme.cpp`), dans <https://invent.kde.org/utilities/konsole> ;
  - **message de bienvenue de Toolbx** : `/etc/profile.d/toolbox.sh` (paquet `toolbox` 0.3) ne l'affiche pas si `~/.config/toolbox/host-welcome-shown` existe. Ce fichier vide est donné à chaque nouveau compte par `/etc/skel`.
- **Mise en œuvre** (`build_files/build.sh`, `build_files/plasma/ankh-barre.js`, `build_files/files`) :
  - la construction échoue si un réglage de la base a changé : jeu de couleurs d'« Ankh Sombre » différent de Breeze sombre, disposition absente, `/etc/xdg/breezerc` déjà présent, profil Konsole déjà fixé, message de Toolbx lu autrement ;
  - `/etc/xdg/konsolerc` existe dans la base : il vient du paquet `konsole-part` de Fedora (26.08.1 : barre de menus masquée, historique dans le cache). Vu par la construction de la CI le 2026-10-09, qui s'est arrêtée comme prévu. Il est gardé, et le profil Ankh y est seulement ajouté ;
  - les fichiers de réglages écrits sont rendus lisibles par tous les comptes (KConfig peut les créer pour leur seul propriétaire).
- **Pas encore traité** :
  - écrans de démarrage, de connexion, de chargement de la session et de verrouillage (deuxième partie de D-037) ;
  - une variante claire aux couleurs d'Ankh (aujourd'hui : Breeze clair) ;
  - VS Code, dans le conteneur de dev : thème et police d'Ankh ;
  - l'icône de VS Code et les images de `generic-logos` (D-034) ;
  - les coins arrondis : ceux de Breeze, sans extension tierce.
- **À VALIDER** :
  - l'aspect sur les captures de la VM, puis sur ma machine (lisibilité d'Inter, translucidité du terminal) ;
  - le flou et la transparence sur une carte graphique modeste (performances) ;
  - la taille ajoutée à l'image par les polices (à mesurer).
- **Vérification** :
  - `just test`, Test 14 (`tests/identite.sh`) : polices installées, thème global et jeu de couleurs, barre des trois thèmes globaux, Breeze, Konsole et message de Toolbx. Les réglages sont lus par un compte ordinaire, dans l'ordre des dossiers de KDE sur Fedora ;
  - test en VM (`tests/vm/run.sh`, `check_identity`) : dans la session du compte de test, Plasma a bien appliqué le jeu de couleurs, le thème global, les icônes, la police, l'opacité des menus et le profil Konsole. Captures : bureau, menu, Dolphin, Konsole, réglages des couleurs, et toutes les autres applications.
- **Résultats (2026-10-09, [run 37986772808](https://github.com/PatrickChoumi/Ankh/actions/runs/37986772808))**, vérifiés par le test :
  - les constructions passent, Test 14 compris (polices, thème, barre, Breeze, Konsole, écran de chargement), sur les deux variantes ;
  - dans la session, Plasma a appliqué : jeu de couleurs `Ankh`, thème global `org.fedoraproject.fedoradark.desktop`, icônes `breeze-dark`, police Inter 10, menus à 85 %, profil Konsole `Ankh.profile`, écran de chargement d'Ankh ;
  - **vu sur les captures** :
    - bureau sombre, menu et applications au centre de la barre flottante ;
    - menu, Dolphin (dossiers violets), Discover et réglages en graphite et violet, police Inter ;
    - Konsole translucide, sans le message de Toolbx ;
    - écrans de connexion et de verrouillage : heure et date sur le fond d'Ankh ;
    - écran de chargement : logo d'Ankh sur le fond du logo ;
    - l'assistant de premier démarrage est maintenant sombre, aux couleurs d'Ankh. Il affiche toujours « Welcome to Plasma Desktop » (D-037) ;
  - la barre se colle au bord quand une fenêtre la touche, puis flotte de nouveau : c'est le comportement de Plasma pour une barre flottante ;
  - taille : l'installation reste à 11,3 Go ; les polices ajoutent 17 Mio. Une mise à jour télécharge toujours 1,2 Go (réduction en phase 10, D-027).
- **Modifiée par D-052 (2026-10-14)** : la barre flottante (point 3) devient collée en bas, pleine largeur, 48 px. La règle « uniquement des paquets de Fedora et des réglages de KDE » devient : des paquets de Fedora, des réglages de KDE, et notre propre code dérivé de KDE, gardé dans ce dépôt. Les autres réglages restent.

## D-040 — La protection (phase 4, safezone) passe à la fin du plan (modifie la feuille de route)

- **Statut** : DÉCIDÉ (2026-10-09), mon choix : « Pour safezone, on envisage ça à la fin. Continuons d'abord le plan. »
- **Décision** :
  - La phase 4 (protection : safezone adapté et intégré, D-026 et D-030) garde son numéro et son contenu, mais se fait en dernier, après la phase 10. Ordre : 3, 5, 6, 7, 8, 9, 10, puis 4.
  - Ankh V1 est déclarée après la phase 4 : la V1 comprend toujours la protection, comme dans le plan d'origine.
- **Conséquences** :
  - La bascule sur ma machine (phase 9) se fait sans safezone. Le « filtrage » sort de sa checklist matériel et se vérifie sur ma machine avec la phase 4.
  - Entre la phase 9 et la phase 4, Ankh n'a pas de protection contre le contenu pour adultes. L'exigence de ANKH-SPEC reste ; seul son moment change.
  - La conception détaillée (D-026, D-030) reste À DÉCIDER au début de la phase 4.
- **Raisons** : avancer d'abord sur le quotidien, le gaming, la cybersécurité, les labs, la sauvegarde et la bascule.
- **Vérification** : la feuille de route de CLAUDE.md (§5) suit cet ordre.

## D-041 — Gaming : le plus d'outils possible, réglages sûrs, noyau de Fedora (précise D-011 et D-036)

- **Statut** : DÉCIDÉ (2026-10-10), mon choix. Mise en œuvre en phase 5.
- **Contexte** : mes réponses aux questions 6 à 9 (ANKH-SPEC.md) : jeux Steam en solo ou en coop et jeux hors Steam, sans jeux compétitifs à anticheat. « Mets le plus d'outils de gaming, un peu comme dans Garuda Linux ou CachyOS. Vas-tu rendre l'OS super optimisé pour le gaming ? » Et : « l'OS ne doit pas me limiter et doit me permettre de faire tout ce que je veux quand je l'envisage. »
- **Options présentées** :
  1. **outils et réglages sûrs** (recommandée, choisie) ;
  2. la même chose, plus un noyau optimisé pour le jeu (façon CachyOS ou Bazzite), signé par ma propre clé Secure Boot (MOK), que je crée, enregistre et garde moi-même. Gain souvent de quelques pour cent, plus d'entretien ;
  3. les outils seulement.
- **Décision** :
  - **Lanceurs dans le menu, prêts au premier clic** (comme VS Code, D-036 ; rien ne se télécharge sans moi, D-031) : Steam, Heroic (Epic, GOG, Amazon), Lutris (Battle.net, EA, Ubisoft…), Bottles, ProtonPlus (versions de Proton plus récentes) et Protontricks, depuis Flathub.
  - **Dans l'image** : GameMode, MangoHud (compteur d'images par seconde, températures), Gamescope, vkBasalt, et les règles des manettes et casques de Steam (`steam-devices`).
  - **Disponibles sans être imposés** : OBS Studio, Discord, mode console (Steam en plein écran). Leur forme exacte se décide en phase 5.
  - **Réglages du système pour le jeu** : seulement ceux qui ne touchent ni au noyau ni à Secure Boot. Chacun avec sa source et mesuré en VM, en phase 5.
  - **Noyau** : celui de Fedora. Secure Boot reste actif sans clé à gérer (D-006, règle 7).
- **Vérifié le 2026-10-10** (<https://mdapi.fedoraproject.org>, Fedora 44 ; <https://flathub.org>) :
  - dans Fedora 44 : `gamemode` 1.8.2, `mangohud` 0.8.3, `gamescope` 3.16.29, `vkBasalt` 0.3.2, `wine` 11.0, `steam-devices` ; `goverlay` et `lutris` seulement dans `updates-testing` ;
  - absents de Fedora 44 : les ordonnanceurs `scx` de CachyOS (`scx-scheds`) ;
  - sur Flathub : Steam, Heroic, Lutris, Bottles, ProtonPlus, ProtonUp-Qt et Protontricks.
- **Alternatives rejetées** :
  - Tout recompiler pour les processeurs récents, comme CachyOS : impossible sur une base Fedora, et contraire à l'image générique (D-021).
  - Un noyau tiers : il demande ma propre clé Secure Boot et plus d'entretien. Réexaminable après des mesures, par une nouvelle décision.
- **IA locale** (question 7 : oui, important) : CUDA ou ROCm dans un conteneur, selon mon GPU (question 3, inconnue). À concevoir avec le dev ou le gaming, quand le GPU sera connu.
- **Vérification** : en phase 5, chaque outil présent et lancé en VM ; captures ; jeux testés sur ma machine en phase 9 (D-011).
- **Précisé le 2026-10-12** (mes réponses, avec D-046 : Gaming est une option cochée à l'installation) :
  - **Discord et OBS Studio** font partie de l'option Gaming. Comme les lanceurs, ils sont dans le menu et se préparent au premier clic (Flatpak, D-031, D-036) ;
  - **mode console** : une session à choisir sur l'écran de connexion d'Ankh, à côté de la session Plasma : Steam en plein écran (mode Big Picture), dans Gamescope. Son nom et sa mise en œuvre exacte se décident en phase 5 ;
  - **noms de mes jeux** : plus tard. La question 6 reste TODO ; le critère de la phase 5 (« chaque jeu de ANKH-SPEC Q6 testé ») attend ces noms.
- **Précisée par D-050 (2026-10-13)** : MangoHud, vkBasalt et Gamescope existent aussi en Flatpak, préparés avec chaque application ; la session console passe par KWin et Steam Big Picture, sans Gamescope.
- **Précisée par D-051 (2026-10-13)** : réglages sûrs du système pour le jeu : ntsync, chargé avec l'option Gaming ; `vm.max_map_count` déjà réglé par Fedora ; la protection contre les « split locks » reste active.

## D-042 — Interface, deuxième passe : finitions au niveau de macOS et de Windows 11, écran de connexion d'Ankh (complète D-039)

- **Statut** : DÉCIDÉ (2026-10-10), ma demande. Les réglages sont choisis par Claude, sur les sources ci-dessous ; je les valide sur les captures de la VM avant de fusionner.
- **Contexte** : mes demandes du 2026-10-10 : « si tu peux encore améliorer toute l'interface pour qu'elle n'ait rien à envier à macOS ou à Windows 11, fais-le. Ne lésine pas sur les moyens. » Puis : « l'écran de connexion n'a pas le design propre à Ankh. » Puis : « pousse encore plus loin le design visuel d'Ankh, au niveau de macOS et de Windows 11, voire au-dessus. Fais des recherches sur ce qui rend ces systèmes magnifiques, vérifie qu'il n'y a aucune marque de Fedora, sois créatif. »
- **Ce qui rend macOS et Windows 11 beaux, d'après leurs guides officiels** (lus le 2026-10-10) :
  - **une couche de navigation en verre au-dessus du contenu** : chez Apple, Liquid Glass est réservé aux commandes et à la navigation (barres, menus), qui flottent au-dessus du contenu et le laissent transparaître, sans nuire à la lisibilité ; le contenu garde des matières plus sobres (Human Interface Guidelines, « Materials », <https://developer.apple.com/design/human-interface-guidelines/materials>). Chez Microsoft, Mica teinte le fond des fenêtres avec le fond d'écran et montre quelle fenêtre est active ; Acrylic, translucide, sert aux menus et volets passagers (<https://learn.microsoft.com/windows/apps/design/style/mica>) ;
  - **une géométrie douce et régulière** : coins de 8 pixels pour les fenêtres, menus et dialogues, 4 pixels pour les boutons et les champs ; pas de coins arrondis pour une fenêtre agrandie ou ancrée (<https://learn.microsoft.com/windows/apps/design/signature-experiences/geometry>) ;
  - **une couleur de marque cohérente**, toujours avec le même sens, et **chaque couleur en version claire et sombre**, avec un mode automatique qui passe de l'une à l'autre dans la journée (HIG, « Color » et « Dark Mode ») ;
  - **une typographie lisible** : 13 points par défaut sur macOS, des graisses moyennes plutôt que fines, peu de polices différentes (HIG, « Typography ») ;
  - **un mouvement utile, bref et précis**, jamais gratuit, et désactivable (HIG, « Motion »).
- **Ce qui était déjà fait par KDE** (Plasma 6.7, vérifié dans les sources le 2026-10-10) :
  - **coins arrondis des fenêtres**, en haut et en bas : `RoundedCorners`, vrai par défaut (`kdecoration/breezesettingsdata.kcfg` et `breezedecoration.cpp` de <https://invent.kde.org/plasma/breeze>). Le point « coins arrondis » de D-039 est donc réglé sans rien ajouter ;
  - **flou derrière les menus, la barre et le terminal** : au plus fort par défaut, avec grain et saturation, comme sous macOS (`BlurStrength` 15 sur 15, `NoiseStrength` 5, `Saturation` 150, `src/plugins/blur/blur.kcfg` de <https://invent.kde.org/plasma/kwin>). Il est éteint seulement sans carte graphique (rendu logiciel : `BlurEffect::enabledByDefault`), comme dans la VM de test ;
  - **fenêtres nouvelles au centre de l'écran** (`Placement`, `src/kwin.kcfg`).
- **Décision** : toujours avec des paquets de Fedora et des réglages par défaut de KDE, modifiables par chaque compte, sans thème tiers.
  1. **Thème clair aux couleurs d'Ankh** : jeu de couleurs « Ankh Clair » (`AnkhClair.colors`, dérivé de Breeze clair) : gris très clair, texte graphite, violet foncé du logo pour les sélections et le focus (contraste 5,7 avec du texte blanc ; texte secondaire 4,8 ; liens 7,1). Il remplace Breeze clair dans tous les thèmes globaux clairs : « Ankh », « Ankh Clair », et Breeze clair de KDE (celui de l'assistant de premier démarrage).
  2. **Clair et sombre automatiques**, comme sous macOS, si je l'active dans les réglages : entre « Ankh Clair » et « Ankh Sombre », au lieu de Breeze (`DefaultLightLookAndFeel` et `DefaultDarkLookAndFeel`, `kcms/lookandfeel/lookandfeelsettings.kcfg` de plasma-workspace). Par défaut : toujours sombre.
  3. **Recherche au milieu de l'écran**, comme Spotlight : Alt+Espace ouvre la recherche au tiers de la hauteur de l'écran, au lieu d'un bandeau collé en haut (`FreeFloating`, `krunner/view.cpp` de plasma-workspace).
  4. **Menu et barre** : favoris du menu (navigateur, VS Code, fichiers, terminal, Discover, VLC, OnlyOffice, réglages) au lieu de ceux de Fedora (KWrite, Kontact), lus à la création du menu de chaque compte (`kicker-extra-favoritesrc`, `portOldFavorites` de `applets/kicker/kastatsfavoritesmodel.cpp`) ; applications épinglées dans la barre : fichiers, navigateur, VS Code, terminal, Discover, réglages (`launchers`, `applets/taskmanager/main.xml` de plasma-desktop).
  5. **Accueil de KDE (Welcome Center)**, ouvert à la première session : texte et logo d'Ankh sur la première page, à la place de Konqi, et une page « Raccourcis utiles » (menu, recherche, vue d'ensemble, moitié d'écran, fichiers, terminal, presse-papiers, capture d'écran, émojis, verrouillage). Méthode prévue par KDE (`intro-customization.desktop` et `extra-pages`, README.md de <https://invent.kde.org/plasma/plasma-welcome>). Les raccourcis sont ceux de KDE par défaut, vérifiés un par un : `shell/shellcorona.cpp` (Windows), `krunner/org.kde.krunner.desktop.cmake` (Alt+Espace), `src/plugins/overview/overvieweffect.cpp` (Windows+W) et `src/useractions.cpp` (Windows+flèches) de KWin, `org.kde.dolphin.desktop` (Windows+E), `org.kde.konsole.desktop` (Ctrl+Alt+T), `klipper/klipper.cpp` (Windows+V), `org.kde.spectacle.desktop.cmake` (Impr. écran, Windows+Maj+S), `emojier/app/org.kde.plasma.emojier.desktop` (Windows+.), `settings/kscreensaversettings.cpp` de kscreenlocker (Windows+L).
  6. **VS Code** (conteneur de dev) : police JetBrains Mono, et le violet d'Ankh à la place du bleu dans le thème sombre de VS Code (`workbench.colorCustomizations` limité à « Default Dark Modern », <https://code.visualstudio.com/api/references/theme-color>). Réglages écrits à la création du conteneur, seulement s'il n'en a pas déjà.
  7. **Barre toujours en verre** : translucide et floutée même quand une fenêtre est agrandie, comme le Dock de macOS et la barre des tâches de Windows 11 (`panel.opacity = "translucent"`, `PanelView::OpacityMode` de `shell/panelview.h` et `shell/scripting/panel.cpp` de plasma-workspace). Par défaut, Plasma la rend opaque dans ce cas.
  8. **Écran de chargement** : sous le logo, une fine barre de progression violette qui avance à chaque étape du chargement de la session (six étapes, `ksplash/ksplashqml/splashapp.cpp`), comme au démarrage d'un Mac, au lieu de l'indicateur qui tourne.
  9. **Fond « Ankh Signal » en clair et en sombre** : mêmes rubans, en violet et cyan foncés sur un gris très clair, rangés dans `contents/images` ; la version sombre passe dans `contents/images_dark`. Plasma prend celle qui va avec le jeu de couleurs : le fond suit le thème clair ou sombre, et le mode automatique (`build_files/artwork/fonds.py`).
  10. **Icône de VS Code** dans le style d'Ankh : la touche graphite du logo, avec « </> » en blanc et la barre oblique violette (`ankh-code.svg`), au lieu de l'icône générique de KDE. VS Code ouvert garde son icône à lui.
  11. **Écran de connexion et de verrouillage** :
     - ce que l'on peut régler : le gestionnaire de connexion de Fedora 44 (Plasma Login) dessine son écran dans son propre programme (`Main.qml` compilé, `src/frontend/greeter/main.cpp` de <https://invent.kde.org/plasma/plasma-login-manager>) ; sa disposition ne se change pas. Il prend déjà le fond d'Ankh, le jeu de couleurs et les polices du thème global (`src/frontend/startkde/startplasma.cpp`), et floute le fond quand on s'en sert ;
     - ce qui manquait : l'**image du compte**. Sans image, c'est la silhouette de KDE. Chaque nouveau compte reçoit maintenant l'image d'Ankh (le A et son curseur sur un disque graphite, `build_files/artwork/generer.py`), dans `/etc/skel/.face.icon`, que la session et l'écran de verrouillage lisent ;
     - l'écran de connexion ne peut pas lire le dossier personnel : il ne voit que l'image enregistrée auprès d'AccountsService (`KUser::faceIconPath`, `src/lib/util/kuser_unix.cpp` de kcoreaddons). À la première session, `/usr/libexec/ankh-image-de-compte` l'enregistre (méthode `SetIconFile`, que chaque compte peut appeler pour lui-même, `src/user.c` de <https://gitlab.freedesktop.org/accountsservice/accountsservice>). Une seule fois par compte : une image choisie ensuite, ou retirée, est respectée ;
     - **option si cela ne suffit pas** (à décider par moi, pas faite) : remplacer Plasma Login par SDDM, avec un écran de connexion entièrement dessiné pour Ankh. Plus de liberté, mais un changement du gestionnaire de connexion, donc du démarrage de la session : à tester en VM, et à surveiller à chaque version de Fedora.
- **Alternatives rejetées** : thèmes et décorations tiers (Klassy, Lightly, Kvantum, thèmes macOS) : hors de Fedora, à suivre nous-mêmes, souvent cassés par une nouvelle version de Plasma ; un écran de connexion modifié dans le programme de KDE : notre propre version à maintenir.
- **Mise en œuvre** : `build_files/build.sh` (bloc D-042), `build_files/plasma/ankh-barre.js` et `ankh-splash.qml`, `build_files/artwork` (image de compte, icône de VS Code, fond clair), `build_files/files` (jeu de couleurs, accueil de KDE, image de compte et son lancement automatique), `dev/setup.sh` et `dev/packages.txt`. La construction échoue si la base fixe déjà l'un de ces réglages (`krunnerrc`, `kicker-extra-favoritesrc`, `/etc/skel/.face.icon`, page d'accueil de Fedora) ou si un thème global attendu ne prend plus Breeze clair.
- **Proposé pour plus tard, à décider par moi** : un écran de démarrage (Plymouth) entièrement d'Ankh, logo et barre de progression comme au démarrage d'un Mac, au lieu du thème de Fedora dont seul le logo du bas est changé (D-034). Il touche au démarrage et à la saisie du mot de passe LUKS : à tester en VM avec LUKS avant de l'adopter.
- **À VALIDER** :
  - l'aspect sur les captures de la VM, puis sur ma machine ;
  - l'image de compte sur l'écran de connexion de ma machine (vérifiée en VM par le test) ;
  - le flou de la barre translucide sur une carte graphique modeste ;
  - les raccourcis « Windows » sur mon clavier.
- **Vérification** :
  - `just test`, Test 14 (`tests/identite.sh`) : « Ankh Clair » dans les thèmes clairs, thèmes clair et sombre automatiques, barre translucide, fond clair et sombre, recherche flottante, favoris du menu, applications épinglées dans chaque barre, pages de l'accueil de KDE, image de compte et son lancement automatique ; Test 9 : icône de VS Code ;
  - `just test ankh-dev`, Test 3 : réglages de VS Code lisibles, police JetBrains Mono installée dans le conteneur ;
  - test en VM (`tests/vm/run.sh`) : recherche flottante dans la session, image de compte enregistrée auprès d'AccountsService ; captures : recherche, page « Raccourcis utiles », thème clair, écran de verrouillage et écran de connexion avec l'image du compte. Dans la VM seulement, le test essaie d'allumer le flou pour le compte de test, et affiche le type de rendu de KWin.
- **Résultats (2026-10-10, [run 38057489422](https://github.com/PatrickChoumi/Ankh/actions/runs/38057489422))**, vérifiés par le test :
  - les constructions passent : Test 14, Test 11 (aucune marque de Fedora), Test 9, et Test 3 du conteneur de dev ;
  - dans la session : recherche flottante appliquée ; image de compte enregistrée (`/var/lib/AccountsService/icons/ankhvm`) ;
  - **vu sur les captures** :
    - accueil de KDE avec le texte et le logo d'Ankh, et la page « Raccourcis utiles » ;
    - favoris du menu et applications épinglées d'Ankh, avec l'icône « </> » de VS Code ;
    - recherche au centre de l'écran, écran de chargement avec sa barre de progression ;
    - écran de verrouillage : l'image de compte d'Ankh dans un cercle, le champ du mot de passe en violet, le fond flouté ;
    - aucune marque de Fedora sur les captures d'Ankh. Seule l'étape 4 du test, qui revient à l'image de base sans Ankh, montre celle de Universal Blue, comme prévu ;
  - **défauts vus, corrigés ensuite** :
    - le fond de l'assistant restait uni : en thème sombre, l'assistant cherche dans `images_dark`, et son repli vers `images` ne marche pas (code de `src/qml/LandingComponent.qml` ; cause supposée : une adresse vide y passe pour valide). Le fond d'Ankh est maintenant dans les deux dossiers ;
    - le titre « Bienvenue dans Ankh » de la page de l'assistant était affiché deux fois : l'assistant l'affiche déjà ;
    - la capture de l'écran de connexion montrait l'heure seule : le clic n'avait pas fait apparaître la liste des comptes. Le test attend maintenant plus longtemps, puis bouge la souris avant de cliquer ;
  - **à comprendre** :
    - VS Code ouvert apparaît à côté de son icône épinglée, au lieu de s'y regrouper. Le test affiche maintenant la classe et le fichier `.desktop` de chaque fenêtre vus par KWin, pour corriger le lien ;
    - le flou ne se voit pas dans la VM (rendu logiciel `llvmpipe`, affiché dans « À propos ») ; le test affiche maintenant si l'effet peut s'y charger. Sur une vraie carte graphique, il est allumé par défaut (À VALIDER sur ma machine).
- **Complétée par D-052 (2026-10-14)** : l'interface passe au pixel près de Windows 11, avec nos propres thèmes dérivés du code de KDE. Les thèmes tiers restent écartés. La barre reste en verre (point 7), mais collée en bas.

## D-043 — Démarrage et connexion entièrement d'Ankh : Plymouth « ankh » et SDDM ; logo officiel de VS Code ; vouvoiement (modifie D-034 et D-042)

- **Statut** : DÉCIDÉ (2026-10-10), mes demandes. Les dessins sont de Claude ; je les valide sur les captures de la VM avant de fusionner ([PR #13](https://github.com/PatrickChoumi/Ankh/pull/13)).
- **Contexte** : mes demandes du 2026-10-10 : « fais l'écran de démarrage entièrement d'Ankh et passe à SDDM. Remets le logo initial de VS Code, et ne tutoie pas dans tes textes. » Ce sont les deux propositions laissées ouvertes par D-042 (option du point 11, et « proposé pour plus tard »).
- **Ce changement touche au démarrage, à la saisie du mot de passe LUKS et au gestionnaire de connexion : à relire.**
- **Décision** :
  1. **Écran de connexion : SDDM au lieu de Plasma Login** (modifie D-042, point 11).
     - Pourquoi : l'écran de Plasma Login est compilé dans son programme et ne se redessine pas (D-042). SDDM charge un thème écrit en QML, que l'on dessine entièrement.
     - Paquets de Fedora 44 : `sddm` 0.21 et `sddm-wayland-plasma` (son écran tourne sous Wayland, dans KWin : `/usr/lib/sddm/sddm.conf.d/plasma-wayland.conf`). `plasma-login-manager` et sa page des réglages (`kcm-plasmalogin`) sont retirés ; `display-manager.service` désigne `sddm.service`. La construction échoue si la base désigne un autre gestionnaire que Plasma Login, si un thème SDDM y est déjà choisi, ou si le réglage de KWin ou son programme manquent.
     - L'assistant de premier démarrage sait travailler avec SDDM : il y écrit sa connexion automatique dès que Plasma Login n'est pas activé (`src/bootutil/bootutil.cpp` de <https://invent.kde.org/plasma/plasma-setup>).
     - **Thème « ankh »** (`/usr/share/sddm/themes/ankh`, Qt 6) : fond « Ankh Signal » flouté et assombri, grande horloge et date en français, image du compte dans un cercle (celle d'Ankh par défaut, dans `faces/.face.icon`, `UserModel.cpp` de <https://github.com/sddm/sddm>, version 0.21.0), champ du mot de passe en pilule avec le focus violet, secousse et message si le mot de passe est faux, alerte « Verr. Maj est activé », boutons ronds translucides (veille, redémarrage, arrêt), choix du compte, de la session et de la disposition du clavier s'il y en a plusieurs. Choisi par `/usr/lib/sddm/sddm.conf.d/ankh.conf` ; mes propres réglages, dans `/etc/sddm.conf.d`, passent après.
     - Pas de page des réglages de SDDM : `sddm-kcm` n'existe dans Fedora 44 qu'en version 6.6.4, plus ancienne que Plasma 6.7 (À VALIDER à chaque version). L'écran se change dans ce dépôt.
  2. **Écran de démarrage : thème Plymouth « ankh »** (modifie D-034, qui ne changeait que le filigrane du thème de Fedora).
     - Module `two-step` de Plymouth 24 : fond graphite, logo d'Ankh au centre, fine barre de progression violette dessous, comme l'écran de chargement de la session ; sans le logo du fabricant du PC.
     - **Saisie du mot de passe du disque (LUKS)** : champ en pilule au contour violet, puces et cadenas d'Ankh, comme l'écran de connexion. Les indicateurs de clavier (Verr. Maj, disposition) sont repris du thème « spinner » de Plymouth, celui que Fedora utilise. La construction échoue s'ils manquent.
     - Textes des modes de mise à jour du système en français, en vouvoyant (« N'éteignez pas l'ordinateur »).
     - Choisi par `plymouth-set-default-theme ankh`, puis copié dans l'initramfs, reconstruit à la fin de la construction (D-034).
  3. **Logo officiel de VS Code** (remplace D-042, point 10) : l'icône du pack que Microsoft publie pour représenter VS Code (<https://code.visualstudio.com/brand>), téléchargée à la construction et refusée si son empreinte SHA-256 change. L'icône « </> » d'Ankh est retirée. VS Code ouvert se regroupe maintenant avec son icône épinglée : sous Wayland, sa fenêtre s'appelle `com.microsoft.VSCode` (vu par le test en VM), écrit dans `StartupWMClass`.
  4. **Vouvoiement** : les textes affichés par Ankh vouvoient (page de l'assistant, accueil de KDE, raccourcis, messages des outils de dev). Les réponses de Claude aussi.
- **Alternatives rejetées** :
  - garder Plasma Login et modifier son programme : notre propre version à maintenir ;
  - un thème SDDM ou Plymouth tiers : hors de Fedora, à suivre nous-mêmes ;
  - le thème Plymouth « spinner » avec seulement d'autres images : il garde le logo du fabricant du PC et la disposition de Fedora.
- **À VALIDER** :
  - l'aspect sur les captures de la VM, puis sur ma machine ;
  - la saisie du mot de passe LUKS sur ma machine : la VM de test n'a pas de disque chiffré, l'écran y est lancé à la main ;
  - le portefeuille de KDE (KWallet) déverrouillé à la connexion par SDDM, comme avec Plasma Login (module `pam_kwallet` dans la configuration PAM de SDDM) ;
  - SDDM et `sddm-wayland-plasma` à chaque nouvelle version de Fedora (D-017).
- **Vérification** :
  - `just test`, Test 14 (`tests/identite.sh`) : SDDM est le gestionnaire de connexion, Plasma Login est absent, le thème « ankh » est choisi et complet ; le thème est chargé par SDDM en mode test, hors écran, et la moindre erreur QML fait échouer la construction ; aucun tutoiement dans les pages d'Ankh. Test 9 : icône officielle de VS Code. Test 11 (`tests/sans-fedora.sh`) : thème Plymouth « ankh » choisi, et présent à l'identique dans l'initramfs ;
  - test en VM (`tests/vm/run.sh`) : captures de l'écran de connexion, d'un faux mot de passe, puis connexion par cet écran avec le bon ; Plymouth lancé à la main pour capturer l'écran de démarrage et la saisie du mot de passe.
- **Résultats** : première construction de la PR #13 en échec, `package kwin-wayland is not installed` : ce paquet n'existe pas sous ce nom dans Fedora 44. La construction vérifie maintenant le réglage de KWin et son programme.
- **Résultats (2026-10-11, [run 38156340145](https://github.com/PatrickChoumi/Ankh/actions/runs/38156340145), commit f5afd3f)**, vérifiés par la CI et vus sur les captures :
  - les trois constructions passent : Test 14 (thème SDDM chargé sans erreur QML), Test 11 (thème Plymouth dans l'initramfs), Test 12 ;
  - le test en VM réussit ses quatre étapes ; le gestionnaire de connexion est `sddm.service` ;
  - **écran de connexion d'Ankh** : fond flouté, horloge, image de compte d'Ankh, champ en pilule, boutons ronds ; un faux mot de passe affiche « Mot de passe incorrect », puis **la connexion par cet écran réussit** avec le bon mot de passe ;
  - **écran de démarrage d'Ankh** : logo et barre de progression violette ; **saisie du mot de passe du disque** dans le style d'Ankh (lancée à la main : la VM n'a pas de disque chiffré) ;
  - VS Code apparaît avec son logo officiel dans la barre ;
  - **défauts vus, corrigés ensuite** :
    - la date de l'écran de connexion suivait la langue du système (en anglais dans la VM) : elle est maintenant toujours en français, comme les autres textes de cet écran ;
    - la carte remontait de 17 pixels à l'apparition du message d'erreur : un `Column` de Qt ne place pas un élément de largeur nulle (texte vide). Le message a maintenant une largeur fixe ;
    - les points du mot de passe du disque commençaient contre le bord du champ. Plymouth place la puce n à `x + n × L + L / 2` (`src/libply-splash-graphics/ply-entry.c`, ligne 209). Une puce de 15 pixels, avec le point à droite, met le premier point à 18,5 pixels du bord (aperçu calculé avec cette formule) ;
  - **corrections vérifiées** ([run 38159636158](https://github.com/PatrickChoumi/Ankh/actions/runs/38159636158), commit d159255) : date « Dimanche 11 octobre » ; la carte reste au pixel près à la même place quand le message d'erreur apparaît (comparaison des deux captures) ; les points du mot de passe du disque sont décollés du bord du champ ;
  - **toujours à comprendre** : le fond de l'assistant de premier démarrage reste uni (gris graphite d'Ankh). Les fichiers sont là et lisibles, l'environnement de l'assistant contient bien `/usr/share` dans `XDG_DATA_DIRS`, et aucune erreur de chargement n'est signalée. Impact faible : la page reste propre.

## D-044 — Quatre éditions d'Ankh : Dev, Gaming, Hacking, et Complète qui les réunit (modifie D-036)

- **Statut** : REMPLACÉE par D-046 (2026-10-11), le jour même, après mes réponses sur la façon de les construire. Était : DÉCIDÉ (2026-10-11) pour le principe, construction À DÉCIDER.
- **Contexte** : « Ma vision s'est affinée. Je veux une version d'Ankh pour le dev, une pour le gaming, une pour le hacking, et une qui réunit toutes les versions. » D-036 avait fixé « un seul Ankh », avec tous les outils dans le menu.
- **Décision (ce que je veux)** :
  - **Ankh Dev** : coder (D-012, D-032, D-038, D-043). **Ankh Gaming** : jouer (D-011, D-041). **Ankh Hacking** : la cybersécurité, les labs et plus tard l'analyse de malware (D-013, D-014). **Ankh Complète** : les trois réunies.
  - Toutes partagent le même socle : identité visuelle, sécurité (Secure Boot, LUKS, SELinux, pare-feu), mises à jour sans rien d'automatique, retour arrière, applications du quotidien, sauvegarde (phase 8) et protection (phase 4). Chacune existe pour Mesa et pour NVIDIA (D-021), avec et sans protection (D-030).
  - **Ce qui ne change pas** : les règles 5, 7 et 8. Même dans Ankh Hacking, aucun outil offensif ni malware sur l'hôte : ils restent dans le conteneur Kali ou dans une VM. De D-036, je garde : chaque outil apparaît dans le menu comme une application ordinaire, isolé dessous, préparé au premier clic avec sa progression, sans « ankh-dev » à gérer. Ce qui change : une édition ne montre que ses outils.
  - Noms (proposés, à confirmer) : Ankh Dev, Ankh Gaming, Ankh Hacking, Ankh Complète. Le nom `ankh-dev` est déjà celui de l'image du conteneur de dev (D-032) : l'un des deux devra être renommé.
- **Options présentées pour la construction (À DÉCIDER)** :
  1. **Quatre images construites en couches sur un socle commun** (recommandée).
     - La CI construit une fois le socle, puis chaque édition par-dessus ; Ankh Complète empile les trois couches. Avec Mesa et NVIDIA : 8 images ; 16 avec les versions protégées de la phase 4 (D-030), sauf si la protection devient elle-même une couche.
     - Changer d'édition, c'est `bootc switch` vers une autre image, appliqué au redémarrage que je choisis (D-010), avec retour arrière. Seules les couches qui diffèrent se téléchargent. Indice : en phase 2, un basculement entre deux images Ankh de même base n'a téléchargé que 641 octets (D-004). Le gain réel entre éditions est À VALIDER : il suppose que le socle soit construit une seule fois et réutilisé tel quel.
     - Pour : de vraies versions, chacune ne contient que ce qu'elle utilise (Ankh Gaming n'a ni libvirt ni les outils des labs, Ankh Dev n'a pas les réglages du jeu) ; chacune est signée, testée et réversible comme aujourd'hui.
     - Contre : quatre fois plus de constructions et de tests en VM à chaque changement. Ils peuvent tourner en parallèle ; leur gratuité pour un dépôt public est À VALIDER. Plus d'images à surveiller à chaque version de Fedora (D-017). Il faut redémarrer pour changer d'édition.
  2. **Une seule image complète ; l'édition se choisit au premier démarrage, puis dans les réglages.**
     - L'assistant demande « Dev, Gaming, Hacking ou Complète » ; le choix décide de ce que montrent le menu et la barre, et des outils préparés. Il se change à tout moment, sans redémarrer ni rien télécharger.
     - Pour : le moins de travail (2 images, 4 avec la protection) ; changement instantané.
     - Contre : ce ne sont pas de vraies versions. Tout ce qui est dans l'image est présent dans chaque édition, même caché (libvirt dans Ankh Gaming, par exemple). La différence de taille est faible, car le lourd (conteneur de dev, Steam, Kali) se télécharge au premier clic dans les deux options.
  3. **Quatre images indépendantes, sans socle commun** : déconseillée. Le socle est construit quatre fois, les couches ne se partagent pas, et changer d'édition retélécharge presque toute l'image (D-027).
- **Recommandation : option 1.** Elle colle à la vision (de vraies versions), garde le modèle image-based (une édition est une image signée, testée, réversible), et Ankh Complète est exactement la somme des trois. Son coût est surtout pour la CI, pas pour moi.
- **Conséquences sur la feuille de route** : la phase 3 fait le contenu d'Ankh Dev, la phase 5 celui d'Ankh Gaming, les phases 6 et 7 celui d'Ankh Hacking. Avec l'option 1, une étape vient avant la phase 5 : séparer `build_files/build.sh` en socle et éditions, puis construire et tester les quatre éditions en CI. Avec l'option 2 : une page de choix dans l'assistant de premier démarrage.
- **Vérification** : selon l'option choisie. Pour l'option 1 : chaque édition construite, testée et signée en CI ; démarrage en VM des éditions Mesa ; en VM, passage d'une édition à l'autre et retour arrière, avec la taille téléchargée mesurée.

## D-045 — VISION.md : le portrait d'Ankh à la fin, pour vérifier qu'on ne dévie pas

- **Statut** : DÉCIDÉ (2026-10-11), ma demande.
- **Contexte** : « Fais-moi un document qui dit les caractéristiques et les spécificités qu'Ankh devrait avoir à la toute fin, afin que je me rassure qu'on n'a pas dévié de ma vision. » La règle 11 demande une décision pour tout nouveau document.
- **Décision** :
  - [VISION.md](VISION.md) décrit Ankh une fois terminé : ses quatre éditions (D-044), ce qu'elles ont en commun, et ce que chacune apporte.
  - Il ne crée ni besoin ni choix : chaque trait renvoie à mon besoin (ANKH-SPEC.md) ou à sa décision (D-xxx). Ce qui n'est pas encore tranché y est marqué `À DÉCIDER`, `TODO` ou `À VALIDER`, comme ailleurs.
  - Il ne contient ni l'état d'avancement (AVANCEMENT.md), ni les raisons et les sources (DECISIONS.md), ni les étapes (CLAUDE.md, §5).
  - **Garde-fou** : une décision qui change un trait de VISION.md met ce fichier à jour dans le même commit, et le compte rendu le signale. En cas de contradiction, DECISIONS.md fait foi pour les choix et ANKH-SPEC.md pour les besoins ; VISION.md est alors à corriger.
- **Vérification** : je relis VISION.md ; chaque compte rendu dit s'il a changé.
- **Modifiée par D-046 (2026-10-11)** : VISION.md décrit maintenant une seule version et ses options, au lieu des quatre éditions de D-044.

## D-046 — Une seule version d'Ankh, avec des options choisies à l'installation ; ISO d'installation hors ligne (remplace D-044 ; modifie D-001, D-027 et D-036)

- **Statut** : DÉCIDÉ (2026-10-11), mes choix. Le lieu exact du choix et la fabrication de l'ISO sont À VALIDER (ci-dessous).
- **Contexte** : D-044 proposait quatre éditions et trois façons de les construire. Mes réponses du 2026-10-11 :
  - « Et si on faisait juste une version complète, et c'est lors de l'installation que chacun choisit ce qu'il veut ? »
  - « Comme Ubuntu, qui à l'installation propose la version complète ou la version simple, mais adapté pour Ankh. »
  - « Tous les outils dans un ISO, et on installe juste ce qu'on veut : VS Code ne devrait être installé que si l'on a choisi l'option dev. »
- **Décision** :
  - **Une seule image du système**, complète. Elle existe toujours pour Mesa et pour NVIDIA (D-021), avec et sans protection (D-030). Les quatre éditions de D-044 sont abandonnées.
  - **À l'installation, des cases à cocher**, combinables. Toutes ont le bureau d'Ankh :
    - **Simple**, toujours incluse : Chrome, VLC et OnlyOffice ;
    - **Dev** : VS Code et le conteneur de dev (D-032, D-036, D-038) ;
    - **Gaming** : les lanceurs et les outils de D-041 ;
    - **Hacking** : Kali (D-013) et les labs en VMs isolées (D-014) ;
    - **Complète** : coche Dev, Gaming et Hacking.
  - **Ce qui n'est pas choisi** : les gros outils sont absents du disque (conteneur de dev et VS Code, Steam et les lanceurs en Flatpak, conteneur Kali). Les petites pièces du système qui les servent restent dans l'image, cachées et à l'arrêt : outils du jeu (GameMode, MangoHud, Gamescope…), moteur des VMs. Leur taille est à mesurer.
  - **Après l'installation**, une page des réglages permet d'ajouter ou de retirer une option. Ce qui est ajouté se télécharge quand je le décide (D-031). Ce qui est retiré libère sa place.
  - **ISO d'installation d'Ankh** : elle contient le système et tous les outils des options, pour installer sans internet. Elle est construite par la CI et testée en VM juste avant la bascule sur ma machine (phase 9). Cela modifie D-001 (« pas d'ISO custom en V1 ») et reprend le point 4 de D-027, abandonné le 2026-10-07. L'ISO sert mes machines : Ankh n'est pas une distribution publique (D-001).
  - **Les règles ne changent pas** :
    - placement (règle 5) ;
    - rien n'est installé sur l'hôte en dehors de l'image (D-009) : une option n'ajoute que des Flatpaks et des conteneurs, à leur place ;
    - aucun outil offensif sur l'hôte (D-013).
- **Raisons** :
  - une seule image à construire et à tester, au lieu de 8 à 16 avec les éditions de D-044 ;
  - les options se combinent (Dev et Gaming, par exemple) et se changent sans redémarrer ;
  - avec l'ISO, l'installation ne dépend pas de ma connexion lente (D-027).
- **Alternatives rejetées** :
  - les quatre images de D-044 (option 1) : changer d'édition demande un redémarrage, et la CI travaille quatre fois plus ;
  - rien d'absent du disque, même les petites pièces du système : il faudrait une image par combinaison d'options ;
  - l'ISO tout de suite : elle grossirait à chaque phase et serait à refaire et à retester à chaque fois.
- **À VALIDER**, à la mise en œuvre :
  - **où se fait le choix**. L'installateur de Fedora (Anaconda) ne propose sans doute pas de choisir des logiciels pour un système image-based. Pistes : une extension de l'installateur, ou l'assistant de premier démarrage, juste après l'installation, qui piocherait dans ce que l'ISO a copié ;
  - **par machine ou par compte**. Les conteneurs (dev, Kali) appartiennent à chaque compte ; les Flatpaks peuvent servir toute la machine ;
  - **comment l'ISO embarque les Flatpaks et les images des conteneurs**, et l'outil qui la construit (`bootc-image-builder` ou un autre) ;
  - **la taille de l'ISO** (10 à 15 Go, estimés) et **où l'héberger** : les fichiers d'une version publiée sur GitHub sont limités à 2 Gio ;
  - **les données d'une option retirée** (projets du conteneur de dev, VMs des labs) : gardées, sauf si je demande à les supprimer.
- **Feuille de route** :
  - phase 3 : la page de choix et la page des réglages, pour Simple et Dev, testées en VM. Sans ISO pour l'instant : ce qui est choisi se télécharge ;
  - phases 5 à 7 : elles remplissent Gaming et Hacking ;
  - phase 9 : l'ISO, construite et testée en VM avant d'installer ma machine.
- **Précisé le 2026-10-11** (mes réponses) :
  - le choix se fait **au premier démarrage**, dans l'assistant de KDE (plasma-setup), sur une page d'Ankh ;
  - il vaut **pour toute la machine**.
- **Mise en œuvre prévue du choix (fin de la phase 3)** :
  1. **Page « Que voulez-vous installer ? »** dans l'assistant, ajoutée comme « Bienvenue dans Ankh » (module QML, `docs/CUSTOM_MODULES.md` de <https://invent.kde.org/plasma/plasma-setup>). Elle montre :
     - Simple : toujours incluse, cochée et grisée ;
     - Dev, Gaming et Hacking : des cases ;
     - Complète : coche les trois.

     Gaming et Hacking restent grisés, marqués « bientôt », tant que les phases 5 à 7 ne les ont pas remplis.
  2. **La page n'applique rien elle-même.**
     - Un module QML n'a aucun moyen de changer le système. Les pages de KDE passent par des actions autorisées par polkit au compte spécial de l'assistant, `plasma-setup` (`files/plasma-setup-polkit.rules` : création du compte, nom de la machine, langue…).
     - La page d'Ankh démarre donc un service d'Ankh, `ankh-options@<choix>.service` (par exemple `ankh-options@dev.service`), qui tourne en root et applique le choix.
     - Une règle polkit d'Ankh permet au compte `plasma-setup` de démarrer ce service, et rien d'autre. Elle repose sur l'action `org.freedesktop.systemd1.manage-units`, avec les détails `unit` et `verb`, que systemd transmet à polkit depuis sa version 226 (`NEWS`, et `src/core/dbus-util.c` de <https://github.com/systemd/systemd>).
     - **Touche à polkit : à relire.**
  3. **Lancer la commande depuis la page** : par le moteur « executable » de Plasma5Support, utilisé par les widgets de Plasma. À VALIDER au premier essai. Repli : un petit module compilé, comme ceux de KDE.
  4. **Le service** écrit le choix dans `/etc/ankh/options`, puis rend visibles les entrées des options choisies.
     - Les lanceurs de chaque option sont rangés dans l'image hors du menu (`/usr/share/ankh/options/<option>/`).
     - Le service pose un lien vers eux dans `/usr/local/share/applications`, que KDE lit avant `/usr/share` (spécification XDG). Sur Fedora Atomic, `/usr/local` est modifiable.
     - Une option non choisie n'a donc aucune entrée : ni dans le menu, ni dans la recherche, ni dans les favoris.
     - Les fichiers restent ceux de l'image : rien n'est installé en dehors d'elle (D-009).
  5. **Préparation des outils** : au premier clic, comme aujourd'hui (D-036). Avec l'ISO (phase 9), au premier démarrage, depuis la copie de l'ISO.
  6. **Page des réglages « Options d'Ankh »** :
     - les mêmes cases, dans la Configuration du système ;
     - le même service, démarré cette fois avec le mot de passe administrateur (règle par défaut de systemd) ;
     - retirer une option fait disparaître ses entrées. Ses données (projets, VMs) restent, sauf si je demande à les supprimer.
  7. **Sans choix enregistré** (machine installée avant cette page, ou test) : Ankh se comporte comme avec Complète. Aucun outil ne disparaît sans qu'on l'ait demandé.
  8. **Tests** :
     - dans l'image : la page se charge hors écran sans erreur QML ; le service et la règle polkit sont présents ; chaque choix produit les bons liens ;
     - en VM : capture de la page de l'assistant ; le compte `plasma-setup` démarre bien le service, et rien d'autre ; menu sans VS Code avec Simple, puis avec VS Code après l'ajout de Dev dans les réglages (captures).
- **Mise en œuvre (2026-10-12, après la fusion de la PR #13)** : le plan ci-dessus, avec ces précisions :
  - **entrées de Dev** : `ankh-vscode.desktop` et « Mettre à jour les outils de dev » passent dans `/usr/share/ankh/options/dev/applications`. La construction échoue si une entrée de Dev reste dans `/usr/share/applications` ;
  - **`/usr/libexec/ankh-options`** : `appliquer <choix>`, `synchroniser` et `choix`. Le choix est vérifié : `simple`, ou des options connues séparées par « _ ». Tout autre texte est refusé ;
  - **`ankh-options.service`** remet les liens en place à chaque démarrage, y compris après une mise à jour qui ajoute ou retire une entrée ;
  - **page de l'assistant** (`org.ankh.plasmasetup.options`, poids 1, après la langue) : elle s'applique quand elle s'affiche (`onPageActivated`, comme les pages de KDE), puis à chaque changement. Elle lance `systemctl --no-ask-password` : si la règle polkit refusait, aucune fenêtre de mot de passe n'apparaîtrait dans l'assistant. En cas d'erreur, un message propose de réessayer, et le bouton « Next » reste utilisable ;
  - **page des réglages « Options d'Ankh »** (remplacée le 2026-10-12 par la fenêtre décrite plus bas) : une fenêtre de KDE à cases (`kdialog`), ouverte depuis la Configuration du système (catégorie Système) ou le menu. Elle applique le choix avec le mot de passe administrateur, puis rafraîchit le menu de la session (`kbuildsycoca6`). Retirer Dev propose de supprimer l'environnement de dev du compte (`ankh-dev supprimer` : le conteneur et son image) ; les fichiers et projets restent dans le dossier personnel ;
  - **barre** : VS Code n'est épinglé que si son entrée existe (`applicationExists`, `shell/scripting/scriptengine_v1.cpp` de plasma-workspace) ;
  - **page « Bienvenue dans Ankh »** : elle annonce le choix des outils, au lieu de renvoyer directement à VS Code.
- **Tests de la mise en œuvre** :
  - `just test`, Test 15 (`tests/options.sh`) : fichiers, service activé, règle polkit, page de l'assistant, page des réglages ; sans choix enregistré, comme Complète ; Simple seule retire VS Code du menu ; Dev le remet ; choix invalides refusés ;
  - test en VM :
    - capture de la page de l'assistant ; la page a bien enregistré « dev » en s'affichant ;
    - le compte de l'assistant démarre `ankh-options@simple`, mais pas un autre service ;
    - VS Code quitte puis retrouve le menu ;
    - capture de « Options d'Ankh » dans la Configuration du système.
- **Vérifié en VM le 2026-10-12** ([run 38219240112](https://github.com/PatrickChoumi/Ankh/actions/runs/38219240112)) : la page de l'assistant enregistre « dev » en s'affichant ; le compte de l'assistant ne démarre que `ankh-options@` ; VS Code quitte le menu avec Simple seule, puis y revient avec Dev ; « Options d'Ankh » est dans la Configuration du système, catégorie Système, avec le logo d'Ankh.
- **« Options d'Ankh » redessinée (2026-10-12, ma réponse : « Oui, maintenant », avant la phase 5)** : la fenêtre à cases de KDE (`kdialog`) avait l'air d'un outil d'administration. Elle devient une vraie fenêtre d'Ankh :
  - **les mêmes cartes que la page de l'assistant**. Elles sont dans un module QML partagé, `org.ankh.composants` (`/usr/lib64/qt6/qml/org/ankh/composants`), utilisé par les deux : elles restent identiques ;
  - **la fenêtre est un widget de Plasma**, `org.ankh.options`, caché de la liste des widgets (`NoDisplay`, `components/shellprivate/plasmaappletitemmodel.cpp` de plasma-workspace) et ouvert dans une fenêtre ordinaire par `plasmawindowed` (`plasma-windowed/` de plasma-workspace, déjà dans l'image). Aucun module compilé ;
  - **dans la barre**, la fenêtre s'annonce `org.kde.plasmawindowed` : `StartupWMClass` relie ce nom à l'entrée « Options d'Ankh », dont la barre montre le nom et le logo (`windowUrlFromMetadata`, `libtaskmanager/tasktools.cpp`). Limite : une autre fenêtre de `plasmawindowed`, rare, serait rangée sous « Options d'Ankh » ;
  - **appliquer** : bouton « Appliquer », ou Entrée sur une case. La fenêtre lance `/usr/libexec/ankh-options-reglages appliquer <choix>`, qui applique le choix par `pkexec /usr/libexec/ankh-options appliquer <choix>`. Une action polkit d'Ankh, `org.ankh.options.appliquer` (`/usr/share/polkit-1/actions/org.ankh.options.policy`), vise ce seul programme et demande toujours le mot de passe d'un administrateur (`auth_admin`, `auth_admin_keep` pour la session active). **Touche à polkit : à relire** ;
  - **pourquoi `pkexec` plutôt que le service** : systemd n'attend la réponse de polkit que 25 secondes (`src/shared/bus-polkit.c`, délai par défaut `BUS_DEFAULT_TIMEOUT` de `src/libsystemd/sd-bus/bus-internal.h`, systemd 258). Au-delà, le choix échouerait pendant que je tape le mot de passe. `pkexec` l'attend sans limite (`src/polkit/polkitauthority.c` de polkit). Vérifié dans le code, pas par un test. L'assistant garde le service : sa règle polkit l'autorise sans mot de passe, il n'attend rien ;
  - **la session suit tout de suite** : `ankh-options-reglages`, lancé en mon nom, rafraîchit le menu (`kbuildsycoca6`) et retire VS Code de la barre, ou l'y remet après le navigateur, par le script de Plasma (méthode `evaluateScript` de `org.kde.PlasmaShell`). Sans cela, VS Code restait épinglé avec une icône vide : la barre ne retire pas une application disparue (`libtaskmanager/launchertasksmodel.cpp`). Limite : seule la barre du compte qui ouvre la fenêtre suit. Les autres comptes de la machine gardent l'épingle ; je suis seul sur ma machine ;
  - **Dev retirée** : la fenêtre propose « Supprimer » ou « Garder » l'environnement de dev du compte (`ankh-dev supprimer`). Garder permet à VS Code de le retrouver si je recoche Dev ;
  - **messages** : réussite ; mot de passe non donné (rien n'a changé) ; refus ; erreur, avec son détail ;
  - **clavier** : la première case a le clavier à l'ouverture ; Espace coche, Entrée applique, Échap ferme ;
  - `kdialog` ne sert plus : la construction ne l'installe plus. Elle vérifie que `plasmawindowed`, `pkexec`, `kbuildsycoca6` et `busctl` sont là.
- **Tests de la fenêtre redessinée** :
  - `just test`, Test 15 : fichiers du widget, du module de cartes et de l'action polkit ; widget caché ; l'action ne vise que `/usr/libexec/ankh-options`, avec le mot de passe d'un administrateur ; les deux pages utilisent les cartes partagées ; entrée « Options d'Ankh » qui ouvre la fenêtre ; outils présents ; choix invalides refusés avant toute demande de mot de passe ;
  - test des textes : vouvoiement, y compris dans les cartes, la fenêtre et le message de polkit ;
  - en VM (compte de test administrateur, groupe `wheel`, le temps de l'essai, comme le compte créé par l'assistant) :
    - ouverture depuis la Configuration du système (capture) ;
    - Dev retirée au clavier, avec le mot de passe (captures de la fenêtre et de celle de polkit) : VS Code quitte le menu et la barre ; la fenêtre propose de supprimer l'environnement de dev (capture) ; `ankh-dev supprimer` retire le conteneur et son image ;
    - Dev remise de la même façon : VS Code revient dans le menu et dans la barre ;
    - Échap ferme la fenêtre.
- **Vérifié en VM le 2026-10-12** ([run 38284941203](https://github.com/PatrickChoumi/Ankh/actions/runs/38284941203), CI verte) :
  - la fenêtre s'ouvre depuis la Configuration du système, avec le logo d'Ankh dans sa barre de titre et dans la barre des tâches ;
  - la fenêtre de polkit montre le message d'Ankh (« Changer les outils installés sur cette machine demande le mot de passe d'un administrateur. ») ;
  - Dev retirée : VS Code quitte le menu et la barre ; la fenêtre dit « C'est fait » et propose « Supprimer » ou « Garder » l'environnement de dev ;
  - `ankh-dev supprimer` retire le conteneur et son image ;
  - Dev remise : VS Code revient dans le menu et dans la barre, après le navigateur ;
  - Échap ferme la fenêtre.
  - Non testés en VM : les boutons « Supprimer » et « Garder » eux-mêmes (leur commande est testée), le mot de passe refusé ou non donné, et les autres comptes de la machine.
- **Précisée par D-050 (2026-10-13)** : l'option Gaming est remplie (huit applications préparées au premier clic, outils du jeu, session « Ankh Console ») ; Complète coche Dev et Gaming.
- **Vérification** :
  - en VM, une installation par choix utile (Simple seule, Dev, Complète) : ce qui n'est pas choisi est absent du disque et du menu ;
  - ajout puis retrait d'une option dans les réglages ;
  - avec l'ISO : installation en VM sans réseau.
- **Modifiée par D-053 (2026-10-15)** : Simple contient Chrome, VLC, WordCraft, GridCraft et DeckCraft ; une option « Création » s'ajoute (les sept clones d'Adobe de la suite Craft), et Complète la coche aussi.

## D-047 — Plus de fenêtres Claude ni GitHub installées par Chrome (modifie D-024 et D-035)

- **Statut** : DÉCIDÉ (2026-10-11), mon choix : « Finalement, laisse tomber toutes les fenêtres de Chrome. Je vais les installer moi-même. »
- **Décision** :
  - La politique de Chrome qui installait Claude et GitHub dans leur propre fenêtre (`WebAppInstallForceList`, D-024 et D-035) est retirée de l'image.
  - Je les installe moi-même depuis Chrome, si je le veux. GitHub reste accessible dans VS Code par Git (D-024).
  - Les exigences « Claude installé par défaut » et « client GitHub installé par défaut » sont retirées de ANKH-SPEC.md (4.2).
- **Conséquence** : aucune machine n'a encore Ankh, donc rien à nettoyer.
- **Vérification** :
  - `just test`, Test 12 (`tests/applications.sh`) : aucune politique de Chrome n'installe d'application web ;
  - le test en VM ne vérifie plus ces fenêtres.

## D-048 — ISO d'installation : une seule pour toutes les cartes graphiques, construite et hébergée par GitHub (précise D-046)

- **Statut** : DÉCIDÉ (2026-10-12), mon choix : une seule ISO, publiée dans une Release GitHub. Son contenu est allégé par D-049 : elle ne contient plus que le système en version AMD et Intel. Mise en œuvre au début de la phase 9 (D-046).
- **Contexte** : mes questions du 2026-10-11 :
  - peut-on faire une ISO qui détecte toute seule si le PC a une carte AMD ou Intel, ou une carte NVIDIA, au lieu de deux ISO ?
  - peut-on construire l'ISO et l'héberger avec GitHub ?
- **Recherche du 2026-10-11**. Les sources sont citées. « Mesuré » veut dire lu par Claude dans les manifests du registre `ghcr.io`, le 2026-10-11 :
  - **Outils** :
    - `bootc-image-builder` est déprécié au profit de `image-builder` (<https://osbuild.org/docs/bootc/deprecation-notice/>) ;
    - son type `anaconda-iso` est en fin de vie, et il n'embarque qu'une image, en écrivant lui-même la ligne d'installation (README de <https://github.com/osbuild/bootc-image-builder>, version a686afe). Il ne permet donc pas de choisir entre deux images ;
    - Bazzite, Bluefin et Aurora construisent leurs ISO avec `titanoboa` (<https://github.com/ublue-os/titanoboa>). C'est une ISO « live » : l'environnement d'installation est lui-même une image de conteneur, qui peut contenir les images à installer et les Flatpaks (`.github/workflows/build_iso.yml` et `installer/` de <https://github.com/ublue-os/bazzite>).
  - **Détection de la carte graphique** :
    - l'installateur (Anaconda) exécute un script `%pre` avant l'installation. Ce script peut écrire la ligne d'installation, lue ensuite par `%include` (<https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html>) ;
    - lire `/sys/bus/pci/devices/*/vendor` suffit à reconnaître NVIDIA (`0x10de`). Supposé, non testé ;
    - aucun projet trouvé ne le fait : Bazzite, Bluefin et Aurora publient une ISO par variante graphique.
  - **Taille (mesurée)** :
    - `ankh` fait 5,46 Go compressés, `ankh-nvidia` 6,47 Go (et non plus 4,3 et 5,2 Go comme en phase 1) ;
    - elles partagent 3,34 Go de couches de Fedora (`kinoite-main` et `kinoite-nvidia` sortent du même Containerfile, sans rechunk : <https://github.com/ublue-os/main>) ;
    - mettre les deux images dans une ISO coûte donc environ 3,1 Go de plus. Avec les Flatpaks et les conteneurs des options, l'ISO ferait 15 à 20 Go (estimé).
  - **Construction sur GitHub Actions** :
    - le runner standard est gratuit pour un dépôt public : 4 processeurs, 16 Go de mémoire, 14 Go de disque documentés, 6 h maximum par tâche (<https://docs.github.com/en/actions/reference/runners/github-hosted-runners>, <https://docs.github.com/en/actions/reference/limits>) ;
    - les runners plus gros sont toujours payants ;
    - Bazzite libère de la place sur le runner avant de construire (`jlumbroso/free-disk-space`). Que la place suffise pour Ankh est À VALIDER.
  - **Hébergement** :
    - **Release GitHub** : chaque fichier fait moins de 2 Gio, mais la taille totale et la bande passante sont illimitées, sans compte pour télécharger (<https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases>). L'ISO doit donc être découpée en morceaux, que l'on recolle après le téléchargement ;
    - **artefacts de GitHub Actions** : gardés 90 jours au plus, et téléchargeables seulement avec un compte GitHub connecté. Utiles pour les tests ;
    - **Cloudflare R2**, utilisé par Universal Blue : 10 Go gratuits, puis 0,015 $ par Go et par mois (<https://developers.cloudflare.com/r2/pricing/>) ; il faut un compte ;
    - **construire l'ISO soi-même**, sur sa machine Linux, avec `image-builder` ou `titanoboa` dans un conteneur.
  - **Options au premier démarrage depuis l'ISO** :
    - les Flatpaks se copient sur le disque comme sur une clé USB, puis s'installent sans réseau (`flatpak create-usb` et `--sideload-repo`, <https://docs.flatpak.org/en/latest/usb-drives.html>) ;
    - les images des conteneurs se chargent avec `podman load`. Supposé.
- **Options présentées** :
  1. **Une seule ISO, qui détecte la carte graphique** (recommandée) :
     - ISO live de type `titanoboa`, qui contient `ankh` et `ankh-nvidia` ;
     - un court script `%pre` choisit l'image selon la carte ;
     - pour : je n'ai pas besoin de connaître ma carte graphique (question 3 encore inconnue), et une seule ISO à construire et à publier ;
     - contre : environ 3,1 Go de plus. Personne ne le fait encore, donc c'est à tester par nous. La VM n'a pas de carte NVIDIA : il faut un moyen de forcer le choix NVIDIA pour le tester (paramètre au démarrage de l'ISO) ;
     - les portables avec deux cartes (Intel et NVIDIA) prennent `ankh-nvidia` (D-021).
  2. **Deux ISO**, comme Bazzite, Bluefin et Aurora : chacune plus petite et plus simple, mais il faut savoir laquelle prendre.
- **Hébergement proposé** : construction sur GitHub Actions ; publication dans une Release GitHub du dépôt, en morceaux de moins de 2 Gio, avec leurs sommes de contrôle. C'est gratuit, sans compte pour télécharger et sans limite de bande passante. Les artefacts servent aux tests.
- **À relire** :
  - l'ISO touche au démarrage et à Secure Boot. Bazzite inscrit la clé de signature d'Universal Blue pendant l'installation, pour les pilotes NVIDIA ;
  - une Release publique rend l'ISO téléchargeable par tous. Les images d'Ankh le sont déjà sur `ghcr.io`, et Ankh reste personnel, sans support (D-001).
- **Vérification** (phase 9) :
  - l'ISO est construite par la CI ;
  - en VM sans réseau : installation avec chaque choix d'options ; branche Mesa détectée, et branche NVIDIA forcée ;
  - recollage des morceaux et sommes de contrôle vérifiés.

## D-049 — ISO légère : le système seul ; options et version NVIDIA téléchargées si besoin (modifie D-046 et D-048)

- **Statut** : DÉCIDÉ (2026-10-12), mes choix. Mise en œuvre au début de la phase 9.
- **Contexte** : « Après réflexion, l'ISO sera trop lourde. Comment la rendre moins lourde ? » Tailles mesurées le 2026-10-12, dans les registres :
  - système Ankh (`ghcr.io/patrickchoumi/ankh`) : 5,46 Go compressés ; la version NVIDIA en ajoute 3,1 (D-048) ;
  - option Dev, conteneur `ankh-dev` : 1,57 Go ;
  - option Gaming, sur Flathub (API `https://flathub.org/api/v2/summary/<application>`) :
    - Steam : 36 Mo, plus sa partie 32 bits (140 Mo) ;
    - Heroic : 326 Mo ; Lutris : 334 Mo ; Bottles : 176 Mo ;
    - plus leurs bases d'exécution : Freedesktop 25.08 et 26.08, GNOME 49 et 50. Leur taille n'a pas pu être lue (À VALIDER). Environ 2 Go en tout (estimé) ;
  - option Hacking : la base de Kali fait 53 Mo, plus les outils choisis en phase 6.
- **Options présentées** :
  - **Pour le contenu** :
    - système seul (recommandé, choisi) ;
    - système et Dev : 1,6 Go de plus ;
    - tout, mais allégé : environ 10 à 12 Go.
  - **Pour NVIDIA** :
    - version téléchargée si besoin (recommandé, choisi) ;
    - version NVIDIA construite au-dessus d'Ankh : environ 1 Go de plus, mais c'est nous qui assemblerions les pilotes ;
    - les deux versions entières : 3,1 Go de plus.
- **Décision** :
  - **L'ISO contient le système seul**, en version AMD et Intel : environ 5,5 Go, plus l'installateur (à mesurer quand l'ISO existera).
  - **Les options cochées se téléchargent ensuite**, seulement elles, au premier clic de chaque outil (D-031, D-036), comme aujourd'hui sans ISO.
  - **Sur un PC NVIDIA** :
    - l'ISO voit la carte (fabricant `0x10de`) ;
    - au premier démarrage, Ankh propose de passer à la version NVIDIA (`bootc switch`, environ 3 Go à télécharger) ;
    - le passage s'applique au redémarrage que je choisis (D-010) ;
    - rien ne change dans la fabrication des images.
  - **Toujours une seule ISO** pour tous les PC, publiée dans une Release GitHub en morceaux de moins de 2 Gio (D-048).
- **Ce qui change par rapport à D-046** : l'ISO n'installe plus tout sans internet. Le système s'installe sans réseau ; les options et la version NVIDIA en demandent. Au total, je télécharge moins : seulement ce que je choisis (D-027).
- **Alternatives rejetées** : celles des options présentées ci-dessus ; la version NVIDIA construite au-dessus d'Ankh toucherait aux pilotes et à Secure Boot.
- **À DÉCIDER en phase 9** : comment Ankh propose la version NVIDIA (une ligne de la page « Choisissez vos outils », ou un message au premier démarrage).
- **À VALIDER en phase 9** : sur un PC NVIDIA, Secure Boot et l'inscription de la clé d'Universal Blue après le passage (D-006, D-021).
- **Vérification** (phase 9) :
  - taille de l'ISO mesurée ;
  - installation en VM sans réseau ;
  - proposition NVIDIA testée en forçant la détection, puisque la VM n'a pas de carte NVIDIA.

## D-050 — Phase 5 : l'option Gaming, avec les outils du jeu en Flatpak et la session « Ankh Console » (précise D-041 et D-046)

- **Statut** : DÉCIDÉ (2026-10-13), mes choix. Mise en œuvre dans la PR de la phase 5 ; vérifiée en VM le 2026-10-13.
- **Contexte** : D-041 fixe le contenu de l'option Gaming, D-046 la façon de la choisir. En préparant la mise en œuvre, Claude a vérifié dans les sources comment ces outils marchent avec des lanceurs en Flatpak (D-011) :
  - **les jeux lancés par Steam, Heroic, Lutris ou Bottles ne voient ni MangoHud, ni vkBasalt, ni Gamescope installés dans le système** : ce sont des applications Flatpak. Leurs versions Flatpak sont des extensions de Flathub, `org.freedesktop.Platform.VulkanLayer.*`, montées dans `/usr/lib/extensions/vulkan` de chaque application (point d'extension « version: %{branch} », `elements/flatpak-images/platform.bst` de freedesktop-sdk ; le manifeste de Steam sur Flathub lit `/usr/lib/extensions/vulkan/share` et partage `~/.config/MangoHud`). Branches le 2026-10-13 : MangoHud et Gamescope jusqu'à 26.08, vkBasalt jusqu'à 25.08 seulement ;
  - l'ancienne extension `com.valvesoftware.Steam.Utility.gamescope` est en fin de vie, remplacée par `org.freedesktop.Platform.VulkanLayer.gamescope`. Pour Steam, `gamescope -- %command%` ne marche qu'avec une version de Proton empaquetée pour Flatpak (README de l'extension) ;
  - **GameMode, lui, sert aussi les jeux en Flatpak**, par le portail GameMode (`data/org.freedesktop.portal.GameMode.xml` de xdg-desktop-portal) ;
  - **les manettes** demandent les règles de `steam-devices` dans le système (wiki de <https://github.com/flathub/com.valvesoftware.Steam>) ;
  - **le mode console de SteamOS et Bazzite (Gamescope)** n'est pas prouvé avec Steam en Flatpak : Bazzite le fait avec Steam installé dans le système, et des essais avec Steam en Flatpak ont échoué (recherche du 2026-10-13, sources dans le compte rendu). Une ancienne page de Bazzite le réserve aux cartes AMD et Intel Arc ;
  - **KWin peut lancer une seule application comme session**, et s'arrêter avec elle (option `--exit-with-session`, `src/main_wayland.cpp` de <https://invent.kde.org/plasma/kwin>).
- **Questions et mes réponses (2026-10-13)** :
  1. **Session console** : « KWin + Big Picture (Recommandé) », plutôt que Gamescope comme SteamOS, ou plus tard ;
  2. **outils du jeu en Flatpak** : « Oui, au premier clic (Recommandé) », plutôt que seulement ceux du système ;
  3. **barre** : « Steam seul (Recommandé) », plutôt que Steam et Discord, ou aucune.
- **Décision** :
  - **dans le système**, comme D-041 : GameMode, MangoHud, Gamescope, vkBasalt et `steam-devices`. Sans l'option Gaming, ils restent à l'arrêt : `gamemoded` ne démarre qu'à la demande, et les couches Vulkan ne s'activent qu'avec leur variable (`MANGOHUD=1`, `ENABLE_VKBASALT=1` ; `src/mangohud.json.in` de MangoHud et `config/vkBasalt.json.in` de vkBasalt) ;
  - **huit applications dans le menu**, de Flathub, prêtes au premier clic (D-031, D-036) : Steam, Heroic, Lutris, Bottles, ProtonPlus, Protontricks, Discord et OBS Studio ;
  - **au premier clic**, une fenêtre montre le téléchargement de l'application, pour toute la machine, puis celui de MangoHud, Gamescope et vkBasalt en Flatpak pour sa version, quand ils existent ; puis l'application s'ouvre ;
  - **session « Ankh Console »** sur l'écran de connexion, avec l'option Gaming : KWin seul, sans le bureau, et Steam en plein écran (Big Picture). Quitter Steam ramène à l'écran de connexion. Gamescope n'est pas utilisé ;
  - **barre** : Steam y est épinglé avec l'option Gaming, comme VS Code avec Dev ; il en part si Gaming est décochée.
- **Mise en œuvre** :
  - **entrées du menu** : `/usr/share/ankh/options/gaming/applications/<application>.desktop`, posées par `ankh-options` comme celles de Dev (D-046). Chacune porte le nom de fichier de l'entrée que Flatpak installera : après l'installation, l'entrée de Flatpak passe devant, car les dossiers de Flatpak précèdent `/usr/local/share` dans `XDG_DATA_DIRS` (`profile/flatpak.sh` de <https://github.com/flatpak/flatpak> ; vu dans la session de la VM le 2026-10-12) ;
  - **icônes** : les icônes officielles, prises sur Flathub le 2026-10-13 (`https://flathub.org/api/v2/appstream/<application>`, champ `icons`), dans `/usr/share/icons/hicolor` sous le nom de chaque application. Flatpak installe ensuite les siennes, du même nom, qui passent devant. Licences : GPL pour Heroic, Lutris, Bottles, ProtonPlus, Protontricks et OBS ; Steam et Discord sont propriétaires, leur logo sert seulement à les reconnaître dans le menu, comme celui de VS Code (D-043) ;
  - **`/usr/libexec/ankh-flatpak`** : au premier clic, Konsole montre la préparation (`flatpak install --system` depuis Flathub), puis l'application s'ouvre par sa propre entrée du menu, installée par Flatpak (`gio launch`, `gio/gio-tool-launch.c` de GLib) : certaines y ajoutent des options. Protontricks n'ouvre sa fenêtre qu'avec `--no-term --gui` (`src/protontricks/data/share/applications/protontricks.desktop` de <https://github.com/Matoking/protontricks>) ; lancé sans elles, il n'affiche que son aide (`src/protontricks/cli/main.py`). La préparation garde son journal dans `~/.cache/ankh/preparation-<application>.log`. Pour toute la machine, Flatpak n'a pas besoin de mot de passe pour un administrateur dans sa session active et locale (règle polkit de Flatpak pour le groupe wheel, `system-helper/org.freedesktop.Flatpak.rules.in`). Une application lancée par le menu tourne hors de la session, mais polkit la rattache à la session graphique du compte (`src/polkitbackend/polkitbackendsessionmonitor-systemd.c` de <https://github.com/polkit-org/polkit>). polkit prend les groupes du programme qui demande, tels que D-Bus les voit, donc ceux de l'ouverture de la session (`src/polkitbackend/polkitbackendduktapeauthority.c`, polkit 127) : un compte ajouté au groupe wheel doit se reconnecter pour en profiter. Le compte créé par l'assistant est administrateur dès sa création, donc dès sa première session. Sinon, l'agent polkit de KDE demande le mot de passe d'un administrateur : `ankh-flatpak` passe `-y` à Flatpak, et pas `--noninteractive`, qui interdit aussi cette demande (`app/flatpak-quiet-transaction.c` de Flatpak) et faisait échouer la préparation (« Flatpak system operation Deploy not allowed for user », VM du 2026-10-13) ;
  - **version des outils du jeu en Flatpak** : celle du point d'extension `org.freedesktop.Platform.VulkanLayer` du runtime de l'application (`flatpak info --show-metadata`), sinon la branche du runtime. Un outil qui n'existe pas encore pour cette version est annoncé dans la fenêtre, sans échec ;
  - **session** : `/usr/share/ankh/options/gaming/wayland-sessions/ankh-console.desktop`, posée par `ankh-options` dans `/usr/local/share/wayland-sessions`, que SDDM lit avant `/usr/share` (`src/common/Configuration.h` de <https://github.com/sddm/sddm>). Elle lance `/usr/libexec/ankh-console` : `kwin_wayland --xwayland --exit-with-session`, puis Steam par `ankh-flatpak … -gamepadui` ;
  - **pages des options** : Gaming devient une case comme Dev, dans l'assistant et dans « Options d'Ankh ». Complète coche Dev et Gaming. Retirer Gaming propose de supprimer ses applications (`ankh-flatpak supprimer`) : les jeux et les données restent dans le dossier personnel.
- **Limites connues** :
  - **vkBasalt** n'existe pas encore sur Flathub pour la version 26.08 : pas de vkBasalt pour Steam, Protontricks et Discord tant qu'il n'est pas publié. Il sert Heroic et OBS (25.08) ;
  - **Lutris, Bottles et ProtonPlus** n'ont aucun des trois outils en Flatpak : leur runtime GNOME (versions 49 et 50) ne donne pas de version de couche Vulkan, et Flathub n'a pas de couche 49 ou 50 (vu en VM le 2026-10-14). Si leurs jeux peuvent quand même se servir des couches 25.08 reste À VALIDER : le prochain test complet affiche le point d'extension du runtime GNOME ;
  - **dans « Ankh Console »**, sans Gamescope : pas de limite d'images ni de mise à l'échelle FSR dans le menu rapide de Steam ; elles restent possibles jeu par jeu. Le menu d'alimentation de Steam en Flatpak ne peut sans doute pas éteindre la machine (pas d'accès à `org.freedesktop.login1` dans son manifeste) : À VALIDER sur ma machine ;
  - « Quitter Big Picture » laisse Steam en fenêtre dans la session : il faut alors quitter Steam pour revenir à l'écran de connexion ;
  - **compte qui n'est pas administrateur** : Flatpak devrait demander le mot de passe d'un administrateur. En VM, avec un compte ajouté au groupe wheel pendant sa session, donc sans ses droits pour polkit, aucune fenêtre ne s'est ouverte : refus immédiat (2026-10-13). À VALIDER, et à corriger si un deuxième compte doit installer des jeux.
- **Tests** :
  - `just test`, Test 16 (`tests/gaming.sh`) : outils du jeu présents, règles des manettes, couches Vulkan à l'arrêt sans leur variable ; les huit entrées valides, chacune avec son icône et passant par `ankh-flatpak` ; rien d'installé dans l'image ; application inconnue refusée ; session présente seulement avec Gaming ;
  - Test 15 : avec Complète, Steam et la session apparaissent ; avec Simple, ils partent ;
  - test des textes : vouvoiement, aussi dans les entrées, la session et la préparation ;
  - en VM : l'assistant enregistre « dev gaming » ; « Options d'Ankh » retire puis remet Dev et Gaming (VS Code et Steam dans le menu et la barre) ; premier clic sur Steam (captures de la préparation, puis de Steam) avec MangoHud et Gamescope en Flatpak ; avant ce clic, polkit, interrogé comme Flatpak le fait (le programme qui demande, par son nom sur le bus système), laisse l'administrateur installer sans question. Le compte de test est administrateur dès sa création, comme celui de l'assistant ; session « Ankh Console » ouverte par la connexion automatique (KWin seul démarré ; capture de ce que Steam affiche dans une VM sans carte graphique).
- **Vérifié en VM le 2026-10-13** ([run 38407899063](https://github.com/PatrickChoumi/Ankh/actions/runs/38407899063), captures jointes au compte rendu) :
  - l'assistant propose la case Gaming et enregistre « dev gaming » ;
  - « Options d'Ankh » retire puis remet Dev et Gaming, avec le mot de passe : le menu et la barre suivent (VS Code et Steam) ;
  - premier clic sur Steam : la fenêtre de préparation montre le téléchargement, sans mot de passe pour l'administrateur, puis Steam s'ouvre sur sa page de connexion. MangoHud et Gamescope en Flatpak, version 26.08, sont installés avec lui ;
  - session « Ankh Console » : KWin seul, au premier plan, et Steam en Big Picture sur tout l'écran ; le bureau revient ensuite ;
  - les sept autres applications : test ajouté le 2026-10-14 (premier clic, application qui tourne, capture, outils du jeu préparés pour sa version). Il télécharge plusieurs Go : il tourne chaque lundi et à la demande (entrée « gaming_complet » du test en VM), pas pour chaque PR ;
- **Vérifié en VM le 2026-10-14** ([run 38565792193](https://github.com/PatrickChoumi/Ankh/actions/runs/38565792193), test complet, captures jointes au compte rendu) :
  - Heroic, Lutris, Bottles, ProtonPlus, Discord et OBS se préparent au premier clic et s'ouvrent sur leur premier écran ;
  - Protontricks ouvre sa fenêtre, grâce au lancement par sa propre entrée du menu, et signale qu'il ne trouve pas Steam. Il cherche le dossier `steamapps` de la bibliothèque de Steam (`src/protontricks/steam.py`), et Steam n'a jamais été connecté à un compte dans la VM. À VALIDER sur ma machine, Steam connecté ;
  - outils du jeu en Flatpak, selon le runtime : MangoHud, Gamescope et vkBasalt pour Heroic et OBS (25.08) ; MangoHud et Gamescope pour Steam, Protontricks et Discord (26.08) ; aucun pour Lutris, Bottles et ProtonPlus (GNOME 49 et 50, voir les limites).
  - trois essais avaient échoué avant, tous à cause du test : session de test hors du premier plan après l'essai de l'écran de démarrage, `$$` remplacé par systemd-run, compte de test ajouté au groupe wheel pendant sa session.
- **Vérification sur ma machine (phase 9)** : mes jeux (noms à donner, Q6), les manettes, MangoHud et Gamescope dans un jeu, la session « Ankh Console » à la manette.
- **Précisée par D-051 (2026-10-13)** : ntsync est chargé avec l'option Gaming, et retiré sans elle.

## D-051 — Réglages du système pour le jeu : ntsync avec l'option Gaming (précise D-041 et D-050)

- **Statut** : DÉCIDÉ (2026-10-13), mon choix. Mise en œuvre dans la PR de la phase 5 ; vérifiée en VM le 2026-10-13.
- **Contexte** : D-041 ne veut que des réglages sûrs, avec le noyau de Fedora et sans désactiver de protection. Claude a vérifié trois réglages courants dans les sources, le 2026-10-13 :
  - **`vm.max_map_count`**, que certains jeux veulent grand : **déjà réglé par Fedora**, à 1 048 576 (fichier `10-map-count.conf` du paquet systemd de Fedora, <https://src.fedoraproject.org/rpms/systemd> ; changement « IncreaseVmMaxMapCount » de Fedora). Rien à faire ;
  - **`kernel.split_lock_mitigate=0`** : **écarté**. Il retire une protection : la documentation du noyau dit qu'il expose la machine à un déni de service par les programmes qui font des « split locks » (`Documentation/admin-guide/sysctl/kernel.rst` de Linux). Règle 7 de CLAUDE.md ;
  - **ntsync** : pilote du noyau qui reproduit les objets de synchronisation de Windows (`drivers/misc/ntsync.c` de Linux) :
    - Wine s'en sert dès qu'il trouve `/dev/ntsync` (`server/inproc_sync.c` de <https://gitlab.winehq.org/wine/wine>, version 11.19). Proton 11 aussi, sauf avec `PROTON_NO_NTSYNC` (README de <https://github.com/ValveSoftware/Proton>, branche `proton_11.0`) ;
    - Steam en Flatpak voit les périphériques de la machine (`--device=all`, manifeste de <https://github.com/flathub/com.valvesoftware.Steam>) ;
    - Fedora le construit en module (`CONFIG_NTSYNC=m`, `redhat/configs/fedora/generic` de <https://gitlab.com/cki-project/kernel-ark>), livré dans `kernel-modules-core` (liste des fichiers du paquet pour Fedora 44, <https://mdapi.fedoraproject.org>), donc toujours présent avec le noyau ;
    - mais Fedora ne le charge pas : son périphérique n'a pas de numéro fixe (`MISC_DYNAMIC_MINOR`), donc rien ne le charge à sa première ouverture. Une fois chargé, `/dev/ntsync` est ouvert à tous les comptes (`mode = 0666`).
  - Les réglages de Bazzite n'ont pas pu être relus : son dépôt est hors de la portée de la session de Claude.
- **Question et ma réponse (2026-10-13)** : charger ntsync ? « Avec Gaming seulement (Recommandé) », plutôt que toujours, ou jamais.
- **Décision** :
  - ntsync est chargé quand l'option Gaming est choisie : tout de suite, puis à chaque démarrage. Sans Gaming, il n'est pas chargé, comme les autres outils du jeu restent à l'arrêt (D-050) ;
  - aucun autre réglage pour l'instant : on optimise après avoir vécu avec le système (règle 13 de CLAUDE.md, phase 10).
- **Mise en œuvre** : `/usr/libexec/ankh-options synchroniser`, lancé à chaque démarrage et à chaque choix (D-046), charge `ntsync` avec Gaming (`modprobe`) et le retire sans elle. S'il sert encore, à un jeu ouvert, il reste chargé jusqu'au démarrage suivant, avec un message. Seulement sur un système démarré par systemd (`/run/systemd/system`, sd_booted(3)) : pas dans le conteneur de test, dont le noyau n'est pas celui de l'image.
- **Limites** :
  - le gain dépend des jeux et ne se mesure pas en VM (pas de carte graphique). À mesurer sur ma machine en phase 9 (À VALIDER) ;
  - avec Gaming, le noyau a une interface de plus, ouverte à tous les comptes de la machine.
- **Tests** :
  - `just test`, Test 16 : le module ntsync est dans le noyau de l'image (`modinfo`) ;
  - en VM : `/dev/ntsync` présent au démarrage avec Gaming ; ntsync retiré quand « Options d'Ankh » retire Gaming, et rechargé à son retour ; `/dev/ntsync` visible depuis Steam en Flatpak.
- **Vérifié en VM le 2026-10-13** ([run 38407899063](https://github.com/PatrickChoumi/Ankh/actions/runs/38407899063)) : tout ce qui précède, au premier démarrage, après le retour arrière, et dans « Options d'Ankh ». Le gain dans les jeux reste à mesurer sur ma machine.

## D-052 — Interface au pixel près, au niveau de Windows 11 : nos propres thèmes, dérivés du code de KDE (modifie D-037, D-039 et D-042)

- **Statut** : DÉCIDÉ (2026-10-14), mes choix. Police et icônes choisies le 2026-10-15, sur les planches de comparaison du 2026-10-14. Mise en œuvre lot par lot, en parallèle de la phase 5.
- **Contexte** : ma demande du 2026-10-14 : « Je mets un point d'honneur sur l'aspect pixel perfect, du même niveau que Windows 11 en termes d'interface. Fais d'abord un plan super exhaustif, pose-moi des questions, fais des recherches, puis allons-y. »
  - D-039 et D-042 s'en tenaient aux paquets de Fedora et aux réglages de KDE, sans thème tiers.
  - Sur les captures du dernier test complet en VM, les écarts avec Windows 11 se voient encore :

    | Où | Ankh aujourd'hui | Windows 11 |
    |---|---|---|
    | Barre de titre | Titre centré, petits boutons ronds | Titre à gauche avec son icône de 16 px, boutons rectangulaires de 46×32, fermeture rouge (#C42B1C) au survol, barre de 32 px |
    | Coins | 5 px partout | 8 px pour les fenêtres, menus et dialogues ; 4 px pour les boutons et les champs |
    | Barre des tâches | Flottante, surbrillance carrée sous l'application active | Collée en bas, pleine largeur, 48 px, petit trait d'accent (16×3) sous l'application active |
    | Menu | Kickoff : catégories à gauche, boutons texte en bas | Démarrer centré : recherche en haut, 6×3 épingles, « Toutes les applications », « Recommandé », compte et alimentation en bas |
    | Contrôles | Breeze : barres de défilement larges, sélection violette pleine | Barre de défilement fine qui s'élargit au survol ; pastille d'accent de 3×16 devant l'élément choisi ; focus en double trait |
    | Paramètres rapides | Applets séparées (réseau, son, batterie) | Un seul volet : Wi-Fi, Bluetooth, volume, luminosité |
    | Icônes, curseur | Breeze aux dossiers violets, curseur sombre | Icônes Fluent, curseur blanc |
- **Recherches (2026-10-14)**, en deux volets, faites par Claude dans les sources :
  - **la référence Windows 11**, lue dans le code de WinUI 3, sous licence MIT (dictionnaires `*_themeresources.xaml` de <https://github.com/microsoft/microsoft-ui-xaml>, `controls/dev/CommonStyles`, commit `566a040`), et dans la documentation officielle de Microsoft (<https://learn.microsoft.com/windows/apps/design/>). Le kit Figma de Microsoft n'est pas lisible par une machine : rien n'en vient ;
  - **ce que permet Plasma 6.7**, lu dans le code de KDE, branches `Plasma/6.7` (breeze `ca217f1`, kwin `3ce3452`, plasma-workspace `60a25d0`, plasma-desktop `66c0d62`, libplasma `032c5df`, aurorae `0202957`), et dans les paquets de Fedora 44 (<https://mdapi.fedoraproject.org>).
- **La référence Windows 11** (pixels à l'échelle 100 %, couleurs en `#AARRGGBB`) :
  - **géométrie** : rayon 4 pour les contrôles (`ControlCornerRadius`), 8 pour les fenêtres, menus, volets et dialogues (`OverlayCornerRadius`), 4 pour les infobulles ; coins carrés quand la fenêtre est agrandie ou ancrée ; contour de 1 px ; tailles et marges en multiples de 4 (`CornerRadius_themeresources.xaml` ; pages `signature-experiences/geometry` et `layering`) ;
  - **texte** : légende 12/16, corps 14/20, sous-titre 20/28, titre 28/36, grand titre 40/52, affichage 68/92 ; semi-gras (600) pour les titres ; casse de phrase partout (`TextBlock_themeresources.xaml` ; page `signature-experiences/typography`) ;
  - **couleurs, thème sombre** : texte #FFFFFFFF, secondaire #C5FFFFFF, tertiaire #87FFFFFF, désactivé #5DFFFFFF ; fond des contrôles #0FFFFFFF (survol #15FFFFFF) ; cartes #0DFFFFFF ; contours #12FFFFFF ; fonds pleins #202020, #1C1C1C, #282828, #2C2C2C ; voile des dialogues #4D000000 (`Common_themeresources_any.xaml`). Le thème clair a ses propres valeurs, dans le même fichier ;
  - **matières** : Acrylic (volets passagers : flou 30, grain 0,02, teinte #2C2C2C à 15 %, luminosité 0,96 en sombre) ; Mica (fond des fenêtres : teinte #202020 à 80 % en sombre) (`AcrylicBrush.h`, `AcrylicBrush_themeresources.xaml`, `MicaController.h` de WinUI 2) ;
  - **ombres** : élévation E = Z/2 ; menus : flou 16, décalage 8, 26 % en sombre ; fenêtres et dialogues : ombre ambiante (flou 21,3, décalage 2) et ombre directionnelle (flou 64, décalage 32), 37 % chacune en sombre (`DropShadowRecipe.h` ; page `develop/ui/shadows`) ;
  - **mouvement** : 83, 167, 250 et 333 ms ; courbe d'entrée cubic-bezier(0, 0, 0, 1) (page `signature-experiences/motion`) ;
  - **contrôles** : bouton de 32 de haut ; case à cocher de 20 ; interrupteur de 40×20 ; élément de navigation de 36, pastille d'accent de 3×16 ; pouce de défilement de 8, puis 12 au survol ; menus : éléments à 4 px des bords, colonne d'icône de 28 ; infobulle : 12 px, largeur au plus 320 ; dialogue : de 320 à 548 de large, marge de 24 ; focus : trait de 2 et trait intérieur de 1 (fichiers des contrôles dans `CommonStyles` ; page `develop/input/guidelines-for-visualfeedback`) ;
  - **fenêtres** : barre de titre de 32, icône de 16 à 16 du bord, titre en légende (pages `basics/titlebar-design` et `develop/title-bar`) ; boutons de 46 de large, fermeture #C42B1C au survol (copie de Windows Terminal : `src/cascadia/TerminalApp/MinMaxCloseControl.xaml` de <https://github.com/microsoft/terminal>) ;
  - **icônes** : 16 dans les menus, les barres de titre et la zone de notification, 24 dans la barre des tâches, 32 pour les épingles de Démarrer (page `iconography/app-icon-construction`) ;
  - **barre des tâches et Démarrer** : Microsoft ne publie presque aucune mesure du shell. Hauteur de 48, boutons d'environ 44×40, notifications de 364 de large : observés seulement, À VALIDER.
- **Ce que permet Plasma 6.7** (vérifié dans le code, pas encore en VM) :
  - **avec les réglages de KDE** : titre à gauche (`TitleAlignment`, `breezesettingsdata.kcfg`) ; icône à gauche et boutons à droite (`ButtonsOnLeft`, `ButtonsOnRight`, `kwindecorationsettings.kcfg`) ; barre de 48 px (`panel.height`) ; heure et date sur deux lignes (`dateDisplayFormat`, `applets/digital-clock/main.xml`) ; « Afficher le bureau » ; notifications en bas à droite (`PopupPosition`, `notificationsettings.kcfg`) ; durée des animations (`[Effect-scale] Duration`, `AnimationDurationFactor`) ; curseur blanc (`Breeze_Light`, paquet `breeze-cursor-theme`) ; coins carrés quand la fenêtre est agrandie (déjà le cas) ;
  - **avec nos propres fichiers de thème** : rayon de 8 px des volets, de la barre et des infobulles, et trait d'accent sous l'application active (SVG du style Plasma : `dialogs/background`, `widgets/panel-background`, `widgets/tooltip`, `widgets/tasks`, dans `src/desktoptheme/breeze` de libplasma) ; Alt+Tab (`[TabBox] LayoutName`) ; écran de déconnexion (`logout/Logout.qml` du thème global) ;
  - **impossible sans reprendre le code de KDE** : le rayon de Breeze est une constante de 5 px (`Frame_FrameRadius`, `kdecoration/breeze.h` et `kstyle/breezemetrics.h`) ; ses boutons de fenêtre sont ronds (`breezebutton.cpp`) ; ses barres de défilement sont larges (`ScrollBar_Extend` 21) ;
  - **impossible tout court en 6.7** : le contenu de l'OSD du volume (module QML compilé, `shell/osd.cpp`) ; la largeur des notifications (`gridUnit * 18`, `applets/notifications/global/Globals.qml`) ; le menu de disposition au survol du bouton « Agrandir » (rien dans KWin) ; le thème des applications libadwaita, qui ne reçoivent que la couleur d'accent, ramenée au violet d'Adwaita #9141ac (`src/adw-style-manager.c` et `adw-accent-color.c` de libadwaita) ;
  - **Démarrer et paramètres rapides propres à Ankh** : faisables en QML, mais avec des modules privés de Plasma (`org.kde.plasma.private.kicker`, `…private.volume`, `…private.bluetooth`, `…private.brightnesscontrolplugin`), sans garantie d'une version à l'autre.
- **Questions et mes réponses (2026-10-14)** :
  1. **Cible** : « Ankh + rigueur Win11 (Recommandé) » : la géométrie, la typographie, les matières, les animations et la disposition du shell de Windows 11, avec les couleurs graphite et violet et le logo d'Ankh. Plutôt qu'un clone visuel de Windows 11 (accent bleu), ou une simple inspiration.
  2. **Moyens** : « Nos thèmes, code KDE (Recommandé) » : un style, une décoration, un style Plasma et un Démarrer propres à Ankh, dérivés du code de Breeze et de Plasma, gardés dans ce dépôt et compilés dans l'image. Plutôt que Kvantum avec nos dessins, des projets tiers (Klassy, Menu11), ou les seuls réglages de KDE (1 à 3 px d'écart, l'allure de KDE reste).
  3. **Barre des tâches** : « Collée, comme Win11 (Recommandé) » : pleine largeur, 48 px, trait d'accent sous l'application active, horloge sur deux lignes, bande « Afficher le bureau ». Plutôt que la barre flottante de D-037.
  4. **Police** : « Comparer d'abord (Recommandé) ». Segoe UI Variable, celle de Windows 11, ne peut pas être livrée.
  5. **Icônes** : « Comparer d'abord (Recommandé) ».
  6. **Curseur** : « Blanc, comme Windows (Recommandé) » : `Breeze_Light`, déjà dans Fedora.
  7. **Calendrier** : « Maintenant, en parallèle (Recommandé) » : ce chantier commence tout de suite ; la phase 5 reste ouverte jusqu'aux noms de mes jeux.
- **Décision** :
  - **Cible** : Ankh avec la rigueur de Windows 11. Chaque mesure de la référence ci-dessus devient une valeur d'Ankh, sauf les couleurs : celles d'Ankh (graphite et violet, D-037, D-042), rangées par couches comme celles de Windows 11 (fond de fenêtre, couche, carte, contrôle, contour), en sombre et en clair.
  - **Moyens** : nos propres thèmes, dérivés du code de KDE, dans ce dépôt :
    - un **style Qt « Ankh »**, dérivé du style Breeze (`kstyle` de <https://invent.kde.org/plasma/breeze>) : rayons de 4 et 8, tailles des contrôles de Windows 11, barres de défilement fines, focus en double trait, menus et infobulles de Windows 11. Il dessine aussi les applications de KDE en QML, qui passent par lui (`org.kde.desktop` de qqc2-desktop-style) ;
    - une **décoration de fenêtres « Ankh »**, dérivée de celle de Breeze (`kdecoration`) : barre de 32, titre à gauche, boutons de 46×32, rayon de 8, ombres de Windows 11 ;
    - un **style Plasma « Ankh »** : nos SVG pour les volets, la barre, les infobulles et les tâches ; le reste vient de Breeze (`FallbackTheme`) ;
    - un **Démarrer d'Ankh** et des **paramètres rapides d'Ankh**, en QML, dérivés de Kickoff et des applets de Plasma ;
    - le **thème global d'Ankh** pour Alt+Tab, la déconnexion et l'écran de chargement (D-037).
  - **Comment ce code vit dans le dépôt** :
    - le code repris de KDE garde sa licence (GPL ou LGPL) et ses en-têtes ;
    - il part de la version exacte de Plasma de l'image de base. À chaque nouvelle version de Plasma, nos changements sont reportés ; la construction échoue tant que ce n'est pas fait, et la construction de chaque lundi prévient (D-023, D-031) ;
    - il est compilé dans une étape à part du `Containerfile`, sur la même base, avec les outils de compilation de Fedora. Seul le résultat entre dans l'image : rien ne s'installe sur l'hôte en dehors de l'image (D-009).
  - **Barre des tâches collée en bas**, pleine largeur, 48 px, toujours en verre (D-042, point 7). Elle remplace la barre flottante de D-037 et de D-039 (point 3).
  - **Curseur blanc** `Breeze_Light`, à la taille de Plasma (24). Remplacé le 2026-10-15 par les curseurs Fluent blancs, à l'anneau violet (inspiration AnduinOS, ci-dessous).
  - **Rien de Windows dans l'image** : ni Segoe UI, ni ses icônes, ni ses sons, ni ses curseurs, ni ses fonds d'écran. Leur licence l'interdit (<https://learn.microsoft.com/typography/fonts/font-faq> ; conditions des produits Microsoft). Seules les mesures sont reprises : les valeurs de WinUI sont publiées sous licence MIT.
  - **Ce que D-039 et D-042 deviennent** : leurs réglages restent. La règle « uniquement des paquets de Fedora et des réglages de KDE » est remplacée par celle-ci : des paquets de Fedora, des réglages de KDE, et notre propre code dérivé de KDE. Les projets tiers (Klassy, Lightly, Menu11, thèmes macOS) restent écartés (D-042), sauf les icônes et la police si je les choisis ci-dessous, et, depuis le 2026-10-15, les curseurs et le thème GTK Fluent (inspiration AnduinOS, ci-dessous) : des images et des feuilles de style, pas du code.
- **Police (choisie le 2026-10-15 : Selawik)** : planche du 2026-10-14, la même fenêtre de réglages aux mesures de Windows 11, dans chaque police :
  - **Inter** (actuelle, `rsms-inter-fonts` 4.1 de Fedora) : très lisible, mais plus large et plus géométrique que Segoe UI ;
  - **Selawik** : le remplaçant libre de Segoe UI publié par Microsoft (OFL 1.1, <https://github.com/microsoft/Selawik>), aux mêmes mesures. La plus proche de Windows 11 sur la planche. Mais elle n'est plus suivie depuis 2023 ; son README dit qu'il lui manque le crénage de Segoe UI ; elle est absente de Fedora : il faudrait la compiler depuis sa source, à une version figée, dans l'image ;
  - **Open Sans** : humaniste, comme Segoe UI ; dans Fedora (`open-sans-fonts`), mais en version 1.10, plus ancienne que la version 3 montrée sur la planche ;
  - **Noto Sans** (la police de Fedora) et **Source Sans 3** : humanistes, dans Fedora.
- **Icônes (choisies le 2026-10-15 : Fluent, recolorées au violet d'Ankh)** : planche du 2026-10-14, dossiers et fichiers à 48 px, épingles de Démarrer à 32, barre des tâches à 24, barre d'outils à 16 :
  - **Breeze**, dossiers violets (actuelles, KDE, LGPL) ;
  - **Fluent** (<https://github.com/vinceliuice/Fluent-icon-theme>, GPL-3.0) : le style de Windows 11. Absent de Fedora : il serait inclus dans l'image depuis une version figée, avec Breeze pour les icônes qui lui manquent. Sa variante « violette » est en fait rose-magenta (#dc63ee) : elle serait recolorée au violet d'Ankh. Ce sont des images, pas du code : une nouvelle version de Plasma ne les casse pas ;
  - **Papirus**, violet (dans Fedora, GPL-3.0).
- **Mes choix du 2026-10-15** (recommandés par Claude) :
  - **police : Selawik**, la plus proche de Segoe UI. Elle sera compilée depuis sa source officielle, à une version figée, dans l'image (lot 1). Son crénage incomplet est accepté ; il se verra peut-être sur certaines paires de lettres (À VALIDER sur les captures du lot 1) ;
  - **icônes : Fluent**, recolorées au violet d'Ankh, incluses dans l'image depuis une version figée, avec Breeze pour celles qui manquent (lot 9).
- **Inspiration : AnduinOS (ma demande du 2026-10-15 : « inspire-toi d'AnduinOS, je viens de tomber dessus »)** :
  - **ce que c'est** : une distribution Ubuntu faite pour ressembler à Windows 11, par Anduin Xue, ingénieur chez Microsoft ; version 2.0 sur Ubuntu 26.04 et GNOME 50 (<https://www.anduinos.com/>, <https://en.wikipedia.org/wiki/AnduinOS>). Claude a lu ses sources le 2026-10-15 : <https://github.com/Anduin2017/AnduinOS> (version 1, dossier `src/mods`, réglages `35-dconf-patch/dconf.ini`) et <https://github.com/aiursoftweb/anduinos-2> (liste des composants, `OSS.md`). Licence GPL-3.0 ;
  - **sous GNOME, ses pièces ne servent pas telles quelles à Ankh (KDE)** : ArcMenu (disposition « Eleven »), Dash to Panel, Blur My Shell, Tiling Assistant, une extension pour les notifications en bas à droite. Ce sont ses choix et ses valeurs qui servent ;
  - **ce qu'elle confirme** : icônes Fluent, barre collée en bas de 48 px, icônes centrées, bouton « Afficher le bureau », Démarrer de Windows 11, notifications en bas à droite ;
  - **ses valeurs pour la barre**, reprises au lot 4 : opacité de 60 %, flou de rayon 20 et luminosité de 0,8 ; 8 px autour des icônes des applications ; icônes de la zone de notification à 16 px ; trait sous l'application active, tirets sous les autres ;
  - **ses idées pour plus tard** : dispositions d'ancrage par un raccourci (son « Tiling Assistant ») → un script de KWin d'Ankh pour Windows+Z, au lot 7 ; météo à gauche de la barre, comme Windows 11, au lot 4 ;
  - **questions et mes réponses (2026-10-15)**, là où elle diffère de notre plan :
    1. curseur : « Fluent blanc, anneau violet (Recommandé) » : les curseurs Fluent blancs (« Fluent-dark-cursors », <https://github.com/vinceliuice/Fluent-icon-theme>, dossier `cursors`, GPL-3.0), ceux d'AnduinOS, plus proches de Windows 11 que Breeze_Light ; leur anneau d'attente, bleu, est recoloré au violet d'Ankh. Ils remplacent `Breeze_Light`, choisi le 2026-10-14. Planche du 2026-10-15 ;
    2. applications GTK : « Fluent GTK violet (Recommandé) » : le thème d'AnduinOS (<https://github.com/vinceliuice/Fluent-gtk-theme>, GPL-3.0), variante ronde et violette, recolorée au violet d'Ankh, à la place d'un thème dérivé de breeze-gtk (lot 3). Inclus dans l'image depuis une version figée ;
    3. rendu des polices : « Niveaux de gris (Recommandé) » : lissage en niveaux de gris et lissage léger des contours (`hintslight`), comme AnduinOS (`font-antialiasing='grayscale'`) et les applications de Windows 11 en WinUI (À VALIDER pour Windows), au lieu du sous-pixel de KDE (lot 1) ;
    4. police du terminal et du code : « JetBrains Mono (actuelle) », plutôt que Cascadia Mono (celle du Terminal Windows et d'AnduinOS, `cascadia-mono-fonts` dans Fedora 44).
  - **taille du curseur** : AnduinOS règle 32 ; Ankh garde 24 pour l'instant. La hauteur de la flèche, comparée à celle de Windows 11, se mesure au lot 1 (À VALIDER).
- **Mise en œuvre : onze lots, chacun dans sa PR**, avec des captures « avant » et « après », les mesures du banc (lot 0) et mon accord avant de fusionner :
  0. **Banc de mesure** : la référence dans un seul fichier de valeurs (`build_files/interface/jetons.toml`) ; des mesures automatiques en VM (barre de titre et bords des fenêtres par KWin, barre des tâches par Plasma, tailles des contrôles, rayons et couleurs lus sur l'image) ; des captures de chaque surface, en sombre et en clair, à 100, 125 et 150 %. Le test compare chaque mesure à sa valeur cible : un écart est signalé, et il fait échouer le test dès que le lot qui règle cette mesure est fusionné.
  1. **Fondations** : police et tailles (corps de 14 px), couleurs d'Ankh rangées par couches en sombre et en clair, rendu des polices, durées des animations, curseur blanc.
  2. **Fenêtres** : la décoration « Ankh ».
  3. **Contrôles** : le style Qt « Ankh », appliqué aussi aux applications de KDE en QML ; un thème GTK aux mêmes mesures, dérivé de breeze-gtk.
  4. **Shell** : le style Plasma « Ankh », la barre collée de 48 px, la zone de notification, l'horloge, les notifications.
  5. **Démarrer d'Ankh**, avec la disposition de Windows 11.
  6. **Paramètres rapides** en un seul volet ; calendrier et notifications harmonisés.
  7. **Alt+Tab, vue d'ensemble, déconnexion, écran de verrouillage, sons.**
  8. **Applications** : Dolphin disposé comme l'Explorateur, Configuration du système, Discover, Konsole, Chrome, VS Code, applications GTK, Flatpak, libadwaita et Electron ; plus de fenêtre de KDE Wallet au premier lancement de Chrome (D-037).
  9. **Icônes et curseurs**, selon mon choix.
  10. **Finitions** : hautes résolutions, thème clair aussi soigné que le sombre, accessibilité (contrastes, focus au clavier, animations réduites), mesures du banc toutes obligatoires.
- **Limites acceptées** :
  - les applications libadwaita (Bottles, ProtonPlus) gardent leur allure, avec le violet d'Adwaita ;
  - pas de menu de disposition au survol du bouton « Agrandir » : les dispositions passent par Windows+flèches et l'éditeur de tuiles de KWin (Windows+T) ;
  - le contenu de l'OSD du volume, et la largeur des notifications, restent ceux de Plasma ;
  - Chrome, VS Code et les applications Electron dessinent leur propre barre de titre ;
  - le Démarrer et les paramètres rapides peuvent casser à une nouvelle version de Plasma : la construction et le test en VM le montrent avant que je reçoive la mise à jour (D-031) ;
  - Claude ne peut pas tester sur ma machine : l'aspect final se vérifie en phase 9.
- **Alternatives rejetées** : un clone visuel de Windows 11 (pas l'identité d'Ankh) ; Kvantum (intégration imparfaite avec les applications de KDE en QML) ; Klassy, Menu11 et KDE-Rounded-Corners (hors de Fedora, un seul mainteneur chacun, à recompiler à chaque version de Plasma) ; une décoration Aurorae en SVG (elle n'arrondit pas le contenu des fenêtres : `setBorderRadius` n'est jamais appelé dans `v2/` d'aurorae).
- **Vérification** : le banc du lot 0, à chaque PR ; puis, à chaque lot, ses mesures rendues obligatoires, et les captures « avant » et « après » vues par moi.
- **Lot 0, le banc de mesure (commencé le 2026-10-15)** :
  - **valeurs de référence** : `build_files/interface/jetons.toml`, 47 mesures, chacune avec sa cible de Windows 11, sa tolérance, sa source et son lot. `lots_termines` liste les lots fusionnés : leurs mesures deviennent obligatoires. Il est vide au lot 0 : le banc relève les écarts sans faire échouer le test ;
  - **test en VM** (`tests/vm/banc/banc.sh`, lancé par `tests/vm/run.sh` après `check_identity`) :
    - réglages lus dans la session : curseur, animations, barre de titre, barre des tâches et horloge (par le scripting de Plasma), notifications ;
    - **galerie des contrôles** (`tests/vm/banc/org.ankh.banc`) : un widget de Plasma, installé seulement dans le compte de test, ouvert par `plasmawindowed` comme « Options d'Ankh ». Il montre chaque contrôle dans le style des applications de KDE en QML, et écrit dans le journal la police et les tailles que donne le style (`implicitHeight`, indicateurs) ;
    - **géométrie des fenêtres par KWin** : cadre et contenu de Dolphin placé à un endroit fixe, d'où la hauteur de la barre de titre et les bords ;
    - **mesures sur l'image**, sur un fond d'écran noir (l'ombre, noire, ne compte plus) : rayon des coins de Dolphin, du menu et des contrôles de la galerie (aire manquante à l'angle, r² (1 − π/4) pour un quart de cercle), bouton Fermer survolé (taille et couleur de la zone rouge), barre des tâches (espace en dessous, hauteur, couleur) — `tests/vm/banc/mesurer.py`, sans module tiers ;
    - **captures de chaque surface**, nommées `ui-<thème>-<échelle>-<surface>` : bureau, Démarrer, menu du bureau, Dolphin, dialogue, Configuration du système, Konsole, galerie, notification, volume, calendrier, infobulle, Alt+Tab, vue d'ensemble, recherche, déconnexion, en sombre à 100 % ; les principales en clair à 100 %, puis en sombre à 125 et 150 % ;
    - **rapport** `ui-rapport.md`, joint aux captures : chaque mesure, la cible de Windows 11, l'écart, son lot et son état (conforme, écart, relevé, non mesuré) ;
  - **vérifié en local le 2026-10-15** : la galerie se charge et écrit toutes ses mesures (Qt 6.12, sans Plasma, avec un Kirigami simulé) ; sur des images de synthèse, le rayon d'un coin est retrouvé à 0,2 px près sans contour, à 0,5 px près avec un contour clair, mais sous-estimé d'environ 1 px avec un contour plus sombre que le fond de la fenêtre ; un bouton Fermer de 46×32 et une barre de 44 px avec 8 px d'espace sont retrouvés exactement.
  - **premier passage en VM, le 2026-10-15** ([run 38695602550](https://github.com/PatrickChoumi/Ankh/actions/runs/38695602550), vert) : 46 mesures sur 47, et 34 captures. Bilan : 7 conformes, 27 écarts, 12 relevés. Ankh aujourd'hui, face à Windows 11 :
    - fenêtres : barre de titre de 28 px (32), coins de 5 px (8), titre centré (à gauche), bouton Fermer rond de 16 px au survol (rectangle de 46×32, rouge #c42b1c) ;
    - contrôles : boutons, listes déroulantes, cases et boutons radio déjà aux mesures de Windows 11 ; coins de 5 px (4), champs de 30 px (32), interrupteurs de 36×18 (40×20), barres de défilement de 21 px (12), barres de progression de 22 px (3), éléments de liste de 36 px (40) ;
    - texte : 13 px (14), légendes de 10 px (12), police Inter ;
    - barre des tâches : 44 px (48), réglée flottante mais affichée collée sur les captures, horloge sur une ligne ;
    - défauts du banc vus sur les captures et corrigés ensuite : bureau jamais dégagé, sélecteur Alt+Tab absent, dialogue remplacé par le menu de Dolphin, recherche restée ouverte, volet du menu non mesuré (son nom pour KWin est `org.kde.plasmashell`).
  - **second passage, le 2026-10-15** ([run 38702400701](https://github.com/PatrickChoumi/Ankh/actions/runs/38702400701), vert) : les corrections sont vérifiées sur les captures (bureau dégagé, sélecteur Alt+Tab, dialogue Propriétés, menu du bureau). Le bouton Fermer a été vérifié à l'œil sur l'image de mesure : au survol, Breeze dessine un cercle rose pâle (#ffc3c0) de 16 px avec une croix sombre. Le rayon du menu manquait encore : KWin était interrogé avant l'ouverture du menu ; il l'est maintenant jusqu'à trois fois (À VALIDER au prochain passage).
- **Lot 1, les fondations (commencé le 2026-10-15 ; vérifié par la CI et en VM le 2026-10-20 ; fusionné le 2026-10-22, [#19](https://github.com/PatrickChoumi/Ankh/pull/19))** :
  - **police Selawik**, compilée depuis ses sources UFO (commit `89362e8` de <https://github.com/microsoft/Selawik>, sources de la version 1.01) par `fontmake` de Fedora, dans une étape à part du `Containerfile` (« outils », `build_files/outils.sh`) : ses outils de compilation n'entrent pas dans l'image. Trois graisses, Light, Regular et Bold, 369 glyphes ; elle couvre le français, sauf les espaces insécables (U+00A0, U+202F), que fontconfig prend dans une autre police. Pas de semi-gras : un titre en semi-gras s'affiche en gras. Compilée sans modification, elle garde son nom réservé (OFL 1.1, « Reserved Font Name ») ; licence dans `/usr/share/licenses/selawik`. Vérifié le 2026-10-15 dans un conteneur Fedora 44 : l'étape « outils » passe en 12 secondes (sans les dépendances facultatives de fontmake) ; les fichiers de police sont identiques, octet pour octet, à ceux compilés ailleurs (date fixée par `SOURCE_DATE_EPOCH`) ;
  - **tailles** : texte courant 14 px (10,5 points à 96 points par pouce), petites légendes 12 px (9 points), titre des fenêtres en légende (12 px, graisse normale). JetBrains Mono reste la police du code ; Inter reste celle de l'écran de connexion et de l'écran de démarrage (D-043), à revoir avec le lot 7 ;
  - **rendu des polices** : niveaux de gris, contours légers. Il est décidé par fontconfig, pas par KDE : sans réglage, Qt prend la disposition des sous-pixels annoncée par l'écran (vérifié dans `kcms/fonts/kxftconfig.cpp` et `fontsaasettings.cpp` de plasma-workspace, branche Plasma/6.7). Les fichiers de fontconfig de la base ajoutent leurs valeurs à la suite (« append ») : `/etc/fonts/conf.d/29-ankh-rendu.conf` impose donc les siennes (« assign_replace »), et un choix fait dans le module des polices de KDE passe encore après. Vérifié en local : `fc-match` donne rgba 5 (aucun sous-pixel) et hintstyle 1 (léger) ; la construction le vérifie aussi ;
  - **animations** : facteur 5/6 (`AnimationDurationFactor`) : les durées de Kirigami, 50, 100, 200 et 400 ms, deviennent 42, 83, 167 et 333 ms, celles de Windows 11 ;
  - **curseurs « Ankh-curseurs »** : les curseurs Fluent blancs (commit `c8a244f` de <https://github.com/vinceliuice/Fluent-icon-theme>, dossier `cursors`, GPL-3.0), dessinés avec `rsvg-convert` et assemblés avec `xcursorgen` dans la même étape « outils ». Leur bleu d'accent (#0078d4 et son reflet #23e6fa) devient le violet d'Ankh (#8455f0 et #a78bfa) : l'anneau d'attente, et aussi les flèches de redimensionnement, qui portent le même bleu. 47 curseurs, 64 autres noms. Taille 24. Chaque thème global désigne son curseur dans ses réglages par défaut, recopiés à chaque session avant `/etc/xdg` : le curseur d'Ankh y est écrit aussi, et dans les réglages de SDDM ;
  - **couleurs par couches** (`Ankh.colors`, `AnkhClair.colors`) : chaque gris de Windows 11 (`Common_themeresources_any.xaml`), de niveau L, devient le graphite bleuté d'Ankh (L−4, L, L+7). En sombre : fenêtre 28,32,39 (Mica, #202020), barre de titre et en-têtes de la même couleur, continues avec la fenêtre ; contenu 24,28,35 (#1C1C1C) ; carte 39,43,50 ; contrôle 41,45,52 ; infobulle 40,44,51 ; texte secondaire au niveau de Windows (77 % du texte). En clair : fenêtre et barre de titre #f3f4f6, contenu blanc, carte et contrôle #fbfbfc, infobulle #f9f9fa. Le violet d'Ankh ne change pas ;
  - **accent** : il suit le fond d'écran (D-054, ma demande du 2026-10-16), mis en œuvre avec ce lot ;
  - **banc** : `lots_termines = [1]` : la police, ses deux tailles et les curseurs deviennent obligatoires en VM ;
  - **tests** : Test 14 (Selawik et sa licence, tailles, rendu par fontconfig, facteur des animations, curseurs dans l'image et dans chaque thème global) ; en VM, police et curseur lus dans la session.
  - **premier passage, le 2026-10-16** ([construction 38875140630](https://github.com/PatrickChoumi/Ankh/actions/runs/38875140630), rouge ; [VM 38875143673](https://github.com/PatrickChoumi/Ankh/actions/runs/38875143673), verte) : fontconfig ne trouvait pas Selawik dans l'image, alors que ses fichiers y étaient. L'interface restait en Noto Sans (vu sur les captures), et le banc ne le voyait pas : il lisait la police demandée, pas celle affichée. Cause probable : le cache de fontconfig, refait par dnf juste avant pour Inter et JetBrains Mono, ne connaissait pas Selawik. Je n'ai pas pu reproduire le défaut hors de l'image construite (À VALIDER). Corrigé : le cache est refait après Selawik, et la construction échoue si fontconfig ne la trouve pas par son nom ; le banc lit la police vraiment affichée (`fontInfo` de Qt) ;
  - **vérifié le 2026-10-20** (commit `239ebaf` ; [construction 39424181807](https://github.com/PatrickChoumi/Ankh/actions/runs/39424181807) et [VM 39424185717](https://github.com/PatrickChoumi/Ankh/actions/runs/39424185717), vertes) : Selawik est la police affichée en VM, corps de 14 px, légendes de 12 px ; curseurs Ankh-curseurs de 24 ; facteur des animations de 5/6 ; mesures du lot 1 conformes.
- **Lot 2, les fenêtres (commencé le 2026-10-16 ; vérifié par la CI et en VM le 2026-10-22, branche `claude/lot-2-fenetres`)** :
  - **décoration « Ankh »** (`build_files/decoration`, C++), dérivée de celle de Breeze 6.7.5 (`kdecoration/` de <https://invent.kde.org/plasma/breeze>, commit `ca217f1`, même licence GPL), compilée dans l'étape « outils » du Containerfile et installée dans `/usr/lib64/qt6/plugins/org.kde.kdecoration3`. La construction échoue si une de ses bibliothèques ou un de ses symboles manque dans l'image (`ldd -r`) ;
  - **mesures de Windows 11**, avec leurs sources dans `ankhmetrique.h` (WinUI, commit `866ba81` de <https://github.com/microsoft/microsoft-ui-xaml> ; boutons copiés par Windows Terminal, commit `44b440b` de <https://github.com/microsoft/terminal>) :
    - barre de titre de 32 px, de la couleur de la fenêtre ; icône de 16 px à 16 px du bord, titre à gauche, 16 px après l'icône, coupé par « … » ; icône et titre à 50 % dans une fenêtre inactive ;
    - boutons réduire, agrandir et fermer de 46×32, symboles de 10×10 ; survol en voile léger (blanc à 6 % en sombre, noir à 4 % en clair) ; Fermer rouge `#C42B1C` au survol, symbole blanc ;
    - coins de 8 px, contour de 1 px (formule de Breeze), carrés quand la fenêtre est agrandie ou collée à un bord ;
    - aucun bord visible ; une marge invisible de 8 px pour redimensionner ;
    - ombre de Windows (élévation 64 : une ombre ambiante et une ombre dirigée, plus douce en clair), moitié moins forte pour une fenêtre inactive ;
  - **réglages** : la décoration d'Ankh, l'icône à gauche, réduire, agrandir et fermer à droite, sans bords (`/etc/xdg/kwinrc`, et chaque thème global, dont les réglages passent avant à chaque session, comme pour le curseur) ;
  - **aperçu hors écran** (outil d'aperçu des décorations de KWin, 2026-10-16) : la croix de Fermer paraissait plus pâle que les autres symboles. Qt répartit une diagonale de 1 px sur deux pixels à moitié allumés ; à 1,25 px, chaque rangée a un pixel plein (essai avec QPainter). Corrigé ;
  - **banc** : `lots_termines = [1, 2]` : ses 11 mesures des fenêtres deviennent obligatoires en VM (barre de titre, bords, rayon des coins, alignement du titre, boutons, taille et couleur de Fermer). Le banc lit l'alignement du titre selon la décoration ;
  - **tests** : Test 14 (décoration présente, ses bibliothèques trouvées, choisie par défaut et dans chaque thème global, boutons) ; en VM, décoration lue dans la session.
  - **relecture du code**, le 2026-10-21, avec les sources de KDecoration3 et de KWin : huit points, corrigés :
    - les 4 px du haut, qui servent à redimensionner, passaient sous les boutons : les boutons commencent sous cette bande, et leur fond la couvre pour garder une barre de 32 px ;
    - une fenêtre agrandie n'a plus d'ombre (elle débordait sur l'écran voisin) et sa barre devient opaque ;
    - un jeu de couleurs qui prévoit un texte pour les fenêtres inactives le voit appliqué tel quel, sans l'atténuation de 50 % ;
    - le groupe de boutons de droite reste collé au bord quand les boutons changent dans les réglages, ou quand un bouton apparaît ou disparaît (Agrandir d'une fenêtre de taille fixe), et quand la hauteur de la barre change ;
    - symboles, rayon et marges d'ombre posés sur la grille des pixels, pour des traits nets à 125 et 150 % ;
    - un échec de ldd lui-même arrête la construction (relevé par la relecture du lot 3).
    Vu sur l'aperçu hors écran : barre de 32 px, symboles nets, en sombre et en clair.
  - **premier passage en VM, le 2026-10-21** ([run 39575978529](https://github.com/PatrickChoumi/Ankh/actions/runs/39575978529), rouge) : 9 mesures obligatoires sur 11 conformes. Fermer n'était rouge que sur 28 px : KDecoration3 ne repeint que la géométrie d'un bouton, et la bande de 4 px au-dessus gardait la couleur de la barre ; chaque repeinte du bouton la couvre maintenant. Le rayon des coins n'était pas mesuré : la galerie du banc, ouverte au-dessus de Dolphin, cachait son bord haut ; le banc réduit maintenant les autres fenêtres pendant cette mesure ;
  - **vérifié le 2026-10-22** (commit `d6c1cc2` ; [construction 39753433287](https://github.com/PatrickChoumi/Ankh/actions/runs/39753433287) et [VM 39753437837](https://github.com/PatrickChoumi/Ankh/actions/runs/39753437837), vertes) : les 11 mesures des fenêtres conformes, dont la barre de titre de 32 px, Fermer rouge #c42b1c de 46×32 et des coins de 8,2 px.
- **Lot 3, les contrôles (commencé le 2026-10-21 ; vérifié par la CI et en VM le 2026-10-22, branche `claude/lot-3-controles`)** :
  - **style Qt « Ankh »** (`build_files/style`, C++) : le style de Breeze 6.7.5 (`kstyle/` et `libbreezecommon/` de <https://invent.kde.org/plasma/breeze>, commit `ca217f1`, la même source que la décoration), copié puis renommé pour pouvoir être chargé à côté de Breeze. Les propriétés `_breeze_…`, posées par les applications de KDE sur leurs widgets, gardent leur nom. Compilé dans l'étape « outils » ; la construction échoue si ldd échoue, ou s'il manque une bibliothèque ou un symbole. Il devient le style des applications (`widgetStyle`), aussi dans chaque thème global. Ses réglages sont dans `ankhrc` : les menus translucides et l'ombre réglés pour Breeze (D-039) y sont recopiés. Il n'a pas de page de réglages ;
  - **mesures de WinUI** (CommonStyles, commit `09cfc8f` de <https://github.com/microsoft/microsoft-ui-xaml>) : coins de 4 ; boutons, champs, compteurs, listes déroulantes et cases avec leur texte de 32 de haut ; marges de bouton de 12, bord compris ; barre de défilement de 12, poignée de 6 ; barre de progression de 3 ; curseur : rail de 4, poignée de 18 ; bouton d'outil avec cadre de 32 ;
  - **dessin** : cases et boutons radio de 20, remplis d'accent une fois cochés (rond central de 12, 14 au survol, 10 à l'appui), vides sous un voile (`ControlAltFillColor`) ; bouton principal rempli d'accent, texte et icônes de la couleur prévue sur l'accent, même dans une fenêtre inactive ; survol et appui des boutons par le fond, aux valeurs des calques de Windows 11 posés sur la fenêtre (en sombre : 41, 50, 35 ; en clair : 251, 246, 245) ; contour d'accent seulement pour le focus au clavier et les boutons plats ; anneau de focus autour des cases et boutons radio ; poignée du curseur pleine, avec un point d'accent ;
  - **gardé de Breeze** : dans une boîte de dialogue, le bouton rempli d'accent suit le focus, comme le bouton par défaut des dialogues de Windows (Entrée agit sur lui) ; une barre de progression de fenêtre classique reste centrée dans la hauteur que Qt lui impose (texte + 2), sa barre dessinée faisant 3 px ;
  - **contrôles QtQuick de KDE** (`org.kde.desktop`, qqc2-desktop-style 6.31) : le style d'Ankh dessine leurs boutons, cases et champs ; ceux écrits en QML sont modifiés dans l'image par `build_files/qqc2/adapter.py` : interrupteur d'Ankh de 40×20 (`build_files/qqc2/SwitchIndicator.qml`, le ToggleSwitch de WinUI), case et bouton radio exactement de la hauteur de leur indicateur, élément de liste de 40 au moins, infobulle de 12 px, bouton mis en avant (`highlighted`) rempli d'accent. Ces fichiers sont aussi compilés dans le greffon du module : la ligne `prefer` de leurs `qmldir`, qui fait charger cette copie compilée, est retirée. Chaque texte remplacé est vérifié : la construction échoue si une nouvelle version de KDE l'a changé, au lieu de laisser un contrôle à moitié adapté ;
  - **thème GTK « Fluent-Ankh »** : mon choix du 2026-10-15, confirmé le 2026-10-21 (« Fluent GTK violet (Recommandé) ») : le thème Fluent d'AnduinOS (commit `7a49a46` de <https://github.com/vinceliuice/Fluent-gtk-theme>, GPL-3.0), rond et sans bord, ses violets remplacés par ceux d'Ankh (#7c3aed en clair, #a78bfa en sombre) dans ses feuilles et ses dessins. Il garde le violet d'Ankh quand l'accent suit le fond d'écran. Thème des nouveaux comptes (GTK 2, 3 et 4) et valeur par défaut de `org.gnome.desktop.interface`, lue par GTK sous Wayland. Les applications GTK en Flatpak ne le voient pas : à traiter à part ;
  - **relecture du code**, le 2026-10-21, comparé à Breeze 6.7.5 : neuf points ; corrigés : clignotement des boutons et du curseur à la fin des animations (elles allaient vers les couleurs de Breeze), éléments de menu QtQuick grandis d'environ 11 px par la hauteur des cases, texte presque noir sur le bouton principal d'une fenêtre inactive, anneau de focus dessiné dans la case, bouton d'outil de 40, appui plus clair que le survol en thème clair, fond des cases vides différent en QtQuick ;
  - **mesuré hors écran** (Fedora 44, Selawik 14 px, couleurs d'Ankh) : fenêtres classiques : bouton, champ, liste déroulante et case de 32, bouton d'outil de 32, défilement de 12, progression de 3, poignée de 18 ; QtQuick : bouton, champ, liste déroulante et case de 32, interrupteur de 40×20, poignée de 18, défilement de 12, élément de liste de 40, infobulle de 12, élément de menu de 29 (comme Breeze). Ces mesures restent à confirmer en VM ;
  - **banc** : la barre de progression est mesurée par la barre dessinée (`implicitBackgroundHeight`) : le contrôle de KDE ajoute 8 px de marge au-dessus et au-dessous, gardés pour l'espacement des applications. Premier passage en VM, le 2026-10-21 ([run 39577621226](https://github.com/PatrickChoumi/Ankh/actions/runs/39577621226)) : toutes les mesures du lot 3 conformes (bouton, champ et liste déroulante de 32, case de 20 et de 32 avec son texte, bouton radio de 20, interrupteur de 40×20, poignée de 18, progression de 3, défilement de 12, élément de liste de 40, infobulle de 12, coins des boutons et des champs de 3,75 et 3,95 pour 4). Le test a échoué sur deux mesures du lot 2, corrigées depuis (voir le lot 2). `lots_termines = [1, 2, 3]` : les mesures des contrôles deviennent obligatoires en VM ;
  - **tests** : Test 14 (style présent, ses bibliothèques, choisi par défaut et dans chaque thème global, opacité des menus ; adaptations de `org.kde.desktop` ; thème GTK, ses violets, les nouveaux comptes et gsettings).
  - **vérifié le 2026-10-22** (commit `3d093a6` ; [construction 39753441421](https://github.com/PatrickChoumi/Ankh/actions/runs/39753441421) et [VM 39753444882](https://github.com/PatrickChoumi/Ankh/actions/runs/39753444882), vertes) : les mesures des lots 1 à 3, obligatoires, toutes conformes.
- **Lot 4, le shell (commencé le 2026-10-22 ; vérifié par la CI et en VM le 2026-10-22, branche `claude/lot-4-shell`)** :
  - **état de départ**, au passage du lot 3 en VM ([run 39577621226](https://github.com/PatrickChoumi/Ankh/actions/runs/39577621226)) : barre de 50 px, flottante à 8 px du bord, date placée selon la place, notifications près de leur icône, menu aux coins de 4,82 px (Breeze : 6) ;
  - **barre** (`build_files/plasma/ankh-barre.js`) : 48 px, collée, sur toute la largeur (la limite à un écran 21:9 du modèle de KDE est retirée), toujours translucide (D-042) ; horloge : la date sous l'heure (`dateDisplayFormat` 2, `applets/digital-clock/main.xml` de plasma-workspace) ;
  - **notifications** en bas à droite (`PopupPosition` `BottomRight`, `/etc/xdg/plasmanotifyrc`) ;
  - **style Plasma « Ankh »** (`/usr/share/plasma/desktoptheme/ankh`, `FallbackTheme=default`) : ses SVG sont écrits à la construction par `build_files/plasma/style-ankh.py`, depuis ceux de Breeze installés dans l'image (libplasma 6.7.5), dont ils gardent les ombres. KSvg cherche d'abord la variante du moment (`translucent/` quand le flou est actif) puis le fichier simple, dans le style d'Ankh, avant de passer à Breeze (`imageset.cpp` et `imageset_p.cpp` de KSvg 6.31) :
    - volets et menus (`dialogs/background`, et ses variantes `translucent/` et `solid/`) : coins de 8, contour de 1 px (couleur du texte à 12 %), fond à 95 %, 85 % sous le flou, plein dans `solid/` ;
    - infobulles (`widgets/tooltip`, et `solid/`) : coins de 4, contour de 1 px ;
    - barre (`widgets/panel-background`, et `solid/` pour le réglage « opaque ») : translucide à 60 % (valeur d'AnduinOS), un trait de 1 px en haut, sans ombre ; marges de 4 pour les applets ;
    - boutons de la barre des tâches (`widgets/tasks`, préfixes de `applets/taskmanager` de plasma-desktop) : carré arrondi de 40×40 (coins de 4) au survol et sous l'application active ; trait d'accent de 16×3 sous l'application active, tiret de 6×3 sous les autres applications ouvertes, à 1 px du bas du carré (place estimée sur des captures de Windows 11, À VALIDER) ; icônes de 24 px : le gestionnaire de tâches remplit la hauteur de la barre (`CanFillArea`), et ses marges de 12 viennent du SVG (dessin remplacé le 2026-10-22 : icônes de 32 px, boutons de 56, rectangle de 48×44, ci-dessous) ;
    - chaque forme est découpée par calcul en ses neuf morceaux (polygones, arcs à 24 segments par quart de cercle) : Qt ignore les découpes (`clip-path`) quand il mesure un élément, et la taille de chaque morceau doit être exacte ; un rectangle sans remplissage donne sa taille à chaque morceau, comme dans les SVG de Breeze ;
    - **vérifié hors écran**, avec KSvg 6.31 dans Fedora 44 : rendu de chaque élément ; rayons mesurés par le code du banc : 7,74 px pour les volets (cible 8, tolérance 0,75), 3,81 pour les infobulles. Premier rendu : un fond posé sous le contour, en retrait de 1 px, donnait un coin de 7 px, invisible sur fond sombre ; le fond couvre maintenant toute la forme, et le contour est posé dessus ;
  - **limites** : les icônes de la zone de notification restent à 22 px au plus (Windows 11 : 16), fixé dans le code de Plasma (`applets/systemtray/qml/main.qml`) ; le bouton « Afficher le bureau » de Plasma a une largeur fixe de 32 px (`applets/showdesktop/main.qml`) : il est remplacé par l'applet d'Ankh `org.ankh.bureau`, une bande de 8 px sur toute la hauteur de la barre avec un trait de 16 px (mesures estimées sur des captures de Windows 11, À VALIDER), dont un clic réduit les fenêtres et un second les rend (logique de `MinimizeAllController.qml` de Plasma, module public `org.kde.taskmanager`) ;
  - **volets flottants** (mon choix du 2026-10-22, ci-dessous) : `build_files/plasma/adapter-plasma.py` modifie `contents/applet/CompactApplet.qml` de la coque de Plasma (plasma-desktop 6.7.5, fichier QML installé tel quel) : marge de 12 px au lieu de 0 avec une barre collée. Avec une marge, libplasma garde les quatre bords du volet et la même distance aux bords de l'écran (`PopupPlasmaWindowPrivate::updateBorders`, `TransientPlacementHint`, `src/plasmaquick` de libplasma). Le texte remplacé est vérifié : la construction échoue si Plasma le change. Le banc mesure l'écart entre le menu et la barre (`volet.ecart_barre`, cible 12) ;
  - **tests** : Test 14 (barre collée de 48 px et date sous l'heure dans chaque thème global, place des notifications, SVG du style lisibles, ses ombres, son choix par défaut et dans chaque thème global, volets à 12 px).
  - **vérifié le 2026-10-22** (commit `14dbea8` ; [construction 39761170501](https://github.com/PatrickChoumi/Ankh/actions/runs/39761170501) et [VM 39761174583](https://github.com/PatrickChoumi/Ankh/actions/runs/39761174583), vertes) : bilan du banc, 37 mesures conformes et aucun écart : barre de 48 px, collée, sans espace dessous, date sous l'heure, notifications en bas à droite, coins du menu de 7,36 px (cible 8, tolérance 0,75 : près de la limite, la mesure sous-estime le rayon d'un contour lissé), menu à 12 px de la barre ; le calendrier aussi, et à 12 px du bord droit de l'écran (lu sur la capture). `lots_termines = [1, 2, 3, 4]` : les mesures du shell deviennent obligatoires ;
  - **icônes des applications à 32 px (ma demande du 2026-10-22, après les captures du lot 4)** : « la taille des icônes de la barre des tâches a beaucoup trop diminué. Peux-tu conserver leur taille ? ». Elles gardent donc leur taille d'avant le lot 4 (32 px ; Windows 11 : 24). En les mesurant, Claude a trouvé deux défauts du lot 4, que le banc ne voyait pas :
    - Plasma fait chaque bouton aussi large que la barre est haute, plus les marges de gauche et de droite du SVG (`preferredMaxWidth`, `code/LayoutMetrics.js` d'`applets/taskmanager`, plasma-desktop 6.7.5), et non 48 px comme le supposait le dessin. Avec des marges de 12, les boutons faisaient 70 à 72 px. Le carré était un rectangle de 62×40, et le trait d'accent, qui s'étire avec le bouton, mesurait 38 px au lieu de 16 (capture de mesure du [run 39761174583](https://github.com/PatrickChoumi/Ankh/actions/runs/39761174583)) ;
    - la liste des applications s'étirait entre les deux espaceurs (option `fill`, vraie par défaut) : la largeur des boutons variait avec la place (70 px au lieu de 72 sur cette capture) ;
    - **corrigé** : marges de 7 en haut, 9 en bas et 4 sur les côtés. L'icône fait 48 − 7 − 9 = 32 px, un pixel au-dessus du centre pour laisser 3 px au trait. Chaque bouton fait 48 + 4 + 4 = 56 px ; le rectangle de 48×44 (coins de 4) entoure l'icône de 8 px sur les côtés. Le trait d'accent (16×3) et le tiret (6×3) sont dessinés pour un bouton de 56. La liste garde sa taille naturelle (`fill` à faux, `ankh-barre.js`). Vérifié hors écran avec KSvg 6.31 : marges lues 7, 9, 4, 4 ; icône de 32 ; trait de 16×3 et tiret de 6×3 centrés, 3 px sous l'icône ; rectangle de 48×44 ;
    - **limite** : quand la barre manque de place, Plasma rétrécit les boutons (jusqu'à 40 px), et le trait raccourcit d'autant ;
    - **banc** : quatre nouvelles mesures obligatoires (lot 4), lues sur la capture de la barre, l'application active étant Dolphin : longueur (16) et épaisseur (3) du trait d'accent, largeur (48) et hauteur (44) du rectangle. S'y ajoute un relevé, le dessin de l'icône de Dolphin. Rejouées sur la capture du lot 4, elles signalent bien ses trois écarts (38, 62 et 40). Test 14 : la barre garde `fill` à faux, et les marges du style donnent des icônes de 32 px ;
- **Questions et mes réponses (2026-10-22)**, après la recherche du lot 5 (rapport de Claude : le module privé `org.kde.plasma.private.kicker` se charge depuis un paquet QML ; mesures du Démarrer relevées au pixel sur des images officielles de Microsoft) :
  1. **Démarrer** : « Celui de D-052 (Recommandé) » : le Démarrer de Windows 11 tel qu'il était jusqu'en 2025 (épingles en grille, bouton « Toutes les applications », « Recommandé », compte et alimentation en bas), entièrement mesuré (volet de 640×726, cellules de 96×84, icônes de 32, coins de 8). Plutôt que le nouveau Démarrer livré depuis fin 2025 (une seule page qui défile, 8 colonnes, mesuré sur une seule maquette de Microsoft).
  2. **Volets de la barre** : « Oui, volets flottants (Recommandé) » : le Démarrer, l'horloge, la zone de notification et les autres volets flottent à 12 px de la barre avec leurs quatre coins, comme Windows 11, au prix d'un fichier de Plasma modifié dans l'image. Plutôt que des volets collés à la barre, sans coins de ce côté.
- **Lot 5, le Démarrer d'Ankh (commencé le 2026-10-22, branche `claude/lot-5-demarrer`)**. C'est le Démarrer classique de Windows 11 (mon choix du 2026-10-22, ci-dessus) :
  - **paquet QML** `org.ankh.demarrer` (`build_files/files/usr/share/plasma/plasmoids/`) :
    - dérivé de Kickoff (plasma-desktop 6.7.5, GPL-2.0-or-later) ; les en-têtes de KDE sont gardés, et les textes sont en français, au vouvoiement ;
    - il se sert du module privé `org.kde.plasma.private.kicker` (plasma-workspace 6.7.5) pour les épingles, toutes les applications, la recherche (lanceurs de KRunner), les documents récents et les actions de session ;
    - il déclare `X-Plasma-Provides: org.kde.plasma.launchermenu` : la touche Méta et `activateLauncherMenu` l'ouvrent, comme Kickoff ;
  - **disposition** : celle mesurée sur les images officielles de Microsoft (recherche du lot 5) :
    - volet de 640×726 ;
    - champ de recherche en haut, à 32 px des bords, de 576×40 ;
    - « Épinglé » en grille de 6 colonnes, cellules de 96×84, icônes de 32 ;
    - bouton « Toutes les applications › » ;
    - « Recommandé » : les applications ajoutées récemment, puis les documents récents ;
    - en bas : le compte et le bouton d'alimentation ;
    - « Toutes les applications » : liste alphabétique, avec la grille des lettres pour sauter à l'une d'elles ;
  - **épingles** : celles d'Ankh (`kicker-extra-favoritesrc`), reprises au premier lancement comme dans Kickoff. Elles sont partagées avec les menus de KDE ; leur ordre est propre au Démarrer (`org.ankh.demarrer.favorites.instance-<id>`, sans tiret : `kastatsfavoritesmodel.cpp` découpe le nom au tiret) ;
  - **bouton dans la barre** : le même dessin que les boutons des applications du lot 4 (`widgets/tasks`, préfixe `hover`, au survol et volet ouvert) ; 56 px de large, logo d'Ankh de 32 px. Il remplace Kickoff dans `ankh-barre.js`. `ankh-lanceur.js` lui donne aussi le logo ;
  - **la construction échoue si le Démarrer casse** (`build_files/plasma/verifier-demarrer.sh`, appelé par `build_files/outils.sh`, dans l'étape « outils » du `Containerfile`, sur le Plasma de la même image de base) :
    - si plasma-workspace ou plasma-desktop ne sont plus en 6.7.5 (règle de D-052 : les changements de Kickoff et de Kicker sont reportés d'abord, avec un message qui dit quoi et où) ;
    - si `metadata.json` ou les singletons du `qmldir` changent ;
    - si qmllint trouve un module, un type ou un import introuvable ;
    - si la sonde hors écran (`build_files/plasma/demarrer-sonde.qml`), qui crée les vrais modèles de Kicker et le volet entier, échoue ou écrit un avertissement QML. Une erreur QML ne fait pas tomber Plasma : le menu s'afficherait à moitié sans que rien n'échoue ;
  - **vérifié hors écran** dans un conteneur Fedora 44 (Plasma 6.7.5, Qt 6.11.2), par l'agent du lot 5 :
    - la vérification passe : qmllint sans erreur sur 19 fichiers, « SONDE OK » ;
    - sept copies volontairement cassées sont toutes refusées : type, valeur d'énumération, propriété, singleton, interface, `X-Plasma-Provides`, version de Plasma ;
    - avec une vraie session D-Bus et kactivitymanagerd, les épingles sont reprises dans l'ordre et leur ordre est enregistré ;
    - dans `plasmawindowed`, le volet fait 640×726, sans avertissement QML ;
    - le bouton fait 56×48, le logo 32×32 en (12, 7), le rectangle de survol 48×44 ;
  - **banc** : `demarrer.largeur` (640 ± 2), `demarrer.hauteur` (726 ± 2), `demarrer.erreurs_qml` (0, lu dans le journal de la session) et un relevé, `demarrer.decalage_centre`. Obligatoires depuis le passage en VM (`lots_termines = [1, 2, 3, 4, 5]`) ;
  - **vérifié en VM le 2026-10-23** (commit `d41dd70` ; [construction 39912113781](https://github.com/PatrickChoumi/Ankh/actions/runs/39912113781) et [VM 39912110741](https://github.com/PatrickChoumi/Ankh/actions/runs/39912110741), vertes) : bilan du banc, 44 mesures conformes et aucun écart. Le Démarrer s'ouvre par `activateLauncherMenu`, l'appel que fait la touche Méta ; il fait 640×726, à 12 px de la barre, coins de 7,34 px (cible 8, tolérance 0,75), sans avertissement QML dans le journal de la session ; les mesures du lot 4 restent conformes (trait de 15×3, rectangle de 47×44). Captures `ui-sombre-100-demarrer` et `ui-clair-100-demarrer` : recherche, épingles, « Toutes les applications », « Recommandé » (Ankh-dev ajoutée récemment), compte et alimentation. Le premier passage ([run 39840151935](https://github.com/PatrickChoumi/Ankh/actions/runs/39840151935)) avait échoué à la construction : la sonde quittait pendant une recherche de KRunner (corrigé dans `d41dd70`, la sonde attend la fin de la recherche) ;
  - **limites** :
    - un compte créé avant le lot 5 garde Kickoff : Plasma ne relance pas la disposition de la barre (sans effet pour moi : l'installation se fait en phase 9) ;
    - Selawik n'est compilée qu'en Light, Regular et Bold : le semi-gras des titres sera sans doute rendu en gras (À VALIDER) ;
    - les valeurs relevées sur une seule image restent À VALIDER : titres de 14 px, marges des cellules, points des pages, lignes de liste de 40, grille des lettres de 72×56 ;
  - **centrage** : le Démarrer est centré sur son bouton, à 250 px à gauche du centre de l'écran (`demarrer.decalage_centre`, mesuré en VM). Windows 11 le centre sur l'écran. C'est Plasma qui place le volet (`transientplacementhint.cpp` de libplasma 6.7) : écart connu, à reprendre si une solution propre se trouve ;
  - **reste à vérifier** : la touche Méta elle-même (le banc passe par l'appel D-Bus qu'elle déclenche), menus contextuels, compte et alimentation, glisser-déposer, lanceurs de KRunner en français (la VM de test est en anglais).
- **Modifiée par D-054 (2026-10-16)** : l'accent suit le fond d'écran ; les fonds d'Ankh gardent le violet d'Ankh. Les curseurs gardent leur anneau violet (images figées). Pour les icônes Fluent (lot 9) et le thème GTK (lot 3 ; « lot 9 » écrit ici par erreur à l'origine), suivre l'accent comme le reste : à étudier. Pour le thème GTK, réponse le 2026-10-21 : il garde le violet d'Ankh (voir le lot 3).

## D-053 — La suite Craft d'ArtCraft remplace OnlyOffice : bureautique dans Simple, clones d'Adobe dans une option « Création » (modifie D-024, D-035 et D-046)

- **Statut** : DÉCIDÉ (2026-10-15), mes choix. Mise en œuvre après le lot 0 de D-052, dans sa propre PR.
- **Contexte** : ma demande du 2026-10-15 : « Laisse tomber OnlyOffice, retire tout ce qui y a trait, et mets toute la suite ArtCraft à la place. Je viens de tomber dessus et c'est trop une masterclass. Penses-tu que c'est une bonne idée ? »
- **Ce que Claude a vérifié** dans les dépôts officiels (<https://github.com/storytold>, lus le 2026-10-15 ; presse : <https://gizmodo.com/someone-vibe-coded-a-free-knockoff-of-adobe-creative-suite-2000823322>, <https://futurism.com/future-society/adobe-creative-suite-software-open-source-artcraft>) :
  - **les « Crafting Apps »**, de l'équipe ArtCraft : des réécritures « en salle blanche », en Rust, écrites en grande partie par des agents d'IA. Dix applications :
    - PhotoCraft (comme Photoshop), VectorCraft (Illustrator), FilmCraft (Premiere Pro), LightCraft (Lightroom) ;
    - PdfCraft (Acrobat), EffectCraft (After Effects), DesignCraft (InDesign) ;
    - WordCraft (Word), GridCraft (Excel), DeckCraft (PowerPoint) ;
  - **licence** : MIT ou Apache-2.0, au choix. Les noms et logos d'ArtCraft sont des marques, utilisables seulement sans modification (`docs/brand/LICENSE-brand.txt`) ;
  - **maturité**, selon leurs propres feuilles de route (`ROADMAP.md` de chaque dépôt, 2026-10-11 à 2026-10-15) :
    - toutes en alpha, DesignCraft en pré-alpha ;
    - « prêtes pour du vrai travail » à 45-61 % selon leurs propres estimations ;
    - PhotoCraft : 953 tickets ouverts, et les PSD qu'il écrit ne sont pas encore acceptés de façon fiable par Photoshop ;
    - WordCraft : ses fichiers .docx « n'ont jamais été testés sur de vrais fichiers » ;
  - **Linux** : chaque version publie un Flatpak en un seul fichier, mais aussi une AppImage, un .deb, un .rpm et une archive (« Releases » GitHub). Les applications ne sont pas sur Flathub ; leurs manifestes se disent prêts à y être proposés. Les paquets Linux ne sont pas signés : chaque version publie seulement les sommes SHA256 de ses fichiers (les versions Windows et macOS sont signées) ;
  - **isolation Flatpak** (`packaging/linux/flatpak/*.yml`) : runtime `org.freedesktop.Platform` 26.08, carte graphique, Wayland. Ni réseau ni dossier personnel en entier, sauf :
    - EffectCraft : réseau, pour des modèles téléchargés seulement à la demande, « pas de télémétrie » selon son manifeste ;
    - FilmCraft : dossier personnel en entier, car un projet vidéo désigne ses médias par leur chemin ;
    - les autres : Images ou Documents seulement.
  - **le studio ArtCraft** (`storytold/artcraft`) est autre chose : de la génération d'images et de vidéos par des services en ligne (ArtCraft, Grok, Midjourney, Sora), et pas de version Linux prête (à compiler).
- **Avis de Claude, donné avant mes choix** :
  - le projet est réel et prometteur, et il s'accorde avec Ankh : applications natives et rapides, open source, sans compte, isolées en Flatpak ;
  - mais il est très jeune. Remplacer OnlyOffice confie mes documents de bureau à des logiciels en alpha, qui peuvent abîmer un .docx ou un .xlsx. Claude recommandait de garder OnlyOffice à côté jusqu'à la bêta de WordCraft et GridCraft.
- **Questions et mes réponses (2026-10-15)** :
  1. OnlyOffice : « Remplacer par les Craft », plutôt que de le garder à côté (recommandé) ou de le retirer sans remplaçant ;
  2. placement : « Option “Création” (Recommandé) », plutôt que dans Simple ou dans l'image ; puis précisé : « L'option Création devrait être pour les clones d'Adobe, mais ceux qui clonent Office devraient être toujours là, dans Simple » ;
  3. applications : « Les 10 Crafting Apps (Recommandé) », sans le studio ArtCraft (services payants en ligne) ;
  4. calendrier : « Après le lot 0 (Recommandé) ».
- **Décision** :
  - **OnlyOffice est retiré** d'Ankh : de l'image, de son dépôt et de sa clé, des applications par défaut, des favoris du menu et des tests. LibreOffice reste absent (D-035) ;
  - **Simple**, toujours là : Chrome et VLC dans l'image, et la bureautique de la suite Craft, **WordCraft, GridCraft et DeckCraft**, dans le menu de toute installation, prêtes au premier clic en Flatpak, pour toute la machine. Le premier clic demande donc internet, comme les options (D-049) ;
  - **nouvelle option « Création »**, à cocher à l'installation et dans « Options d'Ankh », comme Gaming (D-046, D-050) : les clones d'Adobe, **PhotoCraft, VectorCraft, FilmCraft, LightCraft, PdfCraft, EffectCraft et DesignCraft**, dans le menu, prêts au premier clic, en Flatpak, pour toute la machine. **Complète** la coche aussi.
- **Mise en œuvre prévue** (à confirmer à la réalisation, dans la PR) :
  - **versions figées** : à chaque construction de l'image, la dernière version publiée de chaque application, et l'empreinte SHA256 de son Flatpak, sont écrites dans l'image. La construction échoue s'il manque le Flatpak x86_64 ou son empreinte ;
  - **premier clic** : une fenêtre montre le téléchargement du Flatpak depuis GitHub. Son empreinte est vérifiée contre celle de l'image avant l'installation, pour toute la machine ; le runtime vient de Flathub, comme pour Gaming. Rien ne se télécharge avant ce clic (D-031) ;
  - **mises à jour** : pas dans Discover tant que les applications ne sont pas sur Flathub. Une nouvelle version, figée dans une nouvelle image, est proposée à l'ouverture de l'application, jamais imposée (D-031). Le jour où elles arrivent sur Flathub, Ankh passe par Flathub, par une nouvelle décision ;
  - **formats de fichiers** : les applications installées déclarent leurs formats (.docx, .xlsx, .pptx, .pdf, .psd…), et KDE les propose à l'ouverture.
- **Risques acceptés par moi** : logiciels en alpha pour mes documents (garder des copies ; tester sur ma machine en phase 9) ; paquets Linux non signés, vérifiés seulement par l'empreinte figée dans l'image signée d'Ankh ; projet jeune, dont la suite reste à voir.
- **Vérification prévue** : Test 12 adapté (OnlyOffice absent, entrées de WordCraft, GridCraft et DeckCraft dans le menu) ; en VM, premier clic sur WordCraft pour chaque PR, et sur chacune des dix applications dans le test complet (chaque lundi et à la demande, comme Gaming).
- **Mise en œuvre (2026-10-15, à vérifier par la CI et en VM)** :
  - **retrait d'OnlyOffice** : son paquet, son dépôt (`/etc/yum.repos.d/onlyoffice.repo`), sa clé et ses réglages ne sont plus dans `build_files/build.sh` ; le Test 17 vérifie qu'il n'en reste rien ;
  - **versions figées** : `build_files/build.sh` lit, pour chacune des dix applications, le fichier `SHA256SUMS.txt` de sa dernière version (`https://github.com/storytold/<nom>/releases/latest/download/SHA256SUMS.txt`), y prend la ligne de `<nom>-<version>-linux-x86_64.flatpak`, vérifie que le fichier existe à son adresse, et écrit `option nom version empreinte adresse` dans `/usr/share/ankh/craft/versions`. La construction échoue s'il manque une ligne. Le 2026-10-15 : WordCraft, GridCraft et DeckCraft 0.7.0 ; PhotoCraft 0.9.0 ; VectorCraft 0.11.0 ; FilmCraft, LightCraft, PdfCraft et DesignCraft 0.8.0 ; EffectCraft 0.10.0 ;
  - **entrées du menu** : en français, avec les formats, catégories et classes de fenêtre de leurs propres entrées (`packaging/linux/ai.storyteller.<nom>.desktop` de chaque dépôt) ; WordCraft, GridCraft et DeckCraft dans `/usr/share/applications`, les sept autres dans `/usr/share/ankh/options/creation/applications`, rendues visibles par `ankh-options` avec l'option Création (D-046) ;
  - **icônes** : les icônes officielles, en SVG (`assets/app-icon/hicolor/scalable/apps/ai.storyteller.<nom>.svg` de chaque dépôt, lues le 2026-10-15), dans `/usr/share/icons/hicolor/scalable/apps`. Licence : MIT ou Apache-2.0, comme les applications (`assets/app-icon/LICENSE.txt` et fichiers `.attribution` des dépôts) ; Flatpak installe ensuite les siennes, du même nom ;
  - **premier clic** (`/usr/libexec/ankh-craft`) : une fenêtre Konsole démarre le service `ankh-craft@<nom>.service` et affiche son journal. Le service, en root, télécharge le Flatpak (curl, en HTTPS seulement), vérifie son empreinte contre celle de l'image, et l'installe pour toute la machine (`flatpak install --system --bundle`). Le runtime vient de Flathub : le fichier le désigne (`runtime-repo`, vu dans le Flatpak de WordCraft 0.7.0 : `org.freedesktop.Platform` 25.08, `https://dl.flathub.org/repo/flathub.flatpakrepo`). L'application s'ouvre ensuite par sa propre entrée, installée par Flatpak ;
  - **pourquoi un service en root** : installer un Flatpak en un seul fichier demande le mot de passe d'un administrateur, même au groupe wheel. L'action `org.freedesktop.Flatpak.install-bundle` n'est pas dans la règle de Flatpak pour ce groupe, qui couvre seulement les installations depuis un dépôt (`system-helper/org.freedesktop.Flatpak.rules.in` et `.policy.in` de <https://github.com/flatpak/flatpak>, lus le 2026-10-15). Une règle polkit d'Ankh (`/usr/share/polkit-1/rules.d/50-ankh-craft.rules`) laisse un administrateur, dans sa session active et locale, démarrer `ankh-craft@<nom>.service` sans mot de passe, et rien d'autre. Le service refuse un nom inconnu, une application dont l'option n'est pas choisie, et un fichier d'une autre empreinte. **Touche à polkit : à relire** ;
  - **mises à jour, changement par rapport au plan** : une nouvelle version est proposée **à l'ouverture de la session**, et non de l'application. Une fois l'application installée, l'entrée du menu est celle de Flatpak, qui passe devant celle d'Ankh (`XDG_DATA_DIRS`, vu pour Gaming, D-050) : le lanceur d'Ankh n'est plus appelé. À l'ouverture de la session (`/etc/xdg/autostart/ankh-craft-nouveautes.desktop`), une notification nomme les versions figées dans l'image qui ne sont pas installées, avec « Mettre à jour » et « Ignorer cette version ». Fermée sans réponse, elle revient à la session suivante ; rien n'est jamais mis à jour d'office (D-031). Pour ses boutons, `notify-send` (paquet `libnotify` de Fedora) est ajouté à l'image ;
  - **Discover** : un Flatpak installé depuis un fichier vient d'un dépôt « d'origine » sans adresse, que Flatpak ne consulte jamais pour les mises à jour (« Empty url, silently disables updates », `common/flatpak-dir.c` de Flatpak, lu le 2026-10-15). Le test en VM capture Discover après l'installation de WordCraft (résultat ci-dessous) ;
  - **formats** : les documents de bureau s'ouvrent avec WordCraft, GridCraft et DeckCraft (`/etc/xdg/mimeapps.list`). Les autres formats que la suite déclare (texte brut, PDF, images…) restent aux applications de l'image qui les ouvrent déjà (Gwenview, Okular, KWrite, Kate ou Chrome, la première présente), pour qu'une application en alpha ne les prenne pas une fois installée ; sinon, KDE choisit. Les applications de la suite restent proposées dans « Ouvrir avec » ;
  - **« Options d'Ankh »** : une carte Création, cochée par défaut comme les autres ; Complète la coche. Retirer Création propose de supprimer ses applications (`ankh-craft supprimer`) ; WordCraft, GridCraft et DeckCraft restent ;
  - **tests** : Test 12 adapté (formats par défaut) ; nouveau Test 17 (`tests/craft.sh` : OnlyOffice absent, versions, entrées, icônes, service, règle polkit, refus d'un nom inconnu et d'une application sans son option) ; Test 15 (Création dans les options). En VM : premier clic sur WordCraft pour chaque PR, réponse de polkit (service de la suite autorisé sans mot de passe, autre service refusé), formats, Discover après l'installation, notification d'une nouvelle version ; premier clic sur les neuf autres dans le test complet (entrée `craft_complet` du workflow, et chaque lundi).
- **Vérifié le 2026-10-15** :
  - **construction et tests de l'image** ([run 38736521491](https://github.com/PatrickChoumi/Ankh/actions/runs/38736521491)) : verts pour les trois variantes. Versions figées ce jour-là : WordCraft, GridCraft et DeckCraft 0.7.0 ; DesignCraft, FilmCraft, LightCraft et PdfCraft 0.8.0 ; PhotoCraft 0.9.0 ; EffectCraft 0.10.0 ; VectorCraft 0.11.0. Le texte brut reste à KWrite, le PDF et les images à Chrome ;
  - **en VM** ([run 38736525586](https://github.com/PatrickChoumi/Ankh/actions/runs/38736525586), test complet de la suite) : toute l'étape 1 réussit. polkit autorise l'administrateur à démarrer `ankh-craft@wordcraft.service` sans mot de passe, et lui demande toujours le mot de passe pour un autre service. Les dix applications se préparent au premier clic et s'ouvrent, à la version figée. Les .docx s'ouvrent avec WordCraft. « Options d'Ankh » retire et remet Création ;
  - **Discover après l'installation de WordCraft** : « Update Issue » s'affiche, mais son journal montre l'erreur de fwupd (`Fwupd Error 21 … attempted previous download … just 963ms ago`), le défaut connu de Discover accepté dans D-028 (bug KDE 523258). La source Flatpak ne signale aucune erreur ;
  - **corrigé après ce passage** :
    - la notification d'une nouvelle version n'était pas à l'écran au moment de la capture : Plasma masque une bulle après 5 secondes (`applets/notifications/NotificationPopup.qml` de plasma-workspace). Elle reste maintenant affichée jusqu'à ma réponse ;
    - à l'étape 2, la version publiée avant D-053 ne connaît pas l'option « creation », et son service des options échoue. Ce cas reviendrait à chaque nouvelle option, après un retour arrière vers une version plus ancienne : `ankh-options` ignore désormais une option inconnue, en le signalant, et la garde dans le fichier. Le test en VM accepte cet échec de la version publiée, avec son message exact, jusqu'à la publication de D-053.
- **Vérifié après ces correctifs, le 2026-10-15** (commit `0324fb1`) :
  - **construction et tests de l'image** ([run 38745564039](https://github.com/PatrickChoumi/Ankh/actions/runs/38745564039)) : verts ;
  - **en VM** ([run 38745557276](https://github.com/PatrickChoumi/Ankh/actions/runs/38745557276), test de chaque PR, premier clic sur WordCraft) : les quatre étapes réussissent (démarrage, basculement vers la version publiée, retour arrière, retour à l'image de base). La notification « nouvelle version » est à l'écran au moment de la capture, avec ses deux boutons. À l'étape 2, la version publiée échoue sur l'option « creation » avec le message attendu, et le test l'accepte.

## D-054 — La couleur d'accent suit le fond d'écran ; les fonds d'Ankh gardent le violet d'Ankh (modifie D-037 et D-052)

- **Statut** : DÉCIDÉ (2026-10-16), à ma demande. Mis en œuvre avec le lot 1 de D-052 ; vérifié par la CI et en VM le 2026-10-20.
- **Contexte** : ma demande du 2026-10-16 : « faudrait que la couleur du système s'adapte à l'arrière-plan. C'était prévu ? ». Ce n'était pas prévu : D-037 fixait un accent violet, et D-052 le gardait (« aux couleurs d'Ankh »). Windows 11 le fait avec l'accent « Automatique » (Paramètres > Personnalisation > Couleurs : <https://support.microsoft.com/en-us/windows/experience/personalization/personalize-your-colors-in-windows>, lu le 2026-10-16).
- **Ce que KDE fait déjà** (sources de Plasma 6.7, branche `Plasma/6.7` de plasma-workspace et de plasma-desktop sur <https://invent.kde.org>, lues le 2026-10-16) :
  - le réglage `accentColorFromWallpaper` de kdeglobals (`kcms/colors/colorssettings.kcfg`), faux par défaut. C'est le choix « depuis le fond d'écran » de la page « Couleurs » des réglages ;
  - Plasma prend la couleur dominante du fond de l'écran principal (Kirigami `ImageColors` : `desktoppackage/contents/views/Desktop.qml` de plasma-desktop ; `shell/desktopview.cpp`), et le module `accentColorService` de kded l'applique au jeu de couleurs (`kcms/colors/accentColorService/accentColorService.cpp`) ;
  - un fond peut désigner sa couleur dans son `metadata.json` (`X-KDE-PlasmaImageWallpaper-AccentColor`) : une couleur, ou une pour « Light » et une pour « Dark », prise selon que le jeu de couleurs est clair ou sombre, et reprise quand il change (`wallpapers/image/plugin/utils/mediaproxy.cpp`) ;
  - l'accent remplace le focus, le survol, le texte actif et les liens. Les liens sont éclaircis ou assombris s'ils n'ont pas un contraste de 5 avec le fond. Le fond des sélections devient l'accent à 70 % sur le fond des listes, avec un texte blanc, ou noir si le blanc n'a pas un contraste de 4,5 (`kcms/colors/colorsapplicator.cpp` et `colorsapplicator.h`).
- **Décision** :
  - l'accent suit le fond d'écran, par défaut, pour chaque compte (`accentColorFromWallpaper=true` dans `/etc/xdg/kdeglobals`). Une couleur fixe reste possible dans « Couleurs » ;
  - chaque fond d'Ankh désigne le violet d'Ankh, celui des jeux de couleurs : `#7c3aed` en clair, `#a78bfa` en sombre. Ils sont tous violets ; la couleur que Plasma en tirerait seul serait plus terne (pour Ankh Signal, Claude estime `#b7a8de` en clair et `#412f76` en sombre, avec une méthode proche, pas celle de Plasma) ;
  - avec une autre image, une photo par exemple, l'accent prend sa couleur dominante. Les fonds de KDE présents dans l'image (Altai, Mountain…) donnent la leur : leur couleur dominante, ou celle qu'ils désignent (Mountain : `#3d818d` en clair, `#018786` en sombre, vu dans l'image le 2026-10-16).
- **Raisons** : c'est ma demande ; c'est le réglage de KDE, sans code d'Ankh à maintenir ; avec les fonds d'Ankh, le violet d'Ankh exact.
- **Conséquences** :
  - les sélections sont recalculées par Plasma : en sombre, `#7c6aba` (le violet du logo à 70 % sur le fond des listes) au lieu de `#8455f0` ; en clair, `#a375f2` avec un texte noir (le blanc n'a qu'un contraste de 3,25), au lieu de `#7c3aed` avec un texte blanc. Calculé par Claude avec les formules de KDE ; à voir sur les captures (À VALIDER) ;
  - restent violets, quel que soit le fond : le logo, l'écran de démarrage et l'écran de connexion (avant toute session), l'anneau d'attente des curseurs (images figées) et les couleurs de Konsole ;
  - avec une photo terne, l'accent peut être peu visible. Liens et sélections gardent un contraste minimal (formules de KDE ci-dessus), pas le focus ni le survol (À VALIDER sur mes propres images, en phase 10) ;
  - seul l'écran principal compte, comme dans KDE.
- **Mise en œuvre (2026-10-16)** :
  - `build_files/build.sh` : `accentColorFromWallpaper=true` dans `/etc/xdg/kdeglobals` ;
  - les sept `metadata.json` des fonds d'Ankh et `build_files/artwork/generer.py`, qui les écrit : `"X-KDE-PlasmaImageWallpaper-AccentColor": {"Light": "#7c3aed", "Dark": "#a78bfa"}` ;
  - banc de l'interface : l'accent est figé pendant les mesures sur fond noir, puis rendu au fond d'écran.
- **Tests** :
  - `just test`, Test 14 : le réglage, et chaque fond désigne les violets des jeux de couleurs d'Ankh (`DecorationFocus` des listes, clair et sombre) ;
  - en VM : accent `167,139,250` avec le fond d'Ankh ; orange avec un fond orange uni (`230,120,30`), avec deux captures (`1-accent-fond-orange`, `1-accent-menu-orange`) ; retour au violet avec le fond d'Ankh ; `124,58,237` en thème clair, puis retour au sombre.
- **Vérifié le 2026-10-16 et le 2026-10-20 en VM** ([run 38875143673](https://github.com/PatrickChoumi/Ankh/actions/runs/38875143673), puis [run 39424185717](https://github.com/PatrickChoumi/Ankh/actions/runs/39424185717)) : accent `167,139,250` avec le fond d'Ankh ; avec un fond orange uni, l'accent devient orange (sélections, dossier de Dolphin, onglet actif, menu Démarrer : captures `1-accent-fond-orange` et `1-accent-menu-orange`) ; retour au violet avec le fond d'Ankh ; `124,58,237` avec le thème clair, puis retour au sombre. Le premier passage de la construction a montré que des fonds de KDE sont aussi dans l'image (Altai, Mountain…) : ils gardent leur couleur, et le Test 14 ne vérifie que ceux d'Ankh.
