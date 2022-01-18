import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: imagehandlingmenu

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
                    text: "De-Noising"
                    icon: "../Images/Denoise.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return true
                        }else{
                            return false
                        }
                    }

                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Denoise"
                        sView.currentIndex = _DenoiseItem
                    }
                }
                ButtonVPanel{
                    id: b2
                    text: "Filtering"
                    icon: "../Images/Filter.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Filter"
                        sView.currentIndex = _FilterItem
                    }

                }
            }

            ButtonVPannelText{
               text: "Noise removal"
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
                    text: "Segmentation"
                    icon: "../Images/Segment.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "3D Gray" || inputType === "2D Thinsection"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Segmentation"
                        sView.currentIndex = _SegmentationItem
                    }
                }

            }

            ButtonVPannelText{
               text: "Segmentation"
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
