import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons

Dialog{

    id:acceptDialog

    property real sizeRatio: (widthRatio <= heightRatio) ? (widthRatio + ((1 - widthRatio) / 2)) : (heightRatio + ((1 - heightRatio) / 2))

    padding: 0
    topPadding: 0

    modal: true
    signal accept()

    property bool internetConnection: false
    property bool isSend: true

    property string bodyText_Dialog: "Done"

    width: parent.width - (40 * ratio)
    height: 150 * ratio

    background: Rectangle{
        radius: 5 * ratio
        color: "#ffffff"
    }

    //-- Header (Title) --//
    header: Rectangle{
        width: parent.width
        height: 45 * ratio * sizeRatio
        radius: 5 * ratio * sizeRatio
        color: "#daa520"
        Rectangle{
            width: parent.width
            height: 40 * ratio * sizeRatio
            color: parent.color
            anchors.bottom: parent.bottom
        }

        //-- Logo Image --//
        Image {
            source: ""
            visible: false
            sourceSize.width: width / 2
            sourceSize.height: height

            width: parent.width
            height: parent.height * 0.8

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            fillMode: Image.PreserveAspectFit
        }

    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0


        //-- Question of Exit Label and Icon --//
        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: 78 * ratio * sizeRatio

            //color: "#55ff0000"

            //-- Exit Label and Icon --//
            RowLayout{
                anchors.fill: parent
//                layoutDirection: Qt.RightToLeft

                //-- Filler --//
                Item {
                    Layout.fillWidth: true
                }

                //-- Exit Icon --//
                Label{
                    Layout.fillHeight: true
                    Layout.preferredWidth: implicitWidth * 0.5

                    text: Icons.bookmark_check

                    font.family: webfont.name
                    font.pixelSize: Qt.application.font.pixelSize * 2 * sizeRatio

                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter

                }

                //-- Text of Exit Popup --//
                Label{
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.8

                    text: bodyText_Dialog
                    font.pixelSize: Qt.application.font.pixelSize * 1.2 * ratio * sizeRatio
                    wrapMode: Text.WordWrap
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    color: "#000000"
                }

                //-- Filler --//
                Item {
                    Layout.fillWidth: true
                }

            }
        }

        //-- Yes No Button --//
        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 5 * ratio

            //color: "#5500ff00"

            RowLayout{
                anchors.fill: parent
                spacing: 10 * ratio
                layoutDirection: Qt.RightToLeft

                //-- Filler --//
                Item {
                    Layout.fillWidth: true
                }

                //-- "Ok" Button --//
                Rectangle{

                    Layout.preferredWidth: 100 * ratio * sizeRatio
                    Layout.preferredHeight: 40 * ratio * sizeRatio

                    Layout.alignment: Qt.AlignTop

                    radius: 5 * ratio

                    color: "#daa520"
                    border{
                        color: noToExit.focus ? "#ffFF0000" : "#00FF0000"
                        width: 1
                    }

                    //-- "Ok" Label --//
                    Label{
                        anchors.centerIn: parent

                        text: "Ok"
                        font.pixelSize: Qt.application.font.pixelSize * 1.2 * ratio * sizeRatio

                        color: "#ffffff"
                    }

                    //-- on No Clicked --//
                    ItemDelegate{
                        id:noToExit
                        anchors.fill: parent

                        Keys.onTabPressed: {
                            noToExit.forceActiveFocus()
                        }

                        Keys.onPressed: {

                            if (event.key === Qt.Key_Enter
                                    || event.key === 16777220) {
                                accept()
                            }
                        }

                        onClicked: {

                            accept()
                        }
                    }
                }

                //-- Filler --//
                Item {
                    Layout.fillWidth: true
                }
            }

        }
    }

}
