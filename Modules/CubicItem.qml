import QtQuick 2.14
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    id: cubicitem

    anchors.fill: parent

    property alias xdimcon: xtext.text
    property alias ydimcon: ytext.text
    property alias zdimcon: ztext.text
    property alias xspacon: xstext.text
    property alias yspacon: ystext.text
    property alias zspacon: zstext.text
    property alias ccon: ctext.text

    objectName: "Cubic"

    signal getMessage(bool msg, var x, var y, var z, var porecoord,
                      var throatlength, var throatcen, var rotation, var angle)

    onGetMessage: {
        constructbutton.enabled = !constructbutton.enabled
        if (msg){
            xdim = (x)*1000000
            ydim = (y)*1000000
            zdim = (z)*1000000

            sceneset.z = (z)*1000000 - 200
            poreprops.clear()
            for (var i=0; i<porecoord.length; i++){
                poreprops.append(
                            {
                                "Radi": (0.3*xstext.text)*1000000/3,
                                "Coordx": porecoord[i][0]* 1000000,
                                "Coordy": porecoord[i][1]* 1000000,
                                "Coordz": porecoord[i][2]* 1000000
                            }
                            )
            }

            throatprops.clear()
            for (i=0; i<throatlength.length; i++){
                throatprops.append(
                            {
                                "Radi": (0.2*xstext.text)*1000000/4/3,
                                "Length": throatlength[i]* 1000000,
                                "Centerx": throatcen[i][0]* 1000000,
                                "Centery": throatcen[i][1]* 1000000,
                                "Centerz": throatcen[i][2]* 1000000,
                                "Rotatex": rotation[i][0],
                                "Rotatey": rotation[i][1],
                                "Rotatez": rotation[i][2],
                                "Angle": angle[i]
                            }
                            )
            }

            sceneset.segmentVisible = false
            sceneset.reconstructVisible = false
            sceneset.throatVisible = true
            sceneset.poreVisible = true
            for (var j=0; j<sceneModel.count; j++){
                if (sceneModel.get(j).name !== "3D Network"){
                    sceneModel.setProperty(j, "state", false)
                }
            }

            if (!findbyNameBool(sceneModel, "3D Network")){
                sceneModel.append(
                            {
                                "name":"3D Network",
                                "state": true
                            }
                            )
            }

            networkmodel.clear()
            networkmodel.append({
                                    "maintext": "Construct (Cubic)",
                                    "proptext": "X:" + x + " Y:" + y + " Z:" + z
                                })

            btn_text.text = "Stop"
            network = true
            acceptPop.bodyText_Dialog = "Construction was done successfully"
            acceptPop.visible = true
            filepanel.saveEnable = true
        }
    }

    Component.onCompleted: MainPython.message_Cubic.connect(getMessage)

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
                        height: parent.height / 10
                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                        font.bold: true
                        text: "Network properties:"
                    }

                    Label{

                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        text: "Shape:"
                    }

                    RowLayout{
                        width: parent.width
                        height: parent.height / 10
                        spacing: 2
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "X"
                        }
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Y"
                        }
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Z"
                        }

                    }
                    RowLayout{
                        width: parent.width
                        height: parent.height /10
                        spacing: 2
                        TextField{
                            id: xtext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "5"
                        }
                        TextField{
                            id: ytext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "5"
                        }
                        TextField{
                            id: ztext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "5"
                        }
                    }


                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }
                    Label{
                        width: parent.width
                        height: parent.height / 25
                        topPadding: 5

                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        text: "Spacing:"
                    }

                    RowLayout{
                        width: parent.width
                        height: parent.height / 10
                        spacing: 2
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "X"
                        }
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Y"
                        }
                        Label{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Z"
                        }

                    }
                    RowLayout{
                        width: parent.width
                        height: parent.height /10
                        spacing: 2
                        TextField{
                            id: xstext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "0.000001"
                        }
                        TextField{
                            id: ystext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "0.000001"
                        }
                        TextField{
                            id: zstext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "0.000001"
                        }
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }
                    RowLayout{
                        width: parent.width
                        height: parent.height / 7
                        spacing: 0

                        Label{
                            id: txt
                            Layout.fillHeight: true
                            Layout.preferredWidth: txt.width
                            verticalAlignment: Qt.AlignVCenter
                            font.bold: true
                            text: "Connectivity:"
                        }
                        TextField{
                            id: ctext
                            Layout.preferredHeight: parent.height / 1.2
                            Layout.fillWidth: true
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            selectByMouse: true
                            text: "6"
                        }

                    }
                }
            }


            Button{
                id: constructbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Run Construction"
                background: Rectangle {

                    border.width: constructbutton.activeFocus ? 2 : 1
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
                        }else if (xstext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the X spacing value"
                            warningPop.visible = true
                        }else if (ystext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Y spacing value"
                            warningPop.visible = true
                        }else if (zstext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the Z spacing value"
                            warningPop.visible = true
                        }else if (ctext.text === ""){
                            warningPop.bodyText_Dialog = "Insert the connectivity value"
                            warningPop.visible = true
                        }else if (xtext.text != "" && isNaN(Number(xtext.text))){
                            warningPop.bodyText_Dialog = "X dimension must be a number"
                            warningPop.visible = true
                        }else if (xtext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "X dimension must be an integer number"
                            warningPop.visible = true
                        }else if (xtext.text <= 0){
                            warningPop.bodyText_Dialog = "X dimension must be positive"
                            warningPop.visible = true
                        }else if (ytext.text != "" && isNaN(Number(ytext.text))){
                            warningPop.bodyText_Dialog = "Y dimension must be a number"
                            warningPop.visible = true
                        }else if (ytext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Y dimension must be an integer number"
                            warningPop.visible = true
                        }else if (ytext.text <= 0){
                            warningPop.bodyText_Dialog = "Y dimension must be positive"
                            warningPop.visible = true
                        }else if (ztext.text != "" && isNaN(Number(ztext.text))){
                            warningPop.bodyText_Dialog = "Z dimension must be a number"
                            warningPop.visible = true
                        }else if (ztext.text % 1 != 0){
                            warningPop.bodyText_Dialog = "Z dimension must be an integer number"
                            warningPop.visible = true
                        }else if (ztext.text <= 0){
                            warningPop.bodyText_Dialog = "Z dimension must be positive"
                            warningPop.visible = true
                        }else if (xstext.text != "" && isNaN(Number(xstext.text))){
                            warningPop.bodyText_Dialog = "X spacing must be a number"
                            warningPop.visible = true
                        }else if (xstext.text <= 0){
                            warningPop.bodyText_Dialog = "X spacing must be positive"
                            warningPop.visible = true
                        }else if (ystext.text != "" && isNaN(Number(ystext.text))){
                            warningPop.bodyText_Dialog = "Y spacing must be a number"
                            warningPop.visible = true
                        }else if (ystext.text <= 0){
                            warningPop.bodyText_Dialog = "Y spacing must be positive"
                            warningPop.visible = true
                        }else if (zstext.text != "" && isNaN(Number(zstext.text))){
                            warningPop.bodyText_Dialog = "Z spacing must be a number"
                            warningPop.visible = true
                        }else if (zstext.text <= 0){
                            warningPop.bodyText_Dialog = "Z spacing must be positive"
                            warningPop.visible = true
                        }else if (ctext.text !== "6" && ctext.text !== "14" &&
                                  ctext.text !== "18" && ctext.text !== "20" && ctext.text !== "26"){
                            warningPop.bodyText_Dialog = "Connectivity must be among 6,14,18,20 or 26 values "
                            warningPop.visible = true
                        }else{
                            constructbutton.enabled = !constructbutton.enabled
                            btn_text.text = "Wait"
                            MainPython.construct("Cubic", xtext.text, ytext.text, ztext.text, xstext.text, ystext.text, zstext.text, ctext.text, "", "")
                        }
                    }
                }
            }
        }
    }

}
