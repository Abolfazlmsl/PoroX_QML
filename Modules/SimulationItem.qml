import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

Item {
    id: siumlationitem

    anchors.fill: parent

    objectName: "Simulation"

    property alias simulationstate: siumlationitem.state
    property alias rescheck: rescb.checked
    property alias resvalue: resText.text
    property alias trapcheck: trapcb.checked

    property string method: "Ordinary Percolation"
    property bool trapping: false

    signal getFinalResult(var overal_pores, var connected_pores, var isolated_pores,
                          var overal_throats, var porosity, var K_tot, var K1, var K2, var K3, var D_tot, var D1, var D2, var D3,
                          var x_eval, var y_eval, var x_eval2, var y_eval2, var coordinationx, var coordinationy,
                          var PCswx, var PCswy, var PCswz, var PCpcx, var PCpcy, var PCpcz,
                          var Krswx, var Krswy, var Krswz, var Krwx, var Krnwx,
                          var Krwy, var Krnwy, var Krwz, var Krnwz,
                          var Drswx, var Drswy, var Drswz, var Drwx, var Drnwx, var Drwy,
                          var Drnwy, var Drwz, var Drnwz, var poreradius, var porecoord,
                          var throatradius, var throatlength, var throatcen, var rotation, var angle, bool success)

    onGetFinalResult: {
        simulationbutton.enabled = !simulationbutton.enabled
        if (success){

            poreprops.clear()
            for (var i=0; i<poreradius.length; i++){
                poreprops.append(
                            {
                                "Radi": poreradius[i]* 1000000/resolution,
                                "Coordx": porecoord[i][0]* 1000000/resolution,
                                "Coordy": porecoord[i][1]* 1000000/resolution,
                                "Coordz": porecoord[i][2]* 1000000/resolution
                            }
                            )
            }

            throatprops.clear()
            for (i=0; i<throatradius.length; i++){
                throatprops.append(
                            {
                                "Radi": throatradius[i]* 1000000/resolution,
                                "Length": throatlength[i]* 1000000/resolution,
                                "Centerx": throatcen[i][0]* 1000000/resolution,
                                "Centery": throatcen[i][1]* 1000000/resolution,
                                "Centerz": throatcen[i][2]* 1000000/resolution,
                                "Rotatex": rotation[i][0],
                                "Rotatey": rotation[i][1],
                                "Rotatez": rotation[i][2],
                                "Angle": angle[i]
                            }
                            )
            }

            btn_state.btnstate = !btn_state.btnstate
            psdxData = x_eval
            psdyData = y_eval
            psdnet.plot()
            tsdxData = x_eval2
            tsdyData = y_eval2
            tsdnet.plot()
            coordxData = coordinationx
            coordyData = coordinationy
            coordchart.plot()
            pcswxData = PCswx
            pcxData = PCpcx
            pcswyData = PCswy
            pcyData = PCpcy
            pcswzData = PCswz
            pczData = PCpcz
            pcchart.plot()

            krswxData = Krswx
            krswyData = Krswy
            krswzData = Krswz
            krwxData = Krwx
            krnwxData = Krnwx
            krwyData = Krwy
            krnwyData = Krnwy
            krwzData = Krwz
            krnwzData = Krnwz
            krchart.plot()

            drswxData = Drswx
            drswyData = Drswy
            drswzData = Drswz
            drwxData = Drwx
            drnwxData = Drnwx
            drwyData = Drwy
            drnwyData = Drnwy
            drwzData = Drwz
            drnwzData = Drnwz
            drchart.plot()

            resultmodel.clear()
            resultmodel.append({"text": "Total pores:  " + overal_pores})
            resultmodel.append({"text": "Connected pores: " + connected_pores})
            resultmodel.append({"text": "Isolated pores: " + isolated_pores})
            resultmodel.append({"text": "Total throats: " + overal_throats})
            resultmodel.append({"text": "Porosity: " + porosity  + " %"})
            resultmodel.append({"text": "Absolute permeability: " + K_tot  + " md"})
            resultmodel.append({"text": "Absolute diffusivity: " + String(D_tot)  + " mol/s"})

            sceneset.segmentVisible = false
            sceneset.reconstructVisible = false
            sceneset.throatVisible = true
            sceneset.poreVisible = true
            for (var j=0; j<sceneModel.count; j++){
                if (sceneModel.get(j).name !== "3D Network"){
                    sceneModel.setProperty(j, "state", false)
                }else{
                    sceneModel.setProperty(j, "state", true)
                }
            }

            if (!findbyNameBool(sceneModel, "3D Network")){
                sceneModel.append(
                            {
                                "name":"3D Network",
                                "state": true
                            }
                            )
            }

            resultview.sResultview = 1

            acceptPop.bodyText_Dialog = "Simulation was done successfully"
            acceptPop.visible = true
            filepanel.saveEnable = true
        }else{
            btn_state.btnstate = false
            errorPop.bodyText_Dialog = "Function was terminated"
            errorPop.visible = true
        }
    }

    Component.onCompleted: MainPython.finalsimulation.connect(getFinalResult)

    state: "Ordinary Percolation"

    states: [
        State {
            name: "Ordinary Percolation"
            PropertyChanges {
                target: radio1
                checked: true
            }
            PropertyChanges {
                target: resRec
                visible: true
            }
            PropertyChanges {
                target: trapRec
                visible: false
            }
        },
        State {
            name: "Invasion Percolation"
            PropertyChanges {
                target: radio2
                checked: true
            }
            PropertyChanges {
                target: resRec
                visible: false
            }
            PropertyChanges {
                target: trapRec
                visible: true
            }
        },
        State {
            name: "MixedInvasion Percolation"
            PropertyChanges {
                target: radio3
                checked: true
            }
            PropertyChanges {
                target: resRec
                visible: true
            }
            PropertyChanges {
                target: trapRec
                visible: true
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
                id: txt
                font.pixelSize: Qt.application.font.pixelSize
                font.bold: true
                text: "Percolation algorithm:"
            }

            ColumnLayout{
                id : lay
                Layout.preferredWidth: parent.width
                spacing: 0
                RadioButton{
                    id: radio1
                    text: "Ordinary Percolation"
                    onClicked: {
                        method = "Ordinary Percolation"
                        siumlationitem.state = "Ordinary Percolation"
                    }
                }
                RadioButton{
                    id: radio2
                    text: "Invasion Percolation"
                    onClicked: {
                        method = "Invasion Percolation"
                        siumlationitem.state = "Invasion Percolation"
                    }
                }
                RadioButton{
                    id: radio3
                    text: "MixedInvasion Percolation"
                    onClicked: {
                        method = "MixedInvasion Percolation"
                        siumlationitem.state = "MixedInvasion Percolation"
                    }
                }
            }

            Label{
                id: txt2
                font.pixelSize: Qt.application.font.pixelSize
                font.bold: true
                text: "Choose the desired properties:"
            }

            Column{
                Layout.preferredWidth: parent.width
                spacing: 0

                Rectangle{
                    id: resRec
                    width: parent.width
                    height: 100
                    color: "transparent"
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: rescb
                            width: parent.width
                            text: "Invader Residual"
                            checked: false

                            onCheckStateChanged: {
                                resText.enabled = !resText.enabled
                            }
                        }

                        RowLayout{
                            width: parent.width
                            height: 50

                            Label{
                                Layout.fillHeight: true
                                verticalAlignment: Qt.AlignVCenter

                                text: "Residual:"
                            }
                            TextField{
                                id: resText
                                enabled: false
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
                            }
                        }
                    }
                }

                Rectangle{
                    id: trapRec
                    width: parent.width
                    height: 50
                    color: "transparent"
                    visible: false
                    Column{
                        anchors.fill: parent
                        spacing: 0
                        CheckBox{
                            id: trapcb
                            width: parent.width
                            text: "Defender trapping"
                            checked: false

                            onCheckStateChanged: {
                                trapping = !trapping
                            }
                        }
                    }
                }
            }

            // **** spacer ****//
            Rectangle{
                id: spacer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 10
                color: "transparent"
            }

            Button{
                id: checkbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Check before run"
                background: Rectangle {

                    border.width: checkbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        checkprops()
                        if (helpmodel.count > 0){
                            isHelpOn = true
                            return
                        }
                        checkBeforeRun()
                    }
                }
            }


            Button{
                id: simulationbutton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Run"
                enabled: false
                background: Rectangle {

                    border.width: simulationbutton.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4
                    color: "#808080"
                }
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (resText.enabled && (resText.text<0 || resText.text>1)){
                            warningPop.bodyText_Dialog = "Residual must be between 0-1"
                            warningPop.visible = true; return
                        }else if (resText.enabled && isNaN(Number(resText.text))){
                            warningPop.bodyText_Dialog = "Residual must be a number"
                            warningPop.visible = true; return
                        }else if (resText.enabled && resText.text === ""){
                            warningPop.bodyText_Dialog = "Insert the residual value"
                            warningPop.visible = true; return
                        }else if (porediam){
                            if (porediamType === "Weibull" || porediamType === "Generic-distribution"){
                                if (poreshape === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore shape value"
                                    warningPop.visible = true; return
                                }else if (porescale === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore scale value"
                                    warningPop.visible = true; return
                                }else if (poreloc === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore loc value"
                                    warningPop.visible = true; return
                                }else if (poreshape <= 0){
                                    warningPop.bodyText_Dialog = "Pore shape must be positive"
                                    warningPop.visible = true; return
                                }else if (porescale <= 0){
                                    warningPop.bodyText_Dialog = "Pore scale must be positive"
                                    warningPop.visible = true; return
                                }else if (poreloc <= 0){
                                    warningPop.bodyText_Dialog = "Pore loc must be positive"
                                    warningPop.visible = true; return
                                }
                            }else if (porediamType === "Normal"){
                                if (porescale === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore scale value"
                                    warningPop.visible = true; return
                                }else if (porescale <= 0){
                                    warningPop.bodyText_Dialog = "Pore scale must be positive"
                                    warningPop.visible = true; return
                                }else if (poreloc === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore loc value"
                                    warningPop.visible = true; return
                                }else if (poreloc <= 0){
                                    warningPop.bodyText_Dialog = "Pore loc must be positive"
                                    warningPop.visible = true; return
                                }
                            }else if (porediamType === "From-neighbor-throats"){
                                if (poremode === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore mode"
                                    warningPop.visible = true; return
                                }else if (poremode !== "min" && poremode !== "max" && poremode !== "mean"){
                                    warningPop.bodyText_Dialog = "Pore mode must be among min, max or mean"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (poreseed){
                            if (poreseedType === "Spatially_correlated"){
                                if (poreweightx === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore weightX value"
                                    warningPop.visible = true; return
                                }else if (poreweighty === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore weightY value"
                                    warningPop.visible = true; return
                                }else if (poreweightz === ""){
                                    warningPop.bodyText_Dialog = "Insert the pore weightZ value"
                                    warningPop.visible = true; return
                                }else if (poreweightx <= 0){
                                    warningPop.bodyText_Dialog = "Pore weightX must be positive"
                                    warningPop.visible = true; return
                                }else if (poreweighty <= 0){
                                    warningPop.bodyText_Dialog = "Pore weightY must be positive"
                                    warningPop.visible = true; return
                                }else if (poreweightz <= 0){
                                    warningPop.bodyText_Dialog = "Pore weightZ must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(poreweightx))){
                                    warningPop.bodyText_Dialog = "Pore weightX must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(poreweighty))){
                                    warningPop.bodyText_Dialog = "Pore weightY must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(poreweightz))){
                                    warningPop.bodyText_Dialog = "Pore weightZ must be a number"
                                    warningPop.visible = true; return
                                }else if (poreweightx % 1 != 0){
                                    warningPop.bodyText_Dialog = "Pore weightX must be an integer number"
                                    warningPop.visible = true; return
                                }else if (poreweighty % 1 != 0){
                                    warningPop.bodyText_Dialog = "Pore weightY must be an integer number"
                                    warningPop.visible = true; return
                                }else if (poreweightz % 1 != 0){
                                    warningPop.bodyText_Dialog = "Pore weightZ must be an integer number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (throatdiam){
                            if (throatdiamType === "Weibull" || throatdiamType === "Generic-distribution"){
                                if (throatShape === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat shape value"
                                    warningPop.visible = true; return
                                }else if (throatscale === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat scale value"
                                    warningPop.visible = true; return
                                }else if (throatloc === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat loc value"
                                    warningPop.visible = true; return
                                }else if (throatShape <= 0){
                                    warningPop.bodyText_Dialog = "Throat shape must be positive"
                                    warningPop.visible = true; return
                                }else if (throatscale <= 0){
                                    warningPop.bodyText_Dialog = "Throat scale must be positive"
                                    warningPop.visible = true; return
                                }else if (throatloc <= 0){
                                    warningPop.bodyText_Dialog = "Throat loc must be positive"
                                    warningPop.visible = true; return
                                }
                            }else if (throatdiamType === "Normal"){
                                if (throatscale === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat scale value"
                                    warningPop.visible = true; return
                                }else if (throatloc === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat loc value"
                                    warningPop.visible = true; return
                                }else if (throatscale <= 0){
                                    warningPop.bodyText_Dialog = "Throat scale must be positive"
                                    warningPop.visible = true; return
                                }else if (throatloc <= 0){
                                    warningPop.bodyText_Dialog = "Throat loc must be positive"
                                    warningPop.visible = true; return
                                }
                            }
                            else if (throatdiamType === "From-neighbor-pores"){
                                if (throatmode === ""){
                                    warningPop.bodyText_Dialog = "Insert the throat mode"
                                    warningPop.visible = true; return
                                }else if (throatmode !== "min" && throatmode !== "max" && throatmode !== "mean"){
                                    warningPop.bodyText_Dialog = "Throat mode must be among min, max or mean"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadedensity){
                            if (invadedensityType === "User defined"){
                                if (invadedensityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase density value"
                                    warningPop.visible = true; return
                                }else if (invadedensityU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase density must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadedensityU))){
                                    warningPop.bodyText_Dialog = "Invading phase density must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadediffusivity){
                            if (invadediffusivityU === "Fuller"){
                                if (invadeMWA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase MW of component A value"
                                    warningPop.visible = true; return
                                }else if (invadeMWB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase MW of component B value"
                                    warningPop.visible = true; return
                                }else if (invadeatomicvolA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase atomic volume of component A value"
                                    warningPop.visible = true; return
                                }else if (invadeatomicvolB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase atomic volume of component B value"
                                    warningPop.visible = true; return
                                }else if (invadeMWA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase MW of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (invadeMWB <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase MW of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (invadeatomicvolA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase atomic volume of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (invadeatomicvolB <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase atomic volume of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeMWA))){
                                    warningPop.bodyText_Dialog = "Invading phase MW of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeMWB))){
                                    warningPop.bodyText_Dialog = "Invading phase MW of component B must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeatomicvolA))){
                                    warningPop.bodyText_Dialog = "Invading phase atomic volume of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeatomicvolB))){
                                    warningPop.bodyText_Dialog = "Invading phase atomic volume of component B must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadediffusivityU === "Fuller_scaling" || invadediffusivityU === "Tyn_calus_scaling"){
                                if (invadediffcoeff === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase diffusion coefficient value"
                                    warningPop.visible = true; return
                                }else if (invadediffcoeff <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase diffusion coefficient must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadediffcoeff))){
                                    warningPop.bodyText_Dialog = "Invading phase diffusion coefficient must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadediffusivityU === "Tyn_calus"){
                                if (invademolvolA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase molar volume of component A value"
                                    warningPop.visible = true; return
                                }else if (invademolvolB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase molar volume of component B value"
                                    warningPop.visible = true; return
                                }else if (invadesurfA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase surface tension of component A value"
                                    warningPop.visible = true; return
                                }else if (invadesurfB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase surface tension of component B value"
                                    warningPop.visible = true; return
                                }else if (invademolvolA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase molar volume of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (invademolvolB <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase molar volume of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (invadesurfA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (invadesurfB <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invademolvolA))){
                                    warningPop.bodyText_Dialog = "Invading phase molar volume of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invademolvolB))){
                                    warningPop.bodyText_Dialog = "Invading phase molar volume of component B must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadesurfA))){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadesurfB))){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension of component B must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadediffusivityU === "User defined"){
                                if (invadediffusivityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase diffusivity value"
                                    warningPop.visible = true; return
                                }else if (invadediffusivityU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase diffusivity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadediffusivityU))){
                                    warningPop.bodyText_Dialog = "Invading phase diffusivity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadeelectrical){
                            if (invadeperrelexp === ""){
                                warningPop.bodyText_Dialog = "Insert the invading phase percolation relation exponent value"
                                warningPop.visible = true; return
                            }else if (invadeperrelexp <= 0){
                                warningPop.bodyText_Dialog = "Invading phase percolation relation exponent must be positive"
                                warningPop.visible = true; return
                            }else if (isNaN(Number(invadeperrelexp))){
                                warningPop.bodyText_Dialog = "Invading phase percolation relation exponent must be a number"
                                warningPop.visible = true; return
                            }
                        }else if (invademixture){
                            if (invademixtureType === "Mole_weighted_average"){
                                if (invadedickey === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase dictionary key"
                                    warningPop.visible = true; return
                                }else if (!isNaN(Number(invadedickey))){
                                    warningPop.bodyText_Dialog = "Invading phase dictionary key must be a dictionary"
                                    warningPop.visible = true; return
                                }
                            }else if (invademixtureType === "Salinity user defined"){
                                if (invadesalinityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase salinity value"
                                    warningPop.visible = true; return
                                }else if (invadesalinityU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase salinity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadesalinityU))){
                                    warningPop.bodyText_Dialog = "Invading phase salinity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invademolar){
                            if (invademolarType === "User defined"){
                                if (invademolardenU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase molar density value"
                                    warningPop.visible = true; return
                                }else if (invademolardenU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase molar density must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invademolardenU))){
                                    warningPop.bodyText_Dialog = "Invading phase molar density must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadepartcoeff){
                            if (invadechemicalformula === ""){
                                warningPop.bodyText_Dialog = "Insert the invading phase chemical formula"
                                warningPop.visible = true; return
                            }else if (!isNaN(Number(invadechemicalformula))){
                                warningPop.bodyText_Dialog = "Invading phase chemical formula must be a string"
                                warningPop.visible = true; return
                            }
                        }else if (invadesurf){
                            if (invadesurfType === "Eotvos"){
                                if (invadeconstparam === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase constant parameter value"
                                    warningPop.visible = true; return
                                }else if (invadeconstparam <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase constant parameter must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeconstparam))){
                                    warningPop.bodyText_Dialog = "Invading phase constant parameter must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadesurfType === "Guggenheim_katayama"){
                                if (invadeK2 === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase specific constant (k2) value"
                                    warningPop.visible = true; return
                                }else if (invadeN === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase specific constant (n) value"
                                    warningPop.visible = true; return
                                }else if (invadeK2 <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase specific constant (k2) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeK2))){
                                    warningPop.bodyText_Dialog = "Invading phase specific constant (k2) must be a number"
                                    warningPop.visible = true; return
                                }else if (invadeN <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase specific constant (n) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeN))){
                                    warningPop.bodyText_Dialog = "Invading phase specific constant (n) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadesurfType === "Brock_bird_scaling"){
                                if (invadesurfprop === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase surface tension value"
                                    warningPop.visible = true; return
                                }else if (invadesurfprop <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadesurfprop))){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadesurfType === "User defined"){
                                if (invadesurfU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase surface tension value"
                                    warningPop.visible = true; return
                                }else if (invadesurfU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadesurfU))){
                                    warningPop.bodyText_Dialog = "Invading phase surface tension must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadevapor){
                            if (invadevaporType === "Antoine"){
                                if (invadeprescoeffA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase pressure coefficient (A) value"
                                    warningPop.visible = true; return
                                }else if (invadeprescoeffB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase pressure coefficient (B) value"
                                    warningPop.visible = true; return
                                }else if (invadeprescoeffC === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase pressure coefficient (C) value"
                                    warningPop.visible = true; return
                                }else if (invadeprescoeffA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (A) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeprescoeffA))){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (A) must be a number"
                                    warningPop.visible = true; return
                                }else if (invadeprescoeffB <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (B) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeprescoeffB))){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (B) must be a number"
                                    warningPop.visible = true; return
                                }else if (invadeprescoeffC <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (C) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeprescoeffC))){
                                    warningPop.bodyText_Dialog = "Invading phase pressure coefficient (C) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadevaporType === "User defined"){
                                if (invadevaporU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase vapor pressure value"
                                    warningPop.visible = true; return
                                }else if (invadevaporU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase vapor pressure must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadevaporU))){
                                    warningPop.bodyText_Dialog = "Invading phase vapor pressure must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (invadeviscosity){
                            if (invadeviscosityType === "Reynolds"){
                                if (invadeviscoeffA === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase viscisity coefficient (u0) value"
                                    warningPop.visible = true; return
                                }else if (invadeviscoeffB === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase viscisity coefficient (b) value"
                                    warningPop.visible = true; return
                                }else if (invadeviscoeffA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase viscisity coefficient (u0) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeviscoeffB))){
                                    warningPop.bodyText_Dialog = "Invading phase viscisity coefficient (u0) must be a number"
                                    warningPop.visible = true; return
                                }else if (invadeviscoeffA <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase viscisity coefficient (b) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadeviscoeffB))){
                                    warningPop.bodyText_Dialog = "Invading phase viscisity coefficient (b) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (invadeviscosityType === "User defined"){
                                if (invadevisU === ""){
                                    warningPop.bodyText_Dialog = "Insert the invading phase viscosity value"
                                    warningPop.visible = true; return
                                }else if (invadevisU <= 0){
                                    warningPop.bodyText_Dialog = "Invading phase viscosity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(invadevisU))){
                                    warningPop.bodyText_Dialog = "Invading phase viscosity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defenddensity){
                            if (defenddensityType === "User defined"){
                                if (defenddensityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase density value"
                                    warningPop.visible = true; return
                                }else if (defenddensityU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase density must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defenddensityU))){
                                    warningPop.bodyText_Dialog = "defending phase density must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defenddiffusivity){
                            if (defenddiffusivityU === "Fuller"){
                                if (defendMWA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase MW of component A value"
                                    warningPop.visible = true; return
                                }else if (defendMWB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase MW of component B value"
                                    warningPop.visible = true; return
                                }else if (defendatomicvolA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase atomic volume of component A value"
                                    warningPop.visible = true; return
                                }else if (defendatomicvolB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase atomic volume of component B value"
                                    warningPop.visible = true; return
                                }else if (defendMWA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase MW of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (defendMWB <= 0){
                                    warningPop.bodyText_Dialog = "defending phase MW of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (defendatomicvolA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase atomic volume of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (defendatomicvolB <= 0){
                                    warningPop.bodyText_Dialog = "defending phase atomic volume of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendMWA))){
                                    warningPop.bodyText_Dialog = "defending phase MW of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendMWB))){
                                    warningPop.bodyText_Dialog = "defending phase MW of component B must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendatomicvolA))){
                                    warningPop.bodyText_Dialog = "defending phase atomic volume of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendatomicvolB))){
                                    warningPop.bodyText_Dialog = "defending phase atomic volume of component B must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defenddiffusivityU === "Fuller_scaling" || defenddiffusivityU === "Tyn_calus_scaling"){
                                if (defenddiffcoeff === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase diffusion coefficient value"
                                    warningPop.visible = true; return
                                }else if (defenddiffcoeff <= 0){
                                    warningPop.bodyText_Dialog = "defending phase diffusion coefficient must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defenddiffcoeff))){
                                    warningPop.bodyText_Dialog = "defending phase diffusion coefficient must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defenddiffusivityU === "Tyn_calus"){
                                if (defendmolvolA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase molar volume of component A value"
                                    warningPop.visible = true; return
                                }else if (defendmolvolB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase molar volume of component B value"
                                    warningPop.visible = true; return
                                }else if (defendsurfA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase surface tension of component A value"
                                    warningPop.visible = true; return
                                }else if (defendsurfB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase surface tension of component B value"
                                    warningPop.visible = true; return
                                }else if (defendmolvolA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase molar volume of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (defendmolvolB <= 0){
                                    warningPop.bodyText_Dialog = "defending phase molar volume of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (defendsurfA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase surface tension of component A must be positive"
                                    warningPop.visible = true; return
                                }else if (defendsurfB <= 0){
                                    warningPop.bodyText_Dialog = "defending phase surface tension of component B must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendmolvolA))){
                                    warningPop.bodyText_Dialog = "defending phase molar volume of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendmolvolB))){
                                    warningPop.bodyText_Dialog = "defending phase molar volume of component B must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendsurfA))){
                                    warningPop.bodyText_Dialog = "defending phase surface tension of component A must be a number"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendsurfB))){
                                    warningPop.bodyText_Dialog = "defending phase surface tension of component B must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defenddiffusivityU === "User defined"){
                                if (defenddiffusivityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase diffusivity value"
                                    warningPop.visible = true; return
                                }else if (defenddiffusivityU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase diffusivity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defenddiffusivityU))){
                                    warningPop.bodyText_Dialog = "defending phase diffusivity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defendelectrical){
                            if (defendperrelexp === ""){
                                warningPop.bodyText_Dialog = "Insert the defending phase percolation relation exponent value"
                                warningPop.visible = true; return
                            }else if (defendperrelexp <= 0){
                                warningPop.bodyText_Dialog = "defending phase percolation relation exponent must be positive"
                                warningPop.visible = true; return
                            }else if (isNaN(Number(defendperrelexp))){
                                warningPop.bodyText_Dialog = "defending phase percolation relation exponent must be a number"
                                warningPop.visible = true; return
                            }
                        }else if (defendmixture){
                            if (defendmixtureType === "Mole_weighted_average"){
                                if (defenddickey === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase dictionary key"
                                    warningPop.visible = true; return
                                }else if (!isNaN(Number(defenddickey))){
                                    warningPop.bodyText_Dialog = "defending phase dictionary key must be a dictionary"
                                    warningPop.visible = true; return
                                }
                            }else if (defendmixtureType === "Salinity user defined"){
                                if (defendsalinityU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase salinity value"
                                    warningPop.visible = true; return
                                }else if (defendsalinityU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase salinity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendsalinityU))){
                                    warningPop.bodyText_Dialog = "defending phase salinity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defendmolar){
                            if (defendmolarType === "User defined"){
                                if (defendmolardenU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase molar density value"
                                    warningPop.visible = true; return
                                }else if (defendmolardenU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase molar density must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendmolardenU))){
                                    warningPop.bodyText_Dialog = "defending phase molar density must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defendpartcoeff){
                            if (defendchemicalformula === ""){
                                warningPop.bodyText_Dialog = "Insert the defending phase chemical formula"
                                warningPop.visible = true; return
                            }else if (!isNaN(Number(defendchemicalformula))){
                                warningPop.bodyText_Dialog = "defending phase chemical formula must be a string"
                                warningPop.visible = true; return
                            }
                        }else if (defendsurf){
                            if (defendsurfType === "Eotvos"){
                                if (defendconstparam === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase constant parameter value"
                                    warningPop.visible = true; return
                                }else if (defendconstparam <= 0){
                                    warningPop.bodyText_Dialog = "defending phase constant parameter must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendconstparam))){
                                    warningPop.bodyText_Dialog = "defending phase constant parameter must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defendsurfType === "Guggenheim_katayama"){
                                if (defendK2 === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase specific constant (k2) value"
                                    warningPop.visible = true; return
                                }else if (defendN === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase specific constant (n) value"
                                    warningPop.visible = true; return
                                }else if (defendK2 <= 0){
                                    warningPop.bodyText_Dialog = "defending phase specific constant (k2) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendK2))){
                                    warningPop.bodyText_Dialog = "defending phase specific constant (k2) must be a number"
                                    warningPop.visible = true; return
                                }else if (defendN <= 0){
                                    warningPop.bodyText_Dialog = "defending phase specific constant (n) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendN))){
                                    warningPop.bodyText_Dialog = "defending phase specific constant (n) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defendsurfType === "Brock_bird_scaling"){
                                if (defendsurfprop === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase surface tension value"
                                    warningPop.visible = true; return
                                }else if (defendsurfprop <= 0){
                                    warningPop.bodyText_Dialog = "defending phase surface tension must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendsurfprop))){
                                    warningPop.bodyText_Dialog = "defending phase surface tension must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defendsurfType === "User defined"){
                                if (defendsurfU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase surface tension value"
                                    warningPop.visible = true; return
                                }else if (defendsurfU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase surface tension must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendsurfU))){
                                    warningPop.bodyText_Dialog = "defending phase surface tension must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defendvapor){
                            if (defendvaporType === "Antoine"){
                                if (defendprescoeffA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase pressure coefficient (A) value"
                                    warningPop.visible = true; return
                                }else if (defendprescoeffB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase pressure coefficient (B) value"
                                    warningPop.visible = true; return
                                }else if (defendprescoeffC === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase pressure coefficient (C) value"
                                    warningPop.visible = true; return
                                }else if (defendprescoeffA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (A) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendprescoeffA))){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (A) must be a number"
                                    warningPop.visible = true; return
                                }else if (defendprescoeffB <= 0){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (B) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendprescoeffB))){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (B) must be a number"
                                    warningPop.visible = true; return
                                }else if (defendprescoeffC <= 0){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (C) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendprescoeffC))){
                                    warningPop.bodyText_Dialog = "defending phase pressure coefficient (C) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defendvaporType === "User defined"){
                                if (defendvaporU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase vapor pressure value"
                                    warningPop.visible = true; return
                                }else if (defendvaporU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase vapor pressure must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendvaporU))){
                                    warningPop.bodyText_Dialog = "defending phase vapor pressure must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }else if (defendviscosity){
                            if (defendviscosityType === "Reynolds"){
                                if (defendviscoeffA === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase viscisity coefficient (u0) value"
                                    warningPop.visible = true; return
                                }else if (defendviscoeffB === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase viscisity coefficient (b) value"
                                    warningPop.visible = true; return
                                }else if (defendviscoeffA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase viscisity coefficient (u0) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendviscoeffB))){
                                    warningPop.bodyText_Dialog = "defending phase viscisity coefficient (u0) must be a number"
                                    warningPop.visible = true; return
                                }else if (defendviscoeffA <= 0){
                                    warningPop.bodyText_Dialog = "defending phase viscisity coefficient (b) must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendviscoeffB))){
                                    warningPop.bodyText_Dialog = "defending phase viscisity coefficient (b) must be a number"
                                    warningPop.visible = true; return
                                }
                            }else if (defendviscosityType === "User defined"){
                                if (defendvisU === ""){
                                    warningPop.bodyText_Dialog = "Insert the defending phase viscosity value"
                                    warningPop.visible = true; return
                                }else if (defendvisU <= 0){
                                    warningPop.bodyText_Dialog = "defending phase viscosity must be positive"
                                    warningPop.visible = true; return
                                }else if (isNaN(Number(defendvisU))){
                                    warningPop.bodyText_Dialog = "defending phase viscosity must be a number"
                                    warningPop.visible = true; return
                                }
                            }
                        }

                        simulationbutton.enabled = !simulationbutton.enabled
                        btn_state.btnstate = !btn_state.btnstate
                        MainPython.simulation(porediamType, poreseedType, poresurfType, porevolType, poreareaType,
                                              throatdiamType, throatseedType, throatsurfType, throatvolType,
                                              throatareaType, throatendpointType, throatlengthType, throatperimType,
                                              throatshapefactorType, throatcentroid, throatvector, capillarypressureType, diffusivecondType,
                                              hydrauliccondType, multiphaseType, flowshapefactorType, poissonshapefactorType,
                                              phase_inv, phase_def, invadedensityType, defenddensityType, invadediffusivityType,
                                              defenddiffusivityType, invadeelectrical, defendelectrical, invademixtureType,
                                              defendmixtureType, invademolarType, defendmolarType, invadepartcoeff, defendpartcoeff,
                                              invadepermittivity, defendpermittivity, invadesurfType, defendsurfType, invadevaporType,
                                              defendvaporType, invadeviscosityType, defendviscosityType, invadeconcentration, defendconcentration,
                                              invadepressure, defendpressure, invadetemp, defendtemp, invademoldiffvol, defendmoldiffvol,
                                              invadevolfrac, defendvolfrac, invadeintcond, defendintcond, invademolweight, defendmolweight,
                                              invadecritemp, defendcritemp, invadecripressure, defendcritemp, invadecrivol, defendcrivol,
                                              invadecriangle, defendcriangle, poreshape, porescale, poreloc, poremode, poreweightx, poreweighty,
                                              poreweightz, throatShape, throatscale, throatloc, throatmode, invadeMWA, invadeMWB, invadeatomicvolA,
                                              invadeatomicvolB, invadediffcoeff, invademolvolA, invademolvolB, invadesurfA, invadesurfB, invadeperrelexp,
                                              invadedickey, invadechemicalformula, invadeconstparam, invadeK2, invadeN, invadesurfprop, invadeprescoeffA,
                                              invadeprescoeffB, invadeprescoeffC, invadeviscoeffA, invadeviscoeffB, defendMWA, defendMWB, defendatomicvolA,
                                              defendatomicvolB, defenddiffcoeff, defendmolvolA, defendmolvolB, defendsurfA, defendsurfB, defendperrelexp,
                                              defenddickey, defendchemicalformula, defendconstparam, defendK2, defendN, defendsurfprop, defendprescoeffA,
                                              defendprescoeffB, defendprescoeffC, defendviscoeffA, defendviscoeffB, method, resText.text, trapping,
                                              invadedensityU, invadediffusivityU, invadesalinityU, invademolardenU, invadesurfU, invadevaporU,
                                              invadevisU, defenddensityU, defenddiffusivityU, defendsalinityU, defendmolardenU, defendsurfU, defendvaporU,
                                              defendvisU)
                    }

                }
            }
        }
    }

    function checkBeforeRun(){
        if (inputdata === "3D Gray" || inputdata === "2D Gray" || inputdata === "2D Thinsection"){
            if (!network){
                if (!segment_image){
                    if (!main_image){
                        warningPop.bodyText_Dialog = "Import the image(s)"
                        warningPop.visible = true
                    }else{
                        warningPop.bodyText_Dialog = "Segment the image(s)"
                        warningPop.visible = true
                    }
                }else{
                    warningPop.bodyText_Dialog = "Extract the network from image(s)"
                    warningPop.visible = true
                }
            }else if (!capillarypressure){
                warningPop.bodyText_Dialog = "Select the capillary pressure in Physics"
                warningPop.visible = true
            }else if (!hydrauliccond){
                warningPop.bodyText_Dialog = "Select the hydraulic conductance in Physics"
                warningPop.visible = true
            }else if (!diffusivecond){
                warningPop.bodyText_Dialog = "Select the diffusive conductance in Physics"
                warningPop.visible = true
            }else if (!poissonshapefactor){
                warningPop.bodyText_Dialog = "Select the poisson shape factor in Physics"
                warningPop.visible = true
            }else{
                simulationbutton.enabled = true
            }
        }else if (inputdata === "3D Binary" || inputdata === "2D Binary"){
            if (!network){
                if (!main_image){
                    warningPop.bodyText_Dialog = "Import the image(s)"
                    warningPop.visible = true
                }else{
                    warningPop.bodyText_Dialog = "Extract the network from image(s)"
                    warningPop.visible = true
                }
            }else if (!capillarypressure){
                warningPop.bodyText_Dialog = "Select the capillary pressure in Physics"
                warningPop.visible = true
            }else if (!hydrauliccond){
                warningPop.bodyText_Dialog = "Select the hydraulic conductance in Physics"
                warningPop.visible = true
            }else if (!diffusivecond){
                warningPop.bodyText_Dialog = "Select the diffusive conductance in Physics"
                warningPop.visible = true
            }else if (!poissonshapefactor){
                warningPop.bodyText_Dialog = "Select the poisson shape factor in Physics"
                warningPop.visible = true
            }else{
                simulationbutton.enabled = true
            }
        }else if (inputdata === "Synthetic Network"){
            if (!network){
                warningPop.bodyText_Dialog = "Construct the network"
                warningPop.visible = true
            }else if (!capillarypressure){
                warningPop.bodyText_Dialog = "Select the capillary pressure in Physics"
                warningPop.visible = true
            }else if (!hydrauliccond){
                warningPop.bodyText_Dialog = "Select the hydraulic conductance in Physics"
                warningPop.visible = true
            }else if (!diffusivecond){
                warningPop.bodyText_Dialog = "Select the diffusive conductance in Physics"
                warningPop.visible = true
            }else if (!poissonshapefactor){
                warningPop.bodyText_Dialog = "Select the poisson shape factor in Physics"
                warningPop.visible = true
            }else{
                simulationbutton.enabled = true
            }
        }
    }
}
