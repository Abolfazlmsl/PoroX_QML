import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: inputmenu

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
                    text: "3D Gray"
                    icon: "../Images/3DGray.png"
                    color: (inputType === "") ? "transparent":(inputType === "3D Gray") ? "#406495ed":"#40ff0000"
                    enabled: (inputType === "") ? true:false
                    onBtnClicked: {
                        inputdata = "3D Gray"
                        isGray = true
                        fileDialog_3D.visible = true
                    }
                }
                ButtonVPanel{
                    id: b2
                    text: "2D Gray"
                    icon: "../Images/2DGray.png"
                    color: (inputType === "") ? "transparent":(inputType === "2D Gray") ? "#406495ed":"#40ff0000"
                    enabled: (inputType === "") ? true:false

                    onBtnClicked: {
                        inputdata = "2D Gray"
                        isGray = true
                        fileDialog.visible = true
                    }

                }
            }

            ButtonVPannelText{
               text: "Grayscale"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b3.width + b4.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b3
                    text: "3D Binary"
                    icon: "../Images/3DBinary.png"
                    color: (inputType === "") ? "transparent":(inputType === "3D Binary") ? "#406495ed":"#40ff0000"
                    enabled: (inputType === "") ? true:false

                    onBtnClicked: {
                        inputdata = "3D Binary"
                        isGray = false
                        fileDialog_3D.visible = true
                    }
                }
                ButtonVPanel{
                    id: b4
                    text: "2D Binary"
                    icon: "../Images/2DBinary.png"
                    color: (inputType === "") ? "transparent":(inputType === "2D Binary") ? "#406495ed":"#40ff0000"
                    enabled: (inputType === "") ? true:false

                    onBtnClicked: {
                        inputdata = "2D Binary"
                        isGray = false
                        fileDialog.visible = true
                    }

                }
            }

            ButtonVPannelText{
               text: "Binarized"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b5.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b5
                    text: "2D Thinsection"
                    icon: "../Images/2DThin.png"
                    color: (inputType === "") ? "transparent":(inputType === "2D Thinsection") ? "#406495ed":"#40ff0000"
                    enabled: (inputType === "") ? true:false
                    onBtnClicked: {
                        inputdata = "2D Thinsection"
                        isGray = true
                        fileDialog.visible = true

                    }
                }
            }

            ButtonVPannelText{
               text: "Thinsection"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b6.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b6
                    text: "Synthetic Network"
                    icon: "../Images/Synthetic.png"
                    color: (inputType === "") ? "transparent":(inputType === "Synthetic Network") ? "#406495ed":"#40ff0000"
                    onBtnClicked: {
                        if (inputType === ""){
                            inputType = "Synthetic Network"
                            inputdata = "Synthetic Network"
                        }else if (inputType === "Synthetic Network"){
                            inputType = ""
                            inputdata = "Synthetic Network"
                        }
                    }
                }
            }

            ButtonVPannelText{
               text: "Synthetic Network"
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
