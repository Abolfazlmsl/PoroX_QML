import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12


Item {
    id: snowitem

    anchors.fill: parent

    objectName: "Maximal Ball"

    property alias minRprop: text.text

    signal getExtractedNetwork(var minR)

    onGetExtractedNetwork: {
        extractbutton.enabled = !extractbutton.enabled
        networkmodel.clear()
        networkmodel.append({
                                "maintext": "Extract (Maximal Ball)",
                                "proptext": "Minimum pore radius:" + minR
                            })

        btn_text.text = "Stop"
        acceptPop.bodyText_Dialog = "Extraction was done successfully"
        acceptPop.visible = true

        hydrauliccondType = "Valvatne_blunt"
        poissonshapefactorType = "Conical_frustum_and_stick"
        physicItem.hydcondstate = "Valvatne_blunt"
        physicItem.poissonshapestate = "Conical_frustum_and_stick"
        physicItem.cpChange()
        physicItem.diffChange()
        physicItem.hydChange()
        physicItem.multiChange()
        physicItem.flowChange()
        physicItem.poiChange()

        network = true
        filepanel.saveEnable = true
    }

    Component.onCompleted: MainPython.extractedMaximalNetwork.connect(getExtractedNetwork)

    //-- body --//
    Rectangle{
        anchors.fill: parent
        color: "#f8f8ff"

        ColumnLayout{
            anchors.fill: parent
            spacing: 0

            Label{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.05
                z: 1
                background: Rectangle {
                    color: "#f8f8ff"
                }


                font.pixelSize: Qt.application.font.pixelSize
                text: "Fill the blank fields:"

            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.85
                Column{
                    anchors.fill: parent
                    spacing: 0

                    Label{
                        width: parent.width
                        height: parent.height / 25

                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        text: "Image properties:"
                    }

                    RowLayout{
                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt2
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt2.width
                            verticalAlignment: Qt.AlignVCenter
                            font.pixelSize: Qt.application.font.pixelSize
                            text: "Minimum Pore Radius (Microns):"
                        }
                        TextField{
                            id: text
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: "0"
                        }

                    }
                }
            }

            Button{
                id: extractbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Run Extraction"
                background: Rectangle {

                    border.width: extractbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (text.text === ""){
                            warningPop.bodyText_Dialog = "Insert the minimum pore radius value"
                            warningPop.visible = true
                        }else if (text.text != "" && isNaN(Number(text.text))){
                            warningPop.bodyText_Dialog = "Minimum pore radius must be a number"
                            warningPop.visible = true
                        }else if (text.text < 0){
                            warningPop.bodyText_Dialog = "Minimum pore radius must be positive"
                            warningPop.visible = true
                        }else if (!segment_image && (inputdata!=="2D Binary" && inputdata!=="3D Binary")){
                            warningPop.bodyText_Dialog = "First segment the image"
                            warningPop.visible = true
                        }else if (!reconstruct_image && (inputdata==="2D Gray" || inputdata==="2D Binary" || inputdata==="2D Thinsection")){
                            warningPop.bodyText_Dialog = "First reconstruct the image"
                            warningPop.visible = true
                        }else{
                            extractbutton.enabled = !extractbutton.enabled
                            btn_text.text = "Wait"
                            MainPython.maximal(text.text)
                        }
                    }
                }
            }
        }

    }

}
