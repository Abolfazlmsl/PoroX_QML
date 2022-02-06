import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import "./../Functions/functions.js" as Functions

Item {
    id: mpsitem

    anchors.fill: parent

    objectName: "MPS"

    property alias tempx: xtemp.text
    property alias tempy: ytemp.text
    property alias tempz: ztemp.text

    signal getReconstructImage(var porosity)

    onGetReconstructImage: {
        reconstbutton.enabled = !reconstbutton.enabled
        xdimReconstruct = xtext.text
        ydimReconstruct = ytext.text
        zdimReconstruct = ztext.text
        reconstructmodel.clear()
        reconstructmodel.append({
                                    "maintext": "Reconstruct (MPS)",
                                    "proptext": "X:" + xtext.text + " Y:" + ytext.text + " Z:" + ztext.text
                                })

        resultmodel.append({
                               "text": "Porosity (Reconstructed image): " + porosity + "%",
                           })

        sceneset.segmentVisible = false
        sceneset.throatVisible = false
        sceneset.poreVisible = false
        sceneset.reconstructVisible = true
        sceneset.source2 = ""
        sceneset.source2 = "file:///" + offlineStoragePath + "/reconstruct.stl"
        for (var j=0; j<sceneModel.count; j++){
            if (sceneModel.get(j).name !== "3D Reconstruct"){
                sceneModel.setProperty(j, "state", false)
            }else{
                sceneModel.setProperty(j, "state", true)
            }
        }

        if (!Functions.findbyNameBool(sceneModel, "3D Reconstruct")){
            sceneModel.append(
                        {
                            "name":"3D Reconstruct",
                            "state": true
                        }
                        )
        }

        if (!Functions.findbyNameBool(scene2dModel, "2D Reconstruct")){
            scene2dModel.append(
                        {
                            "name":"2D Reconstruct",
                            "state": false
                        }
                        )
        }

        btn_text.text = "Stop"
        acceptPop.bodyText_Dialog = "Reconstruction was done successfully"
        acceptPop.visible = true
        reconstruct_image = true
        filepanel.saveEnable = true
    }

    Component.onCompleted: MainPython.reconstructMPSImage.connect(getReconstructImage)

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

                    RowLayout{
                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt1
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt1.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "X dimension:"
                        }
                        TextField{
                            id: xtext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: xdimReconstruct
                        }

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

                            text: "Y dimension:"
                        }
                        TextField{
                            id: ytext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: ydimReconstruct
                        }

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

                            text: "Z dimension:"
                        }
                        TextField{
                            id: ztext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: zdimReconstruct
                        }

                    }

                    Label{
                        width: parent.width
                        height: parent.height / 25

                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        text: "Template:"
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

                            text: "X:"
                        }
                        TextField{
                            id: xtemp
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: "10"
                        }

                    }

                    RowLayout{

                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt5
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt5.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "Y:"
                        }
                        TextField{
                            id: ytemp
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: "10"
                        }

                    }

                    RowLayout{

                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt6
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt6.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "Z:"
                        }
                        TextField{
                            id: ztemp
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            //                            maximumLength: 2
                            text: "10"
                        }

                    }
                }
            }

            Button{
                id: reconstbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Run Reconstruction"
                background: Rectangle {

                    border.width: reconstbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (xtext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the X dimension value"
                            warningPop.visible = true
                        }else if (ytext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Y dimension value"
                            warningPop.visible = true
                        }else if (ztext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Z dimension value"
                            warningPop.visible = true
                        }else if (xtemp.text === ""){
                            warningPop.bodyText_Dialog = "Insert the X template value"
                            warningPop.visible = true
                        }else if (ytemp.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Y template value"
                            warningPop.visible = true
                        }else if (ztemp.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Z template value"
                            warningPop.visible = true
                        }else if (xtext.text != "" && isNaN(Number(xtext.text))){
                            warningPop.bodyText_Dialog = "X dimension must be a number"
                            warningPop.visible = true
                        }else if (ytext.text != "" && isNaN(Number(ytext.text))){
                            warningPop.bodyText_Dialog = "Y dimension must be a number"
                            warningPop.visible = true
                        }else if (ztext.text != "" && isNaN(Number(ztext.text))){
                            warningPop.bodyText_Dialog = "Z dimension must be a number"
                            warningPop.visible = true
                        }else if (xtemp.text != "" && isNaN(Number(xtemp.text))){
                            warningPop.bodyText_Dialog = "X template must be a number"
                            warningPop.visible = true
                        }else if (ytemp.text != "" && isNaN(Number(ytemp.text))){
                            warningPop.bodyText_Dialog = "Y template must be a number"
                            warningPop.visible = true
                        }else if (ztemp.text != "" && isNaN(Number(ztemp.text))){
                            warningPop.bodyText_Dialog = "Z template must be a number"
                            warningPop.visible = true
                        }else if (xtext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "X dimension must be an integer number"
                            warningPop.visible = true
                        }else if (xtext.text <= 0){
                            warningPop.bodyText_Dialog = "X dimension must be positive"
                            warningPop.visible = true
                        }else if (ytext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Y dimension must be an integer number"
                            warningPop.visible = true
                        }else if (ytext.text <= 0){
                            warningPop.bodyText_Dialog = "Y dimension must be positive"
                            warningPop.visible = true
                        }else if (ztext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Z dimension must be an integer number"
                            warningPop.visible = true
                        }else if (ztext.text <= 0){
                            warningPop.bodyText_Dialog = "Z dimension must be positive"
                            warningPop.visible = true
                        }else if (xtemp.text % 1 != 0){
                            warningPop.bodyText_Dialog = "X template must be an integer number"
                            warningPop.visible = true
                        }else if (xtemp.text <= 0){
                            warningPop.bodyText_Dialog = "X template must be positive"
                            warningPop.visible = true
                        }else if (ytemp.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Y template must be an integer number"
                            warningPop.visible = true
                        }else if (ytemp.text <= 0){
                            warningPop.bodyText_Dialog = "Y template must be positive"
                            warningPop.visible = true
                        }else if (ztemp.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Z template must be an integer number"
                            warningPop.visible = true
                        }else if (ztemp.text <= 0){
                            warningPop.bodyText_Dialog = "Z template must be positive"
                            warningPop.visible = true
                        }else if (!segment_image && inputdata!=="2D Binary"){
                            warningPop.bodyText_Dialog = "First segment the image"
                            warningPop.visible = true
                        }else{
                            reconstbutton.enabled = !reconstbutton.enabled
                            btn_text.text = "Wait"
                            MainPython.mps(xtext.text, ytext.text, ztext.text, xtemp.text, ytemp.text, ztemp.text)
                        }
                    }
                }
            }
        }

    }

}
