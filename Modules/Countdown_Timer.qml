import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "./../Fonts/Icon.js" as Icons


Rectangle{

    property alias minutes: lbl_Timer.hour
    property alias second: lbl_Timer.seconds
    property alias lblTimer : lbl_Timer

    //-- Signal for Start Timer --//
    signal startTimer
    onStartTimer: {
        testTimer.start()
    }

    //-- Signal for Stop Timer --//
    signal stopTimer
    onStopTimer: {
        testTimer.stop()
    }

    //-- Signal for Reset Timer --//
    signal resetTimer
    onResetTimer: {
        lbl_Timer.hour = 60
        lbl_Timer.seconds = 0
    }


    property alias iconVisible: lbl_StopWatch.visible
    property real timerScale: 1
    property alias timerLabel: lbl_Timer.text

    width: lbl_Timer.width
    height: parent.height


    color: "transparent"

    RowLayout{
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft

        //-- Filler --//
        Item {
            Layout.fillWidth: true
        }

        //-- "Countdown Timer" Label --//
        Label{
            id: lbl_Timer


            Timer {
                id:testTimer
                interval: 1000; repeat: true

                onTriggered:{
                    if(lbl_Timer.seconds === 0){
                        lbl_Timer.seconds = 59 ;
                        lbl_Timer.hour-- ;
                    }else{
                        lbl_Timer.seconds-- ;
                    }

                    if(lbl_Timer.hour === 0 && lbl_Timer.seconds === 0){
                        testTimer.stop()
                        console.log("Time Over")
                    }

                    //lbl_Timer.seconds++;
                }
            }

            property int hour: 60
            property int seconds: 0

            //-- set 1Digit to 2Digit for Hour --//
            property string stringHour:{
                for(var i = 0 ; i <= 9 ; i++){
                    //console.log(i + " === " + hour)
                    if( hour === i){
                        return "0" + i;
                    }
                }
                return hour;
            }

            //-- set 1Digit to 2Digit for Seconds --//
            property string stringSeconds:{
                for(var i = 0 ; i <= 9 ; i++){
                    //console.log(i + " === " + seconds)
                    if( seconds === i){
                        return "0" + i;
                    }
                }
                return seconds;
            }


            Layout.preferredWidth: implicitWidth
            Layout.fillHeight: true

            verticalAlignment: Qt.AlignVCenter

            text: stringHour + " : " + stringSeconds
            font.pixelSize: Qt.application.font.pixelSize * 1.4 * timerScale
            //font.bold: true

            color: "#ffffff"

        }


        //-- clock Icon --//
        Label{

            id:lbl_StopWatch

            Layout.preferredWidth: implicitWidth
            Layout.fillHeight: true

            text: Icons.timer
            font.family: webfont.name
            font.pixelSize: Qt.application.font.pixelSize * 1.7

            verticalAlignment: Qt.AlignVCenter

            color: lbl_Timer.color
        }

        //-- Filler --//
        Item {
            Layout.fillWidth: true
        }

    }

}
