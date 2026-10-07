# Ankh

**Mon OS personnel immuable pour coder, jouer et faire de la cybersécurité.** Il est générique (le maximum de PC) et s'appuie sur l'isolation forte, la virtualisation et le retour arrière.

> **État actuel : phases 1 et 2 terminées, phase 3 (applications et dev) à venir.** Les images sont construites, signées et publiées par la CI. Elles démarrent en VM, et le retour arrière y fonctionne (D-004).
> Les procédures de récupération décrites ici sont des **cibles** : aucune n'a encore été testée sur une vraie machine.

## Ce qu'est Ankh

- Mon système **personnel**, en image **générique** : il doit fonctionner sur le maximum de PC x86_64 sans réglage propre à une machine (D-001, D-021).
- Un système **image-based** : l'OS est une image immuable, mise à jour d'un bloc, avec retour à la version précédente (D-004).
- Un hôte minimal et protégé : Secure Boot (D-006), chiffrement LUKS (D-007), aucune sécurité désactivée pour faire marcher un outil (D-008).

## Ce qu'Ankh n'est pas

- Pas une distribution publique ni un produit : pas d'utilisateurs à servir, pas de support.
- Pas de branding ni d'ISO custom en V1.
- Pas un hôte où l'on installe des outils offensifs ou où l'on manipule du malware.

La liste complète est dans [ANKH-SPEC.md, section 5](ANKH-SPEC.md#5-ce-que-je-ne-veux-pas).

## Architecture générale (envisagée)

```text
┌────────────────────────────────────────────────────────────┐
│ Applications : Flatpak (Steam, navigateur, …)        D-011 │
├────────────────────┬────────────────────┬──────────────────┤
│ Dev                │ Cyber              │ Labs / malware   │
│ conteneur          │ Kali, Podman       │ VMs isolées      │
│ D-012              │ rootless   D-013   │ libvirt/KVM D-014│
├────────────────────┴────────────────────┴──────────────────┤
│ Hôte immuable : Fedora Kinoite / Atomic + bootc      D-004 │
│ Base : kinoite-main / kinoite-nvidia, Fedora 44      D-005 │
├────────────────────────────────────────────────────────────┤
│ Secure Boot (D-006) · LUKS (D-007)                         │
└────────────────────────────────────────────────────────────┘
```

Règle de placement :
- **Dans l'image** : seulement ce qui doit faire partie du système.
- **En Flatpak** : les applications.
- **En conteneur** : le dev et les outils cyber.
- **En VM** : tout ce qui est dangereux ou non fiable.

Rien ne s'installe sur l'hôte en dehors de l'image (D-009).

## Récupération après une panne

| Situation | Action prévue | Statut |
|---|---|---|
| Une mise à jour casse quelque chose | `sudo bootc rollback` puis redémarrer, ou choisir l'entrée précédente dans le menu de démarrage | `bootc rollback` vérifié en VM (D-004) ; menu de démarrage et vraie machine À VALIDER |
| L'image Ankh elle-même est défectueuse | `sudo bootc switch` vers l'image de base (D-005), sans réinstaller | Vérifié en VM (D-004) ; vraie machine À VALIDER |
| Disque perdu ou réinstallation complète | Procédure ci-dessous | À CONSTRUIRE puis TESTER |
| Compte GitHub ou registre d'images inaccessible | Copie de la dernière image saine sur le support de sauvegarde | PROPOSÉ (D-019) |

### Réinstallation complète (ordre cible, D-019)

1. Réinstaller Fedora Atomic (Kinoite) avec le chiffrement LUKS activé.
2. Basculer sur l'image Ankh avec `bootc switch` (D-018) : `ghcr.io/patrickchoumi/ankh:latest` (AMD, Intel) ou `ghcr.io/patrickchoumi/ankh-nvidia:latest` (NVIDIA récent). Les tags datés `AAAAMMJJ` permettent de revenir à une version précise.
3. Restaurer les **secrets** depuis la sauvegarde chiffrée. C'est nécessaire avant de cloner des dépôts privés.
4. Cloner ce dépôt : il contient la configuration.
5. Recréer les applications Flatpak, les conteneurs et les VMs depuis les définitions du dépôt. Les recettes `just` sont à construire (D-015).
6. Restaurer les données.

Cette procédure ne sera considérée comme valide qu'après un exercice complet réussi en VM (D-016, D-019).

## Documents

- [ANKH-SPEC.md](ANKH-SPEC.md) : ce que je fais avec ma machine, les questions ouvertes, la liste de ce que je ne veux pas.
- [DECISIONS.md](DECISIONS.md) : chaque choix, avec ses raisons, ses alternatives rejetées et sa source ou son test.
- [CLAUDE.md](CLAUDE.md) : guide de travail du projet (règles, méthode, feuille de route, état actuel) (D-020).

**Règle** : ce dépôt est la source de vérité. Toute affirmation technique importante doit être appuyée par une documentation officielle, un test reproductible ou une expérience réelle sur la machine. Sinon, elle est marquée `À VALIDER` (D-016).
