import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

import "./../Functions/functions.js" as Functions

Rectangle{
    id: dock_list
    color: "#f8f8ff"

    property bool expand: false
    property alias sResultview: sSegmentView.currentIndex

    onExpandChanged: {
        if(expand === false){
            rightfilepanel.restart()
        }
        else {
            leftfilepanel.restart()
        }
    }

    //-- down Animation --//
    SequentialAnimation{
        id: rightfilepanel
        PropertyAnimation { target: dock_list ; properties: "visible"; to: true ; duration: 1 }
        PropertyAnimation { target: dock_list ; properties: "Layout.preferredWidth"; to: parent.width * 0.2 ; duration: 300 }
    }

    //-- Up Animation --//
    SequentialAnimation{
        id: leftfilepanel
        PropertyAnimation { target: dock_list ; properties: "Layout.preferredWidth"; to: 0 ; duration: 300 }
        PropertyAnimation { target: dock_list ; properties: "visible"; to: false ; duration: 1 }
    }

    Rectangle{
        anchors.fill: parent
        anchors.margins: 7

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 1//8
            verticalOffset: 1//8
            color: "#80000000"
            spread: 0.0
            samples: 17
            radius: 12
        }
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 2

            //-- list view header --//
            ItemDelegate{
                Layout.fillWidth: true

                font.pixelSize: Qt.application.font.pixelSize

                //- back color --//
                Rectangle{anchors.fill: parent; color: "#a9a9a9"; radius: 50; border{width: 1; color: "#22000000"}}

                //-- materialCategory --//
                Label{
                    id: lbtext
                    text: {
                        if (bar.currentIndex === 2){return "Segment"}
                        else if (bar.currentIndex === 1){return "Result"}
                        else if (bar.currentIndex === 0){return "Curve"}
                    }

                    font.pixelSize: Qt.application.font.pixelSize * 1.7
                    anchors.centerIn: parent
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (main1.expand === true){
                            main1.expand = !main1.expand
                        }
                    }
                }
            }

            //-- ListView --//
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#20000000"
                clip: true
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (main1.expand === true){
                            main1.expand = !main1.expand
                        }
                    }
                }

                SwipeView{
                    id: sSegmentView
                    anchors.fill: parent
                    interactive: false
                    visible: testSection1.checked
                    currentIndex: 0
                    Item{
                        Label{
                            id: docktxt
                            anchors.fill: parent
                            text: "Segment"
//                            background: Image{
//                                source: "../Images/Rightpanel.png"
//                                opacity: 0.1
//                            }

                            font.pixelSize: Qt.application.font.pixelSize * 5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: "#1e90ff"
                        }

                        DropShadow {
                            anchors.fill: docktxt
                            horizontalOffset: 3
                            verticalOffset: 15
                            radius: 8.0
                            samples: 17
                            color: "#80000000"
                            source: docktxt
                        }
                    }

                    Item{
                        //-- Border --//
                        Rectangle{
                            anchors.fill: parent

                            border.width: 2
                            border.color: "#dddddd"

                            //-- header --//
                            Rectangle{
                                id: boardHeader
                                width: parent.width
                                height: parent.height * 0.05

                                color: "#1e90ff"

                                Label{
                                    text: "Segmentation Table"
                                    font.pixelSize: Qt.application.font.pixelSize * 1.6
                                    anchors.centerIn: parent
                                    color: "#ffffff"
                                }
                            }

                            ListView{
                                width: parent.width - 4
                                height: parent.height - boardHeader.height

                                anchors.horizontalCenter: parent.horizontalCenter

                                topMargin: 2

                                clip: true

                                anchors.top: boardHeader.bottom

                                //-- HEADER --//
                                header: Rectangle {
                                    width: parent.width
                                    height: 20
                                    z: 2

                                    RowLayout{

                                        width: parent.width
                                        height: parent.height
                                        anchors.top: parent.top
                                        spacing: 0
                                        layoutDirection: Qt.RightToLeft

                                        //-- "Porosity" --//
                                        Rectangle {
                                            id: header_porosity
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3
                                            color: "#ffffff"
                                            clip: true
                                            Label {
                                                text: "Porosity (%)"
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                                anchors.centerIn: parent
                                            }
                                        }

                                        //-- "Threshold" --//
                                        Rectangle {
                                            id: header_threshold
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3
                                            color: "#ffffff"
                                            clip: true
                                            Label {
                                                text: "Threshold"
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                                anchors.centerIn: parent
                                            }
                                        }

                                        //-- "Method" --//
                                        Rectangle {
                                            id: header_User
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3
                                            color: "#ffffff"
                                            clip: true
                                            Label {
                                                text: "Method"
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                                anchors.centerIn: parent
                                            }
                                        }

                                    }



                                }

                                model: tablemodel

                                headerPositioning: ListView.OverlayHeader

                                delegate: Rectangle{
                                    width: parent.width
                                    height: 30

                                    RowLayout{
                                        anchors.fill: parent
                                        spacing: 0
                                        layoutDirection: Qt.RightToLeft

                                        //-- "Porosity" --//
                                        Rectangle{
                                            id: lst_porosity
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3

                                            Label{
                                                width: parent.width
                                                height: parent.height

                                                verticalAlignment: Qt.AlignVCenter
                                                horizontalAlignment: Qt.AlignHCenter

                                                text: model.porosity
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                            }
                                        }


                                        //-- "Threshold" --//
                                        Rectangle{
                                            id: lst_threshold
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3

                                            Label{
                                                width: parent.width
                                                height: parent.height

                                                verticalAlignment: Qt.AlignVCenter
                                                horizontalAlignment: Qt.AlignHCenter

                                                text: model.threshold
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                            }
                                        }

                                        //-- "Method" --//
                                        Rectangle{
                                            id: lst_method
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.3

                                            Label{
                                                width: parent.width
                                                height: parent.height

                                                verticalAlignment: Qt.AlignVCenter
                                                horizontalAlignment: Qt.AlignHCenter

                                                text: model.method
                                                font.pixelSize: Qt.application.font.pixelSize * 1
                                            }
                                        }

                                    }

                                }
                            }

                        }
                    }
                }

                SwipeView{
                    id: sResultView
                    anchors.fill: parent
                    interactive: false
                    visible: testSection2.checked
                    currentIndex: (resultmodel.count === 0) ? 0:1
                    Item{
                        Label{
                            id: resulttxt
                            anchors.fill: parent
                            text: "Result"
//                            background: Image{
//                                source: "../Images/Resultpanel.png"
//                                opacity: 0.1
//                            }
                            font.pixelSize: Qt.application.font.pixelSize * 5
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: "#1e90ff"
                        }

                        DropShadow {
                            anchors.fill: resulttxt
                            horizontalOffset: 3
                            verticalOffset: 15
                            radius: 8.0
                            samples: 17
                            color: "#80000000"
                            source: resulttxt
                        }
                    }

                    Item{
                        //-- Border --//
                        Rectangle{
                            anchors.fill: parent

                            border.width: 2
                            border.color: "#dddddd"

                            ListView{
                                width: parent.width - 4
                                height: parent.height

                                anchors.horizontalCenter: parent.horizontalCenter

                                topMargin: 2

                                clip: true

                                model: resultmodel

                                delegate: Rectangle{
                                    width: parent.width
                                    height: 30
                                    color: (index%2===0) ? "#f0f8ff":"#a9a9a9"

                                    Label{
                                        width: parent.width
                                        height: parent.height

                                        verticalAlignment: Qt.AlignVCenter
                                        leftPadding: 5

                                        text: model.text
                                        font.pixelSize: Qt.application.font.pixelSize * 1
                                    }
                                }
                            }

                        }
                    }
                }

                ScrollView{
                    id: sCurveView
                    anchors.fill: parent
                    visible: testSection3.checked
                    clip: true

                    Column{
                        spacing: 0

                        CheckBox{
                            text: "PSD (Image)"
                            onCheckStateChanged: {
                                if (psdImage){
                                    curvemodel.remove(Functions.find(curvemodel, "PSD (Image)"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "PSD (Image)",
                                                          "number": 1
                                                      })

                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                psdImage = !psdImage
                            }
                        }
                        CheckBox{
                            text: "GSD (Image)"
                            onCheckStateChanged: {
                                if (gsdImage){
                                    curvemodel.remove(Functions.find(curvemodel, "GSD (Image)"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "GSD (Image)",
                                                          "number": 2
                                                      })

                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                gsdImage = !gsdImage
                            }
                        }
                        CheckBox{
                            text: "S2"
                            onCheckStateChanged: {
                                if (s2){
                                    curvemodel.remove(Functions.find(curvemodel, "S2"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "S2",
                                                          "number": 3
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                s2 = !s2
                            }
                        }
                        CheckBox{
                            text: "PSD (Network)"
                            onCheckStateChanged: {
                                if (psdnetwork){
                                    curvemodel.remove(Functions.find(curvemodel, "PSD (Network)"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "PSD (Network)",
                                                          "number": 4
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                psdnetwork = !psdnetwork
                            }
                        }
                        CheckBox{
                            text: "TSD (Network)"
                            onCheckStateChanged: {
                                if (tsdnetwork){
                                    curvemodel.remove(Functions.find(curvemodel, "TSD (Network)"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "TSD (Network)",
                                                          "number": 5
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                tsdnetwork = !tsdnetwork
                            }
                        }
                        CheckBox{
                            text: "Coordination number"
                            onCheckStateChanged: {
                                if (coord){
                                    curvemodel.remove(Functions.find(curvemodel, "Coordination number"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "Coordination number",
                                                          "number": 6
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                coord = !coord
                            }
                        }
                        CheckBox{
                            text: "Capillary pressure"
                            onCheckStateChanged: {
                                if (cp){
                                    curvemodel.remove(Functions.find(curvemodel, "Capillary pressure"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "Capillary pressure",
                                                          "number": 7
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                cp = !cp
                            }
                        }
                        CheckBox{
                            text: "Relative permeability"
                            onCheckStateChanged: {
                                if (kr){
                                    curvemodel.remove(Functions.find(curvemodel, "Relative permeability"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "Relative permeability",
                                                          "number": 8
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                kr = !kr
                            }
                        }
                        CheckBox{
                            text: "Relative diffusivity"
                            onCheckStateChanged: {
                                if (dr){
                                    curvemodel.remove(Functions.find(curvemodel, "Relative diffusivity"))
                                    bar_main.currentIndex = curvemodel.count - 1
                                }else{
                                    curvemodel.append({
                                                          "text": "Relative diffusivity",
                                                          "number": 9
                                                      })
                                    bar_main.currentIndex = curvemodel.count - 1
                                }
                                dr = !dr
                            }
                        }
                    }
                }


            }

            //-- footer--//
            TabBar {
                id: bar
                Layout.fillWidth: true
                rotation: 180

                font.pixelSize: Qt.application.font.pixelSize
                Material.accent: "#6c88b7"

                currentIndex: (isGray) ? 2:1

                //-- Section 3 Button --//
                TabButton {
                    id: testSection3
                    rotation: 180
                    enabled: setting.isLicensed

                    signal checkSection3()
                    onCheckSection3: {
                        checked = true
                    }

                    Label{
                        text: "Curve"
                        font.bold: testSection3.checked ? true : false
                        font.pixelSize: testSection3.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                        color: testSection3.checked ? "#000000" : "#aaaaaa"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        checkSection3()
                        if (main1.expand === true){
                            main1.expand = !main1.expand
                        }
                    }

                }

                //-- Section 2 Button --//
                TabButton {
                    id: testSection2
                    rotation: 180
                    enabled: setting.isLicensed

                    signal checkSection2()
                    onCheckSection2: {
                        checked = true
                        if (main1.expand === true){
                            main1.expand = !main1.expand
                        }
                    }

                    Label{
                        text: "Result"
                        font.bold: testSection2.checked ? true : false
                        font.pixelSize: testSection2.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                        color: testSection2.checked ? "#000000" : "#aaaaaa"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        checkSection2()
                    }
                }

                //-- Section 1 Button --//
                TabButton {
                    id: testSection1
                    rotation: 180
                    enabled: setting.isLicensed

                    signal checkSection1()
                    onCheckSection1: {
                        checked = true
                        if (main1.expand === true){
                            main1.expand = !main1.expand
                        }
                    }

                    Label{
                        text: "Segment"
                        font.bold: testSection1.checked ? true : false
                        font.pixelSize: testSection1.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                        color: testSection1.checked ? "#000000" : "#aaaaaa"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        checkSection1()
                    }

                }

            }

        }

    }
}
