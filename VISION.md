# VISION — Ankh, une fois terminé

> Le portrait d'Ankh à la fin : la V1, déclarée après la phase 4, et la vie avec Ankh. Il sert à vérifier qu'on ne dévie pas de ma vision (D-045).
> Chaque trait renvoie à mon besoin ([ANKH-SPEC.md](ANKH-SPEC.md)) ou à sa décision (`D-xxx`, dans [DECISIONS.md](DECISIONS.md)), qui dit aussi comment il se prouve.
> Ce fichier ne dit pas où on en est : c'est [AVANCEMENT.md](AVANCEMENT.md).
> Une décision qui change un trait met ce fichier à jour dans le même commit, et le compte rendu le signale.

## En une phrase

Ankh est **mon** système pour coder, jouer et faire de la cybersécurité. C'est **une seule version**, où je coche à l'installation ce que je veux : Simple, Dev, Gaming, Hacking, Création, ou Complète. Il est :

- **incassable** : une mise à jour se défait d'un geste ;
- **protégé** : ce qui est dangereux reste enfermé ;
- **beau** : au pixel près de Windows 11, aux couleurs d'Ankh, sans rien de Fedora à l'écran ;
- **à moi** : rien ne s'y installe ni ne s'y met à jour sans moi.

## Une version, des options choisies à l'installation (D-046)

Comme l'installation d'Ubuntu, adaptée à Ankh : des cases à cocher, combinables. Toutes ont le bureau d'Ankh.

| Case | Ce qu'elle installe |
|---|---|
| **Simple**, toujours incluse | Chrome et VLC ; la bureautique de la suite Craft : WordCraft, GridCraft et DeckCraft (D-053) |
| **Dev** | VS Code et les outils du dev, dans un conteneur |
| **Gaming** | Steam et les autres lanceurs, les outils du jeu, les manettes, le mode console, Discord et OBS |
| **Hacking** | Kali dans un conteneur isolé, les labs dans des VMs isolées ; plus tard, l'analyse de malware et le Wi-Fi offensif |
| **Création** | Les clones d'Adobe de la suite Craft : PhotoCraft, VectorCraft, FilmCraft, LightCraft, PdfCraft, EffectCraft et DesignCraft (D-053) |
| **Complète** | Coche Dev, Gaming, Hacking et Création |

- **Une seule ISO d'installation d'Ankh** pour tous les PC, publiée dans une Release GitHub : elle contient le système, qui s'installe sans internet. Les options cochées se téléchargent ensuite, seulement elles. Sur un PC NVIDIA, Ankh propose sa version NVIDIA (D-048, D-049).
- **Ce qui n'est pas coché n'est pas installé** : sans la case Dev, pas de VS Code ; sans Gaming, pas de Steam ; sans Hacking, pas de Kali. Seules quelques petites pièces du système restent présentes, cachées et à l'arrêt (D-046).
- **Les options se changent après l'installation**, dans la fenêtre « Options d'Ankh » des réglages, avec les mêmes cartes qu'à l'installation et le mot de passe d'un administrateur. Ce qui est ajouté se télécharge quand je le décide ; ce qui est retiré libère sa place (D-031, D-046).
- **Le système reste le même pour tous** : une seule image, pour les cartes graphiques AMD et Intel (Mesa) et NVIDIA récentes (D-021), avec et sans la protection contre le contenu pour adultes (D-030).
- Dans le menu, chaque outil installé apparaît comme une application ordinaire, et reste isolé dessous (D-036).
- **Le choix se fait au premier démarrage**, dans l'assistant d'Ankh, et vaut pour toute la machine (D-046).

## Ce que toutes les installations ont en commun

### Incassable et stable, mais à jour

C'est mon exigence générale (ANKH-SPEC.md).

- Le système est une image, mise à jour d'un bloc. Si une mise à jour casse quelque chose, je reviens à la version précédente (D-004).
- Fedora reste sous le capot, à une version figée. Je décide quand passer à la suivante (D-005, D-017).
- Les images sont construites, testées et signées automatiquement (D-018, D-022). Elles sont reconstruites chaque lundi pour rester à jour, puis seulement proposées (D-023, D-031).
- Rien ne s'installe sur le système en dehors de l'image : pas de `rpm-ostree install`, pas de `curl | bash` (D-009). Les options n'ajoutent que des applications Flatpak et des conteneurs, à leur place.

### Je décide de ce qui se télécharge et s'installe

- Aucune mise à jour automatique : ni du système, ni des applications, ni des outils (D-031).
- Les mises à jour se font dans Discover, sans terminal (D-028).
- Elles s'appliquent au redémarrage que je choisis. Jamais de redémarrage automatique (D-010).
- Ma connexion est lente (D-027) :
  - le système s'installe depuis l'ISO, sans internet ; seuls les outils choisis se téléchargent (D-049) ;
  - les gros tests se font dans le cloud ;
  - la taille des mises à jour sera mesurée et réduite en phase 10.

### Protégé, sans jamais baisser la garde

- Secure Boot, chiffrement du disque (LUKS), SELinux et pare-feu sont toujours actifs. Aucune protection n'est désactivée pour faire marcher un outil (D-006 à D-008).
- Chaque logiciel a sa place (D-011 à D-014) :
  - le système dans l'image ;
  - les applications en Flatpak ;
  - le dev et les outils de cybersécurité en conteneur ;
  - tout ce qui est dangereux en VM.
- Aucun outil offensif ni malware sur le système, même avec l'option Hacking (D-013, D-014).
- L'accès au contenu pour adultes est extrêmement difficile dans les versions protégées : mon projet safezone, adapté et intégré (D-026, D-030). Il arrive en dernier, avec la V1 (D-040). Sa conception est À DÉCIDER en phase 4.

### Beau, et entièrement Ankh

- De l'allumage au bureau, rien de Fedora à l'écran (D-033, D-034, D-043) :
  - l'écran de démarrage, et la saisie du mot de passe du disque ;
  - l'écran de connexion ;
  - le chargement de la session et le bureau ;
  - « À propos ».
- Une identité à lui : graphite et violet, sombre par défaut. Un thème clair existe aussi, avec un passage automatique de l'un à l'autre si je l'active (D-037, D-042).
- Une interface au pixel près de Windows 11, avec l'identité d'Ankh, faite de nos propres thèmes dérivés du code de KDE (D-052) :
  - les mesures de Windows 11 : barres de titre, coins de 4 et 8 px, contrôles, textes, ombres et animations ;
  - sa disposition : la barre des tâches collée en bas, en verre, avec Démarrer et les applications au centre ; les paramètres rapides en un seul volet ;
  - la police Selawik, sosie libre de Segoe UI, les icônes Fluent au violet d'Ankh et un curseur blanc ;
  - chaque mesure vérifiée automatiquement en VM, à chaque changement.
- Des finitions venues de macOS et de Windows 11 (D-039, D-042) : la recherche au centre de l'écran, un accueil et des raccourcis utiles.
- Une collection de fonds d'écran d'Ankh (D-034).
- Tout est en français, et Ankh me vouvoie (D-043).

### Le quotidien sans terminal (D-025)

- Chrome est le navigateur par défaut ; il n'y a pas de Firefox (D-023).
- VLC est toujours là (D-035). La bureautique aussi : WordCraft, GridCraft et DeckCraft, de la suite Craft d'ArtCraft, en Flatpak, préparées au premier clic (D-053).
- Aucune application web n'est imposée dans Chrome : j'installe moi-même celles que je veux, comme Claude ou GitHub (D-047).
- Chaque outil s'ouvre depuis le menu. S'il doit d'abord se télécharger, le premier clic le prépare en montrant la progression (D-036).
- Le terminal reste là, sans restriction, pour quand j'en ai besoin (D-025).

### Fait pour le maximum de PC

- L'image est générique, sans réglage propre à une machine. Elle couvre AMD, Intel et NVIDIA récents. Les anciennes NVIDIA (GTX 900, 1000) ne sont pas couvertes en V1 (D-021).
- C'est un système personnel : pas une distribution publique. L'ISO d'Ankh sert à installer mes machines (D-001, D-046).
- Linux seulement, sans dual boot. Windows reste possible dans une VM (D-003).

### Perdre le disque sans rien perdre

- Le système se reconstruit depuis ce dépôt et l'ISO, et ma configuration vit dans Git. Mes données et mes secrets sont sauvegardés à part (D-019, PROPOSÉE — À VALIDER en phase 8).
- La récupération complète est répétée en VM avant qu'Ankh ne devienne mon système (CLAUDE.md §5, règle de bascule).
- L'outil, la destination et la fréquence des sauvegardes sont TODO (ANKH-SPEC 4.6).

## Ce que chaque option apporte

### Dev

- **VS Code** avec son logo officiel. Il s'ouvre dans le conteneur de dev, et ses réglages et extensions se recréent depuis le dépôt (D-032, D-036, D-043).
- **Langages et outils** : Java, Python, JavaScript et TypeScript, C et C++, les clients de bases de données, « tout le nécessaire pour un fullstack » (D-032). Node.js et Java sont à leur dernière version LTS (D-038).
- **GitHub** par Git, dans VS Code (D-024).
- **IA locale**, importante pour moi : CUDA ou ROCm dans un conteneur, selon ma carte graphique, encore inconnue (ANKH-SPEC Q3 et Q7). Sa conception et son option (Dev ou Gaming, D-041) sont À DÉCIDER quand la carte sera connue.
- **À préciser** (ANKH-SPEC 4.2, TODO) : compatibilité Docker, bases de données de mes projets, autres outils.

### Gaming (phase 5)

- **Lanceurs** : Steam, Heroic (Epic, GOG, Amazon), Lutris, Bottles, ProtonPlus et Protontricks, dans le menu avec leur logo, prêts au premier clic ; Steam est aussi dans la barre (D-041, D-050).
- **Outils du jeu** dans le système : GameMode, MangoHud, Gamescope, vkBasalt, et les règles des manettes et casques de Steam (D-041). MangoHud, vkBasalt et Gamescope existent aussi en Flatpak, préparés avec chaque lanceur, pour qu'ils marchent dans tous mes jeux (D-050).
- **Manettes** : toutes (Xbox, PlayStation, autres), filaires et sans fil (ANKH-SPEC 4.3).
- **Discord et OBS Studio** font partie de l'option Gaming, prêts au premier clic comme les lanceurs (D-041).
- **Mode console** : la session « Ankh Console », à choisir sur l'écran de connexion : Steam en plein écran (Big Picture), à la manette ; quitter Steam ramène à l'écran de connexion (D-041, D-050).
- **Réglages** : seulement des réglages sûrs pour le jeu. Le noyau est celui de Fedora, et Secure Boot reste actif sans clé à gérer (D-041). Avec l'option Gaming, ntsync accélère les jeux Windows sous Proton et Wine ; aucune protection n'est retirée (D-051).
- **Limite assumée** : les jeux en ligne dont l'anticheat refuse Linux ne marcheront pas (ANKH-SPEC Q6, D-003).
- **Mes jeux** seront testés sur ma machine en phase 9. Leurs noms sont TODO (Q6) : je les donnerai plus tard.

### Hacking (phases 6 et 7)

- **Kali** : ses outils sont dans le menu et se lancent dans un conteneur Podman rootless. Seul un dossier de travail dédié y est visible : ni mes clés SSH ni mes données (D-013, D-036).
- **Réseau bas niveau** (scan SYN, ARP, mode monitor) : dans une VM ou un conteneur éphémère, À DÉCIDER (D-013).
- **Labs** dans des VMs isolées : depuis le lab, l'hôte et mon réseau local sont injoignables, et les snapshots se restaurent (D-014).
- **Plus tard**, sans rien changer d'autre (ANKH-SPEC Q8 et Q9, D-014) :
  - l'analyse de malware en VM isolée, sans dossier ni presse-papier partagé ;
  - le Wi-Fi offensif, avec un adaptateur USB confié à une VM.
- **Cadre** : uniquement sur des systèmes à moi, ou avec une autorisation écrite (ANKH-SPEC 4.4).
- **À préciser** (ANKH-SPEC 4.4, TODO) : les outils de Kali que j'utilise, les plateformes de CTF, les VMs nécessaires.

### Création

- **Les clones d'Adobe de la suite Craft d'ArtCraft**, open source, en Rust, isolés en Flatpak, prêts au premier clic : PhotoCraft (comme Photoshop), VectorCraft (Illustrator), FilmCraft (Premiere Pro), LightCraft (Lightroom), PdfCraft (Acrobat), EffectCraft (After Effects) et DesignCraft (InDesign) (D-053).
- **Limite assumée** : ce sont des logiciels jeunes, encore en alpha en 2026 ; leurs mises à jour passent par Ankh tant qu'ils ne sont pas sur Flathub (D-053).

### Complète

- Dev, Gaming, Hacking et Création, dans la même installation.

## Ce qu'Ankh ne sera jamais

- La liste est dans [ANKH-SPEC.md §5](ANKH-SPEC.md#5-ce-que-je-ne-veux-pas).
- Ce qui est repoussé après la V1 est dans [CLAUDE.md §5](CLAUDE.md#5-feuille-de-route).

## Ce qui reste à trancher pour compléter ce portrait

| Point ouvert | Où | Quand |
|---|---|---|
| Comment Ankh propose sa version NVIDIA au premier démarrage | D-049 | Phase 9 |
| Mon matériel et ma distro actuelle (questions 1 à 5 et 10 à 12) | ANKH-SPEC.md §1 | Avant la phase 9 |
| Réseau bas niveau pour le hacking | D-013 | Phase 6 |
| Sauvegarde et récupération | D-019 | Phase 8 |
| Conception de la protection | D-026, D-030 | Phase 4 |
| IA locale | ANKH-SPEC Q3 et Q7, D-041 | Quand ma carte graphique sera connue |
| Les autres `TODO` (dev, cyber, quotidien, secrets) | ANKH-SPEC.md §4 | Avant la phase concernée |

## Comment vérifier qu'on ne dévie pas

- Chaque trait ci-dessus a sa décision. La décision dit comment il se prouve : test en CI, en VM, ou sur ma machine.
- Une décision qui change un trait change aussi ce fichier, dans le même commit. Le compte rendu le dit (D-045).
- Ankh V1 est déclarée à la fin de la phase 4, quand les critères de toutes les phases sont remplis (CLAUDE.md §5).
