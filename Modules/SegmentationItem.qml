import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12


Item {
    id: segmentitem

    anchors.fill: parent

    objectName: "Segment"

    property alias segmentParam: threshinput.text

    property string method: "Otsu"

    signal getSegmentImage(var threshold, var porosity, var xData, var yData, var gxData, var gyData, bool success)

    onGetSegmentImage: {
        segmentbutton.enabled = !segmentbutton.enabled
        if (success){
            btn_state.btnstate = !btn_state.btnstate
            porexData = xData
            poreyData = yData
            psdchart.plot()
            grainxData = gxData
            grainyData = gyData
            gsdchart.plot()
            threshinput.text = threshold
            totalPorosity = porosity
            tablemodel.append({
                                  "method": method,
                                  "threshold": threshold,
                                  "porosity": porosity
                              })

            imagehandlemodel.append({
                                        "maintext": "Segment",
                                        "proptext": method + " (Threshold:" + threshold + ")",
                                    })

            sceneset.source1 = ""
            sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"

            if (!findbyNameBool(scene2dModel, "2D Segment")){
                scene2dModel.append(
                            {
                                "name":"2D Segment",
                                "state": false
                            }
                            )
            }
            resultview.sResultview = 1

            acceptPop.bodyText_Dialog = "Segmentation was done successfully"
            acceptPop.visible = true
            segment_image = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.threshold.connect(getSegmentImage)


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
                text: "Choose the Segmentation Method:"
            }

            ScrollView{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.6
                clip: true

                Column{
                    spacing: 0

                    RadioButton{
                        checked: (method === "User")
                        text: "User-Defined"
                        onClicked: {
                            method = "User"
                        }
                    }
                    RadioButton{
                        checked: (method === "Otsu")
                        text: "Otsu"
                        onClicked: {
                            method = "Otsu"
                        }
                    }
                    RadioButton{
                        checked: (method === "KI")
                        text: "KI"
                        onClicked: {
                            method = "KI"
                        }
                    }
                    RadioButton{
                        checked: (method === "Watershed")
                        text: "Watershed"
                        onClicked: {
                            method = "Watershed"
                        }
                    }
                    RadioButton{
                        checked: (method === "K-means")
                        text: "K-means"
                        onClicked: {
                            method = "K-means"
                        }
                    }
                    RadioButton{
                        checked: (method === "Yen")
                        text: "Yen"
                        onClicked: {
                            method = "Yen"
                        }
                    }
                    RadioButton{
                        checked: (method === "Isodata")
                        text: "Isodata"
                        onClicked: {
                            method = "Isodata"
                        }
                    }
                    RadioButton{
                        checked: (method === "Li")
                        text: "Li"
                        onClicked: {
                            method = "Li"
                        }
                    }
                    RadioButton{
                        checked: (method === "Mean")
                        text: "Mean"
                        onClicked: {
                            method = "Mean"
                        }
                    }
                    RadioButton{
                        checked: (method === "Triangle")
                        text: "Triangle"
                        onClicked: {
                            method = "Triangle"
                        }
                    }
                }
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.2

                RowLayout{
                    id: textsetting
                    anchors.fill: parent
                    spacing: 0

                    Label{
                        id: txt
                        Layout.fillHeight: true
                        Layout.preferredWidth: txt.width
                        verticalAlignment: Qt.AlignVCenter

                        text: "Threshold value:"
                    }
                    TextField{
                        id: threshinput
                        enabled: (method==="User")? true:false
                        Layout.preferredHeight: parent.height / 2
                        Layout.fillWidth: true
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        font.pixelSize: Qt.application.font.pixelSize * 1.7
                        selectByMouse: true
                        maximumLength: 6
                        text: ""
                    }
                }
            }

            Button{
                id: segmentbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Apply Segmentation"
                background: Rectangle {

                    border.width: segmentbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (threshinput.enabled && threshinput.text == ""){
                            warningPop.bodyText_Dialog = "Insert the threshold value"
                            warningPop.visible = true
                        }

                        if (threshinput.enabled && isNaN(Number(threshinput.text))){
                            warningPop.bodyText_Dialog = "Threshold value must be a number"
                            warningPop.visible = true
                        }else{
                            segmentbutton.enabled = !segmentbutton.enabled
                            btn_state.btnstate = !btn_state.btnstate
                            if (method === "User"){
                                MainPython.segment(threshinput.text)
                            }else{
                                MainPython.segment(method)
                            }
                        }
                    }
                }
            }
        }

    }

}
