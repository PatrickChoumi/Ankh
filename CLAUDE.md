# CLAUDE.md — Guide du projet Ankh

> Guide de travail du projet. Claude Code le lit au début de chaque session.
> Il fixe **les règles, la méthode et la feuille de route**. Les détails vivent ailleurs et ne sont pas recopiés ici :
>
> | Je cherche… | Fichier |
> |---|---|
> | Ce que je fais avec ma machine, les questions ouvertes, la liste NON | [ANKH-SPEC.md](ANKH-SPEC.md) |
> | Chaque choix, ses raisons, ses sources et ses tests (`D-xxx`) | [DECISIONS.md](DECISIONS.md) |
> | La présentation, l'architecture et la récupération après panne | [README.md](README.md) |
> | Les règles, la méthode, la feuille de route et l'état du projet | ce fichier |
>
> En cas de contradiction : **DECISIONS.md fait foi pour les choix**, **ANKH-SPEC.md pour les besoins**. Ce fichier est alors à corriger.

---

## 1. Ankh en cinq lignes

- Mon OS **personnel**, pour **une seule machine** et **un seul utilisateur** : dev, gaming, cybersécurité (D-001, D-002).
- Système **image-based** : Fedora Atomic (Kinoite) + bootc, mises à jour d'un bloc, retour arrière (D-004).
- Hôte minimal et protégé : Secure Boot, LUKS, rien d'installé en dehors de l'image (D-006 à D-009).
- Applications en Flatpak, dev en conteneur, Kali en Podman rootless, malware et labs en VMs isolées (D-011 à D-014).
- Ce n'est **pas** une distribution : on optimise ma machine avant de construire quoi que ce soit d'autre.

## 2. État actuel

- **Phase en cours : 0 — Spécification.** Aucun code, aucune image, aucun Containerfile, aucun CLI.
- **Ce qui bloque la suite** : les réponses de ANKH-SPEC.md §1 (questions 1 à 11) et la checklist de ANKH-SPEC.md §6.
- **Langue du projet** : français (documents, messages de commit, échanges).

> Mettre cette section à jour à chaque changement de phase.

---

## 3. Règles non négociables

Elles valent pour moi comme pour tout assistant. Elles ne se contournent pas : si une règle bloque, on ouvre une nouvelle décision dans DECISIONS.md.

### Périmètre
1. Pas de distribution publique, pas de branding, pas d'ISO custom en V1 (D-001).
2. Une seule machine, un seul GPU en V1. Pas de multi-GPU (D-002).
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
- Travailler sur une branche dédiée. Pas de push direct sur `main`.
- **Commit et push uniquement quand je le demande.**
- Messages de commit en français, qui décrivent le pourquoi.

### Après
- Rendre compte de :
  - ce qui a changé ;
  - ce qui est vérifié ;
  - ce qui reste `À VALIDER` ;
  - ce que **je** dois faire physiquement (VM, BIOS, matériel, clés).
- Claude ne peut pas tester sur ma machine. Le dire, plutôt que de présenter un résultat non testé comme acquis.

---

## 5. Feuille de route

Chaque phase a un critère de fin **vérifiable**. On ne passe pas à la suivante tant qu'il n'est pas rempli. Tout se teste **en VM avant la vraie machine**.

| Phase | Objectif | Terminée quand |
|---|---|---|
| **0. Spécification** *(en cours)* | Décrire ma machine et mes usages | ANKH-SPEC.md §6 entièrement coché |
| **1. Base et chaîne de build** | Image minimale construite automatiquement | D-005, D-017 et D-018 tranchées. Une image minimale (base + presque rien) est construite par la CI et publiée, sans toucher ma machine |
| **2. Premier démarrage en VM** | Prouver le modèle image-based | Dans une VM : basculement sur l'image, puis retour arrière (`bootc rollback`), puis retour à l'image de base, tous réussis. Résultats notés dans DECISIONS.md (D-004) |
| **3. Dev** | Environnement de dev reconstructible | Le conteneur dev se supprime et se recrée depuis le dépôt, fonctionnel (D-012) |
| **4. Gaming** | Mes jeux fonctionnent | Chaque jeu de ANKH-SPEC Q6 testé. Manettes, VRR et multi-écran vérifiés si concernés (D-011). Test final sur la vraie machine en phase 8 |
| **5. Cyber** | Kali isolé | Test d'isolation réussi : le `~/.ssh` de l'hôte est inaccessible depuis le conteneur. Solution « réseau bas niveau » tranchée (D-013) |
| **6. Labs** | VMs de lab et de malware isolées | Depuis une VM de lab, l'hôte et le réseau local sont injoignables. La restauration de snapshot fonctionne (D-014) |
| **7. Sauvegarde et récupération** | Pouvoir perdre le disque sans rien perdre | D-019 tranchée. Exercice complet de récupération réussi en VM, en suivant README.md |
| **8. Bascule sur la vraie machine** | Ankh devient mon système | Ma distro actuelle est sauvegardée et la sauvegarde vérifiée. Installation avec LUKS. Checklist matériel validée : GPU, son, réseau, Bluetooth, veille, écrans, jeux. Une semaine d'usage sans retour arrière définitif |
| **9. Vivre avec Ankh** | Corriger selon mes vraies irritations | Plusieurs semaines d'usage. Irritations notées, puis traitées une par une. → **Ankh V1** |

**Repoussé hors V1** : multi-GPU, distribution publique, branding, ISO custom, CLI riche, rollback automatique, optimisations non motivées par l'usage réel.

**Règle de bascule** : Ankh ne remplace pas ma distro actuelle tant que la récupération (phase 7) n'a pas été testée.

---

## 6. Déroulé type d'une tâche

1. **Comprendre** : quelle phase ? quelles décisions et quels besoins sont concernés ?
2. **Vérifier** les prérequis. Il ne doit rester aucun `TODO` bloquant ni aucune décision `À DÉCIDER` nécessaire à la tâche.
3. **Proposer**, si la tâche touche l'architecture. J'arbitre, puis on écrit la décision.
4. **Réaliser** sur une branche, sans contourner les règles du §3.
5. **Vérifier** : tests, CI, VM. Noter ce qui n'a pas pu être testé.
6. **Rendre compte** (§4, « Après »). Commit et push seulement sur demande.
