import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: propertiesmenu

    clip: true
    width: parent.width
    height: 70

    color: "#f8f8ff"

    Row{
        width: parent.width
        height: parent.height
        spacing: 0

        Column{
            width: b1.width + b2.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b1
                    text: "Pore"
                    icon: "../Images/Pore.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Pore"
                        sView.currentIndex = _PoreItem
                    }
                }
                ButtonVPanel{
                    id: b2
                    text: "Throat"
                    icon: "../Images/Throat.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Throat"
                        sView.currentIndex = _ThroatItem
                    }

                }
            }

            ButtonVPannelText{
                text: "Geometry"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b3.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b3
                    text: "Physics"
                    icon: "../Images/Physics.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Physics"
                        sView.currentIndex = _PhysicItem
                    }
                }

            }

            ButtonVPannelText{
                text: "Physic"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b4.width + b5.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b4
                    text: "Invading"
                    icon: "../Images/Invader.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Invading"
                        sView.currentIndex = _InvadingItem
                    }
                }
                ButtonVPanel{
                    id: b5
                    text: "Defending"
                    icon: "../Images/Defender.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Defending"
                        sView.currentIndex = _DefendingItem
                    }

                }
            }

            ButtonVPannelText{
                text: "Phase"
            }
        }


        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

//        Column{
//            width: 20
//            height: parent.height
//            Rectangle{
//                width: parent.width
//                height: 80
//                color: "#f8f8ff"
//            }

//            Rectangle{
//                width: parent.width
//                height: parent.height/5
//                color: "#a9a9a9"
//            }
//        }

//        Button{
//            width: 70
//            height: parent.height
//            background: Rectangle {

//                border.width: 2
//                border.color: "#888"
//                color: "#a9a9a9"
//                radius: 4
//            }
//            Label{
//                anchors.fill: parent

//                font.pixelSize: Qt.application.font.pixelSize * 1.7
//                text: "Apply"
//                verticalAlignment: Qt.AlignVCenter
//                horizontalAlignment: Qt.AlignHCenter
//            }
//            MouseArea{
//                anchors.fill: parent
//                cursorShape: Qt.PointingHandCursor
//                onClicked: {

//                }
//            }
//        }

//        Column{
//            width: 20
//            height: parent.height
//            Rectangle{
//                width: parent.width
//                height: 80
//                color: "#f8f8ff"
//            }

//            Rectangle{
//                width: parent.width
//                height: parent.height/5
//                color: "#a9a9a9"
//            }
//        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: 20
            height: parent.height
            Rectangle{
                width: parent.width
                height: 80
                color: "#f8f8ff"
            }

            Rectangle{
                width: parent.width
                height: parent.height/5
                color: "#a9a9a9"
            }
        }

        Button{
            width: 70
            height: parent.height
            background: Rectangle {

                border.width: 2
                border.color: "#888"
                color: "#a9a9a9"
                radius: 4
            }
            Label{
                anchors.fill: parent

                font.pixelSize: Qt.application.font.pixelSize * 1.7
                text: "Help"
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
            }
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    checkprops()
                    isHelpOn = true
                }
            }
        }

        Column{
            width: 20
            height: parent.height
            Rectangle{
                width: parent.width
                height: 80
                color: "#f8f8ff"
            }

            Rectangle{
                width: parent.width
                height: parent.height/5
                color: "#a9a9a9"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        FillBarModule{}

    }

}
