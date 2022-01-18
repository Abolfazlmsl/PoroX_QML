import QtQuick 2.14
import QtQuick.Controls 2.12
import QtCharts 2.3

Item {

    anchors.fill: parent

    property alias title: ctitle.title
    property alias barxTitle: barcategory.titleText
    property alias yTitle: axisY.titleText

    property var xData: []
    property var yData: []

    signal plot

    onPlot: {

        barSeries.clear()

        axisY.min = 0
        axisY.max = Math.max(...yData)

        var barData = []
        var xBarData = []
        for (var k = 0; k <= xData.length-1; k++) {
            barData.push(yData[k]);
            xBarData.push(Math.round(xData[k] * 10) / 10)
        }
        barcategory.categories = xBarData
        barSeries.append("PSD", barData)

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
            id: axisY
            min: 0
            max: 1
            titleText: "Y"
        }

        BarSeries {
            id: barSeries
            axisX: BarCategoryAxis {
                id: barcategory
                titleText: "X"
                min: Math.min(...xData)
                max: Math.max(...xData)

            }
            axisY: axisY
        }
    }
}
