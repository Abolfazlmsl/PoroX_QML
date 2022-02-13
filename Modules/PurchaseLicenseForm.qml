import QtQuick 2.14
import QtQuick.Window 2.2
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons
import "./../REST/apiService.js" as Service

Item{
    id: root_register

    property real timeLimit: 30
    property real numberOfDevices: 1
    property string gender  : ""
    property int price: 1000000

    property var prices: [1000000, 2800000, 5400000, 10000000]

    signal getMessage(var signalmsg)

    signal registe(var date)

    onRegiste: {
        var licenseData = {
            'email': email.text,
            'expired_on': date,
            'deviceNumber': numberOfDevices,
            'licenseType': "time limit"
        }
        var endpoint = Service.url_license

        Service.create_item(setting.tokenAccess, endpoint, licenseData, function(resp, http) {
            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                //                                    alarmLogin.msg = resp.error
               getMessage("Connection error")
                spinner.visible = false
                return
            }

            //-- 400-Bad Request, 401-Unauthorized --//
            //-- No active account found with the given credentials --//
            if(http.status === 400 || http.status === 401 || resp.hasOwnProperty('non_field_errors')){

                getMessage("Incorrect entered informations")
                spinner.visible = false
                return
            }
            var msg = "Thank you for purchasing the PoroX software license"
            MainPython.sendEmail(msg, email.text, resp.key, resp.serialNumber)
            spinner.visible = false
            root_register.visible = false
            successDynamicPop.messageText = "The license was sent to your email"
            animationdynamicpop.restart()
        })

    }

    //    function priceCount(){
    //        price = parseInt(input_device.currentIndex+1) * prices[parseInt(input_time.currentIndex)]
    //    }

    //    function numberWithCommas(nStr) {
    //        nStr += '';
    //        var x = nStr.split('.');
    //        var x1 = x[0];
    //        var x2 = x.length > 1 ? '.' + x[1] : '';
    //        var rgx = /(\d+)(\d{3})/;
    //        while (rgx.test(x1)) {
    //                x1 = x1.replace(rgx, '$1' + ',' + '$2');
    //        }
    //        return x1 + x2;
    //    }

    //    Component.onCompleted: MainPython.timeLimitData.connect(registe)

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
        height: parent.height

        //-- spacer --//
        Item{Layout.preferredHeight: 50}

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
        Item{Layout.preferredHeight: 30}

        //-- Button Purchase --//
        Rectangle{
            id: purchase
            Layout.fillWidth: true
            Layout.preferredHeight: 38

            radius: height / 2

            color: "darkblue"

            Label{
                anchors.centerIn: parent
                text: "Go to website"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                color: "#ffffff"
            }

            MouseArea{
                id: btn_register
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    spinner.visible = true
                    MainPython.makeLicenseKey(Service.BASE)
                    spinner.visible = false
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

