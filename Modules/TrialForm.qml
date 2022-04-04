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

    property alias name    : input_name.inputText
    property alias phone    : input_phone.inputText
    property alias email    : input_Email.inputText
    property alias education    : input_education.inputText
    property alias job    : input_job.inputText
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
                'name': name.text,
                'phone': name.text,
                'email': email.text,
                'education': education.text,
                'job': job.text,
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
                    swipe_register.currentIndex = 0
                    return
                }

                //-- 400-Bad Request, 401-Unauthorized --//
                //-- No active account found with the given credentials --//
                if(http.status === 400 || http.status === 401 || resp.hasOwnProperty('non_field_errors')){

                    //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                    //                                    alarmLogin.msg = resp.non_field_errors.toString()
                    getMessage("Invalid entered informations")
                    spinner.visible = false
                    swipe_register.currentIndex = 0
                    return
                }
                var msg = "Thank you for installing the PoroX software"
                MainPython.sendEmail(msg, email.text, resp.key, resp.serialNumber, Service.BASE,
                                     name.text, phone.text, education.text, job.text)
                spinner.visible = false
                swipe_register.currentIndex = 0
                trialFinished()
                successDynamicPop.messageText = "The license was sent to your email"
                animationdynamicpop.restart()

            })
        }else if (device_id === -1){
            getMessage("You use trial version once before on this device")
            spinner.visible = false
            swipe_register.currentIndex = 0
        }else if (vpn){
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            getMessage("Please turn off the VPN")
            spinner.visible = false
            swipe_register.currentIndex = 0
        }else{
            var endpoint2 = Service.url_device + device_id + "/"
            Service.delete_item(setting.tokenAccess, endpoint2, function(resp, http) {})
            getMessage("You use trial version once before by using this email")
            spinner.visible = false
            swipe_register.currentIndex = 0
        }

    }

    property string smsCode: ""
    signal getCode(var code)
    onGetCode: {
        smsCode = code
    }

    Component.onCompleted: {
        MainPython.trialData.connect(registe)
        MainPython.registCode.connect(getCode)
    }

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


    SwipeView{
        id: swipe_register
        anchors.fill: parent
        clip: true
        interactive: false
        currentIndex: 0

        onCurrentIndexChanged: {
            if(currentIndex === 1){
                timer_confirmSMS.resetTimer()
                timer_confirmSMS.minutes = 1
                timer_confirmSMS.startTimer()
            }
        }

        //-- User data --//
        Item{
            ColumnLayout{
                width: parent.width
                height: parent.height * 0.5


                //-- spacer --//
                Item{Layout.preferredHeight: 20}

                //-- "purchase PoroX license key --//
                Label{
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    text: "Request trial license for 15 days"
                    color: "darkblue"

                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                    horizontalAlignment: Qt.AlignHCenter

                }

                //-- spacer --//
                Item{Layout.preferredHeight: 10}

                //-- Email --//
                M_inputText{
                    id: input_name
                    label: "Name"
                    icon: Icons.account
                    placeholder: "Name"

                    Keys.onTabPressed: {
                        input_phone.inputText.forceActiveFocus()
                    }

                    //                                    inputText.validator: RegularExpressionValidator { regularExpression: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/ }
                }

                //-- spacer --//
                Item{Layout.preferredHeight: 5}

                //-- Email --//
                M_inputText{
                    id: input_phone
                    label: "Phone"
                    icon: Icons.cellphone
                    placeholder: "09xxxxxxxxx"
                    Keys.onTabPressed: {
                        input_Email.inputText.forceActiveFocus()
                    }
                    inputText.validator: RegularExpressionValidator { regularExpression: /^([0]{1})([9]{1})([0-9]{3,9})$/ }
                }

                //-- spacer --//
                Item{Layout.preferredHeight: 5}

                //-- Email --//
                M_inputText{
                    id: input_Email
                    label: "ایمیل"
                    icon: Icons.email_outline
                    placeholder: "E-Mail"
                    Keys.onTabPressed: {
                        input_education.inputText.forceActiveFocus()
                    }

                    //            inputText.validator: RegularExpressionValidator { regularExpression: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/ }
                }


                //-- spacer --//
                Item{Layout.preferredHeight: 5}

                //-- Email --//
                M_inputText{
                    id: input_education
                    label: "Education"
                    icon: Icons.cast_education
                    placeholder: "Education"
                    Keys.onTabPressed: {
                        input_job.inputText.forceActiveFocus()
                    }
                    //                                    inputText.validator: RegularExpressionValidator { regularExpression: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/ }
                }

                //-- spacer --//
                Item{Layout.preferredHeight: 5}

                //-- Email --//
                M_inputText{
                    id: input_job
                    label: "Job"
                    icon: Icons.worker
                    placeholder: "Job"
                    Keys.onTabPressed: {
                        purchase.forceActiveFocus()
                    }
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
                            if (parseInt(email.length) === 0){
                                getMessage("Enter your email")
                                //                                spinner.visible = false
                            }else if (parseInt(name.length) === 0){
                                getMessage("Enter your name")
                            }else if (parseInt(phone.length) === 0){
                                getMessage("Enter your mobile number")
                            }else if (parseInt(education.length) === 0){
                                getMessage("Enter your education")
                            }else if (parseInt(job.length) === 0){
                                getMessage("Enter your job")
                            }else{
                                MainPython.sendSMS(phone.text)
                                timer_confirmSMS.visible = true
                                lbl_SendAgain.visible = false
                                swipe_register.currentIndex = 1
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

        //-- Confirm phone Number --//
        Item {
            Rectangle{
                anchors.fill: parent
                anchors.leftMargin: parent.width * 0.2
                anchors.rightMargin: parent.width * 0.15

                ColumnLayout{
                    anchors.fill: parent
                    spacing: 10

                    //-- spacer --//
                    Item{Layout.preferredHeight: 50}

                    //-- "Confirmation Code" text --//
                    Label{
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        text: "Confirmation Code was sent to :"
                        color: "darkblue"
                        font.pixelSize: Qt.application.font.pixelSize * 1.3
                        horizontalAlignment: Qt.AlignHCenter

                    }

                    //-- "phoneNumber" and "Phone number correction" --//
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.topMargin: -10

                        RowLayout{
                            anchors.fill: parent
                            spacing: 10

                            //-- spacer --//
                            Item{Layout.fillWidth: true}

                            //-- "phoneNumber" text --//
                            Label{
                                Layout.preferredWidth: implicitWidth
                                Layout.preferredHeight: implicitHeight
                                text: input_phone.inputText.text
                                color: "#444444"

                                font.pixelSize: Qt.application.font.pixelSize * 1.3
                                horizontalAlignment: Qt.AlignHCenter

                            }

                            //-- "Phone number correction" text --//
                            Label{
                                Layout.preferredWidth: implicitWidth
                                Layout.preferredHeight: implicitHeight
                                text: "Change"
                                color: "darkblue"

                                font.pixelSize: Qt.application.font.pixelSize * 1.1
                                horizontalAlignment: Qt.AlignHCenter

                                MouseArea{
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        swipe_register.currentIndex = 0
                                        input_phone.inputText.forceActiveFocus()
                                        input_phone.inputText.selectAll()
                                    }
                                }

                            }

                            //-- spacer --//
                            Item{Layout.fillWidth: true}

                        }
                    }

                    //-- TextInput Confirm --//
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38

                        radius: height / 2

                        border.width: 2
                        border.color: "darkblue"

                        //-- TextField --//
                        TextInput{
                            id:txf_confirm

                            clip: true
                            maximumLength: 5

                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter

                            width: parent.width - (parent.radius * 2)
                            height: parent.height - (parent.border.width * 2)
                            anchors.centerIn: parent

                            font.pixelSize: Qt.application.font.pixelSize * 1.3
                            font.letterSpacing: 15

                            selectByMouse: true

                            validator: RegularExpressionValidator { regularExpression: /^[0-9]{5}$/ }

                            onTextChanged: {
                                if(length === 5){
                                    btn_Confirm.forceActiveFocus()
                                }
                            }


                            //-- placeholder --//
                            Label{
                                id: lbl_placeholder

                                visible: (txf_confirm.length >= 1) ? false : true

                                text: "5-Digits"

                                anchors.centerIn: parent
                                //                                anchors.horizontalCenter: parent.horizontalCenter


                                font.pixelSize: Qt.application.font.pixelSize

                                color: "#dddddd"

                                background: Rectangle{
                                    color: "transparent"
                                }

                            }

                        }



                    }

                    //-- Button Confirm --//
                    Rectangle{
                        id: rect_Confirm
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38

                        radius: height / 2

                        color: "darkblue"

                        Label{
                            anchors.centerIn: parent
                            text: "Confirm"
                            font.pixelSize: Qt.application.font.pixelSize * 1
                            color: "#ffffff"
                        }

                        Rectangle{
                            id: rect_focus
                            visible: btn_Confirm.focus ? true : false
                            width: parent.width - 5
                            height: parent.height - 5
                            anchors.centerIn: parent

                            radius: height / 2
                            color: "transparent"

                            border.color: "#ffffff"
                            border.width: 1


                        }

                        MouseArea{
                            id: btn_Confirm
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (txf_confirm.text === smsCode){
                                    spinner.visible = true
                                    MainPython.makeTrialData(15, setting.tokenAccess, Service.BASE, Service.url_license, Service.url_device)
                                }else{
                                    getMessage("Invalid code")
                                    spinner.visible = false
                                }
                            }

                            Keys.onEnterPressed: {
                                if (txf_confirm.text === smsCode){
                                    spinner.visible = true
                                    MainPython.makeTrialData(15, setting.tokenAccess, Service.BASE, Service.url_license, Service.url_device)
                                }else{
                                    getMessage("Invalid code")
                                    spinner.visible = false
                                }
                            }

                        }
                    }

                    //-- module Timer --//
                    Countdown_Timer{
                        id: timer_confirmSMS
                        Layout.fillWidth: true
                        Layout.preferredHeight: lbl_SendAgain.implicitHeight

                        minutes: 1

                        //color: "#55ff0000"
                        lblTimer.color: "#000000"

                        onSecondChanged: {
                            if(minutes === 0 && second === 0){
                                timer_confirmSMS.visible = false
                                lbl_SendAgain.visible = true
                            }
                        }
                    }

                    Label{
                        id: lbl_SendAgain
                        visible: false
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        text: "Send again"
                        color: "darkblue"

                        font.pixelSize: Qt.application.font.pixelSize * 1.1
                        horizontalAlignment: Qt.AlignHCenter

                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                MainPython.sendSMS(phone.text)
                                timer_confirmSMS.resetTimer()
                                timer_confirmSMS.minutes = 1
                                timer_confirmSMS.startTimer()
                                lbl_SendAgain.visible = false
                                timer_confirmSMS.visible = true
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

