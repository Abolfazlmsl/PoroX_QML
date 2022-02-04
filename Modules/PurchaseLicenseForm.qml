import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons
import "./../REST/apiService.js" as Service
//import "./../../Utils/CheckRegisterValidation.js" as RegiserValidation

ApplicationWindow{
    id: root_register

    property alias email    : input_Email.inputText
    property string gender  : ""

    property alias swipeIndex: swipe_register.currentIndex


    onClosing: {
        email.text = ""
    }

    signal registe()
    //    property bool checkRegisterValidation : RegiserValidation.checkValidation(mobile.text , email.text , name.text , gender , pass.text , c_pass.text)

    onRegiste: {
        var data = {
            'phone_number': mobile.text,
            'password': pass.text,
            'name': name.text,
            'email': email.text,
            'gender': gender
        }

        var endpoint = Service.url_signup

        Service.logIn( endpoint, data, function(resp, http) {

            console.log( "state of " + authWin.objectName + " = " + http.status + " " + http.statusText + ', /n handle log in resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                authWin.log("error detected; " + resp.error)
                //                                    alarmLogin.msg = resp.error
                alarmSignupWin.msg = "مشکلی در ارتباط با اینترنت وجود دارد"
                return
            }

            //-- 400-Bad Request, 401-Unauthorized --//
            //-- No active account found with the given credentials --//
            if(http.status === 400 || http.status === 401 || resp.hasOwnProperty('non_field_errors')){

                //                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                //                                    alarmLogin.msg = resp.non_field_errors.toString()
                alarmSignupWin.msg = "کاربری با مشخصات وارد شده یافت نشد"
                return
            }

            _token_access = resp.access
            _token_refresh = resp.refresh

            //-- save user and pass --//
            _userName = win_login.user.text
            _password = win_login.pass.text

            isLogined = true

            //-- save in Setting --//
            setting.username        = _userName
            setting.password        = _password
            setting.token_access    = _token_access
            setting.token_refresh   = _token_refresh

            root_register.visible = false

        })

        //        mobile.text = ""
        //        email.text = ""
        //        name.text = ""
        //        pass.text = ""
        //        c_pass.text = ""


        alarm_popup.getAlarmData(Icons.check_all , "#00ff00" , "حساب کاربری به موفقیت ایجاد شد" , "تایید" , true , false , "rtl")
        alarm_popup.open()

    }

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

                    onCurrentIndexChanged: {
                        if(currentIndex === 1){
                            timer_confirmSMS.resetTimer()
                            timer_confirmSMS.minutes = 1
                            timer_confirmSMS.startTimer()
                        }
                    }

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
                                height: parent.height * 0.9
                                spacing: 10

                                //-- spacer --//
                                Item{Layout.fillHeight: true}

                                //-- "purchase PoroX license key --//
                                Label{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: implicitHeight
                                    text: "Purchase PoroX software license key"
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

                                //-- Time --//
                                RowLayout{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45 * ratio
                                    Layout.rightMargin: 10 * ratio
                                    Label{
                                        Layout.preferredWidth: parent.width * 0.2
                                        Layout.fillHeight: true
                                        verticalAlignment: Qt.AlignVCenter

                                        text: "Time : "

                                        font.pixelSize: Qt.application.font.pixelSize
                                    }
                                    //-- Time --//
                                    ComboBox{
                                        id: input_time
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        model: ListModel {
                                            id: model
                                            ListElement { text: "30 days" }
                                            ListElement { text: "90 days" }
                                            ListElement { text: "120 days" }
                                            ListElement { text: "360 days" }
                                        }
                                        onActivated: {

                                        }
                                    }
                                }

                                //-- spacer --//
                                Item{Layout.preferredHeight: 10}

                                //-- Devices --//
                                RowLayout{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45 * ratio
                                    Layout.rightMargin: 10 * ratio
                                    Label{
                                        Layout.preferredWidth: parent.width * 0.2
                                        Layout.fillHeight: true
                                        verticalAlignment: Qt.AlignVCenter

                                        text: "Devices : "

                                        font.pixelSize: Qt.application.font.pixelSize
                                    }
                                    //-- Time --//
                                    ComboBox{
                                        id: input_device
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        model: ListModel {
                                            id: model_device
                                            ListElement { text: "1" }
                                            ListElement { text: "2" }
                                            ListElement { text: "3" }
                                            ListElement { text: "4" }
                                        }
                                        onActivated: {

                                        }
                                    }

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
                                        text: "Purchase"
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: "#ffffff"
                                    }

                                    MouseArea{
                                        id: btn_register
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {

                                            //-- clear msg box --//
                                            alarmSignupWin.msg = ""
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
        id: alarmSignupWin

        property string msg: ""

        width: parent.width
        height: lblAlarm.implicitHeight * 2.5
        anchors.bottom: parent.bottom

        color: msg === "" ? "transparent" : "#E91E63"

        Label{
            id: lblAlarm
            text: alarmSignupWin.msg
            anchors.centerIn: parent
            color: "white"

        }
    }

}

