import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    id: maximalballitem

    anchors.fill: parent

    objectName: "SNOW"

    property alias rprop: rtext.text
    property alias sprop: stext.text

    signal getExtractedNetwork(var r_max, var sigma, bool success)

    onGetExtractedNetwork: {
        extractbutton.enabled = !extractbutton.enabled
        if (success){
            btn_state.btnstate = !btn_state.btnstate
            networkmodel.clear()
            networkmodel.append({
                                    "maintext": "Extract (SNOW)",
                                    "proptext": "R_max:" + r_max + " Sigma:" + sigma
                                })

            acceptPop.bodyText_Dialog = "Extraction was done successfully"
            acceptPop.visible = true

            hydrauliccondType = "Hagen_poiseuille"
            poissonshapefactorType = "Ball_and_stick"
            physicItem.hydcondstate = "Hagen_poiseuille"
            physicItem.poissonshapestate = "Ball_and_stick"
            physicItem.cpChange()
            physicItem.diffChange()
            physicItem.hydChange()
            physicItem.multiChange()
            physicItem.flowChange()
            physicItem.poiChange()

            network = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.extractedSNOWNetwork.connect(getExtractedNetwork)

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
                            id: txt3
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt3.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "Maximum R (Microns):"
                        }
                        TextField{
                            id: rtext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: "4"
                        }

                    }

                    RowLayout{

                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt4
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt4.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "Sigma:"
                        }
                        TextField{
                            id: stext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 4
                            text: "0.4"
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
                        if (rtext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the maximum R value"
                            warningPop.visible = true
                        }else if (stext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the sigma value"
                            warningPop.visible = true
                        }else if (rtext.text != "" && isNaN(Number(rtext.text))){
                            warningPop.bodyText_Dialog = "Maximum R must be a number"
                            warningPop.visible = true
                        }else if (rtext.text <= 0){
                            warningPop.bodyText_Dialog = "Maximum R must be positive"
                            warningPop.visible = true
                        }else if (stext.text != "" && isNaN(Number(stext.text))){
                            warningPop.bodyText_Dialog = "Sigma must be a number"
                            warningPop.visible = true
                        }else if (stext.text <= 0){
                            warningPop.bodyText_Dialog = "Sigma must be positive"
                            warningPop.visible = true
                        }else if (!segment_image && (inputdata!=="2D Binary" && inputdata!=="3D Binary")){
                            warningPop.bodyText_Dialog = "First segment the image"
                            warningPop.visible = true
                        }else if (!reconstruct_image && (inputdata==="2D Gray" || inputdata==="2D Binary" || inputdata==="2D Thinsection")){
                            warningPop.bodyText_Dialog = "First reconstruct the image"
                            warningPop.visible = true
                        }else{
                            extractbutton.enabled = !extractbutton.enabled
                            MainPython.snow(rtext.text, stext.text)
                        }
                    }
                }
            }
        }

    }

}
