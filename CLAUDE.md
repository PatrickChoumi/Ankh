# CLAUDE.md — Guide du projet Ankh

> Guide de travail du projet. Claude Code le lit au début de chaque session.
> Il fixe **les règles, la méthode et la feuille de route**. Les détails vivent ailleurs et ne sont pas recopiés ici :
>
> | Je cherche… | Fichier |
> |---|---|
> | Ce que je fais avec ma machine, les questions ouvertes, la liste NON | [ANKH-SPEC.md](ANKH-SPEC.md) |
> | Chaque choix, ses raisons, ses sources et ses tests (`D-xxx`) | [DECISIONS.md](DECISIONS.md) |
> | La présentation, l'architecture et la récupération après panne | [README.md](README.md) |
> | Tout ce qui a été fait depuis le début, et ce qui reste à faire | [AVANCEMENT.md](AVANCEMENT.md) (D-029) |
> | Les règles, la méthode, la feuille de route et l'état du projet | ce fichier |
>
> En cas de contradiction : **DECISIONS.md fait foi pour les choix**, **ANKH-SPEC.md pour les besoins**. Ce fichier est alors à corriger.

---

## 1. Ankh en cinq lignes

- Mon OS **personnel** (pas une distribution publique) pour le dev, le gaming et la cybersécurité. Image **générique**, conçue pour fonctionner sur le maximum de PC x86_64 (D-001, D-021).
- Système **image-based** : Fedora Atomic (Kinoite) + bootc, mises à jour d'un bloc, retour arrière (D-004).
- Hôte minimal et protégé : Secure Boot, LUKS, rien d'installé en dehors de l'image (D-006 à D-009).
- Applications en Flatpak, dev en conteneur, Kali en Podman rootless, malware et labs en VMs isolées (D-011 à D-014).
- Ce n'est **pas** une distribution : on optimise ma machine avant de construire quoi que ce soit d'autre.

## 2. État actuel

- **Phase en cours : 3 — Applications et dev** (depuis le 2026-10-08).
  - Fait : les mises à jour du système dans Discover (D-028, [#4](https://github.com/PatrickChoumi/Ankh/pull/4) fusionnée).
  - Fait ([#5](https://github.com/PatrickChoumi/Ankh/pull/5) fusionnée) :
    - Chrome dans l'image, navigateur par défaut, et Firefox retiré (D-023) ;
    - reconstruction chaque lundi ;
    - aucune mise à jour automatique sur la machine (D-031) ;
    - captures d'écran de la VM.
  - Fait ([#6](https://github.com/PatrickChoumi/Ankh/pull/6) fusionnée) : le conteneur de dev `ankh-dev`, avec VS Code et les langages fullstack (D-032).
  - Fait ([#7](https://github.com/PatrickChoumi/Ankh/pull/7) fusionnée) : l'habillage Ankh sur le bureau : nom, logo, fonds d'écran (D-033).
  - Fait ([#8](https://github.com/PatrickChoumi/Ankh/pull/8) fusionnée) : plus rien de Fedora à l'écran, démarrage compris, et une collection de fonds d'écran (D-034).
  - Fait ([#9](https://github.com/PatrickChoumi/Ankh/pull/9) fusionnée) : VLC et OnlyOffice dans l'image, LibreOffice absent, Claude et GitHub dans Chrome (D-035) ; les mises à jour s'appliquent de nouveau au redémarrage (D-004).
  - En cours : les dernières versions LTS de Node.js et de Java dans le conteneur de dev (D-038).
  - Ensuite :
    - un seul Ankh : VS Code dans le menu dès l'installation, sans « ankh-dev » à gérer (D-036) ;
    - l'identité visuelle d'Ankh (thème sombre, couleurs, icônes, barre flottante), avec des aperçus avant intégration (D-037, à écrire).
- **Phase 2 terminée le 2026-10-07** : son critère est rempli.
  - Dans une VM sur les machines de GitHub, avec la variante Mesa : démarrage complet, basculement, `bootc rollback` et retour à la base sont tous réussis, avec Secure Boot, SELinux et le pare-feu actifs.
  - Résultats dans D-004, test `tests/vm/run.sh`, lancé par `.github/workflows/boot-test.yml` (test « Démarrer ankh en VM », non obligatoire pour l'instant).
- **Phase 1 terminée le 2026-10-07** :
  - Les images sont construites, testées, signées sans clé (D-022) et publiées par la CI : `ghcr.io/patrickchoumi/ankh` (4,3 Go compressés) et `ghcr.io/patrickchoumi/ankh-nvidia` (5,2 Go).
  - `main` est protégée (ruleset `protection-main`, tests « Construire ankh » et « Construire ankh-nvidia » obligatoires). Une PR cassée est bien bloquée ([#2](https://github.com/PatrickChoumi/Ankh/pull/2)).
  - Renovate : installé et actif dans le tableau de bord Mend (2026-10-08), mais il n'a encore créé ni PR ni ticket. Cause probable : le mode « Silent » de Mend (voir D-017). Je dois passer le dépôt en mode « Interactive ».
- **Construire et tester en local** : `just build ankh` puis `just test ankh` (nécessite podman et just).
- **Questions matérielles** : elles ne bloquent pas la phase 1 (D-021). Elles restent nécessaires avant les phases indiquées dans ANKH-SPEC.md §6.
- **Branches** : `main` reçoit les changements uniquement par PR.
- **Langue du projet** : français (documents, messages de commit, échanges).

> Mettre cette section à jour à chaque changement de phase.

---

## 3. Règles non négociables

Elles valent pour moi comme pour tout assistant. Elles ne se contournent pas : si une règle bloque, on ouvre une nouvelle décision dans DECISIONS.md.

### Périmètre
1. Pas de distribution publique, pas d'ISO custom en V1 (D-001). À l'écran, plus rien de Fedora : nom, logos, fonds et écran de démarrage sont ceux d'Ankh. Sous le capot, Fedora reste (D-033, D-034).
2. Image générique : rien de propre à une machine particulière dans l'image. Couverture matérielle et variantes : D-021.
3. Linux uniquement, pas de dual boot, pas de Windows natif. Une VM Windows reste possible (D-003).

### Hôte
4. Rien ne s'installe sur l'hôte en dehors de l'image. Pas de `rpm-ostree install`, pas de `curl | bash` (D-009).
5. Placement de chaque logiciel :
   - **image** : ce qui fait partie du système ;
   - **Flatpak** : les applications ;
   - **conteneur** : le dev et les outils cyber ;
   - **VM** : tout ce qui est dangereux ou non fiable.
6. Pas de redémarrage automatique. Une mise à jour s'applique au redémarrage que je choisis (D-010).

### Sécurité
7. Secure Boot, LUKS, pare-feu et SELinux restent actifs. On ne désactive jamais une protection pour faire marcher un outil : on trouve une autre intégration, ou on renonce à l'outil (D-006 à D-008).
8. Aucun outil offensif ni malware sur l'hôte (D-013, D-014).
9. distrobox et toolbx servent à l'intégration, pas à l'isolation. Jamais pour la cybersécurité (D-012, D-013).

### Méthode
10. **Le dépôt est la source de vérité.** Toute affirmation technique importante s'appuie sur une documentation officielle, un test reproductible ou une expérience réelle sur ma machine. Sinon, elle est marquée `À VALIDER` (D-016).
11. Une information vit dans **un seul** fichier (tableau en tête de ce guide). Pas de nouveau document sans décision.
12. Pas de gros CLI maison tant qu'une recette `just` suffit (D-015).
13. On optimise **après** avoir vécu avec le système, pas avant.

---

## 4. Règles de travail pour Claude Code

### Avant d'agir
- Lire les entrées de DECISIONS.md et les sections de ANKH-SPEC.md concernées par la tâche.
- Vérifier que la **phase en cours** (§2) autorise la tâche. Pendant la phase 0 : uniquement de la documentation.
- Ne jamais inventer une réponse à un `TODO` ou `UNKNOWN` : poser la question.
- Pour un choix d'architecture : présenter les options et une recommandation. C'est moi qui tranche, puis la décision est écrite dans DECISIONS.md.

### Pendant
- Ne citer comme fait que ce qui est vérifié, avec la source ou le test. Si une source est inaccessible, le dire et marquer `À VALIDER`.
- Distinguer clairement « vérifié dans la doc », « vérifié par un test » et « supposé ».
- DECISIONS.md :
  - on ne supprime jamais une entrée ;
  - une décision qui change donne une nouvelle entrée qui cite l'ancienne ;
  - l'index est tenu à jour.
- Futurs scripts : `set -euo pipefail`, jamais `|| true` pour masquer une erreur. Un build qui rencontre un problème doit échouer.
- Signaler explicitement, pour relecture, toute modification qui touche au démarrage, aux pilotes, à Secure Boot, à LUKS, au pare-feu ou aux mises à jour.
- Ne jamais demander, lire ni manipuler une clé privée (cosign, SSH, GPG, MOK). Je les génère et les stocke moi-même.

### Git
- Travailler sur une branche dédiée. Pas de push direct sur `main`, pas de force-push.
- **Claude commite et pousse sur la branche de travail sans demander mon avis** (autorisé le 2026-10-07). Un commit par changement cohérent.
- Messages de commit en français, qui décrivent le pourquoi.

### Après
- Rendre compte de :
  - ce qui a changé, avec le commit poussé ;
  - ce qui est vérifié ;
  - ce qui reste `À VALIDER` ;
  - ce que **je** dois faire physiquement (VM, BIOS, matériel, clés).
- Mettre à jour [AVANCEMENT.md](AVANCEMENT.md) et me l'envoyer à chaque compte rendu (D-029).
- Joindre à chaque compte rendu des captures d'écran de la VM qui montrent le travail fait (ma demande du 2026-10-09). Si une capture manque, dire pourquoi.
- Claude ne peut pas tester sur ma machine. Le dire, plutôt que de présenter un résultat non testé comme acquis.

---

## 5. Feuille de route

Chaque phase a un critère de fin **vérifiable**. On ne passe pas à la suivante tant qu'il n'est pas rempli. Tout se teste **en VM avant la vraie machine**.

| Phase | Objectif | Terminée quand |
|---|---|---|
| **0. Spécification** *(terminée le 2026-10-07)* | Décrire ma machine et mes usages | ANKH-SPEC.md §6 « Avant la phase 1 » entièrement coché |
| **1. Base et chaîne de build** *(terminée le 2026-10-07)* | Images génériques construites automatiquement | D-005, D-017 et D-018 tranchées. Chaque variante de D-021 est construite par la CI, testée, signée et publiée, sans toucher ma machine |
| **2. Premier démarrage en VM, dans le cloud** *(terminée le 2026-10-07)* | Prouver le modèle image-based sans rien télécharger chez moi (D-027) | Dans une VM sur les machines de GitHub, avec la variante Mesa : démarrage complet, puis basculement vers une autre version, retour arrière (`bootc rollback`) et retour à l'image de base, tous réussis automatiquement. Résultats notés dans D-004. La variante NVIDIA ne se teste pas en VM : seulement des contrôles statiques en CI |
| **3. Applications et dev** *(prochaine)* | Le quotidien et le dev fonctionnent sans terminal pour le quotidien (D-025) | Chrome par défaut et Firefox retiré (D-023). VLC, OnlyOffice, Claude et GitHub présents (D-024). Mises à jour par l'interface. VS Code et le conteneur dev se recréent depuis le dépôt (D-012). Tests en CI et en VM cloud |
| **4. Protection** | safezone adapté et intégré (D-026) | Conception tranchée dans DECISIONS.md. Les tests de safezone passent sur l'image Ankh. Les contournements propres au modèle image-based (`bootc switch`, retour arrière, `/etc`) sont traités ou documentés |
| **5. Gaming** | Mes jeux fonctionnent | Chaque jeu de ANKH-SPEC Q6 testé. Manettes, VRR et multi-écran vérifiés si concernés (D-011). Test final sur la vraie machine en phase 9 |
| **6. Cyber** | Kali isolé | Test d'isolation réussi : le `~/.ssh` de l'hôte est inaccessible depuis le conteneur. Solution « réseau bas niveau » tranchée (D-013) |
| **7. Labs** | VMs de lab et de malware isolées | Depuis une VM de lab, l'hôte et le réseau local sont injoignables. La restauration de snapshot fonctionne (D-014) |
| **8. Sauvegarde et récupération** | Pouvoir perdre le disque sans rien perdre | D-019 tranchée. Exercice complet de récupération réussi en VM, en suivant README.md |
| **9. Bascule sur la vraie machine** | Ankh devient mon système | Ma distro actuelle est sauvegardée et la sauvegarde vérifiée. Installation en ligne avec LUKS, même lente (D-027). Checklist matériel validée : GPU, son, réseau, Bluetooth, veille, écrans, jeux, filtrage. Une semaine d'usage sans retour arrière définitif |
| **10. Vivre avec Ankh** | Corriger selon mes vraies irritations | Plusieurs semaines d'usage. Irritations notées, puis traitées une par une. Taille des mises à jour mesurée (D-027). → **Ankh V1** |

**Repoussé hors V1** : le matériel exclu par D-021 (NVIDIA ancien), distribution publique, ISO custom (l'ISO hors ligne envisagée par D-027 est abandonnée), CLI riche, rollback automatique, optimisations non motivées par l'usage réel.

**Règle de bascule** : Ankh ne remplace pas ma distro actuelle tant que la récupération (phase 8) n'a pas été testée.

**Règle de test matériel** : une variante n'est dite « testée » que sur du matériel réel. Les variantes que je ne possède pas restent marquées « non testées sur matériel réel ».

---

## 6. Déroulé type d'une tâche

1. **Comprendre** : quelle phase ? quelles décisions et quels besoins sont concernés ?
2. **Vérifier** les prérequis. Il ne doit rester aucun `TODO` bloquant ni aucune décision `À DÉCIDER` nécessaire à la tâche.
3. **Proposer**, si la tâche touche l'architecture. J'arbitre, puis on écrit la décision.
4. **Réaliser** sur une branche, sans contourner les règles du §3.
5. **Vérifier** : tests, CI, VM. Noter ce qui n'a pas pu être testé.
6. **Rendre compte** (§4, « Après »), avec le commit poussé sur la branche de travail.
