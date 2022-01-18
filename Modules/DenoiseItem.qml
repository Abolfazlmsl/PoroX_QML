import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12


Item {
    id: denoiseitem

    anchors.fill: parent

    objectName: "Denoise"

    property alias denoiseparam: proptxt.text

    property string method: "Gaussian"

    signal getDenoiseImage(var param, bool success)

    onGetDenoiseImage: {
        denoisebutton.enabled = !denoisebutton.enabled
        if (success){
            btn_state.btnstate = !btn_state.btnstate
            if (method === "Prewitt" || method === "Sobel" || method === "Laplace"){
                imagehandlemodel.append({
                                            "maintext": "Denoise",
                                            "proptext": method,
                                        })
            }else if (method === "Gaussian" || method === "Gaussian-Laplace"){
                imagehandlemodel.append({
                                            "maintext": "Denoise",
                                            "proptext": method + " (Sigma:" + param + ")"
                                        })
            }else{
                imagehandlemodel.append({
                                            "maintext": "Denoise",
                                            "proptext": method + " (Size:" + param + ")"
                                        })
            }

            if (!findbyName(scene2dModel, "2D Denoise")){
                scene2dModel.append(
                            {
                                "name":"2D Denoise",
                                "state": false
                            }
                            )
            }

            acceptPop.bodyText_Dialog = "Denoising was done successfully"
            acceptPop.visible = true
            denoise_image = true
            filepanel.saveEnable = true
        }else{
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.denoiseImage.connect(getDenoiseImage)


    state: "Gaussian"

    //-- state of filter item --//
    states: [
        State {
            name: "Gaussian"
            PropertyChanges {
                target: txt
                text : "Sigma:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        },
        State {
            name: "Prewitt"
            PropertyChanges {
                target: txt
                text : ""
            }
            PropertyChanges {
                target: proptxt
                text : ""
            }
            PropertyChanges {
                target: textsetting
                visible : false
            }
        },
        State {
            name: "Sobel"
            PropertyChanges {
                target: txt
                text : ""
            }
            PropertyChanges {
                target: proptxt
                text : ""
            }
            PropertyChanges {
                target: textsetting
                visible : false
            }
        },
        State {
            name: "Laplace"
            PropertyChanges {
                target: txt
                text : ""
            }
            PropertyChanges {
                target: proptxt
                text : ""
            }
            PropertyChanges {
                target: textsetting
                visible : false
            }
        },
        State {
            name: "Gaussian-Laplace"
            PropertyChanges {
                target: txt
                text : "Sigma:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        },
        State {
            name: "Minimum"
            PropertyChanges {
                target: txt
                text : "Size:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        },
        State {
            name: "Maximum"
            PropertyChanges {
                target: txt
                text : "Size:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        },
        State {
            name: "Median"
            PropertyChanges {
                target: txt
                text : "Size:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        },
        State {
            name: "Rank"
            PropertyChanges {
                target: txt
                text : "Size:"
            }
            PropertyChanges {
                target: proptxt
                text : "2"
            }
            PropertyChanges {
                target: textsetting
                visible : true
            }
        }


    ]

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
                text: "Choose the Noise Removal Method:"
            }

            ScrollView{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.6
                clip: true

                Column{
                    spacing: 0

                    RadioButton{
                        checked: (method === "Gaussian")
                        text: "Gaussian"
                        onClicked: {
                            denoiseitem.state = "Gaussian"
                            method = "Gaussian"
                        }
                    }
                    RadioButton{
                        checked: (method === "Prewitt")
                        text: "Prewitt"
                        onClicked: {
                            denoiseitem.state = "Prewitt"
                            method = "Prewitt"
                        }
                    }
                    RadioButton{
                        checked: (method === "Sobel")
                        text: "Sobel"
                        onClicked: {
                            denoiseitem.state = "Sobel"
                            method = "Sobel"
                        }
                    }
                    RadioButton{
                        checked: (method === "Laplace")
                        text: "Laplace"
                        onClicked: {
                            denoiseitem.state = "Laplace"
                            method = "Laplace"
                        }
                    }
                    RadioButton{
                        checked: (method === "Gaussian-Laplace")
                        text: "Gaussian-Laplace"
                        onClicked: {
                            denoiseitem.state = "Gaussian-Laplace"
                            method = "Gaussian-Laplace"
                        }
                    }
                    RadioButton{
                        checked: (method === "Minimum")
                        text: "Minimum"
                        onClicked: {
                            denoiseitem.state = "Minimum"
                            method = "Minimum"
                        }
                    }
                    RadioButton{
                        checked: (method === "Maximum")
                        text: "Maximum"
                        onClicked: {
                            denoiseitem.state = "Maximum"
                            method = "Maximum"
                        }
                    }
                    RadioButton{
                        checked: (method === "Median")
                        text: "Median"
                        onClicked: {
                            denoiseitem.state = "Median"
                            method = "Median"
                        }
                    }
                    RadioButton{
                        checked: (method === "Rank")
                        text: "Rank"
                        onClicked: {
                            denoiseitem.state = "Rank"
                            method = "Rank"
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
                        text: "Sigma:"
                    }
                    TextField{
                        id: proptxt
                        Layout.preferredHeight: parent.height / 2
                        Layout.fillWidth: true
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        font.pixelSize: Qt.application.font.pixelSize * 1.7
                        selectByMouse: true
                        maximumLength: 2
                    }

                }
            }

            Button{
                id: denoisebutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Apply De-noising"
                background: Rectangle {

                    border.width: denoisebutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (textsetting.visible && proptxt.text == ""){
                            warningPop.bodyText_Dialog = "Insert the " + txt.text
                            warningPop.visible = true
                        }else if (proptxt.text != "" && isNaN(Number(proptxt.text))){
                            warningPop.bodyText_Dialog = txt.text + " must be a number"
                            warningPop.visible = true
                        }else{
                            denoisebutton.enabled = !denoisebutton.enabled
                            btn_state.btnstate = !btn_state.btnstate
                            MainPython.denoise(method, proptxt.text)
                        }
                    }
                }
            }
        }

    }

}
