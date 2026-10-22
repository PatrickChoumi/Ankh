// D-033 : le lanceur d'applications affiche le logo d'Ankh.
// Plasma exécute ce script une seule fois par utilisateur, après la création
// du bureau ; un choix d'icône fait ensuite par l'utilisateur est respecté.
// Depuis le lot 5 de D-052, la barre d'Ankh porte le Démarrer d'Ankh
// (org.ankh.demarrer), dont l'icône est déjà le logo par défaut
// (contents/config/main.xml) ; Kickoff, Kicker et le tableau de bord de KDE
// le reçoivent aussi s'ils sont dans une disposition.
const lanceurs = ["org.ankh.demarrer", "org.kde.plasma.kickoff", "org.kde.plasma.kicker", "org.kde.plasma.kickerdash"];

panels().forEach(function (panneau) {
    panneau.widgets().forEach(function (widget) {
        if (lanceurs.indexOf(widget.type) >= 0) {
            widget.currentConfigGroup = new Array("General");
            widget.writeConfig("icon", "ankh-logo");
        }
    });
});
