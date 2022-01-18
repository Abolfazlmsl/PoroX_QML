import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: reconstructionmenu

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
                    text: "Statistical"
                    icon: "../Images/Statistical.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"){
                            return true
                        }else{
                            return false
                        }
                    }

                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Statistical"
                        sView.currentIndex = _StatisticalItem
                    }
                }
                ButtonVPanel{
                    id: b2
                    text: "Multi Point Statistics (MPS)"
                    icon: "../Images/MPS.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "MPS"
                        sView.currentIndex = _MPSItem
                    }

                }
            }

            ButtonVPannelText{
               text: "Reconstruction"
            }
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
