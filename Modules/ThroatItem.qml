import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import "./../Fonts/Icon.js" as Icons
import "./../Functions/functions.js" as Functions

Item {
    id: poreitem

    anchors.fill: parent

    property alias throatdiamcheck: throatdiamcb.checked
    property alias throatdiamstate: throatdiamrec.state
    property alias throatseedcheck: throatseedcb.checked
    property alias throatseedstate: throatseedrec.state
    property alias throatsurfcheck: throatsurfcb.checked
    property alias throatsurfstate: throatsurfrec.state
    property alias throatvolcheck: throatvolcb.checked
    property alias throatvolstate: throatvolrec.state
    property alias throatareacheck: throatareacb.checked
    property alias throatareastate: throatarearec.state
    property alias throatendcheck: throatendcb.checked
    property alias throatendstate: throatendrec.state
    property alias throatlencheck: throatlencb.checked
    property alias throatlenstate: throatlenrec.state
    property alias throatpericheck: throatpericb.checked
    property alias throatperistate: throatperirec.state
    property alias throatshapecheck: throatshapecb.checked
    property alias throatshapestate: throatshaperec.state

    signal changethroatdiam(var param1, var param2, var param3, var param4)
    onChangethroatdiam: {
        throatdiamModel.clear()
        if(throatdiamchx.currentText === "Weibull" || throatdiamchx.currentText === "Generic_distribution"){
            throatdiamModel.append({"name": "Shape:", "value": param1})
            throatdiamModel.append({"name": "Scale:", "value": param2})
            throatdiamModel.append({"name": "Loc:", "value": param3})
            downdiam.restart()
        }else if (throatdiamchx.currentText === "Normal"){
            throatdiamModel.append({"name": "Scale:", "value": param2})
            throatdiamModel.append({"name": "Loc:", "value": param3})
            downdiam.restart()
        }else if (throatdiamchx.currentText === "Random"){
            updiam.restart()
        }else if (throatdiamchx.currentText === "From_neighbor_pores"){
            throatdiamModel.append({"name": "Mode:", "value": param4})
            downdiam.restart()
        }
        throatdiamType = throatdiamchx.currentText
    }

    property bool diamopen: false

    objectName: "Throat"

    Component.onCompleted: {}

    //-- Diameter Animation --//
    ParallelAnimation{
        id: downdiam
        PropertyAnimation { target: throatdiamrec ; properties: "height"; to: 100+throatdiamModel.count*50 ; duration: 300 }
        PropertyAnimation { target: diamIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Diameter Animation --//
    ParallelAnimation{
        id: updiam
        PropertyAnimation { target: throatdiamrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: diamIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    Flickable{
        id: throatflick
        anchors.fill: parent
        clip: true

        contentWidth: parent.width
        contentHeight: 800 + throatdiamrec.height
        ScrollBar.vertical: ScrollBar {

        }
        Rectangle{
            anchors.fill: parent
            color: "#f8f8ff"

            Column{
                anchors.fill: parent
                spacing: 0

                Rectangle{
                    id: throatdiamrec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "From_neighbor_pores"

                    states: [
                        State {
                            name: "Weibull"
                            PropertyChanges {
                                target: porediamchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Normal"
                            PropertyChanges {
                                target: throatdiamchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Random"
                            PropertyChanges {
                                target: throatdiamchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Generic_distribution"
                            PropertyChanges {
                                target: throatdiamchx
                                currentIndex: 3
                            }
                        },
                        State {
                            name: "From-neighbor-throats"
                            PropertyChanges {
                                target: throatdiamchx
                                currentIndex: 4
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatdiamcb
                            width: parent.width / 2
                            height: 50
                            text: "Diameter"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatdiamType = throatdiamchx.currentText
                                    throatmode = "min"
                                    return true
                                }else{
                                    return false
                                }
                            }

                            onCheckStateChanged: {
                                throatdiam = !throatdiam
                                throatdiamchx.currentIndex = 4
                                throatdiamchx.enabled = !throatdiamchx.enabled
                                diamIcon.enabled = !diamIcon.enabled
                                if(throatdiam){
                                    throatdiamModel.append({"name": "Mode:", "value": "min"})
                                    downdiam.restart()
                                    diamopen = !diamopen
                                    throatdiamType = throatdiamchx.currentText
                                    throatmode = "min"
                                    geometrymodel.append({
                                                          "maintext": "Throat diameter",
                                                          "proptext": "Throat diameter" + " (" + throatdiamType + ")"
                                                      })
                                }else{
                                    updiam.restart()
                                    throatdiamModel.clear()
                                    diamopen = !diamopen
                                    throatdiamType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat diameter")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.diameter")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatdiam)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: 50
                            spacing: 10
                            ComboBox{
                                id: throatdiamchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Weibull" }
                                    ListElement { text: "Normal" }
                                    ListElement { text: "Random" }
                                    ListElement { text: "Generic_distribution" }
                                    ListElement { text: "From_neighbor_pores" }
//                                    ListElement { text: "Equivalent_diameter" }
                                }

                                onActivated: {
                                    throatdiamModel.clear()
                                    if(throatdiamchx.currentText === "Weibull" || throatdiamchx.currentText === "Generic_distribution"){
                                        throatdiamModel.append({"name": "Shape:", "value": "1.5"})
                                        throatdiamModel.append({"name": "Scale:", "value": "0.000001"})
                                        throatdiamModel.append({"name": "Loc:", "value": "0"})
                                        downdiam.restart()
                                    }else if (throatdiamchx.currentText === "Normal"){
                                        throatdiamModel.append({"name": "Scale:", "value": "0.000001"})
                                        throatdiamModel.append({"name": "Loc:", "value": "0"})
                                        downdiam.restart()
                                    }else if (throatdiamchx.currentText === "Random"){
                                        updiam.restart()
                                    }else if (throatdiamchx.currentText === "From_neighbor_pores"){
                                        throatdiamModel.append({"name": "Mode:", "value": "min"})
                                        downdiam.restart()
                                    }
                                    throatdiamType = throatdiamchx.currentText
                                    throatdiamChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                id: diamIcon
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                text: Icons.settings

                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter

                                MouseArea{
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if(diamopen){
                                            updiam.restart()
                                            diamopen = !diamopen
                                        }else{
                                            downdiam.restart()
                                            diamopen = !diamopen
                                        }
                                    }
                                }
                            }
                        }
                        Rectangle{
                            id: diamproprec
                            width: parent.width / 2
                            height: throatdiamModel.count*50
                            color: "transparent"
                            ListView{
                                anchors.fill: parent
                                model: ListModel{id: throatdiamModel}
                                delegate: RowLayout{
                                    width: throatdiamrec.width
                                    height: 50

                                    Label{
                                        Layout.fillHeight: true
                                        verticalAlignment: Qt.AlignVCenter

                                        text: model.name
                                    }
                                    TextField{
                                        Layout.preferredHeight: parent.height
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.7
                                        selectByMouse: true
                                        //                                        maximumLength: 2
                                        text: model.value

                                        onTextChanged: {
                                            if(throatdiamchx.currentText === "Weibull" || throatdiamchx.currentText === "Generic_distribution"){
                                                if (model.index === 0){
                                                    throatShape = text
                                                }else if (model.index === 1){
                                                    throatscale = text
                                                }else if (model.index === 2){
                                                    throatloc = text
                                                }
                                            }else if (throatdiamchx.currentText === "Normal"){
                                                if (model.index === 0){
                                                    throatscale = text
                                                }else if (model.index === 1){
                                                    throatloc = text
                                                }
                                            }else if (throatdiamchx.currentText === "From_neighbor_pores"){
                                                if (model.index === 0){
                                                    throatmode = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle{
                    id: throatseedrec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Random"

                    states: [
                        State {
                            name: "Random"
                            PropertyChanges {
                                target: throatseedchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "From_neighbor_pores"
                            PropertyChanges {
                                target: throatseedchx
                                currentIndex: 1
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatseedcb
                            width: parent.width / 2
                            text: "Seed"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatseedType = throatseedchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }

                            onCheckStateChanged: {
                                throatseed = !throatseed
                                throatseedchx.currentIndex = 0
                                throatseedchx.enabled = !throatseedchx.enabled
                                if (throatseed){
                                    throatseedType = throatseedchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat seed",
                                                          "proptext": "Throat seed" + " (" + throatseedType + ")"
                                                      })
                                }else{
                                    throatseedType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat seed")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.seed")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatseed)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatseedchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#ffffff"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Random" }
                                    ListElement { text: "From_neighbor_pores" }
                                }

                                onActivated: {
                                    throatseedType = throatseedchx.currentText
                                    throatseedChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false

                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatsurfrec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "Cylinder"

                    states: [
                        State {
                            name: "Cylinder"
                            PropertyChanges {
                                target: throatsurfchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Cuboid"
                            PropertyChanges {
                                target: throatsurfchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Extrusion"
                            PropertyChanges {
                                target: throatsurfchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Rectangle"
                            PropertyChanges {
                                target: throatsurfchx
                                currentIndex: 3
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatsurfcb
                            width: parent.width / 2
                            text: "Surface area"

                            onCheckStateChanged: {
                                throatsurf = !throatsurf
                                throatsurfchx.currentIndex = 0
                                throatsurfchx.enabled = !throatsurfchx.enabled
                                if(throatsurf){
                                    throatsurfType = throatsurfchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat surface area",
                                                          "proptext": "Throat surface area" + " (" + throatsurfType + ")"
                                                      })
                                }else{
                                    throatsurfType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat surface area")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.surface area")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatsurf)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatsurfchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Cylinder" }
                                    ListElement { text: "Cuboid" }
                                    ListElement { text: "Extrusion" }
                                    ListElement { text: "Rectangle" }
                                }
                                onActivated: {
                                    throatsurfType = throatsurfchx.currentText
                                    throatsurfChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatvolrec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Cylinder"

                    states: [
                        State {
                            name: "Cylinder"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Cuboid"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Extrusion"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Rectangle"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 3
                            }
                        },
                        State {
                            name: "Lens"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 4
                            }
                        },
                        State {
                            name: "Pendular_ring"
                            PropertyChanges {
                                target: throatvolchx
                                currentIndex: 5
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatvolcb
                            width: parent.width / 2
                            text: "Volume"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatvolType = throatvolchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                throatvol = !throatvol
                                throatvolchx.currentIndex = 0
                                throatvolchx.enabled = !throatvolchx.enabled
                                if(throatvol){
                                    throatvolType = throatvolchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat volume",
                                                          "proptext": "Throat volume" + " (" + throatvolType + ")"
                                                      })
                                }else{
                                    throatvolType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat volume")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }
                                var index = Functions.find(helpmodel, "throat.volume")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatvol)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatvolchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Cylinder" }
                                    ListElement { text: "Cuboid" }
                                    ListElement { text: "Extrusion" }
                                    ListElement { text: "Rectangle" }
                                    ListElement { text: "Lens" }
                                    ListElement { text: "Pendular_ring" }
                                }
                                onActivated: {
                                    throatvolType = throatvolchx.currentText
                                    throatvolChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatarearec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "Cylinder"

                    states: [
                        State {
                            name: "Cylinder"
                            PropertyChanges {
                                target: throatareachx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Cuboid"
                            PropertyChanges {
                                target: throatareachx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Rectangle"
                            PropertyChanges {
                                target: throatareachx
                                currentIndex: 2
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatareacb
                            width: parent.width / 2
                            text: "Area"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatareaType = throatareachx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                throatarea = !throatarea
                                throatareachx.currentIndex = 0
                                throatareachx.enabled = !throatareachx.enabled
                                if(throatarea){
                                    throatareaType = throatareachx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat area",
                                                          "proptext": "Throat area" + " (" + throatareaType + ")"
                                                      })
                                }else{
                                    throatareaType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat area")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.area")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatarea)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatareachx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Cylinder" }
                                    ListElement { text: "Cuboid" }
                                    ListElement { text: "Rectangle" }
                                }
                                onActivated: {
                                    throatareaType = throatareachx.currentText
                                    throatareaChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatendrec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Spherical_pores"

                    states: [
                        State {
                            name: "Cubic_pores"
                            PropertyChanges {
                                target: throatendchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Square_pores"
                            PropertyChanges {
                                target: throatendchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Spherical_pores"
                            PropertyChanges {
                                target: throatendchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Circular_pores"
                            PropertyChanges {
                                target: throatendchx
                                currentIndex: 3
                            }
                        },
                        State {
                            name: "Straight_throat"
                            PropertyChanges {
                                target: throatendchx
                                currentIndex: 4
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatendcb
                            width: parent.width / 2
                            text: "End points"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatendpointType = throatendchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                throatendpoint = !throatendpoint
                                throatendchx.currentIndex = 2
                                throatendchx.enabled = !throatendchx.enabled
                                if (throatendpoint){
                                    throatendpointType = throatendchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat endpoints",
                                                          "proptext": "Throat endpoints" + " (" + throatendpointType + ")"
                                                      })
                                }else{
                                    throatendpointType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat endpoints")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.end points")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatendpoint)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatendchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Cubic_pores" }
                                    ListElement { text: "Square_pores" }
                                    ListElement { text: "Spherical_pores" }
                                    ListElement { text: "Circular_pores" }
                                    ListElement { text: "Straight_throat" }
                                }
                                onActivated: {
                                    throatendpointType = throatendchx.currentText
                                    throatendChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatlenrec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "ctc"

                    states: [
                        State {
                            name: "ctc"
                            PropertyChanges {
                                target: throatlengthchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Piecewise"
                            PropertyChanges {
                                target: throatlengthchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Conduit_length"
                            PropertyChanges {
                                target: throatlengthchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Classic"
                            PropertyChanges {
                                target: throatlengthchx
                                currentIndex: 3
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatlencb
                            width: parent.width / 2
                            text: "Length"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    throatlengthType = throatlengthchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                throatlength = !throatlength
                                throatlengthchx.currentIndex = 0
                                throatlengthchx.enabled = !throatlengthchx.enabled
                                if (throatlength){
                                    throatlengthType = throatlengthchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat length",
                                                          "proptext": "Throat length" + " (" + throatlengthType + ")"
                                                      })
                                }else{
                                    throatlengthType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat length")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.length")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatlength)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatlengthchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "ctc" }
                                    ListElement { text: "Piecewise" }
                                    ListElement { text: "Conduit_length" }
                                    ListElement { text: "Classic" }
                                }
                                onActivated: {
                                    throatlengthType = throatlengthchx.currentText
                                    throatlenChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatperirec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Cylinder"

                    states: [
                        State {
                            name: "Cylinder"
                            PropertyChanges {
                                target: throatperimchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Cuboid"
                            PropertyChanges {
                                target: throatperimchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Rectangle"
                            PropertyChanges {
                                target: throatperimchx
                                currentIndex: 2
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatpericb
                            width: parent.width / 2
                            text: "Perimeter"
                            onCheckStateChanged: {
                                throatperim = !throatperim
                                throatperimchx.currentIndex = 0
                                throatperimchx.enabled = !throatperimchx.enabled
                                if (throatperim){
                                    throatperimType = throatperimchx.currentText
                                    geometrymodel.append({
                                                          "maintext": "Throat perimeter",
                                                          "proptext": "Throat perimeter" + " (" + throatperimType + ")"
                                                      })
                                }else{
                                    throatperimType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat perimeter")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }
                                var index = Functions.find(helpmodel, "throat.perimeter")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatperim)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatperimchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Cylinder" }
                                    ListElement { text: "Cuboid" }
                                    ListElement { text: "Rectangle" }
                                }
                                onActivated: {
                                    throatperimType = throatperimchx.currentText
                                    throatperiChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: throatshaperec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "Compactness"

                    states: [
                        State {
                            name: "Compactness"
                            PropertyChanges {
                                target: throatshapechx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Mason_morrow"
                            PropertyChanges {
                                target: throatshapechx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Jenkins_rao"
                            PropertyChanges {
                                target: throatshapechx
                                currentIndex: 2
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: throatshapecb
                            width: parent.width / 2
                            text: "Shape factor"
                            onCheckStateChanged: {
                                throatshapefactor = !throatshapefactor
                                throatshapechx.currentIndex = 0
                                throatshapechx.enabled = !throatshapechx.enabled
                                if (throatshapefactor){
                                    throatshapefactorType = throatshapechx.currentText
                                    geometrymodel.append({
                                                             "maintext": "Throat shape factor",
                                                          "proptext": "Throat shape factor" + " (" + throatshapefactorType + ")"
                                                      })
                                }else{
                                    throatshapefactorType = ""
                                    var index = Functions.findprops(geometrymodel, "Throat shape factor")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "throat.shape factor")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", throatshapefactor)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: throatshapechx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Compactness" }
                                    ListElement { text: "Mason_morrow" }
                                    ListElement { text: "Jenkins_rao" }
                                }
                                onActivated: {
                                    throatshapefactorType = throatshapechx.currentText
                                    throatshapeChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

//                Rectangle{
//                    width: parent.width
//                    height: 50
//                    color: "#ffffff"
//                    Column{
//                        anchors.fill: parent
//                        spacing: 0
//                        CheckBox{
//                            width: parent.width / 2
//                            text: "Centroid"
//                            onCheckStateChanged: {
//                                throatcentroid = !throatcentroid
//                                if (throatcentroid){
//                                    geometrymodel.append({
//                                                          "proptext": "Throat centroid"
//                                                      })
//                                }else{
//                                    var index = Functions.findprops(geometrymodel, "Throat centroid")
//                                    if(index !== null){
//                                        geometrymodel.remove(index)
//                                    }
//                                }

//                                var index = Functions.find(helpmodel, "throat.centroid")
//                                if(index !== null){
//                                    helpmodel.setProperty(index, "check", throatcentroid)
//                                }
//                            }
//                        }
//                    }
//                }

//                Rectangle{
//                    width: parent.width
//                    height: 50
//                    color: "#c0c0c0"
//                    Column{
//                        anchors.fill: parent
//                        spacing: 0
//                        CheckBox{
//                            width: parent.width / 2
//                            text: "Vector"
//                            checked: true
//                            onCheckStateChanged: {
//                                throatvector = !throatvector
//                                if (throatvector){
//                                    geometrymodel.append({
//                                                          "proptext": "Throat vector"
//                                                      })
//                                }else{
//                                    var index = Functions.findprops(geometrymodel, "Throat vector")
//                                    if(index !== null){
//                                        geometrymodel.remove(index)
//                                    }
//                                }

//                                var index = Functions.find(helpmodel, "throat.vector")
//                                if(index !== null){
//                                    helpmodel.setProperty(index, "check", throatvector)
//                                }
//                            }
//                        }
//                    }
//                }
            }
        }
    }

    function throatdiamChange(){
        var index = Functions.findprops(geometrymodel, "Throat diameter")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat diameter" + " (" + throatdiamType + ")")
        }
    }

    function throatseedChange(){
        var index = Functions.findprops(geometrymodel, "Throat seed")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat seed" + " (" + throatseedType + ")")
        }
    }
    function throatsurfChange(){
        var index = Functions.findprops(geometrymodel, "Throat surface area")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat surface area" + " (" + throatsurfType + ")")
        }
    }
    function throatvolChange(){
        var index = Functions.findprops(geometrymodel, "Throat volume")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat volume" + " (" + throatvolType + ")")
        }
    }
    function throatareaChange(){
        var index = Functions.findprops(geometrymodel, "Throat area")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat area" + " (" + throatareaType + ")")
        }
    }

    function throatendChange(){
        var index = Functions.findprops(geometrymodel, "Throat endpoints")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat endpoints" + " (" + throatendpointType + ")")
        }
    }
    function throatlenChange(){
        var index = Functions.findprops(geometrymodel, "Throat length")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat length" + " (" + throatlengthType + ")")
        }
    }
    function throatperiChange(){
        var index = Functions.findprops(geometrymodel, "Throat perimeter")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat perimeter" + " (" + throatperimType + ")")
        }
    }
    function throatshapeChange(){
        var index = Functions.findprops(geometrymodel, "Throat shape factor")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Throat shape factor" + " (" + throatshapefactorType + ")")
        }
    }
}
