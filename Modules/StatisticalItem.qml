import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12


Item {
    id: statisticalitem

    anchors.fill: parent

    property alias cutoff: cutofftext.text

    objectName: "Statistical"

    signal getReconstructImage(var porosity, var sX, var sY, bool success)

    onGetReconstructImage: {
        reconstbutton.enabled = !reconstbutton.enabled
        if (success){
            btn_state.btnstate = !btn_state.btnstate
            s2_x = sX
            s2_y = sY
            s2chart.plot()

            xdimReconstruct = xtext.text
            ydimReconstruct = ytext.text
            zdimReconstruct = ztext.text
            reconstructmodel.clear()
            reconstructmodel.append({
                                        "maintext": "Reconstruct (Statistical)",
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

            if (!findbyNameBool(sceneModel, "3D Reconstruct")){
                sceneModel.append(
                            {
                                "name":"3D Reconstruct",
                                "state": true
                            }
                            )
            }

            if (!findbyNameBool(scene2dModel, "2D Reconstruct")){
                scene2dModel.append(
                            {
                                "name":"2D Reconstruct",
                                "state": false
                            }
                            )
            }

            acceptPop.bodyText_Dialog = "Reconstruction was done successfully"
            acceptPop.visible = true
            reconstruct_image = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.reconstructStatisticalImage.connect(getReconstructImage)

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
                        height: parent.height / 4
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
                            Layout.preferredHeight: parent.height / 2
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
                        height: parent.height / 4
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
                            Layout.preferredHeight: parent.height / 2
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
                        height: parent.height / 4
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
                            Layout.preferredHeight: parent.height / 2
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
                    RowLayout{

                        width: parent.width
                        height: parent.height / 4
                        spacing: 0

                        Label{
                            id: txt4
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt4.width
                            verticalAlignment: Qt.AlignVCenter

                            text: "Cutoff distance:"
                        }
                        TextField{
                            id: cutofftext
                            Layout.preferredHeight: parent.height / 2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            maximumLength: 2
                            text: "4"
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
                        }else if (cutofftext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the cutoff distance value"
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
                        }else if (cutofftext.text != "" && isNaN(Number(cutofftext.text))){
                            warningPop.bodyText_Dialog = "Cutoff distance must be a number"
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
                        }else if (cutofftext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Cutoff distance must be an integer number"
                            warningPop.visible = true
                        }else if (cutofftext.text <= 0){
                            warningPop.bodyText_Dialog = "Cutoff distance must be positive"
                            warningPop.visible = true
                        }else if (!segment_image && inputdata!=="2D Binary"){
                            warningPop.bodyText_Dialog = "First segment the image"
                            warningPop.visible = true
                        }else{
                            reconstbutton.enabled = !reconstbutton.enabled
//                            btn_state.btnstate = !btn_state.btnstate
                            MainPython.statistical(xtext.text, ytext.text, ztext.text, cutofftext.text)
                        }
                    }
                }
            }
        }

    }

}
