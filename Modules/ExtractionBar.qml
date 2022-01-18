import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: exteactionmenu

    clip: true
    width: parent.width
    height: 70

    color: "#f8f8ff"

    Row{
        width: parent.width
        height: parent.height
        spacing: 0

        Column{
            width: b1.width + b2.width + b3.width + b4.width + b5.width + b6.width + b7.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b1
                    text: "Cubic"
                    icon: "../Images/Cubic.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Cubic"
                        sView.currentIndex = _CubicItem
                    }
                }
                ButtonVPanel{
                    id: b2
                    text: "CubicDual"
                    icon: "../Images/Cubicdual.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "CubicDual"
                        sView.currentIndex = _CubicDualItem
                    }

                }
                ButtonVPanel{
                    id: b3
                    text: "Bravais"
                    icon: "../Images/Bravais.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Braivas"
                        sView.currentIndex = _BraivasItem
                    }

                }
                ButtonVPanel{
                    id: b4
                    text: "DelaunayVoronoiDual"
                    icon: "../Images/DelaunayVoronoiDual.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "DelaunayVoronoiDual"
                        sView.currentIndex = _DelaunayVoronoiDualItem
                    }

                }
                ButtonVPanel{
                    id: b5
                    text: "Voronoi"
                    icon: "../Images/Voronoi.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Voronoi"
                        sView.currentIndex = _VoronoiItem
                    }

                }
                ButtonVPanel{
                    id: b6
                    text: "Delaunay"
                    icon: "../Images/Delaunay.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Delaunay"
                        sView.currentIndex = _DelaunayItem
                    }

                }
                ButtonVPanel{
                    id: b7
                    text: "Gabriel"
                    icon: "../Images/Gabriel.png"
                    color: {
                        if (inputType === "Synthetic Network"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "Synthetic Network"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Gabriel"
                        sView.currentIndex = _GabrielItem
                    }

                }
            }

            ButtonVPannelText{
               text: "Construction"
            }
        }

        // **** spacer ****//
        Rectangle{
            width: 1
            height: parent.height
            color: "#000000"
        }

        Column{
            width: b8.width + b9.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b8
                    text: "Maximal Ball"
                    icon: "../Images/Maximal.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"
                                || inputType === "3D Gray" || inputType === "3D Binary"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"
                                || inputType === "3D Gray" || inputType === "3D Binary"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Maximal Ball"
                        sView.currentIndex = _MaximalBallItem
                    }
                }
                ButtonVPanel{
                    id: b9
                    text: "SNOW"
                    icon: "../Images/SNOW.png"
                    color: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"
                                || inputType === "3D Gray" || inputType === "3D Binary"){
                            return "transparent"
                        }else{
                            return "#40ff0000"
                        }
                    }

                    enabled: {
                        if (inputType === "2D Gray" || inputType === "2D Binary" || inputType === "2D Thinsection"
                                || inputType === "3D Gray" || inputType === "3D Binary"){
                            return true
                        }else{
                            return false
                        }
                    }
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "SNOW"
                        sView.currentIndex = _SNOWItem
                    }

                }
            }

            ButtonVPannelText{
               text: "Extraction"
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
