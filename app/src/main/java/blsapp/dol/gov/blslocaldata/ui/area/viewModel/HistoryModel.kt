package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.util.Log
import blsapp.dol.gov.blslocaldata.model.SeriesReport
import blsapp.dol.gov.blslocaldata.model.reports.AreaReport
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry

data class HistoryModel(
        var lineGraphValues:MutableList<MutableList<Entry>>,
        var barGraphValues: MutableList<MutableList<BarEntry>>,
        var titleList: MutableList<String>,
        var xAxisLabels: MutableList<String>,
        var tableLabels: MutableList<String>) {

    constructor(areaReportRows:List<AreaReportRow>?):this(mutableListOf<MutableList<Entry>>(),
                                                            mutableListOf<MutableList<BarEntry>>(),
                                                            mutableListOf<String>(),
                                                            mutableListOf<String>(),
                                                            mutableListOf<String>()) {

        this.lineGraphValues = mutableListOf<MutableList<Entry>>()
        this.barGraphValues = mutableListOf<MutableList<BarEntry>>()
        this.titleList = mutableListOf<String>()

        if (areaReportRows == null) return
        var items: SeriesReport? = null
        for (areaReportRow in areaReportRows!!) {
            if (areaReportRow.areaReports != null) {
                areaReportRow.areaType?.let {
                    Log.i("GGG", "Processing: " + it)
                }
                val retList =  processSeriesDataForHistory(areaReportRow.areaReports)
                retList.let {
                    areaReportRow.areaType?.let {
                        this.titleList.add(it)
                    }
                }
            }
        }
        if (this.lineGraphValues.count() > 1) {
            if (this.lineGraphValues[0].count() > this.lineGraphValues[1].count()) {

                this.lineGraphValues[0].removeAt(0)
                this.barGraphValues[0].removeAt(0)
                this.tableLabels.removeAt(0)
                this.xAxisLabels.removeAt(0)

            } else if (this.lineGraphValues[0].count() < this.lineGraphValues[1].count()) {

                this.lineGraphValues[1].removeAt(0)
                this.barGraphValues[1].removeAt(0)
                this.tableLabels.removeAt(0)
                this.xAxisLabels.removeAt(0)
            }
        }
    }

    private fun processSeriesDataForHistory(areaReportRows: List<AreaReport>):MutableList<BarEntry> {

        var barGraphValues = mutableListOf<BarEntry>()
        var lineGraphValues = mutableListOf<Entry>()
        var items: SeriesReport? = null

        this.xAxisLabels = mutableListOf<String>()
        this.tableLabels = mutableListOf<String>()

        for (areaReport in areaReportRows) {
            if (areaReport.seriesReport != null) {
                items = areaReport.seriesReport
                break
            }
        }
        var nextIndex = items!!.data.count()-1

        for (nextItem in items!!.data) {

            barGraphValues.add(BarEntry(nextIndex.toFloat(), nextItem.value.toFloat()))
            lineGraphValues.add(Entry(nextIndex.toFloat(), nextItem.value.toFloat()))

            val nextXlabel = nextItem.periodName.substring(0,3) + " " + nextItem.year.substring(2,4)
            Log.i("GGG", "Adding History Entry " + nextXlabel + " with value " + nextItem.value)
            this.xAxisLabels.add(nextXlabel)
            this.tableLabels.add( nextItem.periodName + " " + nextItem.year)
            nextIndex--
        }

        this.lineGraphValues.add(lineGraphValues)
        this.barGraphValues.add(barGraphValues)

        return barGraphValues

    }

}