/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

AbstractItem {
    id: plasmoidContainer

    property Item applet
    iconItem: applet
    text: applet ? applet.title : ""

    itemId: applet ? applet.pluginName : ""
    mainText: applet ? applet.toolTipMainText : ""
    subText: applet ? applet.toolTipSubText : ""
    icon: applet ? applet.icon : ""
    mainItem: applet && applet.toolTipItem ? applet.toolTipItem : null
    textFormat: applet ? applet.toolTipTextFormat : ""
    status: applet ? applet.status : PlasmaCore.Types.UnknownStatus
    active: root.activeApplet !== applet

    onClicked: {
        if (applet && mouse.button === Qt.LeftButton) {
            applet.expanded = true;
        }
    }
    onPressed: {
        if (mouse.button === Qt.RightButton) {
            plasmoidContainer.contextMenu(mouse);
        }
    }
    onContextMenu: {
        if (applet) {
            plasmoid.nativeInterface.showPlasmoidMenu(applet, 0, plasmoidContainer.inHiddenLayout ? applet.height : 0);
        }
    }

    onHeightChanged: {
        if (applet) {
            applet.width = Math.min(plasmoidContainer.width, plasmoidContainer.height)
            applet.height = applet.width
        }
    }
    onWidthChanged: {
        if (applet) {
            applet.width = Math.min(plasmoidContainer.width, plasmoidContainer.height)
            applet.height = applet.width
        }
    }

    //This is to make preloading effective, minimizes the scene changes
    function preloadFullRepresentationItem(fullRepresentationItem) {
        if (fullRepresentationItem && fullRepresentationItem.parent === null) {
            fullRepresentationItem.width = expandedRepresentation.width
            fullRepresentationItem.width = expandedRepresentation.height
            fullRepresentationItem.parent = preloadedStorage;
        }
    }

    onAppletChanged: {
        if (applet) {
            applet.parent = plasmoidContainer
            applet.anchors.left = plasmoidContainer.left
            applet.anchors.verticalCenter = plasmoidContainer.verticalCenter
            applet.width = Math.min(plasmoidContainer.width, plasmoidContainer.height)
            applet.height = applet.width
            applet.visible = true

            preloadFullRepresentationItem(applet.fullRepresentationItem)
        }
    }

    Connections {
        target: applet
        onActivated: plasmoidContainer.activated()

        onExpandedChanged: {
            if (expanded) {
                var oldApplet = root.activeApplet;
                root.activeApplet = applet;
                if (oldApplet && oldApplet !== applet) {
                    oldApplet.expanded = false;
                }
                dialog.visible = true;
                plasmoidContainer.activated()

            } else if (root.activeApplet === applet) {
                if (!inHiddenLayout) {
                    dialog.visible = false;
                }
                //if not expanded we don't have an active applet anymore
                root.activeApplet = null;
            }
        }

        onFullRepresentationItemChanged: {
            preloadFullRepresentationItem(fullRepresentationItem)
        }
    }
}
