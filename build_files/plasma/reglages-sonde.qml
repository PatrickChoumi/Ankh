// Sonde des paramètres rapides d'Ankh (D-052, lot 6a), lancée hors écran à
// la construction par verifier-reglages.sh, à côté d'une copie du paquet
// (dossier « paquet »). Elle crée le vrai état (Etat.qml : modules de
// plasma-nm, plasma-pa, bluedevil, powerdevil et plasma-workspace), le
// bouton de la barre et le volet entier, ouvre chacune de ses pages, puis
// vérifie les rôles des modèles dont les pages se servent. Une propriété, un
// type ou un module disparu fait échouer le chargement ; un rôle disparu ou
// une valeur d'énumération disparue ne donne qu'un avertissement, que la
// sonde ou le script refusent. Les messages passent par console.warn :
// console.log est filtré par Qt de Fedora.

import QtQuick

import org.kde.bluezqt as BluezQt
import org.kde.kitemmodels as KItemModels

import "paquet/contents/ui" as Ankh

Item {
    id: sonde

    property var erreurs: []
    property int etape: 0

    width: 372
    height: 800

    function exiger(condition: bool, message: string): void {
        if (!condition) {
            erreurs.push(message);
        }
    }

    function exigerRoles(modele: QtObject, nom: string, roles: var): void {
        for (const role of roles) {
            exiger(modele !== null && modele.KItemModels.KRoleNames.role(role) >= 0, "rôle « " + role + " » absent de " + nom);
        }
    }

    Ankh.Etat {
        id: etat
    }

    Ankh.Bouton {
        id: bouton
        height: 48
        etat: etat
    }

    Ankh.Volet {
        id: volet
        y: 48
        etat: etat
    }

    BluezQt.DevicesModel {
        id: appareils
    }

    // Une page par étape, puis les vérifications
    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            const pages = ["wifi", "bluetooth", "son", "accueil"];
            if (sonde.etape < pages.length) {
                volet.page = pages[sonde.etape];
                sonde.etape++;
                return;
            }
            stop();
            sonde.verifier();
        }
    }

    function verifier(): void {
        // Fonctions de l'état, appelées par les tuiles et les curseurs
        for (const fonction of ["basculerWifi", "basculerAvion", "basculerBt", "basculerMuet", "regler", "reglerLuminosite",
                                "basculerNuit", "basculerSombre", "basculerEconomie", "basculerNePasDeranger", "ouvrir",
                                "chercherReseaux", "connecter", "connecterNouveau", "deconnecter"]) {
            exiger(typeof etat[fonction] === "function", "Etat." + fonction + "() absente");
        }
        // Rôles des modèles des pages
        exigerRoles(etat.reseaux, "AppletProxyModel (plasma-nm)", ["ItemUniqueName", "ConnectionIcon", "ConnectionState",
            "SecurityType", "Uuid", "Type", "ConnectionPath", "DevicePath", "SpecificPath"]);
        exigerRoles(etat.sorties, "SinkModel (plasma-pa)", ["PulseObject", "Description", "IconName"]);
        exigerRoles(appareils, "DevicesModel (bluez-qt)", ["Name", "Icon", "Connected", "Paired", "Device"]);
        // Le volet et le bouton ont leur taille
        exiger(volet.width === 372 - 8 && volet.height === volet.hauteurVisible - 8 && volet.tuiles.length >= 2,
            "volet de " + volet.width + "×" + volet.height + " (" + volet.tuiles.length + " tuiles)");
        exiger(bouton.implicitWidth >= 40 + 2 * 16, "bouton de " + bouton.implicitWidth + " de large");
        exiger(volet.page === "accueil", "le volet n'est pas revenu à l'accueil");

        if (erreurs.length > 0) {
            for (const erreur of erreurs) {
                console.warn("SONDE ÉCHEC : " + erreur);
            }
            Qt.exit(1);
        } else {
            console.warn("SONDE OK : volet " + volet.width + "×" + volet.height + ", bouton " + bouton.implicitWidth
                + ", tuiles " + volet.tuiles.length);
            Qt.exit(0);
        }
    }
}
