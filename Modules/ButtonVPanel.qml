import QtQuick 2.14
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle{
    id: root

    property alias icon: rightMenu_DashboardIcon.source
    property alias text: rightMenu_DashboardLabel.text

    property real iconWidth: rightMenu_DashboardIcon.width + (24 * ratio)

    signal btnClicked

    width: rightMenu_DashboardLabel.width + 10
    height: 53
    color: "transparent"

    //-- Dashboard Icon --//
    Image{
        id:rightMenu_DashboardIcon

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: ratio

        fillMode: Image.PreserveAspectFit
        sourceSize.width: 33
        sourceSize.height: 33
    }

    //-- Dashboard Label --//
    Label{
        id: rightMenu_DashboardLabel

        anchors.top: rightMenu_DashboardIcon.bottom

        anchors.horizontalCenter: parent.horizontalCenter

        text: "عنوان"
        minimumPointSize: 10
        fontSizeMode: Text.Fit
        font.pixelSize: Qt.application.font.pixelSize * 1.3

//        color: rightMenu_DashboardIcon.color
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
