package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.MutableLiveData

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.CountyEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import blsapp.dol.gov.blslocaldata.db.entity.StateEntity
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

/**
 * CountyAreaViewModel - Subclass of AreaViewModel for County Areas
 */

class CountyAreaViewModel(application: Application) : AndroidViewModel(application), AreaViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment
    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()

    var localAreaReports: MutableList<AreaReport>? = null
    var nationalAreaReports = mutableListOf<AreaReport>()

    override var historyLineGraphValues= mutableListOf<MutableList<Entry>>()
    override var historyBarGraphValues= mutableListOf<MutableList<BarEntry>>()
    override var historyTitleList= mutableListOf<String>()
    override var historyXAxisLabels= mutableListOf<String>()
    override var historyTableLabels= mutableListOf<String>()

    val repository: LocalRepository
    override var reportRows = MutableLiveData<List<AreaReportRow>>()

    var reportSections = listOf<ReportSection>(
            ReportSection( application.getString(R.string.unemployment_rate), false, false,
                    listOf(ReportType.Unemployment(LAUSReport.MeasureCode.UNEMPLOYMENT_RATE))),

            ReportSection(application.getString(R.string.employment_wages), true, false,
                    listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.TOTAL_COVERED,
                                    dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                            ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.TOTAL_COVERED,
                                    dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage)),

                    subSections =
                        listOf(
                                ReportSection(title = application.getString(R.string.ownership_private),
                        _collapsed = true, subIndustries = true, reportTypes =
                            listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.PRIVATE_OWNERSHIP,
                                    dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                            ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.PRIVATE_OWNERSHIP,
                                    dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),

                                ReportSection(title = application.getString(R.string.ownership_federal_govt),
                                _collapsed = true, subIndustries = true, reportTypes =
                        listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.FEDERAL_GOVT,
                                dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                                ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.FEDERAL_GOVT,
                                        dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),

                                ReportSection(title = application.getString(R.string.ownership_state_govt),
                                _collapsed = true, subIndustries = true, reportTypes =
                        listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.STATE_GOVT,
                                dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                                ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.STATE_GOVT,
                                        dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),

                                ReportSection(title = application.getString(R.string.ownership_local_govt),
                                _collapsed = true, subIndustries = true, reportTypes =
                        listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.LOCAL_GOVT,
                                dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                                ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.LOCAL_GOVT,
                                        dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage)))
                    )))

    init {
        repository = (application as BLSApplication).repository
    }


    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
        localAreaReports?.clear()
        nationalAreaReports.clear()
        getAreaReports()
    }

    override fun getAreaReports() {
        getLocalReports()
    }

    private fun getLocalReports() {

        doAsync{
            var reportTypes = ArrayList<ReportType>()

            reportSections.forEach { reportSection ->
                reportSection.reportTypes?.let {
                    reportTypes.addAll(it)
                }

                reportSection.subSections?.forEach {  subSection ->
                    subSection.reportTypes?.let {
                        reportTypes.addAll(it)
                    }
                }

            }

            uiThread {
                isLoading.value = true
            }
            ReportManager.getReport(mArea, reportTypes, adjustment = mAdjustment,
                    successHandler = {
                        localAreaReports = it.toMutableList()
                        updateReportRows()

                        // If current Area is not National, get National Data for comparison
                        if (mArea !is NationalEntity) {
                            getNationalReports()
                        } else {
                            uiThread {
                                isLoading.value = false
                            }
                        }
                    },
                    failureHandler = {
                        isLoading.value = false
                        reportError.value = it
                    })
            updateReportRows()

        }
    }

    override fun extractHistoryData() {

    }

    private fun getNationalReports() {
        reportSections.forEach { reportSection ->
            val localAreaReport = localAreaReports?.filter { areaReport -> areaReport.reportType == reportSection.reportTypes?.first() }?.firstOrNull()
            var startYear: String? = null
            localAreaReport?.seriesReport?.latestData()?.let { localReport ->
                startYear = localReport.year
            }
            reportSection.reportTypes?.let { reportTypes ->
                getNationalReports(reportTypes, startYear)
            }

            reportSection.subSections?.let { subSection ->
                val subReportTypes = subSection.flatMap { it.reportTypes!! }
                getNationalReports(reportTypes = subReportTypes, year = startYear)
            }

        }
    }

    private fun getNationalReports(reportTypes: List<ReportType>, year: String?) {
        doAsync{
            val nationalArea = repository.getNationalArea()
                    ReportManager.getReport(nationalArea,
                            reportTypes,
                            startYear = year,
                            endYear = year,
                            adjustment = mAdjustment,
                            successHandler = { areaReport ->
                                nationalAreaReports.addAll(areaReport)
                                updateReportRows()
                                uiThread {
                                    isLoading.value = false
                                }
                            },
                            failureHandler = {

                            })
        }

    }

    private fun updateReportRows() {
        val rows = updateReportRows(reportSections)
        reportRows.value = rows

    }

    private fun updateReportRows(sections: List<ReportSection>): List<AreaReportRow> {
        val rows = ArrayList<AreaReportRow>()

        sections.forEach { reportSection ->

            var rowType = getRowType(reportSection)

            reportSection.title?.let { title ->

                var reportType: ReportType? = null
                if (reportSection.reportTypes != null && reportSection.reportTypes!!.isNotEmpty()) {
                    reportType = reportSection.reportTypes!![0]
                }

                rows.add(AreaReportRow(ReportRowType.HEADER,null, null,
                        header = title, reportType = reportType, headerCollapsed = reportSection.collapsed,
                        subIndustries = reportSection.subIndustries, headerType = rowType))
            }
            if (!reportSection.collapsed) {
                reportSection.reportTypes?.let { reportTypes ->
                    val areaReports = localAreaReports?.filter { areaReport ->
                        areaReport.reportType in reportTypes
                    }
                    val nationalAreaReports = nationalAreaReports.filter { areaReport ->
                        areaReport.reportType in reportTypes
                    }

                    rows.add(AreaReportRow(rowType, getApplication<BLSApplication>().getString(R.string.county_area), areaReports, header = null))
                    val latestLocalData = areaReports?.firstOrNull()?.seriesReport?.latestData()
                    if (nationalAreaReports.filterNotNull().isNotEmpty()) {
                        rows.add(AreaReportRow(rowType, getApplication<BLSApplication>().getString(R.string.national_area),
                                nationalAreaReports,
                                period = latestLocalData?.period,
                                year = latestLocalData?.year,
                                header = null))
                    }
                }

                reportSection.subSections?.let {
                    val subRows = updateReportRows(it)
                    rows.add(AreaReportRow(ReportRowType.SUB_HEADER, areaType = null,
                            areaReports = null, header = null, subReportRows = subRows))
                }
            }
        }
        return rows
    }


    private fun getRowType(reportSection: ReportSection): ReportRowType {
        var rowType: ReportRowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
        val reportType = reportSection.reportTypes?.first()
        when (reportType) {
            is ReportType.Unemployment -> {
                rowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
            }
            is ReportType.IndustryEmployment -> {
                rowType = ReportRowType.INDUSTRY_EMPLOYMENT_ITEM
            }
            is ReportType.OccupationalEmployment -> {
                rowType = ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM
            }
            is ReportType.QuarterlyEmploymentWages -> {
                if (reportType.ownershipCode == QCEWReport.OwnershipCode.TOTAL_COVERED) {
                    rowType = ReportRowType.EMPLOYMENT_WAGES_ITEM
                } else {
                    rowType = ReportRowType.OWNERSHIP_EMPLOYMENT_WAGES_ITEM
                }
            }
        }

        return rowType
    }

    override fun toggleSection(reportRow: AreaReportRow) {
        toggleSection(reportRow, reportSections)
        updateReportRows()
    }

    fun toggleSection(reportRow: AreaReportRow, sections: List<ReportSection>) {
        if (reportRow.type != ReportRowType.HEADER) return

        sections.forEach {
            if (it.title == reportRow.header) {
                if (it.collapsed) {
                    for (reportSection in sections) {
                        reportSection.collapsed = true
                    }
                }
                it.collapsed = !it.collapsed
                return
            }
            else if(it.subSections != null) {
                toggleSection(reportRow, it.subSections!!)
            }
        }
    }
}