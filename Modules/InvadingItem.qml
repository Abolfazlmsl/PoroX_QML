import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import "./../Fonts/Icon.js" as Icons

Item {
    id: invadingitem

    anchors.fill: parent

    property alias denuser: denText.text
    property alias diffuser: diffText.text
    property alias mixuser: mixText.text
    property alias molaruser: molarText.text
    property alias surfuser: surfText.text
    property alias vaporuser: vaporText.text
    property alias visuser: visText.text

    property alias concen: concen.text
    property alias press: press.text
    property alias temp: temp.text
    property alias volfrac: volfracText.text
    property alias intrinsic: intrinsicText.text
    property alias mw: mwText.text
    property alias critemp: critempText.text
    property alias cripressure: cripressureText.text
    property alias crivol: crivolText.text
    property alias criangle: criangleText.text

    property alias dencheck: densityCheck.checked
    property alias denstate: denrec.state
    property alias diffcheck: diffcb.checked
    property alias diffstate: diffrec.state
    property alias eleccheck: eleccb.checked
    property alias mixcheck: mixcb.checked
    property alias mixstate: mixrec.state
    property alias molardencheck: molardensityCheck.checked
    property alias molardenstate: molardenrec.state
    property alias partcoeffcheck: partcoeffcb.checked
    property alias pericheck: pericb.checked
    property alias surfcheck: surfcb.checked
    property alias surfstate: surfrec.state
    property alias vaporcheck: vaporcb.checked
    property alias vaporstate: vaporrec.state
    property alias vischeck: visCheck.checked
    property alias visstate: visrec.state

    signal changediff(var param1, var param2, var param3, var param4,
                      var param5, var param6, var param7, var param8,
                      var param9)
    onChangediff: {
        diffModel.clear()
        if(diffchx.currentText === "Fuller"){
            diffModel.append({"name": "MW (component A):", "visible": true, "value": param1})
            diffModel.append({"name": "MW (component B):", "visible": true, "value": param2})
            diffModel.append({"name": "Atomic vol (A):", "visible": true, "value": param3})
            diffModel.append({"name": "Atomic vol (B):", "visible": true, "value": param4})
            downden.restart()
        }else if (diffchx.currentText === "Fuller_scaling"){
            diffModel.append({"name": "Diffusion coefficient (m2/s):", "visible": true, "value": param5})
            diffModel.append({"name": "*Fill the pressure", "visible": false, "value": ""})
            diffModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
            downden.restart()
        }else if (diffchx.currentText === "Tyn_calus"){
            diffModel.append({"name": "Molar volume (A):", "visible": true, "value": param6})
            diffModel.append({"name": "Molar volume (B):", "visible": true, "value": param7})
            diffModel.append({"name": "Surface tension (A):", "visible": true, "value": param8})
            diffModel.append({"name": "Surface tension (B):", "visible": true, "value": param9})
            downden.restart()
        }else if (diffchx.currentText === "Tyn_calus_scaling"){
            diffModel.append({"name": "Diffusion coefficient (m2/s):", "visible": true, "value": param5})
            diffModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
            downden.restart()
        }else if (diffchx.currentText === "User defined"){
            upden.restart()
        }
        invadediffusivityType = diffchx.currentText
    }

    signal changeelec(var param1)
    onChangeelec: {
        electricalModel.clear()
        electricalModel.append({"name": "*Fill the volume fraction", "visible": false, "value": param1})
        electricalModel.append({"name": "Percolation relation exponent:", "visible": true, "value": ""})
        invadeelectrical = !invadeelectrical
    }

    signal changemixture(var param1)
    onChangemixture: {
        mixtureModel.clear()
        if(mixchx.currentText === "Salinity" || mixchx.currentText === "Fuller_diffusivity" || mixchx.currentText === "Wilke_fuller_diffusivity" || mixchx.currentText === "Salinity user defined"){
            upmix.restart()
        }else if (mixchx.currentText === "Mole_weighted_average"){
            mixtureModel.append({"name": "Dictionary key:", "value": param1})
            downmix.restart()
        }
        invademixtureType = mixchx.currentText
    }

    signal changepartcoeff(var param1)
    onChangepartcoeff: {
        partcoeffModel.append({"name": "Chemical formula:", "value":param1})
        invadepartcoeff = !invadepartcoeff
    }

    signal changesurf(var param1, var param2, var param3, var param4)
    onChangesurf: {
        surfModel.clear()
        if(surfchx.currentText === "Water" || surfchx.currentText === "User defined"){
            upsurf.restart()
        }else if (surfchx.currentText === "Eotvos"){
            surfModel.append({"name": "Constant parameter:", "visible": true, "value": param1})
            downsurf.restart()
        }else if (surfchx.currentText === "Guggenheim_katayama"){
            surfModel.append({"name": "Specific constant (k2):", "visible": true, "value": param2})
            surfModel.append({"name": "Specific constant (n):", "visible": true, "value": param3})
            downsurf.restart()
        }else if (surfchx.currentText === "Brock_bird_scaling"){
            surfModel.append({"name": "Surface tension (N/m):", "visible": true, "value": param4})
            surfModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
            downsurf.restart()
        }
        invadesurfType = surfchx.currentText
    }

    signal changevapor(var param1, var param2, var param3)
    onChangevapor: {
        vaporpressureModel.clear()
        if(vaporchx.currentText === "Water" || vaporchx.currentText === "User defined"){
            upvapor.restart()
        }else if (vaporchx.currentText === "Antoine"){
            vaporpressureModel.append({"name": "Pressure coefficient A (mmHg):", "value": param1})
            vaporpressureModel.append({"name": "Pressure coefficient B (mmHg):", "value": param2})
            vaporpressureModel.append({"name": "Pressure coefficient C (mmHg):", "value": param3})
            downvapor.restart()
        }
        invadevaporType = vaporchx.currentText
    }

    signal changevis(var param1, var param2)
    onChangevis: {
        viscosityModel.clear()
        if(vischx.currentText === "Water" || vischx.currentText === "Chung" || vischx.currentText === "User defined"){
            upvis.restart()
        }else if (vischx.currentText === "Reynolds"){
            viscosityModel.append({"name": "Viscosity coefficient (u0):", "value": param1})
            viscosityModel.append({"name": "Viscosity coefficient (b):", "value": param2})
            downvis.restart()
        }
        invadeviscosityType = vischx.currentText
    }

    objectName: "Invading"

    property bool diffOpen: false
    property bool electricalOpen: false
    property bool mixOpen: false
    property bool partOpen: false
    property bool surfOpen: false
    property bool vaporOpen: false
    property bool visOpen: false

    Component.onCompleted: {}

    //-- Density Animation --//
    ParallelAnimation{
        id: downden
        PropertyAnimation { target: diffrec ; properties: "height"; to: 100+diffModel.count*50 ; duration: 300 }
        PropertyAnimation { target: diffIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Density Animation --//
    ParallelAnimation{
        id: upden
        PropertyAnimation { target: diffrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: diffIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Electrical conductivity Animation --//
    ParallelAnimation{
        id: downelectrical
        PropertyAnimation { target: electricalrec ; properties: "height"; to: 50+electricalModel.count*50 ; duration: 300 }
        PropertyAnimation { target: electricalIcon ; properties: "rotation"; to: -90 ; duration: 300 }
    }

    //-- Electrical conductivity Animation --//
    ParallelAnimation{
        id: upelectrical
        PropertyAnimation { target: electricalrec ; properties: "height"; to: 50 ; duration: 300 }
        PropertyAnimation { target: electricalIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Mixtures Animation --//
    ParallelAnimation{
        id: downmix
        PropertyAnimation { target: mixrec ; properties: "height"; to: 100+mixtureModel.count*50 ; duration: 300 }
        PropertyAnimation { target: mixIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Mixtures Animation --//
    ParallelAnimation{
        id: upmix
        PropertyAnimation { target: mixrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: mixIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Partition coefficient Animation --//
    ParallelAnimation{
        id: downpart
        PropertyAnimation { target: partrec ; properties: "height"; to: 50+partcoeffModel.count*50 ; duration: 300 }
        PropertyAnimation { target: partIcon ; properties: "rotation"; to: -90 ; duration: 300 }
    }

    //-- Partition coefficient Animation --//
    ParallelAnimation{
        id: uppart
        PropertyAnimation { target: partrec ; properties: "height"; to: 50 ; duration: 300 }
        PropertyAnimation { target: partIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Surface Tension Animation --//
    ParallelAnimation{
        id: downsurf
        PropertyAnimation { target: surfrec ; properties: "height"; to: 100+surfModel.count*50 ; duration: 300 }
        PropertyAnimation { target: surfIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Surface Tension Animation --//
    ParallelAnimation{
        id: upsurf
        PropertyAnimation { target: surfrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: surfIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Vapor Pressure Animation --//
    ParallelAnimation{
        id: downvapor
        PropertyAnimation { target: vaporrec ; properties: "height"; to: 100+vaporpressureModel.count*50 ; duration: 300 }
        PropertyAnimation { target: vaporIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Vapor Pressure Animation --//
    ParallelAnimation{
        id: upvapor
        PropertyAnimation { target: vaporrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: vaporIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    //-- Viscosity Animation --//
    ParallelAnimation{
        id: downvis
        PropertyAnimation { target: visrec ; properties: "height"; to: 100+viscosityModel.count*50 ; duration: 300 }
        PropertyAnimation { target: visIcon ; properties: "rotation"; to: 90 ; duration: 300 }
    }

    //-- Viscosity Animation --//
    ParallelAnimation{
        id: upvis
        PropertyAnimation { target: visrec ; properties: "height"; to: 100 ; duration: 300 }
        PropertyAnimation { target: visIcon ; properties: "rotation"; to: 0 ; duration: 300 }
    }

    TabBar {
        id: bar
        width: parent.width

        font.pixelSize: Qt.application.font.pixelSize

        currentIndex: 0

        //-- Section 1 Button --//
        TabButton {
            id: section1

            signal checkSection1()
            onCheckSection1: {
                phaseItem.visible = true
                propsItem.visible = false
            }

            Label{
                text: "Select Phase"
                font.bold: section1.checked ? true : false
                font.pixelSize: section1.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                color: section1.checked ? "#000000" : "#aaaaaa"
                anchors.centerIn: parent
            }

            onClicked: {
                checkSection1()
            }

        }

        //-- Section 2 Button --//
        TabButton {
            id: section2

            signal checkSection2()
            onCheckSection2: {
                phaseItem.visible = false
                propsItem.visible = true
            }

            Label{
                text: "Add/Modify props"
                font.bold: section2.checked ? true : false
                font.pixelSize: section2.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                color: section2.checked ? "#000000" : "#aaaaaa"
                anchors.centerIn: parent
            }

            onClicked: {
                checkSection2()
            }
        }
    }

    Item{
        id: phaseItem
        anchors.top: bar.bottom
        width: parent.width
        height: parent.height - bar.height
        Column{
            id : lay
            anchors.fill: parent
            spacing: 0
            RadioButton{
                checked: (phase_inv === "Air")
                text: "Air"
                onClicked: {
                    phase_inv = "Air"
                }
            }
            RadioButton{
                checked: (phase_inv === "Water")
                text: "Water"
                onClicked: {
                    phase_inv = "Water"
                }
            }
            RadioButton{
                checked: (phase_inv === "Mercury")
                text: "Mercury"
                onClicked: {
                    phase_inv = "Mercury"
                }
            }
            RadioButton{
                checked: (phase_inv === "User defined")
                text: "User defined"
                onClicked: {
                    phase_inv = "User defined"
                }
            }
        }
    }

    //-- Input Data Item --//
    Item{
        id: propsItem
        anchors.top: bar.bottom
        width: parent.width
        height: parent.height - bar.height
        visible: false
        Column{
            anchors.fill: parent
            spacing: 0

            Flickable{
                width: parent.width
                height: parent.height*0.6
                clip: true

                contentWidth: parent.width
                contentHeight: 250+diffrec.height+electricalrec.height+mixrec.height+partrec.height+surfrec.height+vaporrec.height+visrec.height
                ScrollBar.vertical: ScrollBar {

                }
                Rectangle{
                    anchors.fill: parent
                    color: "#f8f8ff"

                    Column{
                        anchors.fill: parent
                        spacing: 0

                        Rectangle{
                            id: denrec
                            width: parent.width
                            height: 100
                            color: "#c0c0c0"
                            state: "Water"

                            states: [
                                State {
                                    name: "Water"
                                    PropertyChanges {
                                        target: denchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Standard"
                                    PropertyChanges {
                                        target: denchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Ideal_gas"
                                    PropertyChanges {
                                        target: denchx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: denchx
                                        currentIndex: 3
                                    }
                                }

                            ]

                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: densityCheck
                                        Layout.fillHeight: true
                                        text: "Density (kg/m3)"
                                        onCheckStateChanged: {
                                            invadedensity = !invadedensity
                                            denchx.currentIndex = 0
                                            denchx.enabled = !denchx.enabled
                                            if(invadedensity){
                                                invadedensityType = denchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Density",
                                                                         "proptext": "Density" + " (" + invadedensityType + ")"
                                                                     })
                                            }else{
                                                invadedensityType = ""
                                                var index = findprops(phaseinvmodel, "Invade Density")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            mwText.enabled = false

                                            var index = find(helpmodel, "Invading density")
                                            if(index !== null){
                                                helpmodel.setProperty(index, "check", invadedensity)
                                            }
                                        }
                                    }
                                    TextField{
                                        id: denText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (denchx.currentIndex === 3)

                                        onTextChanged: {
                                            invadedensityU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: parent.height * 0.5
                                    spacing: 10
                                    ComboBox{
                                        id: denchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#c0c0c0"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Water" }
                                            ListElement { text: "Standard" }
                                            ListElement { text: "Ideal_gas" }
                                            ListElement { text: "User defined" }
                                        }
                                        onActivated: {
                                            invadedensityType = denchx.currentText

                                            if(invadedensityType === "Water"){
                                                mwText.enabled = false
                                            }else if (invadedensityType === "Ideal_gas"){
                                                mwText.enabled = true
                                            }else if (invadedensityType === "Standard"){
                                                mwText.enabled = true
                                            }else if ((invadedensityType === "User defined")){
                                                mwText.enabled = true
                                            }

                                            invadedenChange()
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
                            id: diffrec
                            width: parent.width
                            height: 100
                            color: "#ffffff"
                            state: "Fuller"

                            states: [
                                State {
                                    name: "Fuller"
                                    PropertyChanges {
                                        target: diffchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Fuller_scaling"
                                    PropertyChanges {
                                        target: diffchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Tyn_calus"
                                    PropertyChanges {
                                        target: diffchx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "Tyn_calus_scaling"
                                    PropertyChanges {
                                        target: diffchx
                                        currentIndex: 3
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: diffchx
                                        currentIndex: 4
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: diffcb
                                        Layout.fillHeight: true
                                        height: 50
                                        text: "Diffusivity (m2/s)"

                                        onCheckStateChanged: {
                                            invadediffusivity = !invadediffusivity
                                            diffchx.currentIndex = 0
                                            diffchx.enabled = !diffchx.enabled
                                            diffIcon.enabled = !diffIcon.enabled
                                            if(invadediffusivity){
                                                diffModel.append({"name": "MW (component A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "MW (component B):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Atomic vol (A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Atomic vol (B):", "visible": true, "value": ""})
                                                downden.restart()
                                                diffOpen = !diffOpen
                                                invadediffusivityType = diffchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Diffusivity",
                                                                         "proptext": "Diffusivity" + " (" + invadediffusivityType + ")"
                                                                     })
                                            }else{
                                                upden.restart()
                                                diffModel.clear()
                                                diffOpen = !diffOpen
                                                invadediffusivityType = ""
                                                var index = findprops(phaseinvmodel, "Invade Diffusivity")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            var index = find(helpmodel, "Invading diffusivity")
                                            if(index !== null){
                                                helpmodel.setProperty(index, "check", invadediffusivity)
                                            }
                                        }
                                    }
                                    TextField{
                                        id: diffText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (diffchx.currentIndex === 4)

                                        onTextChanged: {
                                            invadediffusivityU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: 50
                                    spacing: 10
                                    ComboBox{
                                        id: diffchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#ffffff"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Fuller" }
                                            ListElement { text: "Fuller_scaling" }
                                            ListElement { text: "Tyn_calus" }
                                            ListElement { text: "Tyn_calus_scaling" }
                                            ListElement { text: "User defined" }
                                        }

                                        onActivated: {
                                            diffModel.clear()
                                            if(diffchx.currentText === "Fuller"){
                                                diffModel.append({"name": "MW (component A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "MW (component B):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Atomic vol (A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Atomic vol (B):", "visible": true, "value": ""})
                                                downden.restart()
                                            }else if (diffchx.currentText === "Fuller_scaling"){
                                                diffModel.append({"name": "Diffusion coefficient (m2/s):", "visible": true, "value": ""})
                                                diffModel.append({"name": "*Fill the pressure", "visible": false, "value": ""})
                                                diffModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
                                                downden.restart()
                                            }else if (diffchx.currentText === "Tyn_calus"){
                                                diffModel.append({"name": "Molar volume (A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Molar volume (B):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Surface tension (A):", "visible": true, "value": ""})
                                                diffModel.append({"name": "Surface tension (B):", "visible": true, "value": ""})
                                                downden.restart()
                                            }else if (diffchx.currentText === "Tyn_calus_scaling"){
                                                diffModel.append({"name": "Diffusion coefficient (m2/s):", "visible": true, "value": ""})
                                                diffModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
                                                downden.restart()
                                            }else if (diffchx.currentText === "User defined"){
                                                upden.restart()
                                            }
                                            invadediffusivityType = diffchx.currentText
                                            invadediffChange()
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: diffIcon
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
                                                if(diffOpen){
                                                    upden.restart()
                                                    diffOpen = !diffOpen
                                                }else{
                                                    downden.restart()
                                                    diffOpen = !diffOpen
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: diamproprec
                                    width: parent.width / 2
                                    height: diffModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: diffModel}
                                        delegate: RowLayout{
                                            width: diffrec.width
                                            height: 50

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Qt.AlignVCenter

                                                text: model.name
                                            }
                                            TextField{
                                                visible: model.visible
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
                                                    if(diffchx.currentText === "Fuller"){
                                                        if (model.index === 0){
                                                            invadeMWA = text
                                                        }else if (model.index === 1){
                                                            invadeMWB = text
                                                        }else if (model.index === 2){
                                                            invadeatomicvolA = text
                                                        }else if (model.index === 3){
                                                            invadeatomicvolB = text
                                                        }
                                                    }else if (diffchx.currentText === "Fuller_scaling"){
                                                        invadediffcoeff = text
                                                    }else if (diffchx.currentText === "Tyn_calus"){
                                                        if (model.index === 0){
                                                            invademolvolA = text
                                                        }else if (model.index === 1){
                                                            invademolvolB = text
                                                        }else if (model.index === 2){
                                                            invadesurfA = text
                                                        }else if (model.index === 3){
                                                            invadesurfB = text
                                                        }
                                                    }else if (diffchx.currentText === "Tyn_calus_scaling"){
                                                        invadediffcoeff = text
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: electricalrec
                            width: parent.width
                            height: 50
                            color: "#c0c0c0"

                            Column{
                                anchors.fill: parent
                                spacing: 0
                                Row{
                                    width: parent.width
                                    height: 50
                                    spacing: 0
                                    CheckBox{
                                        id: eleccb
                                        width: parent.width * 0.85
                                        text: "Electrical conductivity"
                                        onCheckStateChanged: {
                                            invadeelectrical = !invadeelectrical
                                            electricalIcon.enabled = !electricalIcon.enabled
                                            if(invadeelectrical){
                                                electricalModel.append({"name": "*Fill the volume fraction", "visible": false, "value": ""})
                                                electricalModel.append({"name": "Percolation relation exponent:", "visible": true, "value": ""})
                                                downelectrical.restart()
                                                electricalOpen = !electricalOpen
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Electrical conductivity",
                                                                         "proptext": "Electrical conductivity"
                                                                     })
                                            }else{
                                                upelectrical.restart()
                                                electricalModel.clear()
                                                electricalOpen = !electricalOpen
                                                var index = findprops(phaseinvmodel, "Invade Electrical conductivity")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            intrinsicText.enabled = !intrinsicText.enabled
                                            volfracText.enabled = !volfracText.enabled
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: electricalIcon
                                        width: parent.width * 0.15
                                        height: parent.height
                                        enabled: false
                                        text: Icons.settings
                                        font.family: webfont.name
                                        font.pixelSize: 25//Qt.application.font.pixelSize
                                        verticalAlignment: Qt.AlignVCenter
                                        MouseArea{
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if(electricalOpen){
                                                    upelectrical.restart()
                                                    electricalOpen = !electricalOpen
                                                }else{
                                                    downelectrical.restart()
                                                    electricalOpen = !electricalOpen
                                                }
                                            }
                                        }
                                    }

                                }
                                Rectangle{
                                    id: electricalproprec
                                    width: parent.width / 2
                                    height: electricalModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: electricalModel}
                                        delegate: RowLayout{
                                            width: electricalrec.width
                                            height: 50

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Qt.AlignVCenter

                                                text: model.name
                                            }
                                            TextField{
                                                visible: model.visible
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
                                                    invadeperrelexp = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: mixrec
                            width: parent.width
                            height: 100
                            color: "#ffffff"
                            state: "Salinity"

                            states: [
                                State {
                                    name: "Salinity"
                                    PropertyChanges {
                                        target: mixchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Mole_weighted_average"
                                    PropertyChanges {
                                        target: mixchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Fuller_diffusivity"
                                    PropertyChanges {
                                        target: mixchx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "Wilke_fuller_diffusivity"
                                    PropertyChanges {
                                        target: mixchx
                                        currentIndex: 3
                                    }
                                },
                                State {
                                    name: "Salinity user defined"
                                    PropertyChanges {
                                        target: mixchx
                                        currentIndex: 4
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: mixcb
                                        property string unit: (mixchx.currentIndex === 4) ? "(g/kg)":""
                                        Layout.fillHeight: true
                                        height: 50
                                        text: "Mixtures " + unit

                                        onCheckStateChanged: {
                                            invademixture = !invademixture
                                            mixchx.currentIndex = 0
                                            mixchx.enabled = !mixchx.enabled
                                            mixIcon.enabled = !mixIcon.enabled
                                            if(invademixture){
                                                downmix.restart()
                                                mixOpen = !mixOpen
                                                invademixtureType = mixchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Mixtures",
                                                                         "proptext": "Mixtures" + " (" + invademixtureType + ")"
                                                                     })
                                            }else{
                                                upmix.restart()
                                                mixtureModel.clear()
                                                mixOpen = !mixOpen
                                                invademixtureType = ""
                                                var index = findprops(phaseinvmodel, "Invade Mixtures")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            mwText.enabled = false
                                            molardiffText.enabled = false
                                        }
                                    }
                                    TextField{
                                        id: mixText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (mixchx.currentIndex === 4)

                                        onTextChanged: {
                                            invadesalinityU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: 50
                                    spacing: 10
                                    ComboBox{
                                        id: mixchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#ffffff"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Salinity" }
                                            ListElement { text: "Mole_weighted_average" }
                                            ListElement { text: "Fuller_diffusivity" }
                                            ListElement { text: "Wilke_fuller_diffusivity" }
                                            ListElement { text: "Salinity user defined" }
                                        }
                                        onActivated: {
                                            mixtureModel.clear()
                                            if(mixchx.currentText === "Salinity" || mixchx.currentText === "Fuller_diffusivity" || mixchx.currentText === "Wilke_fuller_diffusivity" || mixchx.currentText === "Salinity user defined"){
                                                upmix.restart()
                                            }else if (mixchx.currentText === "Mole_weighted_average"){
                                                mixtureModel.append({"name": "Dictionary key:", "value": ""})
                                                downmix.restart()
                                            }
                                            invademixtureType = mixchx.currentText

                                            if (invademixtureType==="Salinity" || invademixtureType==="Mole_weighted_average"){
                                                mwText.enabled = false
                                                molardiffText.enabled = false
                                            }else if (invademixtureType==="Fuller_diffusivity" || invademixtureType==="Wilke_fuller_diffusivity"){
                                                mwText.enabled = true
                                                molardiffText.enabled = true
                                            }else if (invademixtureType === "User defined"){
                                                mwText.enabled = true
                                                molardiffText.enabled = true
                                            }
                                            invademixChange()
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: mixIcon
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
                                                if(mixOpen){
                                                    upmix.restart()
                                                    mixOpen = !mixOpen
                                                }else{
                                                    downmix.restart()
                                                    mixOpen = !mixOpen
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: mixproprec
                                    width: parent.width / 2
                                    height: mixtureModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: mixtureModel}
                                        delegate: RowLayout{
                                            width: mixrec.width
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
                                                    invadedickey = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: molardenrec
                            width: parent.width
                            height: 100
                            color: "#c0c0c0"
                            state: "Standard"

                            states: [
                                State {
                                    name: "Standard"
                                    PropertyChanges {
                                        target: molarchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Ideal_gas"
                                    PropertyChanges {
                                        target: molarchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Vanderwaals"
                                    PropertyChanges {
                                        target: molarchx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: molarchx
                                        currentIndex: 3
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: molardensityCheck
                                        Layout.fillHeight: true
                                        text: "Molar density (mol/m3)"
                                        onCheckStateChanged: {
                                            invademolar = !invademolar
                                            molarchx.currentIndex = 0
                                            molarchx.enabled = !molarchx.enabled
                                            if (invademolar){
                                                invademolarType = molarchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Molar density",
                                                                         "proptext": "Molar density" + " (" + invademolarType + ")"
                                                                     })
                                            }else{
                                                invademolarType = ""
                                                var index = findprops(phaseinvmodel, "Invade Molar density")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            if (invademolar){
                                                mwText.enabled = true
                                                critempText.enabled = false
                                                cripressureText.enabled = false
                                                if(!densityCheck){
                                                    densityCheck.checked = true
                                                }
                                            }else{
                                                critempText.enabled = false
                                                cripressureText.enabled = false
                                                mwText.enabled = false
                                            }

                                            var index = find(helpmodel, "Invading molar density")
                                            if(index !== null){
                                                helpmodel.setProperty(index, "check", invademolar)
                                            }
                                        }
                                    }
                                    TextField{
                                        id: molarText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (molarchx.currentIndex === 3)

                                        onTextChanged: {
                                            invademolardenU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: parent.height * 0.5
                                    spacing: 10
                                    ComboBox{
                                        id: molarchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#c0c0c0"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Standard" }
                                            ListElement { text: "Ideal_gas" }
                                            ListElement { text: "Vanderwaals" }
                                            ListElement { text: "User defined" }
                                        }
                                        onActivated: {
                                            invademolarType = molarchx.currentText

                                            if (invademolarType==="Standard"){
                                                mwText.enabled = true
                                                critempText.enabled = false
                                                cripressureText.enabled = false
                                            }else if (invademolarType==="Ideal_gas"){
                                                critempText.enabled = false
                                                cripressureText.enabled = false
                                                mwText.enabled = false
                                            }else if (invademolarType==="Vanderwaals"){
                                                critempText.enabled = true
                                                cripressureText.enabled = true
                                                mwText.enabled = false
                                            }else if (invademolarType === "User defined"){
                                                mwText.enabled = true
                                                critempText.enabled = true
                                                cripressureText.enabled = true
                                            }
                                            invademolarChange()
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
                            id: partrec
                            width: parent.width
                            height: 50
                            color: "#ffffff"

                            Column{
                                anchors.fill: parent
                                spacing: 0
                                Row{
                                    width: parent.width
                                    height: 50
                                    spacing: 0
                                    CheckBox{
                                        id: partcoeffcb
                                        width: parent.width * 0.85
                                        text: "Partition coefficient"
                                        onCheckStateChanged: {
                                            invadepartcoeff = !invadepartcoeff
                                            partIcon.enabled = !partIcon.enabled
                                            if(invadepartcoeff){
                                                partcoeffModel.append({"name": "Chemical formula:", "value": ""})
                                                downpart.restart()
                                                partOpen = !partOpen
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Partition coefficient",
                                                                         "proptext": "Partition coefficient"
                                                                     })
                                            }else{
                                                uppart.restart()
                                                partcoeffModel.clear()
                                                partOpen = !partOpen
                                                var index = findprops(phaseinvmodel, "Invade Partition coefficient")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: partIcon
                                        width: parent.width * 0.15
                                        height: parent.height
                                        enabled: false
                                        text: Icons.settings
                                        font.family: webfont.name
                                        font.pixelSize: 25//Qt.application.font.pixelSize
                                        verticalAlignment: Qt.AlignVCenter
                                        MouseArea{
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if(partOpen){
                                                    uppart.restart()
                                                    partOpen = !partOpen
                                                }else{
                                                    downpart.restart()
                                                    partOpen = !partOpen
                                                }
                                            }
                                        }
                                    }

                                }
                                Rectangle{
                                    id: partproprec
                                    width: parent.width / 2
                                    height: partcoeffModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: partcoeffModel}
                                        delegate: RowLayout{
                                            width: partrec.width
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
                                                    invadechemicalformula = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: perirec
                            width: parent.width
                            height: 50
                            color: "#c0c0c0"
                            Row{
                                anchors.fill: parent
                                spacing: 0
                                CheckBox{
                                    id: pericb
                                    width: parent.width * 0.8
                                    text: "Permittivity"
                                    onCheckStateChanged: {
                                        invadepermittivity = !invadepermittivity
                                        if (invadepermittivity){
                                            phaseinvmodel.append({
                                                                     "maintext": "Invade Permittivity",
                                                                     "proptext": "Permittivity"
                                                                 })
                                        }else{
                                            var index = findprops(phaseinvmodel, "Invade Permittivity")
                                            if(index !== null){
                                                phaseinvmodel.remove(index)
                                            }
                                        }
                                    }
                                }

                            }
                        }

                        Rectangle{
                            id: surfrec
                            width: parent.width
                            height: 100
                            color: "#ffffff"
                            state: "Water"

                            states: [
                                State {
                                    name: "Water"
                                    PropertyChanges {
                                        target: surfchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Eotvos"
                                    PropertyChanges {
                                        target: surfchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Guggenheim_katayama"
                                    PropertyChanges {
                                        target: surfchx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "Brock_bird_scaling"
                                    PropertyChanges {
                                        target: surfchx
                                        currentIndex: 3
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: surfchx
                                        currentIndex: 4
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: surfcb
                                        Layout.fillHeight: true
                                        height: 50
                                        text: "Surface tension (kg/m.s)"
                                        onCheckStateChanged: {
                                            invadesurf = !invadesurf
                                            surfchx.currentIndex = 0
                                            surfchx.enabled = !surfchx.enabled
                                            surfIcon.enabled = !surfIcon.enabled
                                            if(invadesurf){
                                                downsurf.restart()
                                                surfOpen = !surfOpen
                                                invadesurfType = surfchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Surface tension",
                                                                         "proptext": "Surface tension" + " (" + invadesurfType + ")"
                                                                     })
                                            }else{
                                                upsurf.restart()
                                                surfModel.clear()
                                                surfOpen = !surfOpen
                                                invadesurfType = ""
                                                var index = findprops(phaseinvmodel, "Invade Surface tension")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }

                                            critempText.enabled = false
                                            cripressureText.enabled = false

                                            var index = find(helpmodel, "Invading surface tension")
                                            if(index !== null){
                                                helpmodel.setProperty(index, "check", invadesurf)
                                            }
                                        }
                                    }
                                    TextField{
                                        id: surfText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (surfchx.currentIndex === 4)

                                        onTextChanged: {
                                            invadesurfU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: 50
                                    spacing: 10
                                    ComboBox{
                                        id: surfchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#ffffff"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Water" }
                                            ListElement { text: "Eotvos" }
                                            ListElement { text: "Guggenheim_katayama" }
                                            ListElement { text: "Brock_bird_scaling" }
                                            ListElement { text: "User defined" }
                                        }

                                        onActivated: {
                                            surfModel.clear()
                                            if(surfchx.currentText === "Water" || surfchx.currentText === "User defined"){
                                                upsurf.restart()
                                            }else if (surfchx.currentText === "Eotvos"){
                                                surfModel.append({"name": "Constant parameter:", "visible": true, "value": ""})
                                                downsurf.restart()
                                            }else if (surfchx.currentText === "Guggenheim_katayama"){
                                                surfModel.append({"name": "Specific constant (k2):", "visible": true, "value": ""})
                                                surfModel.append({"name": "Specific constant (n):", "visible": true, "value": ""})
                                                downsurf.restart()
                                            }else if (surfchx.currentText === "Brock_bird_scaling"){
                                                surfModel.append({"name": "Surface tension (N/m):", "visible": true, "value": ""})
                                                surfModel.append({"name": "*Fill the temperature", "visible": false, "value": ""})
                                                downsurf.restart()
                                            }
                                            invadesurfType = surfchx.currentText

                                            if (invadesurfType === "Water"){
                                                critempText.enabled = false
                                                cripressureText.enabled = false
                                            }else if (invadesurfType === "Eotvos"){
                                                critempText.enabled = true
                                                cripressureText.enabled = false
                                            }else if (invadesurfType === "Guggenheim_katayama"){
                                                critempText.enabled = true
                                                cripressureText.enabled = true
                                            }else if (invadesurfType === "Brock_bird_scaling"){
                                                critempText.enabled = true
                                                cripressureText.enabled = false
                                            }else if (invadesurfType === "User defined"){
                                                critempText.enabled = true
                                                cripressureText.enabled = true
                                            }
                                            invadesurfChange()
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: surfIcon
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
                                                if(surfOpen){
                                                    upsurf.restart()
                                                    surfOpen = !surfOpen
                                                }else{
                                                    downsurf.restart()
                                                    surfOpen = !surfOpen
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: surfproprec
                                    width: parent.width / 2
                                    height: surfModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: surfModel}
                                        delegate: RowLayout{
                                            width: diffrec.width
                                            height: 50

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Qt.AlignVCenter

                                                text: model.name
                                            }
                                            TextField{
                                                visible: model.visible
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
                                                    if (surfchx.currentText === "Eotvos"){
                                                        invadeconstparam = text
                                                    }else if (surfchx.currentText === "Guggenheim_katayama"){
                                                        if (model.index === 0){
                                                            invadeK2 = text
                                                        }else if (model.index === 1){
                                                            invadeN = text
                                                        }
                                                    }else if (surfchx.currentText === "Brock_bird_scaling"){
                                                        invadesurfprop = text
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: vaporrec
                            width: parent.width
                            height: 100
                            color: "#c0c0c0"
                            state: "Water"

                            states: [
                                State {
                                    name: "Water"
                                    PropertyChanges {
                                        target: vaporchx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Antoine"
                                    PropertyChanges {
                                        target: vaporchx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: vaporchx
                                        currentIndex: 2
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: vaporcb
                                        Layout.fillHeight: true
                                        height: 50
                                        text: "Vapor pressure (Pa)"
                                        onCheckStateChanged: {
                                            invadevapor = !invadevapor
                                            vaporchx.currentIndex = 0
                                            vaporchx.enabled = !vaporchx.enabled
                                            vaporIcon.enabled = !vaporIcon.enabled
                                            if(invadevapor){
                                                downvapor.restart()
                                                vaporOpen = !vaporOpen
                                                invadevaporType = vaporchx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Vapor pressure",
                                                                         "proptext": "Vapor pressure" + " (" + invadevaporType + ")"
                                                                     })
                                            }else{
                                                upvapor.restart()
                                                vaporpressureModel.clear()
                                                vaporOpen = !vaporOpen
                                                invadevaporType = ""
                                                var index = findprops(phaseinvmodel, "Invade Vapor pressure")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }
                                        }
                                    }
                                    TextField{
                                        id: vaporText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (vaporchx.currentIndex === 2)

                                        onTextChanged: {
                                            invadevaporU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: 50
                                    spacing: 10
                                    ComboBox{
                                        id: vaporchx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#c0c0c0"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Water" }
                                            ListElement { text: "Antoine" }
                                            ListElement { text: "User defined" }
                                        }

                                        onActivated: {
                                            vaporpressureModel.clear()
                                            if(vaporchx.currentText === "Water" || vaporchx.currentText === "User defined"){
                                                upvapor.restart()
                                            }else if (vaporchx.currentText === "Antoine"){
                                                vaporpressureModel.append({"name": "Pressure coefficient A (mmHg):", "value": ""})
                                                vaporpressureModel.append({"name": "Pressure coefficient B (mmHg):", "value": ""})
                                                vaporpressureModel.append({"name": "Pressure coefficient C (mmHg):", "value": ""})
                                                downvapor.restart()
                                            }
                                            invadevaporType = vaporchx.currentText
                                            invadevaporChange()
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: vaporIcon
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
                                                if(vaporOpen){
                                                    upvapor.restart()
                                                    vaporOpen = !vaporOpen
                                                }else{
                                                    downvapor.restart()
                                                    vaporOpen = !vaporOpen
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: vaporproprec
                                    width: parent.width / 2
                                    height: vaporpressureModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: vaporpressureModel}
                                        delegate: RowLayout{
                                            width: vaporrec.width
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
                                                        invadeprescoeffA = text
                                                    }else if (model.index === 1){
                                                        invadeprescoeffB = text
                                                    }else if (model.index === 2){
                                                        invadeprescoeffC = text
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: visrec
                            width: parent.width
                            height: 100
                            color: "#ffffff"
                            state: "Water"

                            states: [
                                State {
                                    name: "Water"
                                    PropertyChanges {
                                        target: vischx
                                        currentIndex: 0
                                    }
                                },
                                State {
                                    name: "Reynolds"
                                    PropertyChanges {
                                        target: vischx
                                        currentIndex: 1
                                    }
                                },
                                State {
                                    name: "Chung"
                                    PropertyChanges {
                                        target: vischx
                                        currentIndex: 2
                                    }
                                },
                                State {
                                    name: "User defined"
                                    PropertyChanges {
                                        target: vischx
                                        currentIndex: 3
                                    }
                                }

                            ]
                            Column{
                                anchors.fill: parent
                                spacing: 0
                                RowLayout{
                                    width: parent.width
                                    CheckBox{
                                        id: visCheck
                                        Layout.fillHeight: true
                                        height: 50
                                        text: "Viscosity (kg/m.s)"
                                        onCheckStateChanged: {
                                            invadeviscosity = !invadeviscosity
                                            vischx.currentIndex = 0
                                            vischx.enabled = !vischx.enabled
                                            visIcon.enabled = !visIcon.enabled
                                            if(invadeviscosity){
                                                downvis.restart()
                                                visOpen = !visOpen
                                                invadeviscosityType = vischx.currentText
                                                phaseinvmodel.append({
                                                                         "maintext": "Invade Viscosity",
                                                                         "proptext": "Viscosity" + " (" + invadeviscosityType + ")"
                                                                     })
                                            }else{
                                                upvis.restart()
                                                viscosityModel.clear()
                                                visOpen = !visOpen
                                                invadeviscosityType = ""
                                                var index = findprops(phaseinvmodel, "Invade Viscosity")
                                                if(index !== null){
                                                    phaseinvmodel.remove(index)
                                                }
                                            }
                                            critempText.enabled = false
                                            crivolText.enabled = false
                                            mwText.enabled = false
                                        }
                                    }
                                    TextField{
                                        id: visText
                                        //                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 5
                                        Layout.rightMargin: 5
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.6
                                        selectByMouse: true
                                        //                            maximumLength: 2
                                        text: ""
                                        visible: (vischx.currentIndex === 3)

                                        onTextChanged: {
                                            invadevisU = text
                                        }
                                    }
                                }
                                RowLayout{
                                    width: parent.width * 0.9
                                    height: 50
                                    spacing: 10
                                    ComboBox{
                                        id: vischx
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width *0.9
                                        enabled: false
                                        background: Rectangle {
                                            color:"#ffffff"
                                            border.width: 1
                                            border.color: "#000000"
                                        }
                                        model: ListModel {
                                            ListElement { text: "Water" }
                                            ListElement { text: "Reynolds" }
                                            ListElement { text: "Chung" }
                                            ListElement { text: "User defined" }
                                        }

                                        onActivated: {
                                            viscosityModel.clear()
                                            if(vischx.currentText === "Water" || vischx.currentText === "Chung" || vischx.currentText === "User defined"){
                                                upvis.restart()
                                            }else if (vischx.currentText === "Reynolds"){
                                                viscosityModel.append({"name": "Viscosity coefficient (u0):", "value": ""})
                                                viscosityModel.append({"name": "Viscosity coefficient (b):", "value": ""})
                                                downvis.restart()
                                            }
                                            invadeviscosityType = vischx.currentText

                                            if (invadeviscosityType === "Chung" || invadeviscosityType === "User defined"){
                                                critempText.enabled = true
                                                crivolText.enabled = true
                                                mwText.enabled = true
                                            }else{
                                                critempText.enabled = false
                                                crivolText.enabled = false
                                                mwText.enabled = false
                                            }
                                            invadevisChange()
                                        }
                                    }
                                    //-- Setting Icon --//
                                    Label{
                                        id: visIcon
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
                                                if(visOpen){
                                                    upvis.restart()
                                                    visOpen = !visOpen
                                                }else{
                                                    downvis.restart()
                                                    visOpen = !visOpen
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: visproprec
                                    width: parent.width / 2
                                    height: viscosityModel.count*50
                                    color: "transparent"
                                    ListView{
                                        anchors.fill: parent
                                        model: ListModel{id: viscosityModel}
                                        delegate: RowLayout{
                                            width: visrec.width
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
                                                text: ""

                                                onTextChanged: {
                                                    if (model.index === 0){
                                                        invadeviscoeffA = text
                                                    }else if (model.index === 1){
                                                        invadeviscoeffB = text
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        //                // **** spacer ****//
                        //                Rectangle{
                        //                    width: parent.width
                        //                    height: 10
                        //                    color: "transparent"
                        //                }
                    }
                }
            }

            // **** spacer ****//
            Rectangle{
                id: spacer
                width: parent.width
                height: 3
                color: "black"
            }

            Flickable{
                width: parent.width
                height: parent.height*0.4
                clip: true

                contentWidth: parent.width
                contentHeight: 570
                ScrollBar.vertical: ScrollBar {

                }
                Rectangle{
                    anchors.fill: parent
                    color: "#f8f8ff"

                    Column{
                        anchors.fill: parent
                        spacing: 0
                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Concentration (Kg/m3):"
                            }
                            TextField{
                                id: concen
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""

                                onTextChanged: {
                                    invadeconcentration = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Pressure (Pa):"
                            }
                            TextField{
                                id: press
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
                                onTextChanged: {
                                    invadepressure = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Temperature (K):"
                            }
                            TextField{
                                id: temp
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
                                onTextChanged: {
                                    invadetemp = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Molar diffusion volume:"
                            }
                            TextField{
                                id: molardiffText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invademoldiffvol = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Volume fraction:"
                            }
                            TextField{
                                id: volfracText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadevolfrac = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Intrinsic conductivity:"
                            }
                            TextField{
                                id: intrinsicText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadeintcond = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Molecular weight (Kg/mol):"
                            }
                            TextField{
                                id: mwText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invademolweight = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Critical temperature (K):"
                            }
                            TextField{
                                id: critempText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadecritemp = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Critical pressure (Pa):"
                            }
                            TextField{
                                id: cripressureText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadecripressure = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Critical volume (m3/Kg):"
                            }
                            TextField{
                                id: crivolText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadecrivol = text
                                }
                            }

                        }

                        RowLayout{
                            width: parent.width
                            height: 50
                            spacing: 0

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Critical angle (Degree):"
                            }
                            TextField{
                                id: criangleText
                                Layout.preferredHeight: parent.height / 1.2
                                Layout.fillWidth: true
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.6
                                selectByMouse: true
                                //                            maximumLength: 2
                                text: ""
//                                enabled: false

                                onTextChanged: {
                                    invadecriangle = text
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    function invadedenChange(){
        var index = findprops(phaseinvmodel, "Invade Density")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Density" + " (" + invadedensityType + ")")
        }
    }

    function invadediffChange(){
        var index = findprops(phaseinvmodel, "Invade Diffusivity")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Diffusivity" + " (" + invadediffusivityType + ")")
        }
    }

    function invademixChange(){
        var index = findprops(phaseinvmodel, "Invade Mixtures")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Mixtures" + " (" + invademixtureType + ")")
        }
    }

    function invademolarChange(){
        var index = findprops(phaseinvmodel, "Invade Molar density")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Molar density" + " (" + invademolarType + ")")
        }
    }

    function invadesurfChange(){
        var index = findprops(phaseinvmodel, "Invade Surface tension")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Surface tension" + " (" + invadesurfType + ")")
        }
    }


    function invadevaporChange(){
        var index = findprops(phaseinvmodel, "Invade Vapor pressure")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Vapor pressure" + " (" + invadevaporType + ")")
        }
    }

    function invadevisChange(){
        var index = findprops(phaseinvmodel, "Invade Viscosity")
        if(index !== null){
            phaseinvmodel.setProperty(index, "proptext", "Viscosity" + " (" + invadeviscosityType + ")")
        }
    }
}
