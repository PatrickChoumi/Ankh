# Style des contrôles d'Ankh (D-052, lot 3), dérivé de celui de Breeze 6.7.5
# (kstyle/, libbreezecommon/ et kdecoration/breezesettingsdata.kcfg de
# https://invent.kde.org/plasma/breeze, tag v6.7.5). Tout ce qui portait le
# nom de Breeze porte celui d'Ankh, pour que les deux styles puissent être
# chargés ensemble (aperçus de la page « Style des applications ») ; seules
# les propriétés « _breeze_… » posées par les applications de KDE gardent
# leur nom. Sans le module de réglages de Breeze. Compilé dans l'étape
# « outils » du Containerfile (build_files/outils.sh) ; seul le greffon
# ankh6.so entre dans l'image.
cmake_minimum_required(VERSION 3.22)
project(ankh-style LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Mêmes réglages du compilateur que Breeze (son CMakeLists.txt)
set(KDE_COMPILERSETTINGS_LEVEL "5.82")
find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQtDeclareLoggingCategory)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Widgets DBus Quick)
find_package(KF6 6.0 REQUIRED COMPONENTS ColorScheme Config CoreAddons GuiAddons IconThemes WindowSystem FrameworkIntegration)

set(ANKH_HAVE_QTQUICK 1)
set(ANKH_HAVE_KSTYLE 1)
set(HAVE_QTDBUS 1)
configure_file(config-ankh.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-ankh.h)

include_directories(animations debug ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

set(ankh_SRCS
    animations/ankhanimation.cpp
    animations/ankhanimations.cpp
    animations/ankhanimationdata.cpp
    animations/ankhbaseengine.cpp
    animations/ankhbusyindicatordata.cpp
    animations/ankhbusyindicatorengine.cpp
    animations/ankhdialdata.cpp
    animations/ankhdialengine.cpp
    animations/ankhenabledata.cpp
    animations/ankhgenericdata.cpp
    animations/ankhheaderviewdata.cpp
    animations/ankhheaderviewengine.cpp
    animations/ankhscrollbardata.cpp
    animations/ankhscrollbarengine.cpp
    animations/ankhspinboxengine.cpp
    animations/ankhspinboxdata.cpp
    animations/ankhstackedwidgetdata.cpp
    animations/ankhstackedwidgetengine.cpp
    animations/ankhtabbarengine.cpp
    animations/ankhtabbardata.cpp
    animations/ankhtoolboxengine.cpp
    animations/ankhtransitiondata.cpp
    animations/ankhtransitionwidget.cpp
    animations/ankhwidgetstateengine.cpp
    animations/ankhwidgetstatedata.cpp
    debug/ankhwidgetexplorer.cpp
    ankhaddeventfilter.cpp
    ankhblurhelper.cpp
    ankhboxshadowrenderer.cpp
    ankhframeshadow.cpp
    ankhhelper.cpp
    ankhmdiwindowshadow.cpp
    ankhmnemonics.cpp
    ankhpropertynames.cpp
    ankhshadowhelper.cpp
    ankhsplitterproxy.cpp
    ankhstyle.cpp
    ankhstyleplugin.cpp
    ankhtileset.cpp
    ankhwindowmanager.cpp
    ankhtoolsareamanager.cpp
)
kconfig_add_kcfg_files(ankh_SRCS ankhsettings.kcfgc)
kconfig_add_kcfg_files(ankh_SRCS ankhstyleconfigdata.kcfgc)

add_library(ankh6 MODULE ${ankh_SRCS})
ecm_qt_declare_logging_category(ankh6
    HEADER ankh_logging.h
    IDENTIFIER ANKH
    CATEGORY_NAME ankh6
    DEFAULT_SEVERITY Warning
)
target_link_libraries(ankh6
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::DBus
        Qt6::Quick
        KF6::ColorScheme
        KF6::ConfigCore
        KF6::ConfigGui
        KF6::CoreAddons
        KF6::GuiAddons
        KF6::IconThemes
        KF6::WindowSystem
        KF6::Style
)

install(TARGETS ankh6 DESTINATION ${KDE_INSTALL_QTPLUGINDIR}/styles/)
install(FILES ankh.themerc DESTINATION ${KDE_INSTALL_DATADIR}/kstyle/themes)
