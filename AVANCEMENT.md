# AVANCEMENT — Ce qui est fait, ce qui reste

> Mis à jour à chaque compte rendu (D-029). Dernière mise à jour : **2026-10-09** (nuit, PR #11 : Discover, identité visuelle et interface douce intégrées).
> Ce fichier résume et renvoie aux décisions (`D-xxx`, dans [DECISIONS.md](DECISIONS.md)). Il ne les recopie pas.
> L'état courant tient en quelques lignes dans [CLAUDE.md §2](CLAUDE.md#2-état-actuel).

## En un coup d'œil

| Phase | État |
|---|---|
| 0. Spécification | ✅ Terminée le 2026-10-07 |
| 1. Base et chaîne de build | ✅ Terminée le 2026-10-07 |
| 2. Premier démarrage en VM, dans le cloud | ✅ Terminée le 2026-10-07 |
| 3. Applications et dev | ⏳ En cours depuis le 2026-10-08 |
| 4. Protection (safezone) | À faire |
| 5. Gaming | À faire (questions matérielles à répondre avant) |
| 6. Cyber (Kali isolé) | À faire (questions à répondre avant) |
| 7. Labs (VMs isolées) | À faire (questions à répondre avant) |
| 8. Sauvegarde et récupération | À faire |
| 9. Bascule sur ma vraie machine | À faire |
| 10. Vivre avec Ankh, puis V1 | À faire |

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

### Phase 3 — Applications et dev (depuis le 2026-10-08)

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
  - Vérifié par un nouveau test de l'image (Test 14) et dans la session de la VM ; les captures diront si le résultat me plaît.

---

## Ce qui reste à faire

### Phase 3 — Applications et dev (en cours)

1. **Discover** (D-028) : fusionné. L'affichage à l'écran sera visible sur les captures de la VM.
2. **Chrome** (D-023) : fusionné. Reste à vérifier à l'écran le navigateur par défaut dans KDE (captures).
3. **Applications par défaut** (D-024, D-035) : fusionné. Ensuite : regarder les captures de VLC et d'OnlyOffice, vérifier les codecs de VLC sur ma machine, et mesurer la taille d'une mise à jour.
4. **Conteneur de dev** (D-032) : fusionné, avec les dernières versions LTS (Node.js 24, Java 25, D-038). Ensuite :
   - le tester pour de vrai (création, VS Code, une base de données) en VM ou sur la machine ;
   - le passer à Fedora 45 quand elle sortira (ma demande, procédure de D-017).
5. **Habillage Ankh** (D-033) : fusionné.
6. **Plus rien de Fedora à l'écran et collection de fonds** (D-034) : fusionné.
7. **Un seul Ankh** (D-036) : VS Code dans le menu dès l'installation, prêt au premier clic : fusionné, vérifié en VM. Steam en phase 5, outils Kali en phase 6, sur le même principe.
8. **Discover** (D-028) : causes de « Update Issue » trouvées. Celle du test est corrigée (PR #11). Défaut de Discover : option A choisie, suivi chez KDE (bug 523258).
9. **Identité visuelle d'Ankh** (D-037, D-039) : couleurs, polices, barre, Breeze et terminal intégrés dans l'image (PR #11), à valider sur les captures. Ensuite : écrans de démarrage, de connexion et de verrouillage, variante claire, VS Code.
10. **Critère de fin** : tout cela testé en CI et en VM cloud, et le quotidien faisable sans terminal.

### Phases suivantes

- **Phase 4 — Protection** : concevoir puis intégrer safezone dans Ankh (D-026), en versions avec et sans protection (D-030). Il faudra traiter le basculement d'image (surtout vers une version sans protection), le retour arrière et `/etc`.
- **Phases 5 à 7 — Gaming, Cyber, Labs** : elles demandent mes réponses aux questions matérielles Q1 à Q11 (ANKH-SPEC.md §6).
- **Phase 8 — Sauvegarde et récupération** : trancher D-019, puis réussir un exercice complet en VM.
- **Phase 9 — Ma vraie machine** :
  - sauvegarder ma distro actuelle ;
  - installer Ankh avec LUKS ;
  - valider le matériel (GPU, son, réseau, veille, écrans, jeux, filtrage) ;
  - utiliser Ankh une semaine.
- **Phase 10 — Vivre avec Ankh** : corriger les irritations, mesurer la taille réelle des mises à jour, puis sortir la V1.

### Points à vérifier (À VALIDER)

- **Renovate** : installé et actif, mais probablement en mode « Silent », donc sans PR ni ticket. Une base plus récente existe depuis le 2026-10-02.
- **Signature** : l'imposer sur ma machine (D-022). Le test en VM n'a montré aucune vérification de signature au basculement.
- **Discover** : la notification et l'affichage des mises à jour, à l'écran (D-028).
- **mcelog** : son comportement sur ma vraie machine (phase 9).
- **Variante NVIDIA** : elle ne se teste pas en VM, seulement par des contrôles statiques en CI.
- **Écran du mot de passe LUKS** : avec le logo d'Ankh, à vérifier sur ma machine (le test en VM n'a pas de LUKS, D-034).
- **Taille des mises à jour** : 252,7 Mo pour passer d'une image Ankh à une autre sur la même base ; la part de Chrome, des fonds et de l'initramfs est à mesurer (D-027).
- **Menu du BIOS** : l'entrée de démarrage s'appelle encore « Fedora » ; visible seulement dans le menu de démarrage de la carte mère. À étudier (D-034).
- **D-035** : les codecs de VLC sur ma machine. Taille d'une mise à jour mesurée : 1,2 Go ; la réduire est une piste (D-027).
- **Mise à jour non appliquée** (D-004) : corrigée et vérifiée en VM. Reste à comprendre pourquoi le même test passait sur `main` juste avant.

---

## Ce que je dois faire

1. **Dire à Claude** :
   - si la taille des mises à jour (1,2 Go) doit être réduite maintenant ou en phase 10 (D-027) ;
   - si l'interface d'Ankh sur les captures de la PR #11 me plaît, avant de fusionner (D-039).
2. **Renovate** : dans <https://developer.mend.io/github/PatrickChoumi/Ankh>, ouvrir une exécution (par exemple la plus récente) et chercher `dryRun` dans le journal. Si le mot y est, passer le dépôt, ou toute l'organisation, du mode « Silent » au mode « Interactive » dans les réglages.
3. **Regarder les captures** que Claude m'envoie à chaque compte rendu, et lui dire ce qui ne va pas à l'écran. Surtout les aperçus de l'identité visuelle (`1-apercu-…`) : dire si je les valide avant leur intégration (D-037).
4. **Optionnel** : rendre obligatoire le test « Démarrer ankh en VM » dans `protection-main`. Claude doit d'abord retirer le filtre qui saute ce test sur les PR qui ne touchent que la documentation.
5. **Avant la phase 5** : répondre aux questions matérielles Q1 à Q11 de ANKH-SPEC.md.
