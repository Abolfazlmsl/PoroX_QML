import QtQuick 2.14
import QtQuick.Controls 2.2

Rectangle{
    property alias text: lb.text

    width: parent.width
    height: parent.height/4
    color: "#a9a9a9"
    Label{
        id: lb
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "salam"
        font.pixelSize: Qt.application.font.pixelSize*1.1
    }
}
