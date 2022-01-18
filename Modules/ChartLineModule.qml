import QtQuick 2.14
import QtQuick.Controls 2.12
import QtCharts 2.3

Item {

    anchors.fill: parent

    property alias title: ctitle.title
    property alias xTitle: axisX.titleText
    property alias yTitle: axisY.titleText

    property var xData: []
    property var yData: []

    signal plot

    onPlot: {
        series.clear()

        axisX.min = Math.min(...xData)
        axisX.max = Math.max(...xData)
        axisY.min = Math.min(...yData)
        axisY.max = Math.max(...yData)

        for (var j = 0; j <= xData.length-1; j++) {
            series.append(xData[j], yData[j]);
        }
    }

    ChartView {
        id: ctitle
        title: "Curve"
        anchors.fill: parent
        legend.visible: false
        //        legend.alignment: Qt.AlignBottom
        antialiasing: true
        theme: ChartView.ChartThemeDark
        backgroundColor: "#535353"

        ValueAxis {
            id: axisX
            min: 0
            max: 1
            titleText: "X"
            labelFormat: "%.1f"
        }

        ValueAxis {
            id: axisY
            min: 0
            max: 1
            titleText: "Y"
        }

        SplineSeries {
            id: series
            axisX: axisX
            axisY: axisY
        }
    }
}
