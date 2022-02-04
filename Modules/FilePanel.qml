import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "./../Fonts/Icon.js" as Icons

//-- Right Menu --//
Rectangle{
    id: rightMenu

    property alias saveEnable: btnPractice.enabled

    //-- Left Menu Items --//
    ColumnLayout{
        anchors.fill: parent
        anchors.topMargin: 15 * ratio

        spacing: 0

        //-- Dashboard Button --//
        ButtonPanel{
            id: btnDashboard

            enabled: isLicensed
            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.folder
            text: "New File"

            onBtnClicked: {
                newfilePop.visible = true
            }

        }

        //-- Open Button --//
        ButtonPanel{
            id: btnLearn

            enabled: isLicensed
            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.folder_open
            text: "Open File"

            onBtnClicked: {
                fileOpen.visible = true
            }

        }

        //-- Save Button --//
        ButtonPanel{
            id: btnPractice

            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.content_save
            text: "Save File"
            enabled: false
            colorstate: !btnPractice.enabled

            onBtnClicked: {
                if (savePath === ""){
                    fileSave.visible = true
                }else{
                    MainPython.save_file(savePath)
                }
            }

        }

        //-- Help Button --//
        ButtonPanel{
            id: btnActivity

            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.help
            text: "Help"

            onBtnClicked: {

            }

        }

        //-- License Button --//
        ButtonPanel{
            id: btnLicense

            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.key
            text: "License"

            onBtnClicked: {
                licenseform.visible = true
            }

        }


        Item { Layout.fillHeight: true } //-- Filler --//

        //-- AboutUs Button --//
        ButtonPanel{
            id: btnAboutUs

            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.information_outline
            text: "About Us"

            onBtnClicked: {
                leftfilepanel.restart()
                popup_aboutUs.open()
            }

        }

        //-- Logout --//
        ButtonPanel{
            id: btnLogout

            Layout.fillWidth: true
            Layout.preferredHeight: 45 * ratio

            icon: Icons.logout
            text: "Exit"

            onBtnClicked: {
                close.accepted = false
                if (filepanel.saveEnable){
                    savefilePop.visible = true
                }else{
                    quitPop.visible = true
                }
            }

        }
    }


}
