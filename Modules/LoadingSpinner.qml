import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Row
{

    property real leftMarg: 80
    spacing: 8
    Layout.leftMargin: leftMarg * ratio

    // Rotating icon
    Text
    {
        id: loadingSpinner

        text: "\uf110"
        font.family: awesome.name
        font.pixelSize: 18
        color: "#0091f8";
        NumberAnimation on rotation {
            from: 0; to: 360; running: loadingSpinner.visible == true;
            loops: Animation.Infinite; duration: 700;
        }
    }

    // Text explaining whats happening
    Text {
        text: "Please wait"
        font.family: "Lato"
        font.pixelSize: 16
    }
}
