import QtQuick 2.14
import QtQuick.Controls 2.2

Rectangle{
    id: root

    property alias icon: rightMenu_DashboardIcon.text
    property alias text: rightMenu_DashboardLabel.text
    property alias iconColor: rightMenu_DashboardIcon.color
    property bool colorstate: false

    property real iconWidth: rightMenu_DashboardIcon.width + (24 * ratio)

    signal btnClicked

    width: rightMenu_DashboardIcon.width + rightMenu_DashboardLabel.width + 10
    height: 50
    color: "transparent"


    //-- Dashboard Icon --//
    Label{
        id:rightMenu_DashboardIcon

        height: parent.height

        anchors.left: parent.left
        anchors.leftMargin: ratio

        text: "im" //Icons.home_outline

        font.family: webfont.name
        font.pixelSize: 72//Qt.application.font.pixelSize
        minimumPixelSize: 10
        fontSizeMode: Text.Fit

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: colorstate ? "black":"#ffffff"
    }

    //-- Dashboard Label --//
    Label{
        id: rightMenu_DashboardLabel

        height: parent.height

        anchors.left: rightMenu_DashboardIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: "عنوان"
        minimumPointSize: 10
        fontSizeMode: Text.Fit
        font.pixelSize: Qt.application.font.pixelSize * 1.3

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: rightMenu_DashboardIcon.color
        clip: true
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
