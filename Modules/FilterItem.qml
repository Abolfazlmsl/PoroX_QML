import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import "./../Functions/functions.js" as Functions

Item {
    id: filteritem

    anchors.fill: parent

    property alias filterparam1: proptext1.text
    property alias filterparam2: proptext2.text
    property alias filterparam3: proptext3.text
    property alias filterparam4: proptext4.text

    objectName: "Filter"

    property string method: "Bilateral"

    signal getFilterImage(var param1, var param2, var param3, var param4, bool success)

    onGetFilterImage: {
        filterbutton.enabled = !filterbutton.enabled
        if (success){
            btn_state.btnstate = !btn_state.btnstate
            if (filteritem.state === "Bilateral"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "d:" + param1 + ", sigmaColor:" + param2 + ", sigmaSpace:" + param3
                                        })
            }else if (filteritem.state === "Bilateral Modified"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "sigam_s:" + param1 + ", sigma_v:" + param2
                                        })
            }else if (filteritem.state === "Averaging"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "kernel:" + param1
                                        })
            }else if (filteritem.state === "Smoothing"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "ksizeArg1:" + param1 + ", ksizeArg2:" + param2
                                        })
            }else if (filteritem.state === "Gaussian"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "ksizeArg1:" + param1 + ", ksizeArg2:" + param2 + ", sigmaX:" + param3 + ", sigmaY:" + param4
                                        })
            }else if (filteritem.state === "Median"){
                imagehandlemodel.append({
                                            "maintext": "Filter" + " (" + method + ")",
                                            "proptext": "size:" + param1
                                        })
            }

            if (!Functions.findbyName(scene2dModel, "2D Filter")){
                scene2dModel.append(
                            {
                                "name":"2D Filter",
                                "state": false
                            }
                            )
            }

            acceptPop.bodyText_Dialog = "Filtering was done successfully"
            acceptPop.visible = true
            filter_image = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.filterImage.connect(getFilterImage)

    state: "Bilateral"

    //-- state of filter item --//
    states: [
        State {
            name: "Bilateral"
            PropertyChanges {
                target: txt1
                text : "d:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : true
            }
            PropertyChanges {
                target: txt2
                text : "sigmaColor:"
            }
            PropertyChanges {
                target: proptext2
                text : "3"
            }
            PropertyChanges {
                target: row3
                visible : true
            }
            PropertyChanges {
                target: txt3
                text : "sigmaSpace:"
            }
            PropertyChanges {
                target: proptext3
                text : "3"
            }
            PropertyChanges {
                target: row4
                visible : false
            }
            PropertyChanges {
                target: txt4
                text : ""
            }
            PropertyChanges {
                target: proptext4
                text : ""
            }
        },
        State {
            name: "Bilateral Modified"
            PropertyChanges {
                target: txt1
                text : "sigma_s:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : true
            }
            PropertyChanges {
                target: txt2
                text : "sigma_v:"
            }
            PropertyChanges {
                target: proptext2
                text : "2"
            }
            PropertyChanges {
                target: row3
                visible : false
            }
            PropertyChanges {
                target: txt3
                text : ""
            }
            PropertyChanges {
                target: proptext3
                text : ""
            }
            PropertyChanges {
                target: row4
                visible : false
            }
            PropertyChanges {
                target: txt4
                text : ""
            }
            PropertyChanges {
                target: proptext4
                text : ""
            }
        },
        State {
            name: "Averaging"
            PropertyChanges {
                target: txt1
                text : "Kernel:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : false
            }
            PropertyChanges {
                target: txt2
                text : ""
            }
            PropertyChanges {
                target: proptext2
                text : ""
            }
            PropertyChanges {
                target: row3
                visible : false
            }
            PropertyChanges {
                target: txt3
                text : ""
            }
            PropertyChanges {
                target: proptext3
                text : ""
            }
            PropertyChanges {
                target: row4
                visible : false
            }
            PropertyChanges {
                target: txt4
                text : ""
            }
            PropertyChanges {
                target: proptext4
                text : ""
            }
        },
        State {
            name: "Smoothing"
            PropertyChanges {
                target: txt1
                text : "ksizeArg1:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : true
            }
            PropertyChanges {
                target: txt2
                text : "ksizeArg2:"
            }
            PropertyChanges {
                target: proptext2
                text : "2"
            }
            PropertyChanges {
                target: row3
                visible : false
            }
            PropertyChanges {
                target: txt3
                text : ""
            }
            PropertyChanges {
                target: proptext3
                text : ""
            }
            PropertyChanges {
                target: row4
                visible : false
            }
            PropertyChanges {
                target: txt4
                text : ""
            }
            PropertyChanges {
                target: proptext4
                text : ""
            }
        },
        State {
            name: "Gaussian"
            PropertyChanges {
                target: txt1
                text : "ksizeArg1:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : true
            }
            PropertyChanges {
                target: txt2
                text : "ksizeArg2:"
            }
            PropertyChanges {
                target: proptext2
                text : "2"
            }
            PropertyChanges {
                target: row3
                visible : true
            }
            PropertyChanges {
                target: txt3
                text : "sigmaX:"
            }
            PropertyChanges {
                target: proptext3
                text : "2"
            }
            PropertyChanges {
                target: row4
                visible : true
            }
            PropertyChanges {
                target: txt4
                text : "sigmaY:"
            }
            PropertyChanges {
                target: proptext4
                text : "2"
            }
        },
        State {
            name: "Median"
            PropertyChanges {
                target: txt1
                text : "ksize:"
            }
            PropertyChanges {
                target: proptext1
                text : "2"
            }
            PropertyChanges {
                target: row2
                visible : false
            }
            PropertyChanges {
                target: txt2
                text : ""
            }
            PropertyChanges {
                target: proptext2
                text : ""
            }
            PropertyChanges {
                target: row3
                visible : false
            }
            PropertyChanges {
                target: txt3
                text : ""
            }
            PropertyChanges {
                target: proptext3
                text : ""
            }
            PropertyChanges {
                target: row4
                visible : false
            }
            PropertyChanges {
                target: txt4
                text : ""
            }
            PropertyChanges {
                target: proptext4
                text : ""
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
                text: "Choose the Filtering Method:"
            }

            ScrollView{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.4
                clip: true

                Column{
                    spacing: 0

                    RadioButton{
                        checked: (method === "Bilateral")
                        text: "Bilateral"
                        onClicked: {
                            method = "Bilateral"
                            filteritem.state = "Bilateral"
                        }
                    }
                    RadioButton{
                        checked: (method === "Bilateral Modified")
                        text: "Bilateral Modified"
                        onClicked: {
                            method = "Bilateral Modified"
                            filteritem.state = "Bilateral Modified"
                        }
                    }
                    RadioButton{
                        checked: (method === "Averaging")
                        text: "Averaging"
                        onClicked: {
                            method = "Averaging"
                            filteritem.state = "Averaging"
                        }
                    }
                    RadioButton{
                        checked: (method === "Smoothing")
                        text: "Smoothing"
                        onClicked: {
                            method = "Smoothing"
                            filteritem.state = "Smoothing"
                        }
                    }
                    RadioButton{
                        checked: (method === "Gaussian")
                        text: "Gaussian"
                        onClicked: {
                            method = "Gaussian"
                            filteritem.state = "Gaussian"
                        }
                    }
                    RadioButton{
                        checked: (method === "Median")
                        text: "Median"
                        onClicked: {
                            method = "Median"
                            filteritem.state = "Median"
                        }
                    }
                }
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.1

                RowLayout{
                    id: textsetting
                    anchors.fill: parent
                    spacing: 0

                    Label{
                        id: txt1
                        Layout.fillHeight: true
                        //                        Layout.preferredWidth: txt.width
                        verticalAlignment: Qt.AlignVCenter


                    }
                    TextField{
                        id: proptext1
                        Layout.preferredHeight: parent.height
                        Layout.fillWidth: true
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        font.pixelSize: Qt.application.font.pixelSize* 1.7
                        selectByMouse: true
                        maximumLength: 2

                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.1

                RowLayout{
                    id: row2
                    anchors.fill: parent
                    spacing: 0


                    Label{
                        id: txt2
                        Layout.fillHeight: true
                        //                        Layout.preferredWidth: txt.width
                        verticalAlignment: Qt.AlignVCenter


                    }
                    TextField{
                        id: proptext2
                        Layout.preferredHeight: parent.height
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

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.1

                RowLayout{
                    id: row3
                    anchors.fill: parent
                    spacing: 0


                    Label{
                        id: txt3
                        Layout.fillHeight: true
                        //                        Layout.preferredWidth: txt.width
                        verticalAlignment: Qt.AlignVCenter


                    }
                    TextField{
                        id: proptext3
                        Layout.preferredHeight: parent.height
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

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height *0.1

                RowLayout{
                    id: row4
                    anchors.fill: parent
                    spacing: 0


                    Label{
                        id: txt4
                        Layout.fillHeight: true
                        //                        Layout.preferredWidth: txt.width
                        verticalAlignment: Qt.AlignVCenter


                    }
                    TextField{
                        id: proptext4
                        Layout.preferredHeight: parent.height
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
                id: filterbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Apply Filtering"
                background: Rectangle {

                    border.width: filterbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (proptext1.text == ""){
                            warningPop.bodyText_Dialog = "Insert the " + txt1.text
                            warningPop.visible = true
                        }else if (row2.visible && proptext2.text == ""){
                            warningPop.bodyText_Dialog = "Insert the " + txt2.text
                            warningPop.visible = true
                        }else if (row3.visible && proptext3.text == ""){
                            warningPop.bodyText_Dialog = "Insert the " + txt3.text
                            warningPop.visible = true
                        }else if (row4.visible && proptext4.text == ""){
                            warningPop.bodyText_Dialog = "Insert the " + txt4.text
                            warningPop.visible = true
                        }else if (proptext1.text != "" && isNaN(Number(proptext1.text))){
                            warningPop.bodyText_Dialog = txt1.text + " must be a number"
                            warningPop.visible = true
                        }else if (proptext2.text != "" && isNaN(Number(proptext2.text))){
                            warningPop.bodyText_Dialog = txt2.text + " must be a number"
                            warningPop.visible = true
                        }else if (proptext3.text != "" && isNaN(Number(proptext3.text))){
                            warningPop.bodyText_Dialog = txt3.text + " must be a number"
                            warningPop.visible = true
                        }else if (proptext4.text != "" && isNaN(Number(proptext4.text))){
                            warningPop.bodyText_Dialog = txt4.text + " must be a number"
                            warningPop.visible = true
                        }else{
                            filterbutton.enabled = !filterbutton.enabled
                            btn_state.btnstate = !btn_state.btnstate
                            MainPython.filter(method, proptext1.text, proptext2.text, proptext3.text, proptext4.text)
                        }
                    }
                }
            }
        }

    }

}
