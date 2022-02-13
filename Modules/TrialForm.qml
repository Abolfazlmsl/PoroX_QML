import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../REST/apiService.js" as Service
import "./../Fonts/Icon.js" as Icons
//import "./../../Utils/CheckRegisterValidation.js" as RegiserValidation

Item{
    id: root_register

    property alias email    : input_Email.inputText
    property string gender  : ""

    function isEmailExist(data, email){
        for(var i=0; i<data.length; i++){
            if(data[i].email===email && data[i].licenseType==="trial"){
                return true
            }
        }
        return false
    }

    signal getMessage(var signalmsg)
    signal trialFinished()

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
                    getMessage("مشکلی در ارتباط با اینترنت وجود دارد")
                    spinner.visible = false
                    return
                }

                //-- 400-Bad Request, 401-Unauthorized --//
                //-- No active account found with the given credentials --//
                if(http.status === 400 || http.status === 401 || resp.hasOwnProperty('non_field_errors')){

                    //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                    //                                    alarmLogin.msg = resp.non_field_errors.toString()
                    getMessage("Incorrect entered informations")
                    spinner.visible = false
                    return
                }
                var msg = "Thank you for installing the PoroX software"
                MainPython.sendEmail(msg, email.text, resp.key, resp.serialNumber)
                spinner.visible = false
                trialFinished()
                successDynamicPop.messageText = "The license was sent to your email"
                animationdynamicpop.restart()

            })
        }else if (device_id === -1){
            getMessage("You use trial version once before on this device")
            spinner.visible = false
        }else if (vpn){
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            getMessage("Please turn off the VPN")
            spinner.visible = false
        }else{
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            getMessage("You use trial version once before by using this email")
            spinner.visible = false
        }

    }

    Component.onCompleted: MainPython.trialData.connect(registe)

    objectName: "Registration"

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


    ColumnLayout{
        width: parent.width
        height: parent.height * 0.5


        //-- spacer --//
        Item{Layout.preferredHeight: 50}

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

        //-- Button try trial --//
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
                    if (parseInt(email.length) > 0){
                        spinner.visible = true
                        MainPython.makeTrialData(15, setting.tokenAccess, Service.BASE, Service.url_license, Service.url_device)
                    }else{
                        getMessage("Enter your Email")
                        spinner.visible = false
                    }
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

