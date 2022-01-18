import QtQuick 2.14
import QtQuick.Controls 2.12
import QtCharts 2.3

Item {

    anchors.fill: parent

    property alias title: ctitle.title
    property alias xTitle: axisX.titleText
    property alias yTitle: axisY.titleText

    property string name1: ""
    property var xData1: []
    property var yData1: []

    property string name2: ""
    property var xData2: []
    property var yData2: []

    property string name3: ""
    property var xData3: []
    property var yData3: []

    property string name4: ""
    property var xData4: []
    property var yData4: []

    property string name5: ""
    property var xData5: []
    property var yData5: []

    property string name6: ""
    property var xData6: []
    property var yData6: []

    signal plot

    onPlot: {
        series1.clear()
        series2.clear()
        series3.clear()
        series4.clear()
        series5.clear()
        series6.clear()

        axisX.min = 0
        axisX.max = 1
        axisY.min = 0
        axisY.max = 1

        for (var j = 0; j <= xData1.length-1; j++) {
            series1.append(xData1[j], yData1[j]);
        }
        for (j = 0; j <= xData2.length-1; j++) {
            series2.append(xData2[j], yData2[j]);
        }
        for (j = 0; j <= xData3.length-1; j++) {
            series3.append(xData3[j], yData3[j]);
        }
        for (j = 0; j <= xData4.length-1; j++) {
            series4.append(xData4[j], yData4[j]);
        }
        for (j = 0; j <= xData5.length-1; j++) {
            series5.append(xData5[j], yData5[j]);
        }
        for (j = 0; j <= xData6.length-1; j++) {
            series6.append(xData6[j], yData6[j]);
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
            name: name1
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series2
            name: name2
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series3
            name: name3
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series4
            name: name4
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series5
            name: name5
            axisX: axisX
            axisY: axisY
        }
        LineSeries {
            id: series6
            name: name6
            axisX: axisX
            axisY: axisY
        }
    }
}
