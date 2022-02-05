import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons
import "./../REST/apiService.js" as Service

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
        Service.get_all(Service.url_license , function(data, http){
            //-- check ERROR --//
            if(data.hasOwnProperty('error')) // chack exist error in resp
            {
                //                                    alarmLogin.msg = resp.error
                alarmLoginWin.msg = "No internet connection"
                return
            }

            //-- 400-Bad Request, 401-Unauthorized --//
            //-- No active account found with the given credentials --//
            if(http.status === 400 || http.status === 401 || data.hasOwnProperty('non_field_errors')){

                //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                //                                    alarmLogin.msg = resp.non_field_errors.toString()
                alarmLoginWin.msg = "Incorrect license key"
                return
            }

            for (var i = 0; i < data.length; i++){
                if (data[i].key === user.text){
                    Service.get_all(Service.url_device , function(data2, http2){
                        if (data[i].deviceNumber > data[i].devices.length && !isMacExist(data2, mac)){
                            licenseData = data[i]
                            MainPython.postDeviceSlot(mac)
                            isLicensed = true
                            root_auth.visible = false
                            return
                        }else if (data[i].deviceNumber > data[i].devices.length && isMacExist(data2, mac)){
                            licenseData = data[i]
                            updateLicenseInfo(getDeviceid(data2, mac))
                            isLicensed = true
                            root_auth.visible = false
                            return
                        }else if (data[i].deviceNumber === data[i].devices.length && isMacExist(data2, mac)){
                            isLicensed = true
                            root_auth.visible = false
                            return
                        }else{return}
                    })
                    return
                }
            }
        })
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
        Service.update_item_notsecure(endpoint, newLicenseData, function(resp, http) {})
    }

    Component.onCompleted: {
        MainPython.macData.connect(enterKey)
        MainPython.device_id.connect(updateLicenseInfo)
    }

    property alias alarmLogin: alarmLoginWin
    property alias user: input_UserName.inputText

    //-- when open LoginPage inputs most be Empty --//
    signal resetForm()
    onResetForm: {
        input_UserName.inputText.text = ""
        input_UserName.inputText.forceActiveFocus()
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
                            color: "white"

                            font.pixelSize: Qt.application.font.pixelSize * 2.2
                            horizontalAlignment: Qt.AlignHCenter
                        }

                        Rectangle{
                            Layout.preferredWidth: parent.width / 11
                            Layout.preferredHeight: 4
                            radius: 2
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label{
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            text: "Digital Rock Analysis Software"
                            color: "white"

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
                    anchors.topMargin: parent.height * 0.1
                    anchors.bottomMargin: parent.height * 0.1
                    anchors.leftMargin: parent.width * 0.1
                    anchors.rightMargin: parent.width * 0.15
                    color: "#00ffFF00"


                    ColumnLayout{
                        anchors.fill: parent
                        //                        visible: false

                        //-- filler --//
                        Item{Layout.fillHeight: true}

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
                            id: input_UserName
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
                                    MainPython.enterLicense()
                                }
                            }
                        }

                        //-- spacer --//
                        Item{Layout.preferredHeight: 15}

                        //-- "Try Trial" text --//
                        Label{
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            text: "Try Trial"
                            color: "darkblue"

                            font.pixelSize: Qt.application.font.pixelSize * 1
                            horizontalAlignment: Qt.AlignHCenter

                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showTrial()
                                }
                            }

                        }

                        //-- spacer --//
                        Item{Layout.preferredHeight: 15}

                        //-- "Purchase License" text --//
                        Label{
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            text: "Purchase License"
                            color: "darkblue"

                            font.pixelSize: Qt.application.font.pixelSize * 1
                            horizontalAlignment: Qt.AlignHCenter

                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showPurchase()
                                }
                            }

                        }

                        //-- filler --//
                        Item{Layout.fillHeight: true}
                    }
                }
            }
        }

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
