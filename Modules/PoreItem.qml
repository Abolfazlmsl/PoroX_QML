import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import "./../Fonts/Icon.js" as Icons
import "./../Functions/functions.js" as Functions

Item {
    id: poreitem

    anchors.fill: parent

    property alias porediamcheck: porediamcb.checked
    property alias porediamstate: porediamrec.state
    property alias poreseedcheck: poreseedcb.checked
    property alias poreseedstate: poreseedrec.state
    property alias poresurfcheck: poresurfcb.checked
    property alias poresurfstate: poresurfrec.state
    property alias porevolcheck: porevolcb.checked
    property alias porevolstate: porevolrec.state
    property alias poreareacheck: poreareacb.checked
    property alias poreareastate: porearearec.state

    property bool diamopen: false
    property bool seedopen: false

    signal changeporediam (var param1, var param2, var param3, var param4)
    onChangeporediam: {
        porediamModel.clear()
        if(porediamchx.currentText === "Weibull" || porediamchx.currentText === "Generic-distribution"){
            porediamModel.append({"name": "Shape:", "value":param1})
            porediamModel.append({"name": "Scale:", "value":param2})
            porediamModel.append({"name": "Loc:", "value":param3})
            downdiam.restart()
        }else if (porediamchx.currentText === "Normal"){
            porediamModel.append({"name": "Scale:", "value":param2})
            porediamModel.append({"name": "Loc:", "value":param3})
            downdiam.restart()
        }else if (porediamchx.currentText === "Random"){
            updiam.restart()
        }else if (porediamchx.currentText === "From-neighbor-throats"){
            porediamModel.append({"name": "Mode:", "value":param4})
            downdiam.restart()
        }

        porediamType = porediamchx.currentText
    }

    signal changeporeseed(var param1, var param2, var param3)
    onChangeporeseed: {
        poreseedModel.clear()
        if(poreseedchx.currentText === "Random"){
            upseed.restart()
        }else if (poreseedchx.currentText === "Spatially_correlated"){
            poreseedModel.append({"name": "Weights (X):", "value": param1})
            poreseedModel.append({"name": "Weights (Y):", "value": param2})
            poreseedModel.append({"name": "Weights (Z):", "value": param3})
            downseed.restart()
        }
        poreseedType = poreseedchx.currentText
    }

    objectName: "Pore"

    Component.onCompleted: {}

    //-- Diameter Animation --//
    ParallelAnimation{
        id: downdiam
        PropertyAnimation { target: porediamrec ; properties: "height"; to: 100+porediamModel.count*50 ; duration: 300 }
        PropertyAnimation { target: diamIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Diameter Animation --//
    ParallelAnimation{
        id: updiam
        PropertyAnimation { target: porediamrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: diamIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Seed Animation --//
    ParallelAnimation{
        id: downseed
        PropertyAnimation { target: poreseedrec ; properties: "height"; to: 100+poreseedModel.count*50 ; duration: 300 }
        PropertyAnimation { target: seedIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Seed Animation --//
    ParallelAnimation{
        id: upseed
        PropertyAnimation { target: poreseedrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: seedIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    Flickable{
        id: poreflick
        anchors.fill: parent
        clip: true

        contentWidth: parent.width
        contentHeight: 300 + porediamrec.height + poreseedrec.height
        ScrollBar.vertical: ScrollBar {

        }
        Rectangle{
            anchors.fill: parent
            color: "#f8f8ff"

            Column{
                anchors.fill: parent
                spacing: 0

                Rectangle{
                    id: porediamrec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"

                    state: "From-neighbor-throats"

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
                                target: porediamchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Random"
                            PropertyChanges {
                                target: porediamchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Generic-distribution"
                            PropertyChanges {
                                target: porediamchx
                                currentIndex: 3
                            }
                        },
                        State {
                            name: "From-neighbor-throats"
                            PropertyChanges {
                                target: porediamchx
                                currentIndex: 4
                            }
                        }

                    ]

                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: porediamcb
                            width: parent.width / 2
                            height: 50
                            text: "Diameter"
                            checked: {
                                if (inputdata === "Synthetic Network"){
                                    porediamType = porediamchx.currentText
                                    poremode = "min"
                                    return true
                                }else{
                                    return false
                                }
                            }

                            onCheckStateChanged: {
                                porediam = !porediam
                                porediamchx.currentIndex = 4
                                porediamchx.enabled = !porediamchx.enabled
                                diamIcon.enabled = !diamIcon.enabled
                                if(porediam){
                                    porediamModel.append({"name": "Mode:", "value":"min"})
                                    downdiam.restart()
                                    diamopen = !diamopen
                                    porediamType = porediamchx.currentText
                                    poremode = "min"
                                    geometrymodel.append({
                                                             "maintext": "Pore diameter",
                                                             "proptext": "Pore diameter" + " (" + porediamType + ")"
                                                         })
                                }else{
                                    updiam.restart()
                                    porediamModel.clear()
                                    diamopen = !diamopen
                                    porediamType = ""

                                    var index = Functions.findprops(geometrymodel, "Pore diameter")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "pore.diameter")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", porediam)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: 50
                            spacing: 10
                            ComboBox{
                                id: porediamchx
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
                                    ListElement { text: "Generic-distribution" }
                                    ListElement { text: "From-neighbor-throats" }
//                                    ListElement { text: "Largest-sphere" }
//                                    ListElement { text: "Equivalent-diameter" }
                                }

                                onActivated: {
                                    porediamModel.clear()
                                    if(porediamchx.currentText === "Weibull" || porediamchx.currentText === "Generic-distribution"){
                                        porediamModel.append({"name": "Shape:", "value":"1.5"})
                                        porediamModel.append({"name": "Scale:", "value":"0.000001"})
                                        porediamModel.append({"name": "Loc:", "value":"0"})
                                        downdiam.restart()
                                    }else if (porediamchx.currentText === "Normal"){
                                        porediamModel.append({"name": "Scale:", "value":"0.000001"})
                                        porediamModel.append({"name": "Loc:", "value":"0"})
                                        downdiam.restart()
                                    }else if (porediamchx.currentText === "Random"){
                                        updiam.restart()
                                    }else if (porediamchx.currentText === "From-neighbor-throats"){
                                        porediamModel.append({"name": "Mode:", "value":"min"})
                                        downdiam.restart()
                                    }

                                    porediamType = porediamchx.currentText
                                    porediamChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                id: diamIcon
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                text: Icons.settings
                                enabled: false

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
                            height: porediamModel.count*50
                            color: "transparent"
                            ListView{
                                anchors.fill: parent
                                model: ListModel{id: porediamModel}
                                delegate: RowLayout{
                                    width: porediamrec.width
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
                                            if(porediamchx.currentText === "Weibull" || porediamchx.currentText === "Generic-distribution"){
                                                if (model.index === 0){
                                                    poreshape = text
                                                }else if (model.index === 1){
                                                    porescale = text
                                                }else if (model.index === 2){
                                                    poreloc = text
                                                }
                                            }else if (porediamchx.currentText === "Normal"){
                                                if (model.index === 0){
                                                    porescale = text
                                                }else if (model.index === 1){
                                                    poreloc = text
                                                }
                                            }else if (porediamchx.currentText === "From-neighbor-throats"){
                                                if (model.index === 0){
                                                    poremode = text
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
                    id: poreseedrec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Random"

                    states: [
                        State {
                            name: "Random"
                            PropertyChanges {
                                target: poreseedchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Spatially_correlated"
                            PropertyChanges {
                                target: poreseedchx
                                currentIndex: 1
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: poreseedcb
                            width: parent.width / 2
                            height: 50
                            text: "Seed"
                            checked: {if (inputdata === "Synthetic Network"){
                                    poreseedType = poreseedchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }

                            onCheckStateChanged: {
                                poreseed = !poreseed
                                poreseedchx.currentIndex = 0
                                poreseedchx.enabled = !poreseedchx.enabled
                                seedIcon.enabled = !seedIcon.enabled
                                upseed.restart()
                                if(poreseed){
                                    poreseedType = poreseedchx.currentText
                                    geometrymodel.append({
                                                             "maintext": "Pore seed",
                                                             "proptext": "Pore seed" + " (" + poreseedType + ")"
                                                         })
                                }else{
                                    poreseedType = ""
                                    var index = Functions.findprops(geometrymodel, "Pore seed")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "pore.seed")
                                if (index !== null){
                                    helpmodel.setProperty(index, "check", poreseed)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: 50
                            spacing: 10
                            ComboBox{
                                id: poreseedchx
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
                                    ListElement { text: "Spatially_correlated" }
                                }
                                onActivated: {
                                    poreseedModel.clear()
                                    if(poreseedchx.currentText === "Random"){
                                        upseed.restart()
                                    }else if (poreseedchx.currentText === "Spatially_correlated"){
                                        poreseedModel.append({"name": "Weights (X):", "value": "2"})
                                        poreseedModel.append({"name": "Weights (Y):", "value": "2"})
                                        poreseedModel.append({"name": "Weights (Z):", "value": "2"})
                                        downseed.restart()
                                    }
                                    poreseedType = poreseedchx.currentText
                                    poreseedChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                id: seedIcon
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1
                                text: Icons.settings
                                enabled: false
                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter

                                MouseArea{
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if(seedopen){
                                            upseed.restart()
                                            seedopen = !seedopen
                                        }else{
                                            downseed.restart()
                                            seedopen = !seedopen
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: seedproprec
                            width: parent.width / 2
                            height: poreseedModel.count*50
                            color: "transparent"
                            ListView{
                                anchors.fill: parent
                                model: ListModel{id: poreseedModel}
                                delegate: RowLayout{
                                    width: poreseedrec.width
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
                                            if (model.index === 0){
                                                poreweightx = text
                                            }else if (model.index === 1){
                                                poreweighty = text
                                            }else if (model.index === 2){
                                                poreweightz = text
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: poresurfrec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "Sphere"
                    states: [
                        State {
                            name: "Sphere"
                            PropertyChanges {
                                target: poresurfchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Circle"
                            PropertyChanges {
                                target: poresurfchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Cube"
                            PropertyChanges {
                                target: poresurfchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Square"
                            PropertyChanges {
                                target: poresurfchx
                                currentIndex: 3
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: poresurfcb
                            width: parent.width / 2
                            text: "Surface area"
                            onCheckStateChanged: {
                                poresurf = !poresurf
                                poresurfchx.currentIndex = 0
                                poresurfchx.enabled = !poresurfchx.enabled
                                if(poresurf){
                                    poresurfType = poresurfchx.currentText
                                    geometrymodel.append({
                                                             "maintext": "Pore surface area",
                                                             "proptext": "Pore surface area" + " (" + poresurfType + ")"
                                                         })
                                }else{
                                    poresurfType = ""
                                    var index = Functions.findprops(geometrymodel, "Pore surface area")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "pore.surface area")
                                if (index!==null){
                                    helpmodel.setProperty(index, "check", poresurf)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: poresurfchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Sphere" }
                                    ListElement { text: "Circle" }
                                    ListElement { text: "Cube" }
                                    ListElement { text: "Square" }
                                }
                                onActivated: {
                                    poresurfType = poresurfchx.currentText
                                    poresurfChange()
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
                    id: porevolrec
                    width: parent.width
                    height: 100
                    color: "#ffffff"
                    state: "Sphere"
                    states: [
                        State {
                            name: "Sphere"
                            PropertyChanges {
                                target: porevolchx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Circle"
                            PropertyChanges {
                                target: porevolchx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Cube"
                            PropertyChanges {
                                target: porevolchx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Square"
                            PropertyChanges {
                                target: porevolchx
                                currentIndex: 3
                            }
                        },
                        State {
                            name: "Cylinder"
                            PropertyChanges {
                                target: porevolchx
                                currentIndex: 4
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: porevolcb
                            width: parent.width / 2
                            text: "Volume"
                            checked: {if (inputdata === "Synthetic Network"){
                                    porevolType = porevolchx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                porevol = !porevol
                                porevolchx.currentIndex = 0
                                porevolchx.enabled = !porevolchx.enabled
                                if(porevol){
                                    porevolType = porevolchx.currentText
                                    geometrymodel.append({
                                                             "maintext": "Pore volume",
                                                             "proptext": "Pore volume" + " (" + porevolType + ")"
                                                         })
                                }else{
                                    porevolType = ""
                                    var index = Functions.findprops(geometrymodel, "Pore volume")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "pore.volume")
                                if (index!== null){
                                    helpmodel.setProperty(index, "check", porevol)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: porevolchx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Sphere" }
                                    ListElement { text: "Circle" }
                                    ListElement { text: "Cube" }
                                    ListElement { text: "Square" }
                                    ListElement { text: "Cylinder" }
                                }
                                onActivated: {
                                    porevolType = porevolchx.currentText
                                    porevolChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1

                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle{
                    id: porearearec
                    width: parent.width
                    height: 100
                    color: "#c0c0c0"
                    state: "Sphere"
                    states: [
                        State {
                            name: "Sphere"
                            PropertyChanges {
                                target: poreareachx
                                currentIndex: 0
                            }
                        },
                        State {
                            name: "Circle"
                            PropertyChanges {
                                target: poreareachx
                                currentIndex: 1
                            }
                        },
                        State {
                            name: "Cube"
                            PropertyChanges {
                                target: poreareachx
                                currentIndex: 2
                            }
                        },
                        State {
                            name: "Square"
                            PropertyChanges {
                                target: poreareachx
                                currentIndex: 3
                            }
                        }

                    ]
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: poreareacb
                            width: parent.width / 2
                            text: "Area"
                            checked: {if (inputdata === "Synthetic Network"){
                                    poreareaType = poreareachx.currentText
                                    return true
                                }else{
                                    return false
                                }
                            }
                            onCheckStateChanged: {
                                porearea = !porearea
                                poreareachx.currentIndex = 0
                                poreareachx.enabled = !poreareachx.enabled
                                if(porearea){
                                    poreareaType = poreareachx.currentText
                                    geometrymodel.append({
                                                             "maintext": "Pore area",
                                                             "proptext": "Pore area" + " (" + poreareaType + ")"
                                                         })
                                }else{
                                    poreareaType = ""
                                    var index = Functions.findprops(geometrymodel, "Pore area")
                                    if(index !== null){
                                        geometrymodel.remove(index)
                                    }
                                }

                                var index = Functions.find(helpmodel, "pore.area")
                                if(index !== null){
                                    helpmodel.setProperty(index, "check", porearea)
                                }
                            }
                        }
                        RowLayout{
                            width: parent.width * 0.9
                            height: parent.height * 0.5
                            spacing: 10
                            ComboBox{
                                id: poreareachx
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.9
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Sphere" }
                                    ListElement { text: "Circle" }
                                    ListElement { text: "Cube" }
                                    ListElement { text: "Square" }
                                }

                                onActivated: {
                                    poreareaType = poreareachx.currentText
                                    poreareaChange()
                                }
                            }
                            //-- Setting Icon --//
                            Label{
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width *0.1

                                font.family: webfont.name
                                font.pixelSize: 25//Qt.application.font.pixelSize
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    function porediamChange(){
        var index = Functions.findprops(geometrymodel, "Pore diameter")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Pore diameter" + " (" + porediamType + ")")
        }
    }

    function poreseedChange(){
        var index = Functions.findprops(geometrymodel, "Pore seed")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Pore seed" + " (" + poreseedType + ")")
        }
    }
    function poresurfChange(){
        var index = Functions.findprops(geometrymodel, "Pore surface area")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Pore surface area" + " (" + poresurfType + ")")
        }
    }
    function porevolChange(){
        var index = Functions.findprops(geometrymodel, "Pore volume")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Pore volume" + " (" + porevolType + ")")
        }
    }
    function poreareaChange(){
        var index = Functions.findprops(geometrymodel, "Pore area")
        if(index !== null){
            geometrymodel.setProperty(index, "proptext", "Pore area" + " (" + poreareaType + ")")
        }
    }
}
