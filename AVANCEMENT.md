# AVANCEMENT — Ce qui est fait, ce qui reste

> Mis à jour à chaque compte rendu (D-029). Dernière mise à jour : **2026-10-08**.
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
  - Ce travail est dans la [PR #4](https://github.com/PatrickChoumi/Ankh/pull/4), en cours de vérification par la CI.
- **Ce document d'avancement** (D-029).

---

## Ce qui reste à faire

### Phase 3 — Applications et dev (en cours)

1. **Discover** (D-028) : PR #4 à faire passer au vert puis à fusionner. L'affichage à l'écran sera à vérifier.
2. **Chrome** (D-023) :
   - installer Chrome dans l'image (cas particulier de `/opt` sur une image bootc) ;
   - en faire le navigateur par défaut ;
   - retirer Firefox ;
   - reconstruire l'image régulièrement pour suivre les mises à jour de Chrome.
3. **Applications par défaut** (D-024) :
   - VLC et OnlyOffice en Flatpak, préinstallés ;
   - Claude et GitHub en applications web dans Chrome.
4. **VS Code et le conteneur dev** (D-012) : l'outil exact est encore à décider.
5. **Critère de fin** : tout cela testé en CI et en VM cloud, et le quotidien faisable sans terminal.

### Phases suivantes

- **Phase 4 — Protection** : concevoir puis intégrer safezone dans Ankh (D-026). Il faudra traiter le basculement d'image, le retour arrière et `/etc`.
- **Phases 5 à 7 — Gaming, Cyber, Labs** : elles demandent mes réponses aux questions matérielles Q1 à Q11 (ANKH-SPEC.md §6).
- **Phase 8 — Sauvegarde et récupération** : trancher D-019, puis réussir un exercice complet en VM.
- **Phase 9 — Ma vraie machine** :
  - sauvegarder ma distro actuelle ;
  - installer Ankh avec LUKS ;
  - valider le matériel (GPU, son, réseau, veille, écrans, jeux, filtrage) ;
  - utiliser Ankh une semaine.
- **Phase 10 — Vivre avec Ankh** : corriger les irritations, mesurer la taille réelle des mises à jour, puis sortir la V1.

### Points à vérifier (À VALIDER)

- **Renovate** : installé selon moi, mais aucune activité sur le dépôt, alors qu'une base plus récente existe depuis le 2026-10-02.
- **Signature** : l'imposer sur ma machine (D-022). Le test en VM n'a montré aucune vérification de signature au basculement.
- **Discover** : la notification et l'affichage des mises à jour, à l'écran (D-028).
- **mcelog** : son comportement sur ma vraie machine (phase 9).
- **Variante NVIDIA** : elle ne se teste pas en VM, seulement par des contrôles statiques en CI.

---

## Ce que je dois faire

1. **Renovate** : ouvrir <https://developer.mend.io/github/PatrickChoumi/Ankh> (connexion avec GitHub) et regarder les journaux. S'il n'y a rien, vérifier sur <https://github.com/settings/installations> que Renovate a bien accès au dépôt **Ankh**.
2. **Fusionner la PR #4** quand sa CI sera verte.
3. **Optionnel** : rendre obligatoire le test « Démarrer ankh en VM » dans `protection-main`. Claude doit d'abord retirer le filtre qui saute ce test sur les PR qui ne touchent que la documentation.
4. **Avant la phase 5** : répondre aux questions matérielles Q1 à Q11 de ANKH-SPEC.md.
