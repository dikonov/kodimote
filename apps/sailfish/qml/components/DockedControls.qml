/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *            2014      Robert Meijers <robert.meijers@gmail.com>            *
 *                                                                           *
 * This file is part of Kodimote                                           *
 *                                                                           *
 * Kodimote is free software: you can redistribute it and/or modify        *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * Kodimote is distributed in the hope that it will be useful,             *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtFeedback 5.0
import harbour.kodimote 1.0

DockedPanel {
    id: panel
    property QtObject player: kodi.activePlayer
    property bool hideTemporary: false
    property bool _opened
    property bool _dialogOpen

    property int iconResize: appWindow.largeScreen? 140 : appWindow.mediumScreen ? 128 : appWindow.smallScreen ? 96 : 64
    open: player
    width: parent.width
    height: column.height + (2 * Theme.paddingLarge)
    contentHeight: height

    onPlayerChanged: {
        if (player) {
            _opened = true;
            if (!hideTemporary) {
                show(true);
            }
        } else {
            hide(true);
        }
    }

    onHideTemporaryChanged: {
        if (hideTemporary) {
            _opened = open;
            hide(true);
        } else {
            if (_opened && player) {
                show(true);
            }
        }
    }

    HapticsEffect {
        id: rumbleEffect
        intensity: 0.50
        duration: 50
    }

    Connections {
        target: Qt.inputMethod
        onVisibleChanged: {
            if (Qt.inputMethod.visible) {
                panel.hide(true);
            } else {
                if (open && !hideTemporary) {
                    panel.show(true);
                }
            }
        }
    }

    Connections {
        target: pageStack
        onCurrentPageChanged: {
            var isDialog = pageStack.currentPage.hasOwnProperty('__silica_dialog');
            if (_dialogOpen) {
                if (!isDialog && _opened && player) {
                    show();
                }
            } else if (isDialog) {
                _dialogOpen = true;
                _opened = open;
                if (open) {
                    hide();
                }
            }

            _dialogOpen = isDialog;
        }
    }

    Column {
        id: column
        width:parent.width
        height: childrenRect.height
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingMedium

        Item {
            visible: appWindow.orientation === Orientation.Portrait || appWindow.largeScreen
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }

            height: iconResize

            IconButton {
                id: volumeDownButton
                height: iconResize
                width: height
                icon.height: iconResize; icon.width: iconResize
                anchors.left: parent.left
                icon.source: "../icons/icon-m-volume-down.png"
                onClicked: {
                    if (settings.hapticsEnabled) {
                        rumbleEffect.start(2);
                    }
                    kodi.volumeDown()
                }
            }

            Slider {
                id: volumeSlider
                anchors.left: volumeDownButton.right
                anchors.right: volumeUpButton.left
                anchors.verticalCenter: parent.verticalCenter
                enabled: kodi.connectedHost.volumeControlType !== KodiHost.VolumeControlTypeRelative
                visible: enabled
                leftMargin: Theme.paddingSmall
                rightMargin: Theme.paddingLarge

                minimumValue: 0
                maximumValue: 100

                onValueChanged: {
                    kodi.volume = value
                }

                Binding {
                    target: volumeSlider
                    property: "value"
                    value: kodi.volume
                }
            }

            IconButton {
                id: volumeUpButton
                height: iconResize
                width: height
                icon.height: iconResize; icon.width: iconResize
                anchors.right: parent.right
                icon.source: "image://theme/icon-m-speaker"
                onClicked: {
                    if (settings.hapticsEnabled) {
                        rumbleEffect.start(2);
                    }
                    kodi.volumeUp()
                }
            }
        }

        PlayerControls {
            anchors.horizontalCenter: parent.horizontalCenter
            player: panel.player
        }
    }

    PushUpMenu {
        id: menu

        Row {
            spacing: Theme.itemSizeSmall
            anchors.horizontalCenter: parent.horizontalCenter
            height: childrenRect.height

            //Work around issue of the pully not being able to open
            Item {
                height: 1
                width: 1
            }

            Switch {
                icon.source: "image://theme/icon-m-shuffle"
                visible: kodi.state == "audio"
                checked: player && player.shuffle
                onClicked: player.shuffle = ! player.shuffle
            }

            Switch {
                icon.source: player && player.repeat === Player.RepeatOne ? "../icons/icon-l-repeat-one.png" : "image://theme/icon-m-repeat"
                icon.scale: player && player.repeat === Player.RepeatOne ? appWindow.sizeRatio : 1
                visible: kodi.state == "audio"
                checked: player && player.repeat !== Player.RepeatNone
                automaticCheck: false
                onClicked: {
                    if (player.repeat === Player.RepeatNone) {
                        player.repeat = Player.RepeatOne;
                    } else if (player.repeat === Player.RepeatOne) {
                        player.repeat = Player.RepeatAll;
                    } else {
                        player.repeat = Player.RepeatNone;
                    }
                }
            }

            Switch {
                icon.source: "image://theme/icon-l-speaker"
                visible: kodi.state == "video"
                checked: true
                automaticCheck: false
                onClicked: {
                    menu.active = false;
                    var component = Qt.createComponent("../pages/MediaSelectionDialog.qml");
                    if (component.status === Component.Ready) {;
                        var dialog = component.createObject(panel, {
                                                                mediaModel: player.audiostreams,
                                                                currentIndex: player.currentAudiostream
                                                            });
                        dialog.rejected.connect(function () {

                        });
                        pageStack.push(dialog);
                    }
                }
            }

            Switch {
                icon.source: "image://theme/icon-m-message"
                visible: kodi.state == "video"
                checked: player && player.currentSubtitle >= 0
                automaticCheck: false
                onClicked: {
                    menu.active = false
                    var component = Qt.createComponent("../pages/MediaSelectionDialog.qml");
                    if (component.status === Component.Ready) {
                        var dialog = component.createObject(panel, {
                                                                mediaModel: player.subtitles,
                                                                currentIndex: player.currentSubtitle,
                                                                supportsOff: true
                                                            });
                        dialog.rejected.connect(function () {
                            player.currentSubtitle = -1;
                        });
                        dialog.accepted.connect(function () {
                            player.currentSubtitle = dialog.currentIndex;
                        });
                        pageStack.push(dialog);
                    }
                }
            }
        }
    }
}
