import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

Item {
    id: poreitem

    anchors.fill: parent

    property alias pccheck: pccb.checked
    property alias pcstate: pcrec.state
    property alias diffcondcheck: diffcondcb.checked
    property alias diffcondstate: diffcondrec.state
    property alias hydcondcheck: hydcondcb.checked
    property alias hydcondstate: hydcondrec.state
    property alias multicheck: multicb.checked
    property alias multistate: multirec.state
    property alias flowshapecheck: flowshapecb.checked
    property alias flowshapestate: flowshaperec.state
    property alias poissonshapecheck: poissonshapecb.checked
    property alias poissonshapestate: poissonshaperec.state

    objectName: "Physic"

    Component.onCompleted: {}

    //-- body --//
    Rectangle{
        anchors.fill: parent
        color: "#f8f8ff"

        Column{
            anchors.fill: parent
            spacing: 0

            Label{
                id: txt2
                font.pixelSize: Qt.application.font.pixelSize
                font.bold: true
                text: "Choose the physics properties:"
            }

            // **** spacer ****//
            Rectangle{
                id: spacer
                width: parent.width
                height: 10
                color: "transparent"
            }

            Flickable{
                width: parent.width
                height: parent.height - txt2.height - spacer.height
                clip: true

                contentWidth: parent.width
                contentHeight: 600
                ScrollBar.vertical: ScrollBar {

                }

                Column{
                    anchors.fill: parent
                    spacing: 0

                    Rectangle{
                        id: pcrec
                        width: parent.width
                        height: 100
                        color: "#c0c0c0"
                        state: "Washburn"

                        states: [
                            State {
                                name: "Washburn"
                                PropertyChanges {
                                    target: cpchx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Purcell"
                                PropertyChanges {
                                    target: cpchx
                                    currentIndex: 1
                                }
                            },
                            State {
                                name: "Purcell_bidirectional"
                                PropertyChanges {
                                    target: cpchx
                                    currentIndex: 2
                                }
                            },
                            State {
                                name: "Ransohoff_snap_off"
                                PropertyChanges {
                                    target: cpchx
                                    currentIndex: 3
                                }
                            },
                            State {
                                name: "Sinusoidal_bidirectional"
                                PropertyChanges {
                                    target: cpchx
                                    currentIndex: 4
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: pccb
                                width: parent.width
                                text: "Capillary pressure"
                                checked: true

                                onCheckStateChanged: {
                                    capillarypressure = !capillarypressure
                                    cpchx.currentIndex = 0
                                    cpchx.enabled = !cpchx.enabled
                                    if (capillarypressure){
                                        capillarypressureType = cpchx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Capillary pressure",
                                                                 "proptext": "Capillary pressure" + " (" + capillarypressureType + ")"
                                                             })
                                    }else{
                                        capillarypressureType = ""
                                        var index = findprops(physicmodel, "Capillary pressure")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }

                                    var index = find(helpmodel, "Capillary pressure")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", capillarypressure)
                                    }
                                }
                            }

                            ComboBox{
                                id: cpchx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Washburn" }
                                    ListElement { text: "Purcell" }
                                    ListElement { text: "Purcell_bidirectional" }
                                    ListElement { text: "Ransohoff_snap_off" }
                                    ListElement { text: "Sinusoidal_bidirectional" }
                                }
                                onActivated: {
                                    capillarypressureType = cpchx.currentText
                                    cpChange()
                                }
                            }
                        }
                    }

                    Rectangle{
                        id: diffcondrec
                        width: parent.width
                        height: 100
                        color: "#ffffff"
                        state: "Mixed_diffusion"

                        states: [
                            State {
                                name: "Ordinary_diffusion"
                                PropertyChanges {
                                    target: diffchx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Ordinary_diffusion_2D"
                                PropertyChanges {
                                    target: diffchx
                                    currentIndex: 1
                                }
                            },
                            State {
                                name: "Mixed_diffusion"
                                PropertyChanges {
                                    target: diffchx
                                    currentIndex: 2
                                }
                            },
                            State {
                                name: "Taylor_aris_diffusion"
                                PropertyChanges {
                                    target: diffchx
                                    currentIndex: 3
                                }
                            },
                            State {
                                name: "Classic_ordinary_diffusion"
                                PropertyChanges {
                                    target: diffchx
                                    currentIndex: 4
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: diffcondcb
                                width: parent.width
                                text: "Diffusive conductance"
                                checked: true

                                onCheckStateChanged: {
                                    diffusivecond = !diffusivecond
                                    diffchx.currentIndex = 0
                                    diffchx.enabled = !diffchx.enabled
                                    if(diffusivecond){
                                        diffusivecondType = diffchx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Diffusive conductance",
                                                                 "proptext": "Diffusive conductance" + " (" + diffusivecondType + ")"
                                                             })
                                    }else{
                                        diffusivecondType = ""
                                        var index = findprops(physicmodel, "Diffusive conductance")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }

                                    var index = find(helpmodel, "Diffusive conductance")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", diffusivecond)
                                    }
                                }
                            }

                            ComboBox{
                                id: diffchx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                currentIndex: 2
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Ordinary_diffusion" }
                                    ListElement { text: "Ordinary_diffusion_2D" }
                                    ListElement { text: "Mixed_diffusion" }
                                    ListElement { text: "Taylor_aris_diffusion" }
                                    ListElement { text: "Classic_ordinary_diffusion" }
                                }
                                onActivated: {
                                    diffusivecondType = diffchx.currentText
                                    diffChange()
                                }
                            }
                        }
                    }

                    Rectangle{
                        id: hydcondrec
                        width: parent.width
                        height: 100
                        color: "#c0c0c0"
                        state: "Hagen_poiseuille"

                        states: [
                            State {
                                name: "Hagen_poiseuille"
                                PropertyChanges {
                                    target: hydraulicchx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Hagen_poiseuille_2D"
                                PropertyChanges {
                                    target: hydraulicchx
                                    currentIndex: 1
                                }
                            },
                            State {
                                name: "Hagen_poiseuille_power_law"
                                PropertyChanges {
                                    target: hydraulicchx
                                    currentIndex: 2
                                }
                            },
                            State {
                                name: "Valvatne_blunt"
                                PropertyChanges {
                                    target: hydraulicchx
                                    currentIndex: 3
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: hydcondcb
                                width: parent.width
                                text: "Hydraulic conductance"
                                checked: true

                                onCheckStateChanged: {
                                    hydrauliccond = !hydrauliccond
                                    hydraulicchx.currentIndex = 0
                                    hydraulicchx.enabled = !hydraulicchx.enabled
                                    if (hydrauliccond){
                                        hydrauliccondType = hydraulicchx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Hydraulic conductance",
                                                                 "proptext": "Hydraulic conductance" + " (" + hydrauliccondType + ")"
                                                             })
                                    }else{
                                        hydrauliccondType = ""
                                        var index = findprops(physicmodel, "Hydraulic conductance")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }
                                    var index = find(helpmodel, "Hydraulic conductance")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", hydrauliccond)
                                    }
                                }
                            }

                            ComboBox{
                                id: hydraulicchx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Hagen_poiseuille" }
                                    ListElement { text: "Hagen_poiseuille_2D" }
                                    ListElement { text: "Hagen_poiseuille_power_law" }
                                    ListElement { text: "Valvatne_blunt" }
                                }
                                onActivated: {
                                    hydrauliccondType = hydraulicchx.currentText
                                    hydChange()
                                }
                            }
                        }
                    }

                    Rectangle{
                        id: multirec
                        width: parent.width
                        height: 100
                        color: "#ffffff"
                        state: "Conduit_conductance"

                        states: [
                            State {
                                name: "Conduit_conductance"
                                PropertyChanges {
                                    target: multichx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Late_filling"
                                PropertyChanges {
                                    target: multichx
                                    currentIndex: 1
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: multicb
                                width: parent.width
                                text: "Multiphase"
                                checked: true
                                onCheckStateChanged: {
                                    multiphase = !multiphase
                                    multichx.currentIndex = 0
                                    multichx.enabled = !multichx.enabled
                                    if (multiphase){
                                        multiphaseType = multichx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Multiphase",
                                                                 "proptext": "Multiphase" + " (" + multiphaseType + ")"
                                                             })
                                    }else{
                                        multiphaseType = ""
                                        var index = findprops(physicmodel, "Multiphase")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }
                                    var index = find(helpmodel, "Multiphase")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", multiphase)
                                    }
                                }
                            }

                            ComboBox{
                                id: multichx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Conduit_conductance" }
                                    ListElement { text: "Late_filling" }
                                }
                                onActivated: {
                                    multiphaseType = multichx.currentText
                                    multiChange()
                                }
                            }
                        }
                    }

                    Rectangle{
                        id: flowshaperec
                        width: parent.width
                        height: 100
                        color: "#c0c0c0"
                        state: "Ball_and_stick"

                        states: [
                            State {
                                name: "Ball_and_stick"
                                PropertyChanges {
                                    target: flowchx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Conical_frustum_and_stick"
                                PropertyChanges {
                                    target: flowchx
                                    currentIndex: 1
                                }
                            },
                            State {
                                name: "Ball_and_stick_2D"
                                PropertyChanges {
                                    target: flowchx
                                    currentIndex: 1
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: flowshapecb
                                width: parent.width
                                text: "Flow shape factor"

                                onCheckStateChanged: {
                                    flowshapefactor = !flowshapefactor
                                    flowchx.currentIndex = 0
                                    flowchx.enabled = !flowchx.enabled
                                    if (flowshapefactor){
                                        flowshapefactorType = flowchx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Flow shape factor",
                                                                 "proptext": "Flow shape factor" + " (" + flowshapefactorType + ")"
                                                             })
                                    }else{
                                        flowshapefactorType = ""
                                        var index = findprops(physicmodel, "Flow shape factor")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }

                                    var index = find(helpmodel, "Flow shape factor")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", flowshapefactor)
                                    }
                                }
                            }

                            ComboBox{
                                id: flowchx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                enabled: false
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Ball_and_stick" }
                                    ListElement { text: "Conical_frustum_and_stick" }
                                    ListElement { text: "Ball_and_stick_2D" }
                                }
                                onActivated: {
                                    flowshapefactorType = flowchx.currentText
                                    flowChange()
                                }
                            }
                        }
                    }

                    Rectangle{
                        id: poissonshaperec
                        width: parent.width
                        height: 100
                        color: "#ffffff"
                        state: "Ball_and_stick"

                        states: [
                            State {
                                name: "Ball_and_stick"
                                PropertyChanges {
                                    target: poissonchx
                                    currentIndex: 0
                                }
                            },
                            State {
                                name: "Conical_frustum_and_stick"
                                PropertyChanges {
                                    target: poissonchx
                                    currentIndex: 1
                                }
                            },
                            State {
                                name: "Ball_and_stick_2D"
                                PropertyChanges {
                                    target: poissonchx
                                    currentIndex: 1
                                }
                            }

                        ]
                        Column{
                            anchors.fill: parent
                            spacing: 0
                            CheckBox{
                                id: poissonshapecb
                                width: parent.width
                                text: "Poisson shape factor"
                                checked: true

                                onCheckStateChanged: {
                                    poissonshapefactor = !poissonshapefactor
                                    poissonchx.currentIndex = 0
                                    poissonchx.enabled = !poissonchx.enabled
                                    if (poissonshapefactor){
                                        poissonshapefactorType = poissonchx.currentText
                                        physicmodel.append({
                                                                 "maintext": "Poisson shape factor",
                                                                 "proptext": "Poisson shape factor" + " (" + poissonshapefactorType + ")"
                                                             })
                                    }else{
                                        poissonshapefactorType = ""
                                        var index = findprops(physicmodel, "Poisson shape factor")
                                        if(index !== null){
                                            physicmodel.remove(index)
                                        }
                                    }
                                    var index = find(helpmodel, "Poisson shape factor")
                                    if(index !== null){
                                        helpmodel.setProperty(index, "check", poissonshapefactor)
                                    }
                                }
                            }

                            ComboBox{
                                id: poissonchx
                                width: parent.width * 0.9
                                height: parent.height * 0.5
                                background: Rectangle {
                                    color:"#c0c0c0"
                                    border.width: 1
                                    border.color: "#000000"
                                }
                                model: ListModel {
                                    ListElement { text: "Ball_and_stick" }
                                    ListElement { text: "Conical_frustum_and_stick" }
                                    ListElement { text: "Ball_and_stick_2D" }
                                }
                                onActivated: {
                                    poissonshapefactorType = poissonchx.currentText
                                    poiChange()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function cpChange(){
        var index = findprops(physicmodel, "Capillary pressure")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Capillary pressure" + " (" + capillarypressureType + ")")
        }
    }

    function diffChange(){
        var index = findprops(physicmodel, "Diffusive conductance")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Diffusive conductance" + " (" + diffusivecondType + ")")
        }
    }

    function hydChange(){
        var index = findprops(physicmodel, "Hydraulic conductance")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Hydraulic conductance" + " (" + hydrauliccondType + ")")
        }
    }

    function multiChange(){
        var index = findprops(physicmodel, "Multiphase")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Multiphase" + " (" + multiphaseType + ")")
        }
    }

    function flowChange(){
        var index = findprops(physicmodel, "Flow shape factor")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Flow shape factor" + " (" + flowshapefactorType + ")")
        }
    }

    function poiChange(){
        var index = findprops(physicmodel, "Poisson shape factor")
        if(index !== null){
            physicmodel.setProperty(index, "proptext", "Poisson shape factor" + " (" + poissonshapefactorType + ")")
        }
    }
}
