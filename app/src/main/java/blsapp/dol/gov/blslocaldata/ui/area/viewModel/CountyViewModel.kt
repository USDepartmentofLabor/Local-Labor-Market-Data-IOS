package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.MutableLiveData

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.ui.area.ReportRow
import blsapp.dol.gov.blslocaldata.ui.area.ReportRowType
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import org.jetbrains.anko.doAsync


class CountyViewModel(application: Application) : AndroidViewModel(application), AreaViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment
    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()

    var localAreaReports: MutableList<AreaReport>? = null
    var nationalAreaReports = mutableListOf<AreaReport>()

    val repository: LocalRepository
    override var reportRows = MutableLiveData<List<ReportRow>>()

    var reportSections = listOf<ReportSection>(
            ReportSection("Unemployment Rate", false,
                    listOf(ReportType.Unemployment(LAUSReport.MeasureCode.UNEMPLOYMENT_RATE))),
            ReportSection("Employment & Wages", true,
                    listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.TOTAL_COVERED,
                                    dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                            ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.TOTAL_COVERED,
                                    dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage)), subSections =
                listOf(ReportSection(title = "Private", collapsed = true, reportTypes =
                            listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.PRIVATE_OWNERSHIP,
                                    dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                            ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.PRIVATE_OWNERSHIP,
                                    dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),
                        ReportSection(title = "Federal Government", collapsed = true, reportTypes =
                        listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.FEDERAL_GOVT,
                                dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                                ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.FEDERAL_GOVT,
                                        dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),
                        ReportSection(title = "State Government", collapsed = true, reportTypes =
                        listOf(ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.STATE_GOVT,
                                dataTypeCode = QCEWReport.DataTypeCode.allEmployees),
                                ReportType.QuarterlyEmploymentWages(QCEWReport.OwnershipCode.STATE_GOVT,
                                        dataTypeCode = QCEWReport.DataTypeCode.avgWeeklyWage))),
                        ReportSection(title = "Local Government", collapsed = true, reportTypes =
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
        getReports()
    }

    override fun getReports() {
        getLocalReports()
    }

    private fun getLocalReports() {
        var reportTypes = ArrayList<ReportType>()

        reportSections.forEach { reportSection ->
            reportSection?.reportTypes?.let {
                reportTypes.addAll(it)
            }

            reportSection.subSections?.forEach {  subSection ->
                subSection?.reportTypes?.let {
                    reportTypes.addAll(it)
                }
            }

        }

        isLoading.value = true
        ReportManager.getReport(mArea, reportTypes, adjustment = mAdjustment,
                successHandler = {
                    isLoading.value = false
                    localAreaReports = it.toMutableList()
                    updateReportRows()

                    // If current Area is not National, get National Data for comparison
                    if (mArea !is NationalEntity) {
                        getNationalReports()
                    }
                },
                failureHandler = {
                    isLoading.value = false
                    reportError.value = it
                })
        updateReportRows()
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

            reportSection.subSections?.let { reportSection ->
                val subReportTypes = reportSection?.flatMap { it.reportTypes!! }
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
                            },
                            failureHandler = {

                            })
        }

    }

    private fun updateReportRows() {
        val rows = updateReportRows(reportSections)
        reportRows.value = rows

    }

    private fun updateReportRows(sections: List<ReportSection>): List<ReportRow> {
        val rows = ArrayList<ReportRow>()

        sections.forEach { reportSection ->
            reportSection.title?.let { title ->
                rows.add(ReportRow(ReportRowType.HEADER, null, null, header = title, headerCollapsed = reportSection.collapsed))
            }
            if (!reportSection.collapsed) {
                reportSection.reportTypes?.let { reportTypes ->
                    val areaReports = localAreaReports?.filter { areaReport ->
                        areaReport.reportType in reportTypes
                    }
                    val nationalAreaReports = nationalAreaReports?.filter { areaReport ->
                        areaReport.reportType in reportTypes
                    }

                    var rowType = getRowType(areaReports)
                    rows.add(ReportRow(rowType, "Local Area", areaReports, header = null))
                    val latestLocalData = areaReports?.firstOrNull()?.seriesReport?.latestData()
                    if (nationalAreaReports.filterNotNull().isNotEmpty()) {
                        rows.add(ReportRow(rowType, "National Area", nationalAreaReports,
                                period = latestLocalData?.period,
                                year = latestLocalData?.year,
                                header = null))
                    }
                }

                reportSection.subSections?.let {
                    val subRows = updateReportRows(it)
                    rows.add(ReportRow(ReportRowType.SUB_HEADER, areaType = null,
                            areaReports = null, header = null, subReportRows = subRows))
                }
            }
        }
        return rows
    }



    private fun getRowType(areaReports: List<AreaReport>?): ReportRowType {
        var rowType: ReportRowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
        val reportType = areaReports?.firstOrNull()?.reportType
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

    override fun toggleSection(reportRow: ReportRow) {
        toggleSection(reportRow, reportSections)
        updateReportRows()
    }

    fun toggleSection(reportRow: ReportRow, sections: List<ReportSection>) {
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