/*
    SPDX-License-Identifier: GPL-2.0-or-later

    Écran de connexion d'Ankh pour SDDM (D-043). Dessiné pour Ankh, d'après
    les principes retenus dans D-042 : fond flouté (comme l'écran de
    connexion de Windows 11), grande horloge, image du compte dans un cercle,
    champ de mot de passe arrondi avec le focus en violet, boutons
    translucides, mouvements brefs et utiles.

    Interface de SDDM utilisée (docs/THEMING.md et src/greeter de
    https://github.com/sddm/sddm, version 0.21.0) : l'objet « sddm »
    (login, powerOff, reboot, suspend, signaux loginFailed et
    loginSucceeded), les modèles « userModel » (name, realName, icon,
    needsPassword, lastIndex) et « sessionModel » (name, lastIndex),
    « keyboard » (capsLock, layouts, currentLayout), « config » (theme.conf)
    et « primaryScreen ».
*/

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: racine

    width: 1280
    height: 800
    color: "#0d1117"

    // Couleurs d'Ankh (Ankh.colors)
    readonly property color texte: "#e6edf3"
    readonly property color texteDiscret: Qt.rgba(230 / 255, 237 / 255, 243 / 255, 0.70)
    readonly property color violet: "#a78bfa"
    readonly property color violetPlein: "#8455f0"
    readonly property color erreur: "#f85149"
    readonly property string police: "Inter"
    // Tailles proportionnelles à la hauteur de l'écran (800 pixels de référence)
    readonly property real k: Math.max(0.75, height / 800)

    property int indexSession: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool connexionEnCours: false

    // Compte choisi : celui de la dernière connexion, sinon le premier. Ses
    // valeurs sont recopiées ici par son élément dans la rangée des comptes.
    property int indexCompte: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string compteNom: ""
    property string compteNomAffiche: ""
    property string compteImage: ""
    property bool compteMotDePasse: true
    property string nomSession: ""

    function seConnecter() {
        if (compteNom.length === 0 || connexionEnCours) {
            return;
        }
        message.text = "";
        connexionEnCours = true;
        sddm.login(compteNom, motDePasse.text, indexSession);
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            racine.connexionEnCours = false;
            motDePasse.text = "";
            message.text = "Mot de passe incorrect";
            secousse.restart();
            motDePasse.forceActiveFocus();
        }
        function onLoginSucceeded() {
            disparition.start();
        }
        function onInformationMessage(texte) {
            message.text = texte;
        }
    }

    // Fond : « Ankh Signal » flouté et assombri, préparé une fois pour toutes
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
    }
    // Voile qui assombrit le bas de l'écran, pour la lisibilité
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(13 / 255, 17 / 255, 23 / 255, 0.15) }
            GradientStop { position: 1.0; color: Qt.rgba(13 / 255, 17 / 255, 23 / 255, 0.55) }
        }
    }

    // Tout le contenu apparaît en fondu, avec un léger glissement
    Item {
        id: contenu
        anchors.fill: parent
        visible: primaryScreen
        opacity: 0
        transform: Translate { id: glissement; y: 12 * racine.k }

        Component.onCompleted: {
            apparition.start();
            // Le mot de passe se tape tout de suite, sans clic
            motDePasse.forceActiveFocus();
        }

        ParallelAnimation {
            id: apparition
            NumberAnimation { target: contenu; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
            NumberAnimation { target: glissement; property: "y"; to: 0; duration: 450; easing.type: Easing.OutCubic }
        }
        NumberAnimation {
            id: disparition
            target: contenu; property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic
        }

        // Horloge et date
        Column {
            id: horloge
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.09
            spacing: 2 * racine.k

            property date maintenant: new Date()
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: horloge.maintenant = new Date()
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(horloge.maintenant, "HH:mm")
                color: racine.texte
                font.family: racine.police
                font.pixelSize: 96 * racine.k
                font.weight: Font.DemiBold
                font.letterSpacing: -2 * racine.k
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    // En français, comme tous les textes de cet écran, quelle
                    // que soit la langue du système (la VM de test est en anglais).
                    const jour = horloge.maintenant.toLocaleDateString(Qt.locale("fr_FR"), "dddd d MMMM");
                    return jour.charAt(0).toUpperCase() + jour.slice(1);
                }
                color: racine.texteDiscret
                font.family: racine.police
                font.pixelSize: 22 * racine.k
                font.weight: Font.Medium
            }
        }

        // Compte, nom et mot de passe, au centre
        Column {
            id: carte
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.height * 0.08
            spacing: 14 * racine.k
            transform: Translate { id: decalage }

            // Image du compte, dans un cercle (celle d'Ankh par défaut :
            // faces/.face.icon de ce thème, lu par UserModel.cpp de SDDM)
            Kirigami.ShadowedImage {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 112 * racine.k
                height: width
                radius: width / 2
                source: racine.compteImage
                sourceSize.width: width * 2
                sourceSize.height: height * 2
                fillMode: Image.PreserveAspectCrop
                color: "#161b22"
                border.width: 2
                border.color: motDePasse.activeFocus ? Qt.rgba(167 / 255, 139 / 255, 250 / 255, 0.85) : Qt.rgba(1, 1, 1, 0.18)
                shadow.size: 24 * racine.k
                shadow.color: Qt.rgba(0, 0, 0, 0.45)
                shadow.yOffset: 4 * racine.k
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: racine.compteNomAffiche
                color: racine.texte
                font.family: racine.police
                font.pixelSize: 24 * racine.k
                font.weight: Font.DemiBold
            }

            // Champ du mot de passe, en forme de pilule, avec la flèche pour se connecter
            Rectangle {
                id: champ
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300 * racine.k
                height: 44 * racine.k
                radius: height / 2
                visible: racine.compteMotDePasse
                color: Qt.rgba(1, 1, 1, motDePasse.activeFocus ? 0.14 : 0.10)
                border.width: motDePasse.activeFocus ? 2 : 1
                border.color: motDePasse.activeFocus ? racine.violet : Qt.rgba(1, 1, 1, 0.20)
                Behavior on color { ColorAnimation { duration: 200 } }

                TextInput {
                    id: motDePasse
                    anchors.left: parent.left
                    anchors.right: fleche.left
                    anchors.leftMargin: 18 * racine.k
                    anchors.rightMargin: 8 * racine.k
                    anchors.verticalCenter: parent.verticalCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    color: racine.texte
                    selectionColor: racine.violetPlein
                    font.family: racine.police
                    font.pixelSize: 16 * racine.k
                    clip: true
                    focus: true
                    enabled: !racine.connexionEnCours
                    onAccepted: racine.seConnecter()
                    Keys.onEscapePressed: text = ""

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: motDePasse.text.length === 0
                        text: "Mot de passe"
                        color: Qt.rgba(230 / 255, 237 / 255, 243 / 255, 0.50)
                        font: motDePasse.font
                    }
                }

                // Bouton rond, violet, pour se connecter
                Rectangle {
                    id: fleche
                    anchors.right: parent.right
                    anchors.rightMargin: 6 * racine.k
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 12 * racine.k
                    height: width
                    radius: width / 2
                    color: zoneFleche.containsMouse ? racine.violet : racine.violetPlein
                    opacity: motDePasse.text.length > 0 || racine.connexionEnCours ? 1 : 0.45
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: width
                        source: "go-next"
                        isMask: true
                        color: "#ffffff"
                    }

                    // Pendant la connexion, le bouton respire
                    SequentialAnimation on scale {
                        running: racine.connexionEnCours
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.85; duration: 400; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        id: zoneFleche
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: racine.seConnecter()
                    }
                }
            }

            // Compte sans mot de passe : un bouton pour entrer
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !champ.visible
                width: 160 * racine.k
                height: 44 * racine.k
                radius: height / 2
                color: zoneEntrer.containsMouse ? racine.violet : racine.violetPlein
                Text {
                    anchors.centerIn: parent
                    text: "Se connecter"
                    color: "#ffffff"
                    font.family: racine.police
                    font.pixelSize: 16 * racine.k
                    font.weight: Font.DemiBold
                }
                MouseArea {
                    id: zoneEntrer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: racine.seConnecter()
                }
            }

            // Erreur, ou touche Verr. Maj activée. Largeur fixe : un Column ne
            // place pas un élément de largeur nulle (texte vide), et la carte
            // remontait d'un coup à l'apparition du message (captures de la VM).
            Text {
                id: message
                anchors.horizontalCenter: parent.horizontalCenter
                width: 360 * racine.k
                height: 20 * racine.k
                horizontalAlignment: Text.AlignHCenter
                text: ""
                color: racine.erreur
                font.family: racine.police
                font.pixelSize: 14 * racine.k
                font.weight: Font.Medium
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: message.text.length === 0 && keyboard.capsLock
                    text: "Verr. Maj est activé"
                    color: racine.texteDiscret
                    font: message.font
                }
            }

            // Secousse du champ quand le mot de passe est faux
            SequentialAnimation {
                id: secousse
                NumberAnimation { target: decalage; property: "x"; to: -14 * racine.k; duration: 50 }
                NumberAnimation { target: decalage; property: "x"; to: 12 * racine.k; duration: 70 }
                NumberAnimation { target: decalage; property: "x"; to: -8 * racine.k; duration: 60 }
                NumberAnimation { target: decalage; property: "x"; to: 5 * racine.k; duration: 50 }
                NumberAnimation { target: decalage; property: "x"; to: 0; duration: 40 }
            }
        }

        // Comptes de la machine : une rangée de petites images, visible
        // seulement s'il y en a plusieurs. Chaque élément existe toujours :
        // celui du compte choisi recopie ses valeurs dans « racine ».
        Row {
            id: rangeeComptes
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: carte.bottom
            anchors.topMargin: 28 * racine.k
            spacing: 20 * racine.k
            visible: repetiteurComptes.count > 1

            Repeater {
                id: repetiteurComptes
                model: userModel

                delegate: Item {
                    id: element
                    required property int index
                    required property string name
                    required property string realName
                    required property string icon
                    required property bool needsPassword

                    readonly property string nomAffiche: realName.length > 0 ? realName : name
                    readonly property bool choisi: index === racine.indexCompte

                    width: 64 * racine.k
                    height: 78 * racine.k

                    Binding { target: racine; property: "compteNom"; value: element.name; when: element.choisi; restoreMode: Binding.RestoreNone }
                    Binding { target: racine; property: "compteNomAffiche"; value: element.nomAffiche; when: element.choisi; restoreMode: Binding.RestoreNone }
                    Binding { target: racine; property: "compteImage"; value: element.icon; when: element.choisi; restoreMode: Binding.RestoreNone }
                    Binding { target: racine; property: "compteMotDePasse"; value: element.needsPassword; when: element.choisi; restoreMode: Binding.RestoreNone }

                    Kirigami.ShadowedImage {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 44 * racine.k
                        height: width
                        radius: width / 2
                        source: element.icon
                        sourceSize.width: width * 2
                        sourceSize.height: height * 2
                        fillMode: Image.PreserveAspectCrop
                        color: "#161b22"
                        border.width: 2
                        border.color: element.choisi ? racine.violet : Qt.rgba(1, 1, 1, 0.18)
                        opacity: element.choisi || zoneCompte.containsMouse ? 1 : 0.65
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: parent.width + 16 * racine.k
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: element.nomAffiche
                        color: element.choisi ? racine.texte : racine.texteDiscret
                        font.family: racine.police
                        font.pixelSize: 12 * racine.k
                    }
                    MouseArea {
                        id: zoneCompte
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            racine.indexCompte = element.index;
                            motDePasse.text = "";
                            message.text = "";
                            motDePasse.forceActiveFocus();
                        }
                    }
                }
            }
        }

        // En bas à gauche : session et disposition du clavier, s'il y a le choix
        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 24 * racine.k
            spacing: 12 * racine.k

            BoutonTexte {
                visible: repetiteurSessions.count > 1
                texte: "Session : " + racine.nomSession
                onActive: racine.indexSession = (racine.indexSession + 1) % repetiteurSessions.count
            }
            BoutonTexte {
                visible: keyboard.layouts.length > 1
                texte: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : ""
                onActive: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
            }
        }
        // Nom de la session choisie, lu dans le modèle des sessions
        Repeater {
            id: repetiteurSessions
            model: sessionModel
            delegate: Item {
                id: session
                required property int index
                required property string name
                Binding { target: racine; property: "nomSession"; value: session.name; when: session.index === racine.indexSession; restoreMode: Binding.RestoreNone }
            }
        }

        // En bas à droite : veille, redémarrer, éteindre
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 24 * racine.k
            spacing: 16 * racine.k

            BoutonRond { visible: sddm.canSuspend; icone: "system-suspend"; libelle: "Veille"; onActive: sddm.suspend() }
            BoutonRond { visible: sddm.canReboot; icone: "system-reboot"; libelle: "Redémarrer"; onActive: sddm.reboot() }
            BoutonRond { visible: sddm.canPowerOff; icone: "system-shutdown"; libelle: "Éteindre"; onActive: sddm.powerOff() }
        }
    }

    // Bouton rond translucide, avec son nom dessous
    component BoutonRond: Column {
        id: bouton
        property string icone
        property string libelle
        signal active()
        spacing: 6 * racine.k

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 46 * racine.k
            height: width
            radius: width / 2
            color: Qt.rgba(1, 1, 1, zoneBouton.pressed ? 0.24 : zoneBouton.containsMouse ? 0.18 : 0.10)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)
            Behavior on color { ColorAnimation { duration: 150 } }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: parent.width * 0.48
                height: width
                source: bouton.icone
                isMask: true
                color: racine.texte
            }
            MouseArea {
                id: zoneBouton
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bouton.active()
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: bouton.libelle
            color: racine.texteDiscret
            font.family: racine.police
            font.pixelSize: 12 * racine.k
        }
    }

    // Petit bouton texte translucide, en pilule
    component BoutonTexte: Rectangle {
        id: boutonTexte
        property string texte
        signal active()
        width: etiquette.implicitWidth + 28 * racine.k
        height: 34 * racine.k
        radius: height / 2
        color: Qt.rgba(1, 1, 1, zoneTexte.containsMouse ? 0.18 : 0.10)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.16)
        Text {
            id: etiquette
            anchors.centerIn: parent
            text: boutonTexte.texte
            color: racine.texte
            font.family: racine.police
            font.pixelSize: 13 * racine.k
            font.weight: Font.Medium
        }
        MouseArea {
            id: zoneTexte
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: boutonTexte.active()
        }
    }
}
