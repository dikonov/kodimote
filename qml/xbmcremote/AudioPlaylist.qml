import QtQuick 1.0

Item {
    id: playlist
    anchors.fill: parent
    property alias model: list.model

    signal closePlaylist

    Image {
        id: header
        anchors.left: parent.left
        anchors.top: parent.top
        height: 60
        source: "images/header.png"

        Text {
            anchors.fill: parent
            anchors.margins: 10
            text: "Now Playing - Playlist"
            color: "white"
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter

        }

        Behavior on anchors.leftMargin {
            NumberAnimation { duration:  300; easing.type: Easing.OutQuad}
        }
    }

    Image {
        id: nowPlayingButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.rightMargin: 10
        width: 64
        height: width
        source: "images/NowPlayingIcon.png"

        Behavior on anchors.rightMargin {
            NumberAnimation { duration:  300; easing.type: Easing.OutQuad}
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                playlist.closePlaylist()
            }
        }
    }

    BorderImage {
        id: background
        border.top: 15
        border.right: 15
        border.left: 15
        border.bottom: 15
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        anchors {left: parent.left; right: parent.right; bottom: parent.bottom; top: header.bottom }
        source: "images/ContentPanel.png"

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
        }

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 25
            clip: true

            delegate: Item {
                width: parent.width
                height: 64
                //            Rectangle {
                //                width: parent.width
                //                height: 1
                //                anchors.top: parent.bottom
                //                color: "white"
                //                opacity: 0.5

                //            }
                Image {
                    anchors.fill: parent
                    source: AudioPlaylist.currentTrackNumber - 1 == index ? "images/MenuItemFO.png" : "images/MenuItemNF.png"
                }
                Image {
                    anchors {top: parent.top; right: parent.right; bottom: parent.bottom }
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    source: "images/MediaItemDetailBG.png"
                    visible: AudioPlaylist.currentTrackNumber - 1 == index
                }

                Text {
                    color: "white"
                    text: label
                    font.pixelSize: 28
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    color: "white"
                    text: duration
                    font.pixelSize: 28
                    anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                    anchors.rightMargin: 10
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        list.model.playItem(index)
                    }
                }
            }
        }

        ScrollBar {
            scrollArea: list; width: 15; alwaysVisible: false
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom}
            anchors.rightMargin: 10
            anchors.topMargin: 20
            anchors.bottomMargin: 20
        }

    }

    states: [
        State {
            name: "hidden"
            PropertyChanges { target: background; opacity: 0; scale: 0.5 }
            PropertyChanges { target: header; opacity: 0; anchors.leftMargin: -header.width }
            PropertyChanges { target: nowPlayingButton; opacity: 0; anchors.rightMargin: -nowPlayingButton.width }
        },
        State {
            name: "visible"
            PropertyChanges { target: background; opacity: 1; scale: 1 }
        }
    ]
}

