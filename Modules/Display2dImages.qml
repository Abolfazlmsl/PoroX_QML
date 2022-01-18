import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

Item {
    id: root
    anchors.fill: parent

    objectName: "2D_images"

    // Type of Images ("MImages", "DImages", "FImages", "SImages", "RImages")
    property string imageType: ""

    width: 300
    height: 400

    property real imageNum: 1

    Rectangle{
        anchors.fill: parent
        color: "#f8f8ff"

        ColumnLayout{
            anchors.fill: parent
            spacing: 2
            Image{
                cache: false
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.9
                source: (root.visible) ? (slider.value < 10) ? "file:///" + offlineStoragePath + "/" + imageType + "/M000" + String(slider.value) + ".png":
                                                              (slider.value >= 10 && slider.value < 100)? "file:///" + offlineStoragePath + "/" + imageType + "/M00" + String(slider.value) + ".png":
                                                                                                          "file:///" + offlineStoragePath + "/" + imageType + "/M0" + String(slider.value) + ".png":""
            }

            Row{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.1
                spacing: 2
                Slider{
                    id: slider
                    height: parent.height
                    width: parent.width * 0.8
                    from: 1
                    value: 1
                    to: imageNum
                    stepSize: 1
                }
                Text{
                    height: parent.height
                    width: parent.width * 0.2
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    text: slider.value + "/" + imageNum
                }
            }
        }
    }


}
