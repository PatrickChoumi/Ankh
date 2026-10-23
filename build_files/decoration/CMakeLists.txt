# Décoration des fenêtres d'Ankh (D-052, lot 2), dérivée de celle de Breeze
# 6.7.5 (kdecoration/ et libbreezecommon/ de https://invent.kde.org/plasma/breeze).
# Compilée dans l'étape « outils » du Containerfile (build_files/outils.sh) ;
# seul le greffon org.ankh.decoration.so entre dans l'image.
cmake_minimum_required(VERSION 3.22)
project(ankh-decoration LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui DBus)
find_package(KF6 6.0 REQUIRED COMPONENTS ColorScheme Config CoreAddons GuiAddons IconThemes)
find_package(KDecoration3 REQUIRED)

add_library(ankhdecoration MODULE ankhdecoration.cpp ankhbouton.cpp ankhombre.cpp)
set_target_properties(ankhdecoration PROPERTIES OUTPUT_NAME org.ankh.decoration)
target_link_libraries(ankhdecoration
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::DBus
        KF6::ColorScheme
        KF6::ConfigCore
        KF6::ConfigGui
        KF6::CoreAddons
        KF6::GuiAddons
        KF6::IconThemes
        KDecoration3::KDecoration
)

install(TARGETS ankhdecoration DESTINATION ${KDE_INSTALL_PLUGINDIR}/${KDECORATION_PLUGIN_DIR})
