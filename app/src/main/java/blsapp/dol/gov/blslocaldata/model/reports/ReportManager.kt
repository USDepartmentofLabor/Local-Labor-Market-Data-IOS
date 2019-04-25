package blsapp.dol.gov.blslocaldata.model.reports

import android.os.Looper
import android.util.Log
import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.model.BLSReportResponse
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.ReportStatus
import blsapp.dol.gov.blslocaldata.model.SeriesReport
import blsapp.dol.gov.blslocaldata.network.BlsAPI

class AreaReport(val seriesId: String,
                 val reportType: ReportType,
                 val area: AreaEntity) {

    var seriesReport: SeriesReport? = null
}

/**
 * ReportManager - Provides main getReport interface, creates seriesIds and areaReports for reportTypes
 */

class ReportManager {

    companion object {
        const val DATA_NOT_AVAILABLE_STR = "N/A"
        var adjustment: SeasonalAdjustment = SeasonalAdjustment.NOT_ADJUSTED

        fun getReport(area: AreaEntity,
                      reportTypes: List<ReportType>,
                      startYear: String? = null,
                      endYear: String? = null,
                      adjustment: SeasonalAdjustment,
                      annualAvg: Boolean = false,
                      successHandler: (List<AreaReport>) -> Unit,
                      failureHandler: (ReportError) -> Unit) {

            var seriesIds = emptyList<String>()

            var areaReports = emptyList<AreaReport>()

            reportTypes.forEach {
                val seriesId = it.getSeriesId(area, adjustment)
                seriesIds += seriesId
                val areaReport = AreaReport(seriesId, it, area)
                areaReports += areaReport
            }
            if(Looper.myLooper() == Looper.getMainLooper()) {
                // Current Thread is Main Thread.
                assert(Looper.myLooper() != Looper.getMainLooper())
            }
            BlsAPI(BLSApplication.applicationContext()).getReports(seriesIds,
                    startYear = startYear,
                    endYear = endYear,
                    annualAvg = annualAvg,
                    successHandler = {reportResponse ->
                        Log.w("Report", reportResponse.toString())

                        val seriesReports = reportResponse.series
                        // Map the series from Response to requested Report
                        areaReports.forEach { areaReport ->
                            val seriesReport = seriesReports.filter { areaReport.seriesId == it.seriesId }.firstOrNull()
                            areaReport.seriesReport = seriesReport
                        }

                        successHandler(areaReports)

                    }, failureHandler = {
                        Log.w("Failure", it.toString())
                        failureHandler(it)
                    })
        }

    }

}