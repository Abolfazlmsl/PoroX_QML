import QtQuick 2.14
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    anchors.fill: parent

    objectName: "3D_image"

    property string fileurl: ""

    signal re3DNextNumber(var xDim, var yDim, var zDim, bool success)
    signal re3DNextNumberBinary(var xDim, var yDim, var zDim, var porosity, var xData, var yData, var gxData, var gyData, bool success)
    signal showMessage(var msg)

    width: 300
    height: 400

    onRe3DNextNumber: {
        if (success){
            xdim = xDim
            ydim = yDim
            resolution = restext.text
            zdim = zDim
            swipTitle = "Input"
            section1.checked = true
            sView.currentIndex = 1
            inputmodel.clear()
            inputmodel.append({
                                  "maintext": inputdata,
                                  "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + zDim
                              })

            sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"
            sceneset.segmentVisible = true
            sceneModel.append(
                        {
                            "name":"3D Segment",
                            "state": true
                        }
                        )
            scene2dModel.append(
                        {
                            "name":"2D Image",
                            "state": false
                        }
                        )
            main_image = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            inputType = ""
            inputdata = ""
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    onRe3DNextNumberBinary: {
        if (success){
            porexData = xData
            poreyData = yData
            psdchart.plot()

            grainxData = gxData
            grainyData = gyData
            gsdchart.plot()

            xdim = xDim
            ydim = yDim
            resolution = restext.text
            zdim = zDim
            totalPorosity = porosity
            resultmodel.clear()
            resultmodel.append({
                                   "text": "Porosity (Original image): " + porosity + "%"
                               })
            swipTitle = "Input"
            section1.checked = true
            sView.currentIndex = 1
            inputmodel.append({
                                  "maintext": inputdata,
                                  "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + zDim
                              })

            sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"
            sceneset.segmentVisible = true
            sceneModel.append(
                        {
                            "name":"3D Segment",
                            "state": true
                        }
                        )
            scene2dModel.append(
                        {
                            "name":"2D Image",
                            "state": false
                        }
                        )
            main_image = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            inputType = ""
            inputdata = ""
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }

    }

    onShowMessage: {
        inputdata = ""
        inputType = ""
        btn_state.btnstate = !btn_state.btnstate
        errorPop.bodyText_Dialog = msg
        errorPop.visible = true
    }

    Component.onCompleted: {
        MainPython.next3DNumber.connect(re3DNextNumber)
        MainPython.next3DNumberBinary.connect(re3DNextNumberBinary)
        MainPython.importImage.connect(showMessage)
    }

    //-- body --//
    Rectangle{
        anchors.fill: parent
        color: "#f8f8ff"

        ColumnLayout{
            anchors.fill: parent
            spacing: 0

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.7
                color: "#808080"
                Column{
                    anchors.fill: parent
                    spacing: 0

                    Label{
                        height: parent.height / 10

                        font.pixelSize: Qt.application.font.pixelSize * 1.8
                        font.bold: true
                        text: "Image properties:"
                    }

                    Rectangle{
                        width: parent.width
                        height: 10
                        color: "#808080"
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height /8
                        color: "#808080"
                        Label{
                            id: hint
                            anchors.fill: parent
                            font.pixelSize: 12
                            leftPadding: 20
                            wrapMode: Text.WordWrap
                            color: "yellow"
                            text: "Hint: The images name must contain at least one character following the consecutive numbers (i.e. 1, 2, 3, ... ) "
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: 10
                        color: "#808080"
                    }

                    Label{

                        font.pixelSize: Qt.application.font.pixelSize* 1.5
                        font.bold: true
                        text: "Number of images:"
                    }
                    RowLayout{
                        width: parent.width
                        height: parent.height /8
                        spacing: 2
                        TextField{
                            id: ztext
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: "1"
                        }
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }
                    Label{
                        width: parent.width
                        height: parent.height / 15
                        topPadding: 5

                        font.pixelSize: Qt.application.font.pixelSize* 1.5
                        font.bold: true
                        text: "Starting image:"
                    }

                    TextField{
                        id: starttext
                        width: parent.width
                        height: parent.height /8
                        font.pixelSize: Qt.application.font.pixelSize* 1.5
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        selectByMouse: true

                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }
                    Label{
                        width: parent.width
                        height: parent.height / 15
                        topPadding: 5

                        font.pixelSize: Qt.application.font.pixelSize* 1.5
                        font.bold: true
                        text: "Resolution:"
                    }

                    TextField{
                        id: restext
                        width: parent.width
                        height: parent.height /8
                        font.pixelSize: Qt.application.font.pixelSize* 1.5
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        selectByMouse: true

                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.1
                color: "#808080"
                Label{
                    id: warning
                    anchors.fill: parent
                    font.pixelSize: 12
                    leftPadding: 20
                    color: "yellow"
                }
            }

            Row{
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2
                Button{
                    id: cancelbutton
                    height: parent.height
                    width: parent.width/2
                    text: "Cancel"
                    background: Rectangle {
                        border.width: cancelbutton.activeFocus ? 2 : 1
                        border.color: "#888"
                        radius: 4
                        color: "#808080"
                    }
                    onClicked: {
                        image_filter.visible = false
                    }
                }
                Button{
                    id: okbutton
                    height: parent.height
                    width: parent.width/2
                    text: "Ok"
                    background: Rectangle {
                        border.width: okbutton.activeFocus ? 2 : 1
                        border.color: "#888"
                        radius: 4
                        color: "#808080"
                    }
                    onClicked: {
                        if (ztext.text === ""){
                            warning.text = "*Insert the Z value"
                        }else if (starttext.text === ""){
                            warning.text = "*Insert the starting number"
                        }else if (restext.text === ""){
                            warning.text = "*Insert the resolution"
                        }else if (ztext.text <= 1){
                            warning.text = "*Z must be greater than 1"
                        }else if (ztext.text % 1 != 0){
                            warning.text = "*Z must be an integer number"
                        }else if (starttext.text < 1){
                            warning.text = "*Starting number must be greater than 1"
                        }else if (starttext.text % 1 != 0){
                            warning.text = "*Starting number must be an integer number"
                        }else if (restext.text <= 0){
                            warning.text = "*Resolution must be positive"
                        }else if (isNaN(Number(ztext.text))){
                            warning.text = "*Z must be a number"
                        }else if (isNaN(Number(starttext.text))){
                            warning.text = "*Starting number must be a number"
                        }else if (isNaN(Number(restext.text))){
                            warning.text = "*Resolution must be a number"
                        }else{
                            btn_state.btnstate = !btn_state.btnstate
                            if (inputdata === "3D Gray"){
                                MainPython.get3DImage(fileurl, ztext.text, starttext.text, restext.text)
                                inputType = "3D Gray"
                            }else{
                                MainPython.get3DImageBinary(fileurl, ztext.text, starttext.text, restext.text)
                                inputType = "3D Binary"
                            }

                            image_filter.visible = false
                        }
                    }
                }
            }
        }
    }
    Shortcut{
        sequences: ["Enter" , "Return"]
        onActivated:{
            if (ztext.text === ""){
                warning.text = "*Insert the Z value"
            }else if (starttext.text === ""){
                warning.text = "*Insert the starting number"
            }else if (restext.text === ""){
                warning.text = "*Insert the resolution"
            }else if (ztext.text <= 1){
                warning.text = "*Z must be greater than 1"
            }else if (ztext.text % 1 != 0){
                warning.text = "*Z must be an integer number"
            }else if (starttext.text < 1){
                warning.text = "*Starting number must be greater than 1"
            }else if (starttext.text % 1 != 0){
                warning.text = "*Starting number must be an integer number"
            }else if (restext.text <= 0){
                warning.text = "*Resolution must be positive"
            }else if (isNaN(Number(ztext.text))){
                warning.text = "*Z must be a number"
            }else if (isNaN(Number(starttext.text))){
                warning.text = "*Starting number must be a number"
            }else if (isNaN(Number(restext.text))){
                warning.text = "*Resolution must be a number"
            }else{
                btn_state.btnstate = !btn_state.btnstate
                if (inputdata === "3D Gray"){
                    MainPython.get3DImage(fileurl, ztext.text, starttext.text, restext.text)
                    inputType = "3D Gray"
                }else{
                    MainPython.get3DImageBinary(fileurl, ztext.text, starttext.text, restext.text)
                    inputType = "3D Binary"
                }

                image_filter.visible = false
            }
        }
    }

}
