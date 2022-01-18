import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons

Rectangle{
    id: successDynamicPop
    width: 300
    height: 50

    property alias messageText: text2.text

    RowLayout{
        anchors.fill: parent
        spacing: 0
        Rectangle{
            Layout.preferredWidth: 10
            Layout.fillHeight: true
            color: "#00ff7f"
        }
        //-- Filler --//
        Item {
            Layout.fillWidth: true
        }

        //-- Exit Icon --//
        Label{
            Layout.fillHeight: true
            Layout.preferredWidth: implicitWidth * 0.5

            text: Icons.check_circle_outline
            color: "#00ff7f"

            font.family: webfont.name
            font.pixelSize: Qt.application.font.pixelSize * 2

            verticalAlignment: Qt.AlignVCenter

        }

        Column{
            //-- Text of Exit Popup --//
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.8
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: 2
            Label{
                width: parent.width
                height: parent.height * 0.5
                leftPadding: 20
                text: "Success"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                wrapMode: Text.WordWrap
                verticalAlignment: Qt.AlignVCenter
                color: "#000000"
            }
            Label{
                id: text2
                width: parent.width
                height: parent.height * 0.5
                leftPadding: 20
                text: "Salam2"
                opacity: 0.5
                font.pixelSize: Qt.application.font.pixelSize
                wrapMode: Text.WordWrap
                verticalAlignment: Qt.AlignVCenter
                color: "#000000"
            }
        }

        //-- Filler --//
        Item {
            Layout.fillWidth: true
        }
    }
}
