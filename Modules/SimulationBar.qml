import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: simulationmenu

    clip: true
    width: parent.width
    height: 70

    color: "#f8f8ff"

    Row{
        width: parent.width
        height: parent.height
        spacing: 0

        Column{
            width: b1.width
            height: parent.height
            Row{
                spacing: 0
                ButtonVPanel{
                    id: b1
                    text: "Simulation"
                    icon: "../Images/Simulation.png"
                    onBtnClicked: {
                        section1.checked = true
                        swipTitle = "Simulation"
                        sView.currentIndex = _SimulationItem
                    }
                }
            }

            ButtonVPannelText{
               text: "Simulation"
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
