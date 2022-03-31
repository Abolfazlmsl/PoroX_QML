import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Item {
    id: form
    anchors.fill: parent

    objectName: "LicenseData"

    width: 300
    height: 400

    Rectangle{
        anchors.fill: parent
        color: "gray"

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 10

            Label{
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                verticalAlignment: Text.AlignVCenter
                text: "Email: " + setting.licenseEmail
            }

            Label{
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                verticalAlignment: Text.AlignVCenter
                text: "Expired on: " + setting.licenseTime
            }

            Label{
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                verticalAlignment: Text.AlignVCenter
                text: "Type: " + setting.licenseType
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.5
                color: "transparent"
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.1

                Rectangle{
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.fillHeight: true
                    color: "transparent"
                }

                Button{
                    id: button
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "Remove license"
                    background: Rectangle {

                        border.width: button.activeFocus ? 2 : 1
                        border.color: "#ff4500"
                        radius: 4
                        color: "#ff4500"
                    }
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            resetSetting()
                            license_Dataform.visible = false
                            licenseform.visible = true
                        }
                    }
                }
            }
        }
    }
}
