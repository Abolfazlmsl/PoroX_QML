import QtQuick 2.14
import QtQuick.Controls 2.12
import QtCharts 2.3

Item {

    anchors.fill: parent

    property alias title: ctitle.title
    property alias xTitle: axisX.titleText
    property alias yTitle: axisY.titleText

    property var xData1: []
    property var yData1: []

    property var xData2: []
    property var yData2: []

    property var xData3: []
    property var yData3: []

    signal plot

    onPlot: {
        series1.clear()
        series2.clear()
        series3.clear()

        axisX.min = 0
        axisX.max = 1
        axisY.min = 0

        var max1 = Math.max(...yData1)
        var max2 = Math.max(...yData2)
        var max3 = Math.max(...yData3)
        var list = [max1, max2, max3]
        axisY.max = Math.max(...list)

        for (var j = 0; j <= xData1.length-1; j++) {
            series1.append(xData1[j], yData1[j]);
        }
        for (j = 0; j <= xData2.length-1; j++) {
            series2.append(xData2[j], yData2[j]);
        }
        for (j = 0; j <= xData3.length-1; j++) {
            series3.append(xData3[j], yData3[j]);
        }
    }

    ChartView {
        id: ctitle
        title: "Curve"
        anchors.fill: parent
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

        LineSeries {
            id: series1
            name: "Pc_x"
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series2
            name: "Pc_y"
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series3
            name: "Pc_z"
            axisX: axisX
            axisY: axisY
        }
    }
}
