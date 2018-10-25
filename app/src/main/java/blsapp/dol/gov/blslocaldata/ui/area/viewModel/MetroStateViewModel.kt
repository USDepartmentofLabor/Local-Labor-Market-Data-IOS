package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.MutableLiveData

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.ui.area.ReportRow
import blsapp.dol.gov.blslocaldata.ui.area.ReportRowType
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import org.jetbrains.anko.doAsync

data class ReportSection(
    var title: String?,
    var collapsed: Boolean,
    var reportTypes: List<ReportType>?,
    var subSections : List<ReportSection>? = null) {
}


class MetroStateViewModel(application: Application) : AndroidViewModel(application), AreaViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment

    override var isLoading = MutableLiveData<Boolean>()
    var localAreaReports: MutableList<AreaReport>? = null
    var nationalAreaReports = mutableListOf<AreaReport>()

    val repository: LocalRepository
    override var reportRows = MutableLiveData<List<ReportRow>>()

    var reportSections = listOf<ReportSection>(
            ReportSection("Unemployment Rate", false,
                    listOf(ReportType.Unemployment(LAUSReport.MeasureCode.UNEMPLOYMENT_RATE))),
            ReportSection("Industry Employment", true,
                    listOf(ReportType.IndustryEmployment("00000000", CESReport.DataTypeCode.ALLEMPLOYEES))),
            ReportSection("Occupational Employment & Wages", true,
                    listOf(ReportType.OccupationalEmployment("000000", OESReport.DataTypeCode.ANNUALMEANWAGE))))

    init {
        repository = (application as BLSApplication).repository
    }


    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
        localAreaReports?.clear()
        nationalAreaReports.clear()
        getReports()
    }

    override fun getReports() {
        getLocalReports()
    }

    private fun getLocalReports() {
        var reportTypes = mutableListOf<ReportType>()

        reportSections.forEach {
            it?.reportTypes?.let {  reportTypes.addAll(it)}
        }

//        val reportTypes = reportSections.flatMap? {reportSection ->
//            reportSection.reportTypes
//        }

        ReportManager.getReport(mArea, reportTypes, adjustment = mAdjustment,
                successHandler = {
                    localAreaReports = it.toMutableList()
                    updateReportRows()

                    // If current Area is not National, get National Data for comparison
                    if (mArea !is NationalEntity) {
                        getNationalReports()
                    }
                },
                failureHandler = {

                })
        updateReportRows()

    }

    private fun getNationalReports() {
        doAsync{
            val nationalArea = repository.getNationalArea()

            reportSections.forEach { reportSection ->
                val localAreaReport = localAreaReports?.filter { areaReport ->
                    areaReport.reportType == reportSection.reportTypes?.first() }?.firstOrNull()
                var startYear: String? = null
                localAreaReport?.seriesReport?.latestData()?.let { localReport ->
                    startYear = localReport.year
                }

                reportSection.reportTypes?.let { reportTypes ->
                    ReportManager.getReport(nationalArea,
                            reportTypes,
                            startYear = startYear,
                            endYear = startYear,
                            adjustment = mAdjustment,
                            successHandler = { areaReport ->
                                nationalAreaReports.addAll(areaReport)
                                updateReportRows()
                            },
                            failureHandler = {

                            })
                }
            }
        }
    }

    private fun updateReportRows() {
        val rows = ArrayList<ReportRow>()

        reportSections.forEach{ reportSection ->
            rows.add(ReportRow(ReportRowType.HEADER, null, null,header = reportSection.title))
            if (!reportSection.collapsed) {
                val areaReports = localAreaReports?.filter { areaReport ->
                    reportSection.reportTypes?.let { reportTypes ->
                        areaReport.reportType in reportTypes
                    } ?: kotlin.run { false }
                }
                val nationalAreaReports = nationalAreaReports?.filter { areaReport ->
                    reportSection.reportTypes?.let { reportTypes ->
                        areaReport.reportType in reportTypes
                    } ?: kotlin.run { false }
                }

                var rowType = getRowType(areaReports)
                rows.add(ReportRow(rowType, "Local Area", areaReports, header = null))
                val latestLocalData = areaReports?.firstOrNull()?.seriesReport?.latestData()
                if (nationalAreaReports.count() > 0) {
                    rows.add(ReportRow(rowType, "National Area", nationalAreaReports,
                            month = latestLocalData?.period,
                            year = latestLocalData?.year,
                            header = null))

                }
            }
        }

        reportRows.value = rows
    }

    private fun getRowType(areaReports: List<AreaReport>?): ReportRowType {
        var rowType: ReportRowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
        when (areaReports?.firstOrNull()?.reportType) {
            is ReportType.Unemployment -> {
                rowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
            }
            is ReportType.IndustryEmployment -> {
                rowType = ReportRowType.INDUSTRY_EMPLOYMENT_ITEM
            }
            is ReportType.OccupationalEmployment -> {
                rowType = ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM
            }
        }

        return rowType
    }

    override fun toggleSection(reportRow: ReportRow) {
        if (reportRow.type != ReportRowType.HEADER) return

        val currentSection = reportSections.filter { it.title == reportRow.header }.singleOrNull()
        currentSection?.let {

            // Section is being expanded, collapse the other sections
            if (currentSection.collapsed) {
                for (reportSection in reportSections) {
                    reportSection.collapsed = true
                }
            }
            currentSection.collapsed = !currentSection.collapsed
        }

        updateReportRows()
    }
}