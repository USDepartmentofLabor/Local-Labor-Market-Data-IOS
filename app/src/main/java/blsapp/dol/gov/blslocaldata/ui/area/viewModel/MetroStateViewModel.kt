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
import blsapp.dol.gov.blslocaldata.model.DataUtil
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

/**
 * ReportSection - Grouping of elements that make up a section of the Area Report
 */
data class ReportSection(
    var title: String?,
    private var _collapsed: Boolean,
    var  subIndustries: Boolean,
    var reportTypes: List<ReportType>?,
    var subSections : List<ReportSection>? = null) {

    var collapsed: Boolean
        get() {
            if (UIUtil.isTalkBackActive()) {
                return false
            }

            return _collapsed
        }
        set(value) {
            _collapsed = value
        }

}


/**
 * MetroStateViewModel - View Model for Metro, State, National Area Reports
 */
class MetroStateViewModel(application: Application) : AndroidViewModel(application), AreaViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment

    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()

    var localAreaReports: MutableList<AreaReport>? = null
    var nationalAreaReports = mutableListOf<AreaReport>()

    val repository: LocalRepository
    override var reportRows = MutableLiveData<List<AreaReportRow>>()

    var reportSections = listOf<ReportSection>(
            ReportSection(application.getString(R.string.unemployment_rate), false, false,
                    listOf(ReportType.Unemployment(LAUSReport.MeasureCode.UNEMPLOYMENT_RATE))),
            ReportSection(application.getString(R.string.industry_employment), true, true,
                    listOf(ReportType.IndustryEmployment("00000000", CESReport.DataTypeCode.ALLEMPLOYEES))),
            ReportSection(application.getString(R.string.occupational_employment_wages), true, true,
                    listOf(ReportType.OccupationalEmployment("000000", OESReport.DataTypeCode.ANNUALMEANWAGE))))

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

        isLoading.value = true

        doAsync{
            var reportTypes = mutableListOf<ReportType>()

            reportSections.forEach {
                it.reportTypes?.let {  reportTypes.addAll(it)}
            }

//        val reportTypes = reportSections.flatMap? {reportSection ->
//            reportSection.reportTypes
//        }
            ReportManager.getReport(mArea, reportTypes, adjustment = mAdjustment,
                    successHandler = {
                        //GGG-HISTORY
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
                    failureHandler = { it ->
                        isLoading.value = false
                        reportError.value = it
                    })
            updateReportRows()
        }
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
                                uiThread {
                                    isLoading.value = false
                                }
                            },
                            failureHandler = {

                            })
                }
            }
        }
    }

    private fun updateReportRows() {
        val rows = ArrayList<AreaReportRow>()

        reportSections.forEach{ reportSection ->
            var rowType = getRowType(reportSection)

            var reportType: ReportType? = null
            if (reportSection.reportTypes != null && reportSection.reportTypes!!.isNotEmpty()) {
                reportType = reportSection.reportTypes!![0]
            }

            rows.add(AreaReportRow(ReportRowType.HEADER, null, null,
                    header = reportSection.title,
                    reportType = reportType,
                    headerCollapsed = reportSection.collapsed,
                    subIndustries = reportSection.subIndustries,
                    headerType = rowType))

            if (!reportSection.collapsed) {
                val areaReports = localAreaReports?.filter { areaReport ->
                    reportSection.reportTypes?.let { reportTypes ->
                        areaReport.reportType in reportTypes
                    } ?: kotlin.run { false }
                }
                val nationalAreaReports = nationalAreaReports.filter { areaReport ->
                    reportSection.reportTypes?.let { reportTypes ->
                        areaReport.reportType in reportTypes
                    } ?: kotlin.run { false }
                }

                val areaType: Int
                if (mArea is NationalEntity)
                    areaType = R.string.national_area
                else if (mArea is StateEntity)
                    areaType = R.string.state_area
                else if (mArea is CountyEntity)
                    areaType = R.string.county_area
                else
                    areaType = R.string.metro_area

                rows.add(AreaReportRow(rowType,
                        getApplication<BLSApplication>().getString(areaType),
                        areaReports, header = null))
                val latestLocalData = areaReports?.firstOrNull()?.seriesReport?.latestData()
                if (nationalAreaReports.count() > 0) {
                    rows.add(AreaReportRow(rowType,
                            getApplication<BLSApplication>().getString(R.string.national_area),
                            nationalAreaReports,
                            period = latestLocalData?.period,
                            year = latestLocalData?.year,
                            header = null))

                }
                if (rowType == ReportRowType.INDUSTRY_EMPLOYMENT_ITEM && !(mArea is NationalEntity)) {
                    rows.add(AreaReportRow(ReportRowType.HISTORY_ITEM, null, null,
                            header = "History",
                            reportType = reportType,
                            headerCollapsed = reportSection.collapsed,
                            subIndustries = reportSection.subIndustries,
                            headerType = rowType))
                }
            }
        }

        reportRows.value = rows
    }

    private fun getRowType(reportSection: ReportSection): ReportRowType {
        var rowType: ReportRowType = ReportRowType.UNEMPLOYMENAT_RATE_ITEM
        when (reportSection.reportTypes?.first()) {
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

    override fun toggleSection(reportRow: AreaReportRow) {
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