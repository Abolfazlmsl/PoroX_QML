import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons
import "./../REST/apiService.js" as Service
import "./../Functions/functions.js" as Functions

ApplicationWindow{
    id: root_auth

    signal enterKey(var mac)
    property var licenseData

    function isMacExist(data, mac){
        for (var j=0; j<data.length;j++){
            if (data[j].deviceMac === mac){
                return true
            }
        }
        return false
    }

    function getDeviceid(data, mac){
        for (var j=0; j<data.length;j++){
            if (data[j].deviceMac === mac){
                return data[j].id
            }
        }
    }

    onEnterKey: {
        if (mac === "00:00:00:00:00:00"){
            alarmLoginWin.msg = "Please turn off the VPN"
            spinner.visible = false
        }else{
            Service.get_with_token(setting.tokenAccess, Service.url_license , function(data, http){
                //-- check ERROR --//
                if(data.hasOwnProperty('error')) // chack exist error in resp
                {
                    //                                    alarmLogin.msg = resp.error
                    alarmLoginWin.msg = "No internet connection"
                    spinner.visible = false
                    return
                }

                //-- 400-Bad Request, 401-Unauthorized --//
                //-- No active account found with the given credentials --//
                if(http.status === 400 || http.status === 401 || data.hasOwnProperty('non_field_errors')){

                    //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                    //                                    alarmLogin.msg = resp.non_field_errors.toString()
                    alarmLoginWin.msg = "Invalid license key"
                    spinner.visible = false
                    return
                }

                for (var i = 0; i < data.length; i++){
                    if (data[i].key === user.text){
                        if (Functions.isLicenseExpired(data[i])){
                            alarmLoginWin.msg = "The license has been expired"
                            spinner.visible = false
                            return
                        }

                        Service.get_with_token(setting.tokenAccess, Service.url_device , function(data2, http2){
                            if (data[i].deviceNumber > data[i].devices.length && !isMacExist(data2, mac)){
                                licenseData = data[i]
                                MainPython.postDeviceSlot(mac, setting.tokenAccess, Service.BASE, Service.url_device)
                                setting.isLicensed = true
                                var licenseTime = data[i].expired_on
                                licenseTime = licenseTime.replace("-","/")
                                setting.licenseTime = licenseTime.replace("-","/")
                                setting.licenseType = data[i].licenseType
                                setting.licenseEmail = data[i].email
                                setting.licenseKey = data[i].key
                                spinner.visible = false
                                root_auth.visible = false
                                successDynamicPop.messageText = "The license activated successfully"
                                animationdynamicpop.restart()
                                return
                            }else if (data[i].deviceNumber > data[i].devices.length && isMacExist(data2, mac)){
                                licenseData = data[i]
                                updateLicenseInfo(getDeviceid(data2, mac))
                                setting.isLicensed = true
                                var licenseTime = data[i].expired_on
                                licenseTime = licenseTime.replace("-","/")
                                setting.licenseTime = licenseTime.replace("-","/")
                                setting.licenseType = data[i].licenseType
                                setting.licenseEmail = data[i].email
                                setting.licenseKey = data[i].key
                                spinner.visible = false
                                root_auth.visible = false
                                successDynamicPop.messageText = "The license activated successfully"
                                animationdynamicpop.restart()
                                return
                            }else if (data[i].deviceNumber === data[i].devices.length && isMacExist(data2, mac)){
                                setting.isLicensed = true
                                var licenseTime = data[i].expired_on
                                licenseTime = licenseTime.replace("-","/")
                                setting.licenseTime = licenseTime.replace("-","/")
                                setting.licenseType = data[i].licenseType
                                setting.licenseEmail = data[i].email
                                setting.licenseKey = data[i].key
                                spinner.visible = false
                                root_auth.visible = false
                                successDynamicPop.messageText = "The license activated successfully"
                                animationdynamicpop.restart()
                                return
                            }else{
                                alarmLoginWin.msg = "The license can not be used on more devices"
                                spinner.visible = false
                                return
                            }
                        })
                        return
                    }
                }
                if (!setting.isLicensed){
                    alarmLoginWin.msg = "Invalid license key"
                    spinner.visible = false
                    return
                }
            })
        }
    }

    signal updateLicenseInfo(var device_id)
    onUpdateLicenseInfo: {
        licenseData.devices[licenseData.devices.length] = device_id
        var newLicenseData = {
            'key': licenseData.key,
            'email': licenseData.email,
            'expired_on': licenseData.expired_on,
            'deviceNumber': licenseData.deviceNumber,
            'licenseType': licenseData.licenseType,
            'serialNumber': licenseData.serialNumber,
            'devices': licenseData.devices,
        }

        var endpoint = Service.url_license + licenseData.id + "/"
        Service.update_item(setting.tokenAccess, endpoint, newLicenseData, function(resp, http) {})
    }

    Component.onCompleted: {
        MainPython.macData.connect(enterKey)
        MainPython.device_id.connect(updateLicenseInfo)
    }

    property alias alarmLogin: alarmLoginWin
    property alias user: input_License.inputText

    //-- when open LoginPage inputs most be Empty --//
    signal resetForm()
    onResetForm: {
        input_License.inputText.text = ""
        input_License.inputText.forceActiveFocus()
    }

    visible: true//false//
    minimumWidth: 700
    maximumWidth: 700
    minimumHeight: 500
    maximumHeight: 500
    title: " " //صفحه ورود
    objectName: "Auth"
    flags: Qt.Dialog //SplashScreen //Dialog //Widget,SubWindow //Sheet //CoverWindow

    MouseArea {
        //            anchors.fill: parent
        width: parent.width
        height: parent.height

        propagateComposedEvents: true
        property real lastMouseX: 0
        property real lastMouseY: 0
        acceptedButtons: Qt.LeftButton
        onMouseXChanged: root_auth.x += (mouseX - lastMouseX)
        onMouseYChanged: root_auth.y += (mouseY - lastMouseY)
        onPressed: {
            if(mouse.button == Qt.LeftButton){
                parent.forceActiveFocus()
                lastMouseX = mouseX
                lastMouseY = mouseY

                //-- seek clip --//
                //                    player.seek((player.duration*mouseX)/width)
            }
            //                mouse.accepted = false
        }
    }

    Pane {
        id: popup

        Rectangle{
            anchors.fill: parent; color: "white"
        }

        anchors.fill: parent
        anchors.margins: -11

        RowLayout{
            anchors.fill: parent
            spacing: 0

            //-- logo and intro -//
            Rectangle{
                Layout.preferredWidth: parent.width * 0.5
                Layout.fillHeight: true
                color: "#00FF0000"

                Image {
                    id: img_intro
                    source: "../Images/Signin.jpg"
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectFit

                    ColumnLayout{
                        anchors.fill: parent
                        spacing: 15

                        Item {
                            Layout.fillHeight: true
                        }

                        Label{
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            text: "Welcome to PoroX"
                            color: "black"

                            font.pixelSize: Qt.application.font.pixelSize * 2.2
                            horizontalAlignment: Qt.AlignHCenter
                        }

                        Rectangle{
                            Layout.preferredWidth: parent.width / 11
                            Layout.preferredHeight: 4
                            radius: 2
                            Layout.alignment: Qt.AlignHCenter
                            color: "black"
                        }

                        Label{
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            text: "Digital Rock Analysis Software"
                            color: "black"

                            font.pixelSize: Qt.application.font.pixelSize * 1.3
                            horizontalAlignment: Qt.AlignHCenter
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }

                }

            }

            //-- inputs for login -//
            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#0000FF00"

                Rectangle{
                    anchors.fill: parent
//                    anchors.topMargin: parent.height * 0.1
//                    anchors.bottomMargin: parent.height * 0.1
//                    anchors.leftMargin: parent.width * 0.1
//                    anchors.rightMargin: parent.width * 0.15
                    color: "#00ffFF00"
                    ColumnLayout{
                        anchors.fill: parent
                    //-- footer of left layout--//
                    TabBar {
                        id: bar
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        font.pixelSize: Qt.application.font.pixelSize
                        Material.accent: "#6c88b7"

                        currentIndex: 0

                        //-- enter license Button --//
                        TabButton {
                            id: section1

                            signal checkSection1()
                            onCheckSection1: {
                                checked = true
                            }

                            Label{
                                text: "Enter license"
                                font.bold: section1.checked ? true : false
                                font.pixelSize: section1.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                                color: section1.checked ? "#000000" : "#aaaaaa"
                                anchors.centerIn: parent
                            }

                            onClicked: {
                                checkSection1()
                            }
                        }

                        //-- trial Button --//
                        TabButton {
                            id: section2

                            signal checkSection2()
                            onCheckSection2: {
                                checked = true
                            }

                            Label{
                                text: "Try trial"
                                font.bold: section2.checked ? true : false
                                font.pixelSize: section2.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                                color: section2.checked ? "#000000" : "#aaaaaa"
                                anchors.centerIn: parent
                            }

                            onClicked: {
                                checkSection2()
                            }

                        }

                        //-- purchase Button --//
                        TabButton {
                            id: section3

                            signal checkSection3()
                            onCheckSection3: {
                                checked = true
                            }

                            Label{
                                text: "Purchase"
                                font.bold: section3.checked ? true : false
                                font.pixelSize: section3.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                                color: section3.checked ? "#000000" : "#aaaaaa"
                                anchors.centerIn: parent
                            }

                            onClicked: {
                                checkSection3()
                            }

                        }

                    }

                    SwipeView{
                        id: licenseView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        interactive: false
                        clip: true
                        currentIndex: bar.currentIndex

                        Item{
                            id: enterLicense
                            visible: section1.checked
                            ColumnLayout{
                                anchors.fill: parent
                                anchors.leftMargin: parent.width * 0.1
                                anchors.rightMargin: parent.width * 0.15
                                //-- spacer --//
                                Item{Layout.preferredHeight: 50}

                                //-- "Enter the PoroX License Key --//
                                Label{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    text: "Enter the License Key"
                                    color: "darkblue"

                                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                                    horizontalAlignment: Qt.AlignHCenter

                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 15}

                                //-- License key --//
                                M_inputText{
                                    id: input_License
                                    label: "License key"
                                    icon: Icons.key
                                    placeholder: "License Key"

                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 10 }

                                //-- Button continue --//
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38

                                    radius: height / 2

                                    color: "darkblue"


                                    Label{
                                        anchors.centerIn: parent
                                        text: "Continue"
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: "#ffffff"
                                    }

                                    MouseArea{
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (parseInt(input_License.inputText.length) > 0){
                                                spinner.visible = true
                                                MainPython.enterLicense()
                                            }else{
                                                alarmSignupWin.msg = "Enter the license key"
                                                spinner.visible = false
                                            }
                                        }
                                    }
                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 15 }

                                LoadingSpinner{
                                    id: spinner
                                    visible: false
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                }

                                //-- filler --//
                                Item{Layout.fillHeight: true}
                            }
                            //-- Alarm --//
                            Rectangle{
                                id: alarmLoginWin

                                property string msg: ""

                                width: parent.width
                                height: lblAlarm.implicitHeight * 2.5
                                anchors.bottom: parent.bottom

                                color: msg === "" ? "transparent" : "#E91E63"

                                Label{
                                    id: lblAlarm
                                    text: alarmLogin.msg
                                    anchors.centerIn: parent
                                    color: "white"
                                }
                            }
                        }
                        Item{
                            id: trialForm
                            visible: section2.checked
                            TrialForm{
                                anchors.fill: parent
                                anchors.leftMargin: parent.width * 0.1
                                anchors.rightMargin: parent.width * 0.15
                                onGetMessage: {
                                    alarmTrialWin.msg = signalmsg
                                }

                                onTrialFinished: {
                                    root_auth.visible = false
                                }
                            }
                            //-- Alarm --//
                            Rectangle{
                                id: alarmTrialWin

                                property string msg: ""

                                width: parent.width
                                height: lblAlarm2.implicitHeight * 2.5
                                anchors.bottom: parent.bottom

                                color: msg === "" ? "transparent" : "#E91E63"

                                Label{
                                    id: lblAlarm2
                                    text: alarmTrialWin.msg
                                    anchors.centerIn: parent
                                    color: "white"

                                }
                            }
                        }

                        Item{
                            id: purchaseForm
                            visible: section3.checked
                            PurchaseLicenseForm{
                                anchors.fill: parent
                                anchors.leftMargin: parent.width * 0.1
                                anchors.rightMargin: parent.width * 0.15
                                onGetMessage: {
                                    alarmSignupWin.msg = signalmsg
                                }
                            }
                            //-- Alarm --//
                            Rectangle{
                                id: alarmSignupWin

                                property string msg: ""

                                width: parent.width
                                height: lblAlarm3.implicitHeight * 2.5
                                anchors.bottom: parent.bottom

                                color: msg === "" ? "transparent" : "#E91E63"

                                Label{
                                    id: lblAlarm3
                                    text: alarmSignupWin.msg
                                    anchors.centerIn: parent
                                    color: "white"

                                }
                            }
                        }
                    }
                }
                }
            }
        }

    }

}
