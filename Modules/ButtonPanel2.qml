import QtQuick 2.14
import QtQuick.Controls 2.2

Rectangle{
    id: root

    property alias text: rightMenu_DashboardLabel.text
    property bool colorstate: false

    signal btnClicked

    width: rightMenu_DashboardLabel.width + 20
    height: 25
    color: colorstate ? "#f8f8ff":"transparent"

    //-- Dashboard Label --//
    Label{
        id: rightMenu_DashboardLabel

        height: parent.height

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        text: "عنوان"
        minimumPointSize: 10
        fontSizeMode: Text.Fit
        font.pixelSize: Qt.application.font.pixelSize * 1.3

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        clip: true
        color: colorstate ? "#000000":"#ffffff"
        elide: Text.ElideRight
    }

    //-- on Click Dashboard --//
    ItemDelegate{
        anchors.fill: parent
        onPressed: {
            btnClicked()
        }

    }
}
