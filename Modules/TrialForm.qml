import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../REST/apiService.js" as Service
import "./../Fonts/Icon.js" as Icons
//import "./../../Utils/CheckRegisterValidation.js" as RegiserValidation

ApplicationWindow{
    id: root_register

    property alias email    : input_Email.inputText
    property string gender  : ""

    property alias swipeIndex: swipe_register.currentIndex


    onClosing: {
        email.text = ""
    }

    function isEmailExist(data, email){
        for(var i=0; i<data.length; i++){
            if(data[i].email===email && data[i].licenseType==="trial"){
                return true
            }
        }
        return false
    }

    signal registe(var device_id, var keyData, var date, bool vpn)

    onRegiste: {
        if (device_id !== -1 && !vpn && !isEmailExist(data, email)){
            var licenseData = {
                'email': email.text,
                'expired_on': date,
                'deviceNumber': 1,
                'licenseType': "trial",
                'devices': [device_id],
            }
            var endpoint = Service.url_license

            Service.create_item(setting.tokenAccess, endpoint, licenseData, function(resp, http) {
                //-- check ERROR --//
                if(resp.hasOwnProperty('error')) // chack exist error in resp
                {
                    //                                    alarmLogin.msg = resp.error
                    alarmTrialWin.msg = "مشکلی در ارتباط با اینترنت وجود دارد"
                    spinner.visible = false
                    return
                }

                //-- 400-Bad Request, 401-Unauthorized --//
                //-- No active account found with the given credentials --//
                if(http.status === 400 || http.status === 401 || resp.hasOwnProperty('non_field_errors')){

                    //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                    //                                    alarmLogin.msg = resp.non_field_errors.toString()
                    alarmTrialWin.msg = "Incorrect entered informations"
                    spinner.visible = false
                    return
                }
                var msg = "Thank you for installing the PoroX software"
                MainPython.sendEmail(msg, email.text, resp.key, resp.serialNumber)
                spinner.visible = false
                root_register.visible = false
                successDynamicPop.messageText = "The license was sent to your email"
                animationdynamicpop.restart()

            })
        }else if (device_id === -1){
            alarmTrialWin.msg = "You use trial version once before on this device"
            spinner.visible = false
        }else if (vpn){
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            alarmTrialWin.msg = "Please turn off the VPN"
            spinner.visible = false
        }else{
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            alarmTrialWin.msg = "You use trial version once before by using this email"
            spinner.visible = false
        }

    }

    Component.onCompleted: MainPython.trialData.connect(registe)

    visible: true//false//

    minimumWidth: 700
    maximumWidth: 700
    minimumHeight: 500
    maximumHeight: 500

    title: " "
    objectName: "Registration"
    flags: Qt.Dialog //SplashScreen //Dialog //Widget,SubWindow //Sheet //CoverWindow

    MouseArea {
        //            anchors.fill: parent
        width: parent.width
        height: parent.height

        propagateComposedEvents: true
        property real lastMouseX: 0
        property real lastMouseY: 0
        acceptedButtons: Qt.LeftButton
        onMouseXChanged: root_register.x += (mouseX - lastMouseX)
        onMouseYChanged: root_register.y += (mouseY - lastMouseY)
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

            //-- inputs for Register -//
            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                //color: "#0000FF00"

                SwipeView{
                    id: swipe_register
                    anchors.fill: parent
                    clip: true
                    interactive: false
                    currentIndex: 0

                    //-- fill inputs --//
                    Item {
                        Rectangle{
                            anchors.fill: parent
                            anchors.topMargin: parent.height * 0.03
                            anchors.bottomMargin: parent.height * 0.03
                            anchors.leftMargin: parent.width * 0.15
                            anchors.rightMargin: parent.width * 0.2
                            color: "#00ffFF00"

                            ColumnLayout{
                                width: parent.width
                                height: parent.height * 0.5
                                spacing: 10

                                //-- spacer --//
                                Item{Layout.fillHeight: true}

                                //-- "purchase PoroX license key --//
                                Label{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    text: "Activate trial license for 15 days"
                                    color: "darkblue"

                                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                                    horizontalAlignment: Qt.AlignHCenter

                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 10}

                                //-- Email --//
                                M_inputText{
                                    id: input_Email
                                    label: "ایمیل"
                                    icon: Icons.email_outline
                                    placeholder: "E-Mail"

                                    //                                    inputText.validator: RegularExpressionValidator { regularExpression: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/ }
                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 10}

                                //-- Button Purchase --//
                                Rectangle{
                                    id: purchase
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38

                                    radius: height / 2

                                    color: "darkblue"

                                    Label{
                                        anchors.centerIn: parent
                                        text: "Activate"
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: "#ffffff"
                                    }

                                    MouseArea{
                                        id: btn_register
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            spinner.visible = true
                                            MainPython.makeTrialData(15, setting.tokenAccess)
                                        }
                                    }
                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 15}

                                //-- "Try Trial" text --//
                                Label{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    text: "Purchase Key"
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

                                //-- spacer --//
                                Item{Layout.preferredHeight: 15}

                                //-- "Purchase License" text --//
                                Label{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    text: "Enter Key"
                                    color: "darkblue"

                                    font.pixelSize: Qt.application.font.pixelSize * 1
                                    horizontalAlignment: Qt.AlignHCenter

                                    MouseArea{
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showLogin()
                                        }
                                    }

                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 15}

                                LoadingSpinner{
                                    id: spinner
                                    visible: false
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    leftMarg: 60
                                }

                                //-- filler --//
                                Item{Layout.fillHeight: true}
                            }

                        }

                    }
                }

            }

        }


    }

    //    Alarm_Popup{
    //        id: alarm_popup

    //        x: (root_register.width / 2) - (width / 2)
    //        y: (root_register.height / 2) - (height / 2)

    //        onOk_Click: {

    //            alarm_popup.close()
    //            if(alarm_popup.closeMode)
    //                root_register.close()
    //        }
    //    }

    //-- Alarm --//
    Rectangle{
        id: alarmTrialWin

        property string msg: ""

        width: parent.width
        height: lblAlarm.implicitHeight * 2.5
        anchors.bottom: parent.bottom

        color: msg === "" ? "transparent" : "#E91E63"

        Label{
            id: lblAlarm
            text: alarmTrialWin.msg
            anchors.centerIn: parent
            color: "white"

        }
    }

}

