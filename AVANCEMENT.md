# AVANCEMENT — Ce qui est fait, ce qui reste

> Mis à jour à chaque compte rendu (D-029). Dernière mise à jour : **2026-10-15** (PR #16 fusionnée ; chantier Interface au pixel près de Windows 11 décidé, D-052 ; lot 0, le banc de mesure, commencé ; suite Craft d'ArtCraft à la place d'OnlyOffice décidée, D-053).
> Ce fichier résume et renvoie aux décisions (`D-xxx`, dans [DECISIONS.md](DECISIONS.md)). Il ne les recopie pas.
> L'état courant tient en quelques lignes dans [CLAUDE.md §2](CLAUDE.md#2-état-actuel).

## En un coup d'œil

| Phase | État |
|---|---|
| 0. Spécification | ✅ Terminée le 2026-10-07 |
| 1. Base et chaîne de build | ✅ Terminée le 2026-10-07 |
| 2. Premier démarrage en VM, dans le cloud | ✅ Terminée le 2026-10-07 |
| 3. Applications et dev | ✅ Terminée le 2026-10-13 |
| 5. Gaming | ⏳ En cours depuis le 2026-10-13 (D-041, D-050) |
| Chantier Interface, en parallèle (D-052) | ⏳ Commencé le 2026-10-14 : lot 0 sur 10 en cours |
| 6. Cyber (Kali isolé) | À faire (questions à répondre avant) |
| 7. Labs (VMs isolées) | À faire (questions à répondre avant) |
| 8. Sauvegarde et récupération | À faire |
| 9. Bascule sur ma vraie machine | À faire |
| 10. Vivre avec Ankh | À faire |
| 4. Protection (safezone), puis V1 | À faire, en dernier (D-040) |

---

## Ce qui a été fait

### Phase 0 — Spécification (2026-10-07)

- Brainstorm, avis critique, puis choix de la philosophie : **un poste personnel**, pas une distribution (D-001).
- Écriture des documents de base :
  - [ANKH-SPEC.md](ANKH-SPEC.md) : mes besoins, les questions ouvertes, ce que je ne veux pas ;
  - [DECISIONS.md](DECISIONS.md) : les décisions D-001 à D-019 ;
  - [README.md](README.md) : la présentation ;
  - [CLAUDE.md](CLAUDE.md) : le guide de travail du projet (D-020).
- Choix d'une **image générique**, faite pour le maximum de PC (D-021, qui remplace D-002).
- Mes quatre arbitrages :
  - base Universal Blue `kinoite-main` et `kinoite-nvidia`, Fedora 44 (D-005) ;
  - version de Fedora figée (D-017) ;
  - construction et publication par GitHub (D-018) ;
  - bureau KDE (D-004).

### Phase 1 — Base et chaîne de build (2026-10-07)

- **Le squelette de construction** :
  - `Containerfile`, `build_files/build.sh` ;
  - `bases.env` : les images de base, épinglées par empreinte ;
  - `Justfile` : les recettes `just build` et `just test` ;
  - `renovate.json` ;
  - `.github/workflows/build.yml`.
- **`main` protégée** par le ruleset `protection-main` : PR obligatoire, tests obligatoires.
- **Signature sans clé** dans la CI, sans clé privée chez moi (D-022).
- **[PR #1](https://github.com/PatrickChoumi/Ankh/pull/1)** : CI verte, fusionnée.
- **Images publiques, signées et vérifiées** :
  - `ghcr.io/patrickchoumi/ankh` : AMD et Intel, 4,3 Go compressés ;
  - `ghcr.io/patrickchoumi/ankh-nvidia` : NVIDIA récent, 5,2 Go.
- **Test de la protection** : une PR volontairement cassée est bien bloquée ([PR #2](https://github.com/PatrickChoumi/Ankh/pull/2)).
- **Mes nouveaux besoins**, inscrits dans les décisions :
  - Chrome dans l'image et Firefox retiré (D-023) ;
  - les applications par défaut (D-024) ;
  - le terminal au sens « confort » (D-025) ;
  - safezone adapté et intégré (D-026) ;
  - ma connexion lente (D-027).
- **Mesure de la taille d'une mise à jour de la base** : 1,7 à 2,3 Go (D-027).

### Phase 2 — Premier démarrage en VM, dans le cloud (2026-10-07)

- **Le test automatique** `tests/vm/run.sh` tourne sur les machines de GitHub, sans rien télécharger chez moi.
  - Il installe Ankh sur un disque virtuel et démarre la VM en UEFI avec Secure Boot.
  - Il enchaîne quatre étapes : démarrage complet, basculement vers une autre version, retour arrière, retour à l'image de base.
- **Premier essai** : échec dû à `mcelog`, qui refuse les processeurs AMD des machines GitHub. La cause est prouvée, et cet échec précis est désormais toléré (D-004).
- **Deuxième essai** : **les 4 étapes ont réussi** ([PR #3](https://github.com/PatrickChoumi/Ankh/pull/3), fusionnée le 2026-10-08).
  - À chaque démarrage, Secure Boot, SELinux et le pare-feu étaient actifs.
  - Le basculement entre deux images Ankh de même base n'a téléchargé que **641 octets**.
- **Résultats notés** dans D-004, avec des renvois dans D-006, D-008, D-018 et D-027.

### Phase 3 — Applications et dev (2026-10-08 → 2026-10-13)

- **Mises à jour du système dans Discover** : j'ai choisi l'option A (D-028).
  - L'image réinstalle le module de Discover qui gère les mises à jour du système.
  - L'image porte son propre numéro de version (`44.AAAAMMJJ.HHMM`). Discover s'en sert pour savoir qu'une mise à jour existe.
  - Des tests sont ajoutés, en CI et en VM.
  - [PR #4](https://github.com/PatrickChoumi/Ankh/pull/4) fusionnée le 2026-10-08. Sa CI a montré :
    - un seul paquet ajouté, aucun autre paquet de KDE modifié ;
    - le système démarré dans la VM porte bien la version d'Ankh.
- **Ce document d'avancement** (D-029).
- **Chrome et Firefox** (D-023), en cours de vérification par la CI :
  - Chrome est installé dans l'image depuis le dépôt officiel de Google, avec vérification de la clé de signature ;
  - `/opt` devient un vrai dossier de l'image, comme le recommande Universal Blue ;
  - Firefox est retiré ;
  - Chrome devient le navigateur par défaut ;
  - des tests sont ajoutés, en CI et en VM.
- **Captures d'écran de la VM**, à ma demande :
  - écran de connexion, bureau KDE, Discover et Chrome ;
  - jointes à chaque run du test en VM sur GitHub.
- **Renovate** : il est installé et tourne, mais ne crée rien. Cause probable : le mode « Silent » de Mend (D-017).
- **Ma question sur Fedora 45** : la procédure prévue est écrite dans D-017.
- **Premier essai de la PR Chrome** ([#5](https://github.com/PatrickChoumi/Ankh/pull/5)) : la construction a échoué parce que `gpg` ne trouvait pas de dossier où travailler. `/root` n'existe pas pendant la construction d'une image bootc. C'est corrigé avec un dossier temporaire, et vérifié en local avec la vraie clé de Google. La CI tourne de nouveau.
- **Safezone avec et sans** (D-030, 2026-10-09) : chaque variante existera en version protégée et en version libre. Il faudra empêcher, en phase 4, qu'une machine protégée bascule vers une version libre.
- **Chrome mesuré** : 140 Mo à télécharger à chaque reconstruction. Mon choix : une reconstruction **chaque lundi**, faite par la CI.
- **C'est moi qui décide des mises à jour** (D-031, 2026-10-09) : plus aucune mise à jour automatique sur la machine (système, Flatpak, conteneur de dev). Discover me prévient, et je lance la mise à jour quand je veux.
- **Conteneur de dev** (D-032, 2026-10-09) :
  - base Fedora ;
  - Java, Python, JavaScript/TypeScript, C/C++ et bases de données ;
  - VS Code dans le conteneur, avec des extensions préinstallées (liste proposée, à valider) ;
  - mises à jour quand je le décide.
- **CI de la PR #5 verte** ([run du test en VM](https://github.com/PatrickChoumi/Ankh/actions/runs/37887155044)) :
  - Fedora 44 KDE utilise **Plasma Login** et non plus SDDM ; le test s'y est adapté ;
  - Chrome 155 démarre dans la VM, et Firefox est absent ;
  - le téléchargement automatique est bien coupé ;
  - le bureau KDE démarre à chaque étape ;
  - **7 captures d'écran** sont jointes au run : connexion, bureau, Discover, Chrome, et le bureau après chaque basculement ;
  - une mise à jour d'Ankh sur la même base coûte déjà 38,7 Mo, avant Chrome (D-027).
- **PR #5 fusionnée** le 2026-10-09.
- **Conteneur de dev** (D-032, [PR #6](https://github.com/PatrickChoumi/Ankh/pull/6)) :
  - image `ankh-dev` : Fedora, Java, Python, JavaScript/TypeScript, C/C++, clients de bases de données, VS Code officiel ;
  - deux raccourcis du menu, « Créer » et « Mettre à jour l'environnement de dev ». Rien ne se télécharge sans moi (D-031) ;
  - les extensions VS Code s'installent à la création ;
  - les serveurs de bases de données tournent dans des conteneurs Podman du système.
- **CI de la PR #6 verte** :
  - chaque outil répond, avec des versions récentes : Java 25, Python 3.14, Node.js 22, GCC 16, Clang 22, PostgreSQL 18… (liste dans D-032) ;
  - VS Code 1.141 démarre, et les 15 extensions s'installent ;
  - la clé de VS Code est acceptée par Fedora 44, sans affaiblir la sécurité ;
  - le test en VM réussit ses 4 étapes ([run](https://github.com/PatrickChoumi/Ankh/actions/runs/37895079821)).
- **PR #6 fusionnée** le 2026-10-09.
- **Habillage Ankh** (D-033, 2026-10-09) : j'ai choisi d'habiller **le bureau seulement** (nom, logo, fonds d'écran). Le démarrage et Secure Boot ne changent pas.
  - Design choisi parmi trois pistes : **« Curseur »**, un A dont la barre est un curseur de terminal **violet**, sur une touche de clavier graphite. Il est épuré et évoque le dev, le hacking et le gaming.
  - [PR #7](https://github.com/PatrickChoumi/Ankh/pull/7) : la CI est verte du premier coup. Dans la VM, le système s'appelle « Ankh », jusque dans le menu de démarrage, et 8 captures sont jointes, dont « À propos de ce système » ([run](https://github.com/PatrickChoumi/Ankh/actions/runs/37897946381)).
  - La VM a montré que la machine s'appelait encore « fedora » : c'est corrigé et vérifié en VM ([run](https://github.com/PatrickChoumi/Ankh/actions/runs/37901076405)).
- **PR #7 fusionnée** le 2026-10-09.
- **Fait par moi** : le paquet `ankh-dev` est public, et j'ai validé la liste des extensions VS Code (D-032).
- **Plus rien de Fedora à l'écran** (D-034, 2026-10-09) : à ma demande, ni nom ni logo de Fedora visibles, **écran de démarrage compris**. Sous le capot, Fedora reste.
  - L'initramfs est reconstruit avec la commande d'Universal Blue pour cette même base, pour y mettre le logo d'Ankh.
  - Un test liste tout ce qui reste visible au nom de Fedora, et échoue tant qu'il en reste.
- **Fonds d'écran travaillés**, style Kali (D-034) : six fonds sombres autour du logo, gardés tous avec le fond épuré. **« Signal »** est le fond par défaut.
- **CI de la PR #8 verte** ([run du test en VM](https://github.com/PatrickChoumi/Ankh/actions/runs/37915307956)) :
  - le test « rien de Fedora à l'écran » a d'abord servi d'inventaire. Il a trouvé les trois thèmes globaux de Fedora (renommés « Ankh », « Ankh Sombre », « Ankh Clair »), les fonds de Fedora (retirés), le dépôt « Fedora Flatpaks » (coupé) ;
  - il a aussi montré que l'écran de verrouillage et l'écran de connexion affichaient encore le fond de Fedora : ils affichent maintenant « Ankh Signal » ;
  - la VM démarre avec l'initramfs reconstruit et Secure Boot actif, et 4 captures sont prises pendant le démarrage ;
  - passer à l'image publiée a téléchargé 252,7 Mo ; la part de l'initramfs est à mesurer (D-027).
- **PR #8 fusionnée** le 2026-10-09.
- **Le nécessaire dès l'installation** (D-035, 2026-10-09), à ma demande, en cours de vérification par la CI :
  - **VLC** et **OnlyOffice** sont des paquets de l'image, comme Chrome (mon choix « A »), et non plus des Flatpaks à télécharger au premier démarrage ;
  - **LibreOffice est retiré**, comme Firefox ;
  - VLC ouvre par défaut la vidéo et l'audio, OnlyOffice les documents Word, Excel, PowerPoint et OpenDocument ;
  - **Claude et GitHub** : Chrome les installe lui-même, chacun dans sa fenêtre, dès sa première ouverture ;
  - **conteneur de dev** : Node.js dans la version la plus récente que Fedora propose (au lieu de la 22), et la dernière version de Java par défaut (au lieu de la 25).
- **Ma demande d'identité visuelle** (2026-10-09) : sombre partout (variante claire disponible), barre flottante en bas, icônes KDE avec dossiers violets. Des aperçus me seront montrés avant intégration (D-037).
- **Un seul Ankh** (D-036, 2026-10-09) : `ankh-dev` n'était pas une autre version d'Ankh, mais la boîte à outils du dev. Mon choix : tous les outils (dev, hacking, gaming) dans le menu d'Ankh comme des applications ordinaires, isolés en dessous, sans « ankh-dev » à gérer.
- **Mises à jour** : confirmé, rien ne se met à jour tout seul sur ma machine, c'est moi qui lance (D-031). La préparation du lundi sur GitHub est gardée.
- **Captures d'écran à chaque travail** : Claude les joint à chaque compte rendu (règle ajoutée à CLAUDE.md).
- **CI de la PR #9 verte** ([run du test en VM](https://github.com/PatrickChoumi/Ankh/actions/runs/37934589711)) :
  - LibreOffice n'était pas dans la base ; un test garantit qu'il reste absent ;
  - VLC 3.0.24 (dépôt de Fedora) et OnlyOffice 9.4.0 (dépôt officiel, signatures vérifiées) sont installés et deviennent les applications par défaut de leurs formats ;
  - dans la VM, Chrome installe lui-même Claude et GitHub, et VLC et OnlyOffice s'ouvrent (captures `1-vlc` et `1-onlyoffice`) ;
  - conteneur de dev : Node.js 24 (au lieu de 22) et Java 27 (au lieu de 25), que Fedora marque encore « early access » ;
  - **panne trouvée et corrigée** : en VM, une mise à jour préparée ne s'appliquait pas au redémarrage, à cause d'un montage automatique de `/boot` ajouté par systemd. Il est masqué ; les 4 étapes du test passent de nouveau (D-004) ;
  - OnlyOffice pèse 1,3 Go installé : une mise à jour d'Ankh devrait passer d'environ 500 Mo à environ 870 Mo (estimation, à mesurer, D-027).
- **PR #9 fusionnée** le 2026-10-09.
- **Versions LTS** (D-038, 2026-10-09) : à ma demande, le conteneur de dev prend les dernières versions LTS de Node.js et de Java, plus les toutes dernières. Aujourd'hui : Node.js 24 et Java 25. La règle se réapplique à chaque reconstruction. CI verte.
- **Captures récupérées** : j'ai autorisé le domaine des artefacts de GitHub ; Claude voit et m'envoie maintenant les captures. Elles ont montré deux défauts, corrigés dans la PR #10 (D-034) :
  - « À propos » affichait un hot-dog (logo générique de Fedora) et « Kinoite » : il affiche maintenant le logo et le site d'Ankh ;
  - le démarrage affichait les messages du noyau au lieu de l'écran d'Ankh : l'argument `rhgb` manquait.
- **Un seul Ankh, côté dev** (D-036, PR #10) : « Visual Studio Code » est dans le menu dès l'installation. Au premier clic, une fenêtre montre la préparation de l'environnement de dev, puis VS Code s'ouvre. L'entrée « Créer l'environnement de dev » disparaît.
- **CI de la PR #10 verte** ([run 37961330515](https://github.com/PatrickChoumi/Ankh/actions/runs/37961330515)) :
  - en VM, **VS Code s'ouvre au premier clic** (environ 3 minutes de préparation dans la VM) ;
  - « À propos » montre le logo et le site d'Ankh ; l'écran de démarrage d'Ankh s'affiche ;
  - **Discover affiche encore « Update Issue »**, même sur le système venu du vrai registre : à comprendre (D-028) ;
  - **taille mesurée** : une mise à jour d'Ankh télécharge maintenant **1,2 Go** (501 Mo avant OnlyOffice et VLC).
- **PR #10 fusionnée** le 2026-10-09.
- **Discover, « Update Issue »** (D-028) : cette fenêtre ne dit pas quelle source a échoué. Le test en VM affiche maintenant le journal de Discover ([run 37975438997](https://github.com/PatrickChoumi/Ankh/actions/runs/37975438997)). Deux causes trouvées :
  - **propre au test** : le système de test, installé depuis la CI, cherchait ses mises à jour dans un registre « localhost » qui n'existe pas. Le test suit maintenant le registre d'Ankh, comme ma machine ; son étape 2 devient une mise à jour (`bootc upgrade`) au lieu d'un basculement (D-004, à relire) ;
  - **un défaut de Discover** : sa partie « micrologiciels » (fwupd) télécharge deux fois de suite le catalogue des micrologiciels, et fwupd refuse le second téléchargement. Le premier réussit : seul le message est faux. Il dépend du minutage. À moi de choisir quoi faire (D-028).
- **Identité visuelle** (D-037, écrite le 2026-10-09) : mes choix (sombre partout, graphite et violet, barre flottante, icônes KDE à dossiers violets) sont notés. Un jeu de couleurs « Ankh » et des couleurs de Konsole sont prêts. Le test en VM les applique à un compte à part, sans toucher l'image, et capture le résultat.
  - **Aperçus réussis** : bureau, menu, Dolphin, Konsole, Discover et réglages en graphite et violet ; dossiers violets ; Chrome sombre de lui-même.
  - **La barre était déjà flottante** avant l'aperçu : rien à changer.
  - **Vu au passage** : le message de bienvenue de Konsole pousse vers Toolbx et DNF (à remplacer) ; KDE Wallet s'ouvre au premier lancement de Chrome (à vérifier sur ma machine, avec un mot de passe).
- **Mes choix du 2026-10-09** : le style me convient ; option A pour Discover ; et je veux une interface « bien plus belle et soft », au niveau de Windows 11 ou de macOS.
  - **Discover** : le défaut est déjà signalé chez KDE ([bug 523258](https://bugs.kde.org/show_bug.cgi?id=523258), confirmé) et chez Fedora. Les micrologiciels restent dans Discover ; la correction viendra avec Discover (D-028).
  - **Interface d'Ankh dans l'image** (D-037, D-039, PR #11) :
    - le thème « Ankh Sombre », avec les couleurs graphite et violet ;
    - les polices Inter (interface) et JetBrains Mono (code) ;
    - la barre flottante, avec le menu et les applications au centre comme sous Windows 11 ;
    - les menus translucides et floutés, et des ombres plus douces ;
    - Konsole aux couleurs d'Ankh, légèrement translucide, sans le message Toolbx.
  - Vérifié par un nouveau test de l'image (Test 14) et dans la session de la VM.
- **PR #11 verte** ([run 37986772808](https://github.com/PatrickChoumi/Ankh/actions/runs/37986772808)) : interface d'Ankh partout, de l'assistant de premier démarrage à l'écran de verrouillage ; écran de chargement d'Ankh ; Discover sans « Update Issue » au premier démarrage du test. Reste : l'assistant de premier démarrage affiche « Welcome to Plasma Desktop » (D-037).
- **Mes choix (2026-10-09, suite)** : réduire la taille des mises à jour en phase 10 ; safezone (phase 4) en dernier, après la phase 10 (D-040).
- **PR #11 fusionnée** le 2026-10-10.
- **Mes réponses du 2026-10-10** :
  - assistant de premier démarrage : retouches et page « Bienvenue dans Ankh » (D-037) ;
  - questions 6 à 9 (ANKH-SPEC.md) : jeux Steam et hors Steam, sans anticheat compétitif ; IA locale importante ; pas d'analyse de malware ni de Wi-Fi offensif pour l'instant, mais Ankh doit les permettre plus tard ;
  - gaming : le plus d'outils possible, comme Garuda ou CachyOS, avec des réglages sûrs et le noyau de Fedora (D-041) ;
  - améliorer encore toute l'interface, au niveau de macOS et de Windows 11, après l'assistant.
- **Assistant de premier démarrage** (D-037, [PR #12](https://github.com/PatrickChoumi/Ankh/pull/12)) : fond d'Ankh, thème sombre d'Ankh même si l'on touche au choix clair/sombre, et une page « Bienvenue dans Ankh » en premier.
  - La première construction a échoué sur une vérification prévue pour ça : Fedora 44 livre depuis le 2026-10-10 le fond d'écran « Next » de KDE. Il est retiré et remplacé par celui d'Ankh ; les constructions passent.
- **Mes demandes du 2026-10-10 (suite)** : l'écran de connexion n'a pas le design d'Ankh ; pousser encore le design, au niveau de macOS et de Windows 11 ou au-dessus, après des recherches, sans aucune marque de Fedora, avec créativité.
- **Interface, deuxième passe** (D-042, PR #12), d'après les guides officiels d'Apple et de Microsoft (verre pour la navigation au-dessus du contenu, géométrie douce, couleur de marque cohérente en clair et en sombre, mouvement utile) :
  - **thème clair aux couleurs d'Ankh** (« Ankh Clair ») et **clair/sombre automatiques** selon l'heure, si je l'active ;
  - **fond « Ankh Signal » en version claire**, qui suit le thème ;
  - **barre toujours en verre**, même quand une fenêtre est agrandie ;
  - **recherche au milieu de l'écran** (Alt+Espace), comme Spotlight ;
  - **écran de chargement** avec une fine barre de progression, comme au démarrage d'un Mac ;
  - **menu et barre** avec les applications d'Ankh (VS Code, Chrome, fichiers, terminal, Discover, réglages) ;
  - **accueil de KDE** au nom d'Ankh, avec une page « Raccourcis utiles » ;
  - **VS Code** : police JetBrains Mono, violet d'Ankh, et une icône dans le style d'Ankh ;
  - **écran de connexion** : l'image de compte d'Ankh (le A sur un disque graphite) pour chaque nouveau compte. Le reste de cet écran est dessiné par le programme de KDE ; s'il ne suffit pas, l'option est de passer à SDDM avec un écran entièrement d'Ankh (à décider).
  - Déjà fait par KDE, vérifié dans les sources : coins arrondis des fenêtres, flou au plus fort, fenêtres ouvertes au centre.
- **CI de la PR #12 verte** ([run 38057489422](https://github.com/PatrickChoumi/Ankh/actions/runs/38057489422)) : accueil et raccourcis d'Ankh, menu et barre d'Ankh, recherche au centre, barre de progression au chargement, écran de verrouillage avec l'image de compte d'Ankh ; aucune marque de Fedora sur les captures.
  - Corrigé ensuite : fond de l'assistant (il restait uni), titre en double sur sa page, capture de l'écran de connexion.
  - À comprendre : VS Code ouvert à côté de son icône épinglée, et le flou invisible dans la VM (pas de carte graphique).
- **PR #12 fusionnée** le 2026-10-11.
- **Mes demandes du 2026-10-10 (fin)** : l'écran de démarrage entièrement d'Ankh, SDDM pour l'écran de connexion, le logo d'origine de VS Code, et ne plus tutoyer.
- **Démarrage et connexion entièrement d'Ankh** (D-043, [PR #13](https://github.com/PatrickChoumi/Ankh/pull/13)) :
  - **écran de démarrage** (Plymouth) : fond graphite, logo d'Ankh, fine barre de progression violette, sans le logo du fabricant du PC ; la saisie du mot de passe du disque (LUKS) prend le style d'Ankh ;
  - **écran de connexion** : SDDM remplace Plasma Login, avec un écran dessiné pour Ankh : fond flouté, grande horloge, image du compte dans un cercle, champ du mot de passe en pilule, boutons ronds ;
  - **VS Code** reprend son logo officiel, et se regroupe avec son icône épinglée ;
  - **vouvoiement** dans tous les textes d'Ankh ; un test refuse le tutoiement ;
  - la première construction a échoué : un paquet « kwin-wayland » n'existe pas dans Fedora 44. La construction vérifie maintenant le programme de KWin lui-même ;
  - **CI de la PR #13 verte** ([run 38156340145](https://github.com/PatrickChoumi/Ankh/actions/runs/38156340145)) :
    - écran de connexion d'Ankh, message « Mot de passe incorrect », puis connexion réussie par cet écran ;
    - écran de démarrage d'Ankh, et saisie du mot de passe du disque dans le style d'Ankh ;
    - VS Code avec son logo officiel ;
  - corrigé ensuite, d'après les captures : la date de l'écran de connexion en français, la carte qui ne bouge plus quand un message apparaît, et les points du mot de passe du disque, décollés du bord du champ ;
  - ces trois corrections sont vérifiées sur les captures ([run 38159636158](https://github.com/PatrickChoumi/Ankh/actions/runs/38159636158), CI verte) ;
  - toujours à comprendre : le fond de l'assistant de premier démarrage reste uni (gris graphite d'Ankh). Son image est bien trouvable, mais elle n'est pas dessinée, sans erreur signalée. Impact faible : la page reste propre.
- **PR #13 fusionnée** le 2026-10-12.
- **Choix des options** (D-046), fait dans la PR #14, vérifié en VM, fusionnée le 2026-10-13 :
  - **au premier démarrage**, l'assistant montre la page « Choisissez vos outils » :
    - Complète ;
    - Simple, toujours incluse ;
    - Dev ;
    - Gaming et Hacking, grisés, « bientôt ».
  - **sans Dev, VS Code n'apparaît nulle part** : ni dans le menu, ni dans la recherche, ni dans la barre ;
  - **« Options d'Ankh »**, dans la Configuration du système, permet de changer d'avis avec le mot de passe d'un administrateur. Retirer Dev propose de libérer la place de l'environnement de dev ; vos fichiers restent ;
  - **un service d'Ankh applique le choix** pour toute la machine. Une règle polkit permet à l'assistant de le démarrer, et rien d'autre (à relire) ;
  - **vérifié en VM** ([run 38214652308](https://github.com/PatrickChoumi/Ankh/actions/runs/38214652308)) :
    - la page de l'assistant enregistre « dev » dès qu'elle s'affiche ;
    - le compte de l'assistant ne peut démarrer aucun autre service ;
    - VS Code quitte le menu avec Simple seule, puis y revient avec Dev ;
  - **constructions en échec, corrigé ensuite** : dans le conteneur de test, `/usr/local` est un lien qui ne mène encore nulle part ;
  - **« Options d'Ankh » redessinée** (ma réponse du 2026-10-12 : « Oui, maintenant ») :
    - une vraie fenêtre d'Ankh, avec les mêmes cartes que la page de l'assistant ;
    - « Appliquer » demande le mot de passe d'un administrateur, avec un message d'Ankh ;
    - le menu et la barre suivent tout de suite : VS Code quitte la barre quand Dev est retirée (avant, il y restait avec une icône vide), et y revient quand Dev est remise ;
    - retirer Dev propose « Supprimer » ou « Garder » l'environnement de dev ;
    - le mot de passe passe par `pkexec` et une action polkit d'Ankh (à relire). systemd n'attend le mot de passe que 25 secondes, d'après son code ; `pkexec` attend sans limite ;
  - **vérifié en VM** ([run 38284941203](https://github.com/PatrickChoumi/Ankh/actions/runs/38284941203), CI verte) : la fenêtre s'ouvre, Dev est retirée puis remise au clavier avec le mot de passe, le menu et la barre suivent, l'environnement de dev se supprime, Échap ferme la fenêtre.
- **Mes réponses sur le gaming** (2026-10-12, D-041) :
  - Discord et OBS font partie de l'option Gaming, prêts au premier clic ;
  - le mode console est une session à choisir sur l'écran de connexion : Steam en plein écran ;
  - les noms de mes jeux viendront plus tard.
- **Mes choix pour l'ISO** (2026-10-12) :
  - une seule ISO, publiée dans une Release GitHub (D-048) ;
  - allégée (D-049) : le système seul, environ 5,5 Go ;
  - les options cochées se téléchargent ensuite, seulement elles ;
  - sur un PC NVIDIA, Ankh propose sa version NVIDIA, environ 3 Go à télécharger.
- **Ma vision affinée** (2026-10-11) : Ankh reste sur Fedora Kinoite 44 (D-005).
  - J'ai d'abord voulu quatre éditions : Dev, Gaming, Hacking, et Complète qui les réunit (D-044).
  - Puis j'ai choisi **une seule version, à la carte, comme l'installation d'Ubuntu** (D-046, qui remplace D-044) :
    - Simple (Chrome, VLC, OnlyOffice), toujours incluse ;
    - des cases Dev, Gaming et Hacking, combinables, et une case Complète qui coche tout ;
    - ce qui n'est pas coché n'est pas installé ;
    - les options se changent ensuite dans les réglages ;
    - une ISO d'Ankh contient tout, pour installer sans internet. Elle se fait juste avant la bascule sur ma machine (phase 9).
  - **Plus de fenêtres Claude ni GitHub** installées par Chrome : je les installerai moi-même (D-047). Retirées de l'image dans la PR #13.
  - **Mes réponses (suite)** : le choix des options se fait au premier démarrage, et vaut pour toute la machine. Claude a préparé la page de l'assistant et le service qui applique le choix (plan dans D-046).
  - **L'ISO** (D-048, proposée, à décider) :
    - une seule ISO qui reconnaît la carte graphique est faisable : un court script de l'installateur choisit `ankh` ou `ankh-nvidia`. Personne ne le fait encore, et elle coûte environ 3,1 Go de plus ;
    - elle peut être construite gratuitement sur GitHub Actions, comme les ISO de Bazzite ;
    - elle peut être hébergée gratuitement dans une Release GitHub, découpée en morceaux de moins de 2 Gio ;
    - taille estimée avec les options : 15 à 20 Go.
  - **Taille des images mesurée** (registre, 2026-10-11) : `ankh` 5,46 Go compressés, `ankh-nvidia` 6,47 Go, dont 3,34 Go de Fedora en commun.
- **Le portrait d'Ankh une fois terminé** est écrit dans [VISION.md](VISION.md) (D-045), pour vérifier qu'on ne dévie pas.
- **Phase 3 terminée le 2026-10-13** : son critère est rempli.
  - Chrome par défaut et Firefox retiré ; VLC et OnlyOffice présents.
  - Choix des options au premier démarrage et dans « Options d'Ankh », pour Simple et Dev.
  - Mises à jour dans Discover, sans terminal (le défaut de Discover reste suivi chez KDE, D-028).
  - VS Code et le conteneur de dev recréés depuis le dépôt, au premier clic.
  - Tout testé en CI et en VM cloud.

### Phase 5 — Gaming (depuis le 2026-10-13)

- **Mes choix du 2026-10-13** (D-050), après vérification dans les sources :
  - les jeux lancés par Steam, Heroic, Lutris ou Bottles (en Flatpak) ne voient pas MangoHud, vkBasalt ni Gamescope du système : leurs versions Flatpak sont préparées avec chaque lanceur ;
  - le « mode jeu » de SteamOS (Gamescope) n'est pas prouvé avec Steam en Flatpak : la session console sera « Ankh Console », avec KWin et Steam Big Picture ;
  - Steam est épinglé dans la barre avec l'option Gaming.
- **Mon choix du 2026-10-13 sur les réglages du système** (D-051) : ntsync, qui accélère les jeux Windows sous Proton 11 et Wine, est chargé avec l'option Gaming seulement. `vm.max_map_count` est déjà réglé par Fedora ; la protection contre les « split locks » reste active (la retirer exposerait la machine à un déni de service).
- **Fait ([#15](https://github.com/PatrickChoumi/Ankh/pull/15) fusionnée le 2026-10-14), vérifié en VM le 2026-10-13** ([run 38407899063](https://github.com/PatrickChoumi/Ankh/actions/runs/38407899063)) :
  - outils du jeu dans l'image : GameMode, MangoHud, Gamescope, vkBasalt, règles des manettes de Steam ;
  - huit applications dans le menu avec leur logo, préparées au premier clic : Steam, Heroic, Lutris, Bottles, ProtonPlus, Protontricks, Discord, OBS Studio ;
  - ntsync chargé avec l'option Gaming, retiré sans elle (D-051) ;
  - session « Ankh Console » sur l'écran de connexion ;
  - case Gaming dans l'assistant et dans « Options d'Ankh » ; Complète coche Dev et Gaming ;
  - tests : Test 16 dans l'image ; en VM, premier clic sur Steam et session « Ankh Console ».
- **Essais en VM (2026-10-13)** :
  - vérifié : l'assistant enregistre Dev et Gaming ; « Options d'Ankh » les retire puis les remet, avec le mot de passe, et le menu, la barre et ntsync suivent ;
  - vérifié : au premier clic sur Steam, la fenêtre de préparation montre le téléchargement, sans mot de passe, puis Steam s'ouvre sur sa page de connexion, avec MangoHud et Gamescope en Flatpak ; ntsync est visible depuis Steam ;
  - vérifié : la session « Ankh Console » ouvre Steam en Big Picture sur tout l'écran, puis le bureau revient ;
  - le premier clic sur Steam échouait : Flatpak n'avait pas le droit d'installer pour toute la machine. Trois causes, corrigées :
    - Ankh demandait à Flatpak de ne jamais rien demander (`--noninteractive`), ce qui empêchait aussi la fenêtre du mot de passe. Maintenant, si la règle des administrateurs ne s'applique pas, KDE demande le mot de passe d'un administrateur ;
    - le test cliquait sur Steam dans une session de test qui n'était plus au premier plan (écran figé après l'essai de l'écran de démarrage). Le test vérifie maintenant que la session est active avant chaque capture ;
    - le compte de test devenait administrateur pendant sa session. Or polkit prend les groupes de l'ouverture de la session : pour Flatpak, il n'était pas administrateur. Le compte de test l'est maintenant dès sa création, comme le mien, créé par l'assistant ; et avant le clic, polkit est interrogé comme Flatpak le fait.
- **Les sept autres applications, vérifiées en VM le 2026-10-14** ([run 38565792193](https://github.com/PatrickChoumi/Ankh/actions/runs/38565792193), test complet) :
  - Heroic, Lutris, Bottles, ProtonPlus, Discord et OBS se préparent au premier clic et s'ouvrent ;
  - Protontricks n'aurait rien ouvert au premier clic : il n'ouvre sa fenêtre qu'avec les options de sa propre entrée du menu. Corrigé : chaque application démarre maintenant par son entrée du menu. Dans la VM, il dit ne pas trouver Steam, qui n'y a jamais été connecté à un compte ;
  - outils du jeu en Flatpak : les trois pour Heroic et OBS ; MangoHud et Gamescope pour Steam, Protontricks et Discord (vkBasalt pas encore publié pour leur version) ; aucun pour Lutris, Bottles et ProtonPlus (leur runtime GNOME n'a pas de version publiée) ;
  - ce test télécharge plusieurs Go : il tourne chaque lundi et à la demande, pas pour chaque PR.
- **Résultats notés dans D-050** ([#16](https://github.com/PatrickChoumi/Ankh/pull/16) fusionnée le 2026-10-15).

### Suite Craft d'ArtCraft (décidée le 2026-10-15, D-053)

- **Ma demande** : remplacer OnlyOffice par la suite ArtCraft, découverte le jour même.
- **Vérifié par Claude** dans les dépôts officiels : dix « Crafting Apps » open source (MIT ou Apache-2.0), en Rust, isolées en Flatpak, toutes en alpha (DesignCraft en pré-alpha), pas encore sur Flathub, paquets Linux non signés (sommes SHA256 seulement). Le studio ArtCraft, lui, génère par des services d'IA payants en ligne.
- **Mes choix** : OnlyOffice remplacé, malgré l'alpha ; WordCraft, GridCraft et DeckCraft toujours là (Simple) ; les sept clones d'Adobe dans une nouvelle option « Création » ; sans le studio ArtCraft ; après le lot 0.

### Chantier Interface — au pixel près de Windows 11 (depuis le 2026-10-14)

- **Ma demande du 2026-10-14** : une interface « pixel perfect », au niveau de Windows 11. D'abord un plan exhaustif, des questions et des recherches.
- **Recherches de Claude** (D-052) :
  - la référence Windows 11, chiffrée et sourcée, lue dans le code de WinUI (licence MIT) et la documentation de Microsoft : coins, textes, couleurs, matières, ombres, animations, contrôles, barre de titre, icônes ;
  - ce que Plasma 6.7 permet, lu dans le code de KDE : ce qui se règle, ce qui demande nos propres fichiers, ce qui demande de reprendre le code de Breeze, ce qui est impossible ;
  - les licences : rien de Windows ne peut entrer dans l'image (police, icônes, sons, curseurs, fonds) ; ses mesures, si.
- **Mes choix** (D-052) : la rigueur de Windows 11 avec l'identité d'Ankh ; nos propres thèmes, dérivés du code de KDE et compilés dans l'image ; la barre des tâches collée en bas, 48 px ; le curseur blanc ; le chantier tout de suite, en parallèle de la phase 5. Le 2026-10-15, sur les planches : police Selawik, icônes Fluent au violet d'Ankh.
- **Planches de comparaison** envoyées le 2026-10-14, aux mesures de Windows 11 et aux couleurs d'Ankh :
  - polices : Inter, Selawik, Noto Sans, Open Sans, Source Sans 3 ;
  - icônes : Breeze, Fluent, Papirus, dans un explorateur, Démarrer et la barre des tâches.
- **Inspiration AnduinOS** (2026-10-15, D-052) : distribution Ubuntu qui ressemble à Windows 11 ; ses sources lues par Claude. Elle confirme nos choix (icônes Fluent, barre de 48 px, Démarrer de Windows 11) et donne ses valeurs pour la barre. Mes choix : curseurs Fluent blancs à l'anneau violet, thème GTK Fluent violet, polices en niveaux de gris ; JetBrains Mono gardée pour le terminal.
- **Lot 0, le banc de mesure** (2026-10-15, D-052) : 47 mesures comparées à Windows 11, une galerie des contrôles, et des captures de chaque surface en sombre, en clair, à 100, 125 et 150 %. Premier passage en VM vert ([run 38695602550](https://github.com/PatrickChoumi/Ankh/actions/runs/38695602550)) : 46 mesures prises ; 7 conformes, 27 écarts, 12 relevés. Les plus grands écarts : barre de titre de 28 px (32), coins de 5 px (8 et 4), bouton Fermer rond de 16 px (46×32), barres de défilement de 21 px (12), texte de 13 px (14). Quatre défauts du banc, vus sur les captures, sont corrigés et vérifiés au second passage ([run 38702400701](https://github.com/PatrickChoumi/Ankh/actions/runs/38702400701)) ; le rayon du menu reste à vérifier.

---

## Ce qui reste à faire

### Phase 5 — Gaming (en cours)

1. **Option Gaming** (D-050, D-051) : fusionnée le 2026-10-14 (PR [#15](https://github.com/PatrickChoumi/Ankh/pull/15)) ; les huit applications vérifiées en VM. Reste : savoir si les jeux de Lutris et de Bottles peuvent se servir de MangoHud, Gamescope et vkBasalt en Flatpak (runtime GNOME, À VALIDER).
2. **Mes jeux** : les noms sont à donner (question 6) ; chacun sera vérifié sous Linux (ProtonDB, anticheat), puis testé sur ma machine en phase 9.
3. **Réglages du système pour le jeu** (D-041, D-051) : ntsync avec Gaming, vérifié en VM. Les autres réglages attendront d'avoir vécu avec le système (phase 10).
4. **Critère de fin** : chaque jeu de la question 6 testé ; manettes, VRR et multi-écran vérifiés si concernés ; test final sur ma machine en phase 9.

### Chantier Interface (D-052, en parallèle)

Onze lots, chacun dans sa PR, avec captures avant et après, et les mesures du banc :

0. **Banc de mesure** (fusionné le 2026-10-15, PR [#17](https://github.com/PatrickChoumi/Ankh/pull/17) ; rayon du menu corrigé ensuite, à vérifier en VM) : fichier des valeurs de référence ; mesures automatiques en VM ; captures de chaque surface en sombre et en clair, à 100, 125 et 150 %.
1. Fondations : police, tailles, couleurs par couches, rendu des polices, animations, curseur blanc.
2. Fenêtres : décoration « Ankh » (barre de 32, boutons de 46×32, coins de 8, ombres).
3. Contrôles : style Qt « Ankh », aussi pour les applications QML ; thème GTK.
4. Shell : style Plasma « Ankh », barre collée de 48 px, horloge, notifications.
5. Démarrer d'Ankh.
6. Paramètres rapides, calendrier, notifications.
7. Alt+Tab, vue d'ensemble, déconnexion, verrouillage, sons.
8. Applications : Dolphin, réglages, Discover, Konsole, Chrome, VS Code, GTK, libadwaita, Electron ; plus de fenêtre de KDE Wallet.
9. Icônes et curseurs.
10. Finitions : hautes résolutions, thème clair, accessibilité, toutes les mesures obligatoires.

### Suite Craft d'ArtCraft (D-053, après le lot 0)

- Retirer OnlyOffice : image, dépôt et clé, applications par défaut, favoris du menu, tests.
- Simple : WordCraft, GridCraft et DeckCraft dans le menu, préparés au premier clic en Flatpak.
- Nouvelle option « Création » (assistant, « Options d'Ankh », Complète) : PhotoCraft, VectorCraft, FilmCraft, LightCraft, PdfCraft, EffectCraft, DesignCraft.
- Versions et empreintes SHA256 figées à chaque construction de l'image, vérifiées au premier clic ; nouvelle version proposée, jamais imposée.
- Tests : Test 12 adapté ; en VM, premier clic sur WordCraft à chaque PR, sur les dix dans le test complet.

### Reste de la phase 3, sans la bloquer

1. **Discover** (D-028) : fusionné. L'affichage à l'écran sera visible sur les captures de la VM.
2. **Chrome** (D-023) : fusionné. Reste à vérifier à l'écran le navigateur par défaut dans KDE (captures).
3. **Applications par défaut** (D-024, D-035) : fusionné. Claude et GitHub retirés (D-047, PR #13). Ensuite : vérifier les codecs de VLC sur ma machine, et mesurer la taille d'une mise à jour.
4. **Conteneur de dev** (D-032) : fusionné, avec les dernières versions LTS (Node.js 24, Java 25, D-038). Ensuite :
   - le tester pour de vrai (création, VS Code, une base de données) en VM ou sur la machine ;
   - le passer à Fedora 45 quand elle sortira (ma demande, procédure de D-017).
5. **Habillage Ankh** (D-033) : fusionné.
6. **Plus rien de Fedora à l'écran et collection de fonds** (D-034) : fusionné.
7. **Un seul Ankh** (D-036) : VS Code dans le menu dès l'installation, prêt au premier clic : fusionné, vérifié en VM. Steam en phase 5, outils Kali en phase 6, sur le même principe.
8. **Discover** (D-028) : causes de « Update Issue » trouvées. Celle du test est corrigée (PR #11). Défaut de Discover : option A choisie, suivi chez KDE (bug 523258).
9. **Identité visuelle d'Ankh** (D-037, D-039, D-042) : intégrée (PR #11 et PR #12). Écran de démarrage et écran de connexion entièrement d'Ankh dans la PR #13 (D-043), à valider sur les captures. Reste : le fond de l'assistant de premier démarrage, toujours uni (D-037).
10. **Options d'installation** (D-046) : fusionnées (PR #14). Gaming se remplit en phase 5, Hacking aux phases 6 et 7.
11. **Critère de fin** : rempli le 2026-10-13.

### Phases suivantes

- **Phases 6 et 7 — Cyber, Labs** : remplissent l'option Hacking (D-013, D-014, D-046). Les questions de ANKH-SPEC.md §4.4 sont à répondre avant.
- **Phase 8 — Sauvegarde et récupération** : trancher D-019, puis réussir un exercice complet en VM.
- **Phase 9 — Ma vraie machine** :
  - sauvegarder ma distro actuelle ;
  - construire l'ISO d'Ankh, et la tester en VM sans réseau (D-046, D-048) ;
  - installer Ankh depuis l'ISO, avec LUKS ;
  - valider le matériel (GPU, son, réseau, veille, écrans, jeux) ;
  - utiliser Ankh une semaine.
  - Avant : répondre aux questions 1 à 5 et 10 à 12 de ANKH-SPEC.md.
- **Phase 10 — Vivre avec Ankh** : corriger les irritations, mesurer puis réduire la taille des mises à jour (mon choix du 2026-10-09, D-027).
- **Phase 4 — Protection, en dernier** (mon choix du 2026-10-09, D-040) : concevoir puis intégrer safezone dans Ankh (D-026), en versions avec et sans protection (D-030). Il faudra traiter le basculement d'image (surtout vers une version sans protection), le retour arrière et `/etc`. Le filtrage se vérifie alors sur ma machine. Ensuite : Ankh V1.

### Points à vérifier (À VALIDER)

- **Renovate** : installé et actif, mais probablement en mode « Silent », donc sans PR ni ticket. Une base plus récente existe depuis le 2026-10-02.
- **Signature** : l'imposer sur ma machine (D-022). Le test en VM n'a montré aucune vérification de signature au basculement.
- **Discover** : la notification et l'affichage des mises à jour, à l'écran (D-028).
- **mcelog** : son comportement sur ma vraie machine (phase 9).
- **Variante NVIDIA** : elle ne se teste pas en VM, seulement par des contrôles statiques en CI.
- **Écran du mot de passe LUKS** : thème d'Ankh, à vérifier sur ma machine (le test en VM n'a pas de LUKS : l'écran y est lancé à la main, D-043).
- **KDE Wallet avec SDDM** : déverrouillé à la connexion comme avec Plasma Login, à vérifier sur ma machine (D-043).
- **KDE Wallet** : sa fenêtre s'ouvre au premier lancement de Chrome dans la VM (compte sans mot de passe) ; à vérifier sur ma machine.
- **Taille des mises à jour** : 252,7 Mo pour passer d'une image Ankh à une autre sur la même base ; la part de Chrome, des fonds et de l'initramfs est à mesurer (D-027).
- **Menu du BIOS** : l'entrée de démarrage s'appelle encore « Fedora » ; visible seulement dans le menu de démarrage de la carte mère. À étudier (D-034).
- **D-035** : les codecs de VLC sur ma machine. Taille d'une mise à jour mesurée : 1,2 Go ; la réduire est une piste (D-027).
- **Mise à jour non appliquée** (D-004) : corrigée et vérifiée en VM. Reste à comprendre pourquoi le même test passait sur `main` juste avant.
- **ntsync** (D-051) : le gain dans mes jeux, à mesurer sur ma machine (phase 9) ; il ne se mesure pas en VM.
- **Protontricks** (D-050) : qu'il trouve Steam une fois Steam connecté à mon compte, sur ma machine.
- **Lutris et Bottles** (D-050) : MangoHud, Gamescope et vkBasalt en Flatpak pour leurs jeux (runtime GNOME 49 et 50, pas de version publiée).
- **Compte qui n'est pas administrateur** (D-050) : Flatpak devrait lui demander le mot de passe d'un administrateur au premier clic ; en VM, il a été refusé sans fenêtre. Seulement utile si un deuxième compte doit installer des jeux.
- **« Options d'Ankh »** (D-046) : non testés en VM, le mot de passe refusé ou non donné, et les boutons « Supprimer » et « Garder » eux-mêmes (leur commande est testée). Limite connue : seule la barre du compte qui ouvre la fenêtre suit ; un autre compte de la machine garderait VS Code épinglé.

---

## Ce que je dois faire

1. **Lire [VISION.md](VISION.md)** et dire à Claude si c'est bien ma vision, ou ce qui manque (D-045).
2. **Regarder les captures des sept autres applications Gaming**, envoyées le 2026-10-14, et dire à Claude ce qui ne va pas (D-050). Les PR [#15](https://github.com/PatrickChoumi/Ankh/pull/15) et [#16](https://github.com/PatrickChoumi/Ankh/pull/16) sont fusionnées.
3. **Renovate** : dans <https://developer.mend.io/github/PatrickChoumi/Ankh>, ouvrir une exécution (par exemple la plus récente) et chercher `dryRun` dans le journal. Si le mot y est, passer le dépôt, ou toute l'organisation, du mode « Silent » au mode « Interactive » dans les réglages.
4. **Regarder les captures** que Claude m'envoie à chaque compte rendu, et lui dire ce qui ne va pas à l'écran.
5. **Optionnel** : rendre obligatoire le test « Démarrer ankh en VM » dans `protection-main`. Claude doit d'abord retirer le filtre qui saute ce test sur les PR qui ne touchent que la documentation.
6. **Plus tard** : donner les noms de mes jeux principaux (question 6), pour vérifier chacun sous Linux ; le critère de la phase 5 les attend. Et, avant la phase 9, les questions 1 à 5 et 10 à 12 (matériel, distro actuelle).
