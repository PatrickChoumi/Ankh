// D-033 : le lanceur d'applications affiche le logo d'Ankh.
// Plasma exécute ce script une seule fois par utilisateur, après la création
// du bureau ; un choix d'icône fait ensuite par l'utilisateur est respecté.
const lanceurs = ["org.kde.plasma.kickoff", "org.kde.plasma.kicker", "org.kde.plasma.kickerdash"];

panels().forEach(function (panneau) {
    panneau.widgets().forEach(function (widget) {
        if (lanceurs.indexOf(widget.type) >= 0) {
            widget.currentConfigGroup = new Array("General");
            widget.writeConfig("icon", "ankh-logo");
        }
    });
});
