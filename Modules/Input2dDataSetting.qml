import QtQuick 2.14
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    anchors.fill: parent

    objectName: "2D_image"

    property string fileurl: ""

    signal reNextNumber(var xDim, var yDim)
    signal reNextNumberBinary(var xDim, var yDim, var porosity, var xData, var yData, var gxData, var gyData)
    signal reNextNumberThinsection(var xDim, var yDim)

    width: 300
    height: 400


    onReNextNumber: {
        xdim = xDim
        ydim = yDim
        zdim = 1
        resolution = restext.text
        swipTitle = "Input"
        section1.checked = true
        sView.currentIndex = 1
        inputmodel.clear()
        inputmodel.append({
                              "maintext": inputdata,
                              "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + 1
                          })

        sceneset.source1 = "file:///" + offlineStoragePath + "/MImages/M0001.png"
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
    }

    onReNextNumberBinary: {
        porexData = xData
        poreyData = yData
        psdchart.plot()
        grainxData = gxData
        grainyData = gyData
        gsdchart.plot()
        xdim = xDim
        ydim = yDim
        zdim = 1
        resolution = restext.text
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
                              "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + 1
                          })

        sceneset.source1 = "file:///" + offlineStoragePath + "/MImages/M0001.png"
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
    }

    onReNextNumberThinsection: {
        xdim = xDim
        ydim = yDim
        zdim = 1
        resolution = restext.text
        swipTitle = "Input"
        section1.checked = true
        sView.currentIndex = 1
        inputmodel.clear()
        inputmodel.append({
                              "maintext": inputdata,
                              "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + 1
                          })

        sceneset.source1 = "file:///" + offlineStoragePath + "/MImages/M0001.png"
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
    }


    Component.onCompleted: {
        MainPython.nextNumber.connect(reNextNumber)
        MainPython.nextNumberBinary.connect(reNextNumberBinary)
        MainPython.nextNumberThinsection.connect(reNextNumberThinsection)
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
                        image2d_filter.visible = false
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
                        if (restext.text === ""){
                            warning.text = "*Insert the resolution"
                        }else if (isNaN(Number(restext.text))){
                            warning.text = "*Resolution must be a number"
                        }else{

                            if (inputdata === "2D Gray"){
                                MainPython.get2DImage(fileurl, restext.text)
                                inputType = "2D Gray"
                            }else if (inputdata === "2D Binary"){
                                MainPython.get2DImageBinary(fileurl, restext.text)
                                inputType = "2D Binary"
                            }else if (inputdata === "2D Thinsection"){
                                MainPython.get2DImageThinsection(fileurl, restext.text)
                                inputType = "2D Thinsection"
                            }

                            image2d_filter.visible = false
                        }
                    }
                }
            }
        }
    }
    Shortcut{
        sequences: ["Enter" , "Return"]
        onActivated:{
            if (restext.text === ""){
                warning.text = "*Insert the resolution"
            }else if (isNaN(Number(restext.text))){
                warning.text = "*Resolution must be a number"
            }else{

                if (inputdata === "2D Gray"){
                    MainPython.get2DImage(fileurl, restext.text)
                    inputType = "2D Gray"
                }else if (inputdata === "2D Binary"){
                    MainPython.get2DImageBinary(fileurl, restext.text)
                    inputType = "2D Binary"
                }else if (inputdata === "2D Thinsection"){
                    MainPython.get2DImageThinsection(fileurl, restext.text)
                    inputType = "2D Thinsection"
                }

                image2d_filter.visible = false
            }
        }
    }
}
