// Sonde de l'horloge d'Ankh (D-052, lot 6b), lancée hors écran à la
// construction par verifier-reglages.sh, à côté d'une copie du paquet
// (dossier « paquet »). Elle crée l'horloge de la barre et son volet
// (notifications et calendrier, avec les vrais modules de plasma-workspace),
// puis vérifie les rôles, énumérations, propriétés et fonctions dont ils se
// servent : un rôle, une valeur d'énumération ou une fonction disparus ne
// donnent qu'un avertissement, ou rien, au lieu d'une erreur de chargement.
// Les messages passent par console.warn : console.log est filtré par Qt de
// Fedora.

import QtQuick

import org.kde.kitemmodels as KItemModels
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.workspace.calendar as PlasmaCalendar

import "paquet/contents/ui" as Ankh

Item {
    id: sonde

    property var erreurs: []

    width: 364
    height: 1000

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

    Ankh.Horloge {
        id: horloge
        height: 48
        nePasDeranger: true
    }

    Ankh.Centre {
        id: centre
        y: 48
    }

    NotificationManager.Notifications {
        id: notifications
    }

    NotificationManager.Settings {
        id: reglages
    }

    PlasmaCalendar.Calendar {
        id: calendrier
        days: 7
        weeks: 6
        today: new Date()
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: sonde.verifier()
    }

    function verifier(): void {
        // Rôles lus par les cartes de notification et les cases du calendrier
        exigerRoles(notifications, "Notifications (notificationmanager)", ["summary", "body", "applicationName",
            "applicationIconName", "created", "hasDefaultAction", "closable"]);
        exigerRoles(calendrier.daysModel, "DaysModel (calendrier de Plasma)", ["dayNumber", "monthNumber", "yearNumber"]);

        // Énumérations : une valeur disparue vaudrait undefined, sans erreur
        for (const nom of ["ClearExpired", "ClosableRole", "ExpiredRole", "Close", "SortByDate", "GroupDisabled",
                           "CriticalUrgency", "NormalUrgency", "LowUrgency"]) {
            exiger(typeof NotificationManager.Notifications[nom] === "number", "NotificationManager.Notifications." + nom + " absente");
        }

        // Propriétés et fonctions : Ne pas déranger, listes d'exclusion, historique, calendrier
        for (const propriete of ["notificationsInhibitedUntil", "notificationsInhibitedByApplication",
                                 "historyBlacklistedApplications", "historyBlacklistedServices", "lowPriorityHistory"]) {
            exiger(reglages[propriete] !== undefined, "NotificationManager.Settings." + propriete + " absente");
        }
        for (const fonction of ["revokeApplicationInhibitions", "save"]) {
            exiger(typeof reglages[fonction] === "function", "NotificationManager.Settings." + fonction + "() absente");
        }
        for (const fonction of ["clear", "close", "invokeDefaultAction", "index", "data"]) {
            exiger(typeof notifications[fonction] === "function", "NotificationManager.Notifications." + fonction + "() absente");
        }
        exiger(notifications.count !== undefined, "NotificationManager.Notifications.count absente");
        for (const fonction of ["resetToToday", "nextMonth", "previousMonth"]) {
            exiger(typeof calendrier[fonction] === "function", "PlasmaCalendar.Calendar." + fonction + "() absente");
        }
        exiger(calendrier.displayedDate instanceof Date && !isNaN(calendrier.displayedDate.getTime()),
            "PlasmaCalendar.Calendar.displayedDate absente");

        // Fonctions du volet, appelées par main.qml et les boutons
        for (const fonction of ["toutEffacer", "revenirAujourdhui"]) {
            exiger(typeof centre[fonction] === "function", "Centre." + fonction + "() absente");
        }
        if (typeof centre.toutEffacer === "function" && typeof centre.revenirAujourdhui === "function") {
            centre.toutEffacer();
            centre.revenirAujourdhui();
        }

        // Le volet et l'horloge ont leur taille
        exiger(centre.width === 364 - 8 && centre.height === centre.hauteurVisible - 8,
            "volet de " + centre.width + "×" + centre.height);
        exiger(horloge.implicitWidth >= 16 + 8 + 2 * 12 + 20, "horloge de " + horloge.implicitWidth + " de large");

        if (erreurs.length > 0) {
            for (const erreur of erreurs) {
                console.warn("SONDE ÉCHEC : " + erreur);
            }
            Qt.exit(1);
        } else {
            console.warn("SONDE OK : volet " + centre.width + "×" + centre.height + ", horloge " + horloge.implicitWidth);
            Qt.exit(0);
        }
    }
}
