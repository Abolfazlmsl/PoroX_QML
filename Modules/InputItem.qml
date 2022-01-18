import QtQuick 2.14
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    id: voronoiitem

    anchors.fill: parent

    objectName: "Input"

    signal getSwithResult(var porosity, var xData, var yData, var gxData, var gyData)

    onGetSwithResult: {
        porexData = xData
        poreyData = yData
        psdchart.plot()
        grainxData = gxData
        grainyData = gyData
        gsdchart.plot()

        totalPorosity = porosity
        resultmodel.setProperty(0, "text", "Porosity (Original image): " + porosity + "%")
        swipTitle = "Input"
        section1.checked = true
        sView.currentIndex = 1

        sceneset.source1 = ""
        if (inputdata === "3D Binary"){
            sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"
        }else{
            sceneset.source1 = "file:///" + offlineStoragePath + "/MImages/M0001.png"
        }

        main_image = true
    }

    Component.onCompleted: MainPython.changeBW.connect(getSwithResult)


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
                Layout.preferredHeight: parent.height
                Column{
                    anchors.fill: parent
                    spacing: 0

                    Label{
                        height: parent.height / 10

                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                        font.bold: true
                        text: "Image properties:"
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
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: xdim
                            readOnly: true
                        }
                        TextField{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: ydim
                            readOnly: true
                        }
                        TextField{
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3.5
                            font.pixelSize: Qt.application.font.pixelSize
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            selectByMouse: true
                            text: zdim
                            readOnly: true
                        }
                    }


                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }
                    Label{
                        width: parent.width
                        height: parent.height / 20
                        topPadding: 5

                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        text: "Resolution:"
                    }

                    TextField{
                        width: parent.width
                        height: parent.height /10
                        font.pixelSize: Qt.application.font.pixelSize
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        selectByMouse: true
                        text: resolution
                        readOnly: true
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height / 20
                        color: "transparent"
                    }

                    CheckBox{
                        width: parent.width
                        height: parent.height /10
                        visible: !isGray
                        text: "Switch Black/White"

                        onCheckStateChanged: {
                            MainPython.changeBlackWhite()
                        }
                    }


                }
            }
        }
    }

}
