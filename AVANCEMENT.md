# AVANCEMENT — Ce qui est fait, ce qui reste

> Mis à jour à chaque compte rendu (D-029). Dernière mise à jour : **2026-10-09** (début d'après-midi).
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

---

## Ce qui reste à faire

### Phase 3 — Applications et dev (en cours)

1. **Discover** (D-028) : fusionné. L'affichage à l'écran sera visible sur les captures de la VM.
2. **Chrome** (D-023) : fusionné. Reste à vérifier à l'écran le navigateur par défaut dans KDE (captures).
3. **Applications par défaut** (D-024) :
   - VLC et OnlyOffice en Flatpak, préinstallés ;
   - Claude et GitHub en applications web dans Chrome.
4. **Conteneur de dev** (D-032) : fusionné. Ensuite :
   - le tester pour de vrai (création, VS Code, une base de données) en VM ou sur la machine ;
   - vérifier la version de Java choisie par défaut, et proposer un Node.js plus récent que la 22 si Fedora en fournit un.
5. **Habillage Ankh** (D-033) : fusionné.
6. **Plus rien de Fedora à l'écran et collection de fonds** (D-034) : CI et VM vertes, PR #8 à fusionner après mon regard sur les captures.
7. **Critère de fin** : tout cela testé en CI et en VM cloud, et le quotidien faisable sans terminal.

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

---

## Ce que je dois faire

1. **Renovate** : dans <https://developer.mend.io/github/PatrickChoumi/Ankh>, ouvrir une exécution (par exemple la plus récente) et chercher `dryRun` dans le journal. Si le mot y est, passer le dépôt, ou toute l'organisation, du mode « Silent » au mode « Interactive » dans les réglages.
2. **Regarder les captures d'écran** de la PR en cours, une fois sa CI verte : page du run « Tester le démarrage en VM », section « Artifacts », fichier `captures-ankh-vm`. Me dire si le démarrage, la connexion, le bureau, Chrome et Discover ont l'air corrects.
3. **Optionnel** : rendre obligatoire le test « Démarrer ankh en VM » dans `protection-main`. Claude doit d'abord retirer le filtre qui saute ce test sur les PR qui ne touchent que la documentation.
4. **Avant la phase 5** : répondre aux questions matérielles Q1 à Q11 de ANKH-SPEC.md.
