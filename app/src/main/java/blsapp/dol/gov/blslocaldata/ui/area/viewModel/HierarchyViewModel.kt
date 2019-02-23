package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.MutableLiveData

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.dao.IndustryType
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ioThread
import blsapp.dol.gov.blslocaldata.model.DataUtil
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.model.reports.ReportType.OccupationalEmployment
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.HierarchyBaseViewModel
import kotlinx.android.synthetic.main.industry_item.view.*

/**
 * HierarchyViewModel - View Model for Industry Comparison View
 */

class HierarchyViewModel(application: Application) : AndroidViewModel(application), HierarchyBaseViewModel {

    override lateinit var mArea: AreaEntity
    override lateinit var mAdjustment: SeasonalAdjustment

    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()
    override var hierarchyRows = MutableLiveData<List<HierarchyRow>>()
    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
        loadReportCategories()
    }

    var localAreaReports: MutableList<AreaReport>? = null

    var areaTitle: String? = null
        get() = mArea.title

    var detailTitle:String = getApplication<BLSApplication>().getString(R.string.industries_title)
    var column1Title:String? = getApplication<BLSApplication>().getString(R.string.metro)
    var column2Title:String = getApplication<BLSApplication>().getString(R.string.national)

    var accessibilityStr: String? = null
        get() = mArea.accessibilityStr

    private val repository: LocalRepository = (application as BLSApplication).repository
    private var nationalArea: NationalEntity? = null
    private lateinit var reportType: ReportType
    private var reportTypes: MutableList<ReportType>? = null
    private var parentId: Long = -1
    private var industryType: IndustryType = IndustryType.CE_INDUSTRY
    private var wageVsLevelTypeOccupation: OESReport.DataTypeCode = OESReport.DataTypeCode.EMPLOYMENT
    private var QCEWwageVsLevelTypeOccupation: QCEWReport.DataTypeCode = QCEWReport.DataTypeCode.allEmployees

    fun getOwnershipTitle(): String {
        var ownTitle = " "
        if (this.reportType is ReportType.QuarterlyEmploymentWages) {
            val reportTypeQCEW: ReportType.QuarterlyEmploymentWages = reportType as ReportType.QuarterlyEmploymentWages
            ownTitle = QCEWReport.getOwnershipTitle(reportTypeQCEW.ownershipCode)
        }
        return ownTitle
    }

    fun getTimePeriodTitle(): String {
        var timeTitle = " "
        val localAreaReport = localAreaReports?.filter { areaReport ->
            areaReport.reportType == reportTypes?.first() }?.firstOrNull()
        localAreaReport?.seriesReport?.latestData()?.let { localReport ->
            timeTitle = localReport.periodName + " " + localReport.year
        }
        return timeTitle
    }

    fun getWageVsLevelTitles(): MutableList<String>? {
        var retArray:MutableList<String>? = null
        when (reportType) {
            is OccupationalEmployment -> {
                retArray = mutableListOf(
                        getApplication<BLSApplication>().getString(R.string.employment_level),
                        getApplication<BLSApplication>().getString(R.string.mean_annual_wage))
            }
            is ReportType.QuarterlyEmploymentWages -> {
                retArray = mutableListOf(
                        getApplication<BLSApplication>().getString(R.string.employment_level),
                        getApplication<BLSApplication>().getString(R.string.average_weekly_wage))
            }
        }
        return retArray
    }

    fun setParentId(originalInput: Long) {
        parentId = originalInput
    }

    fun setReportType(reportType: ReportType) {

        this.reportType = reportType
        if (mArea is NationalEntity) column1Title = null

        when (reportType) {

            is ReportType.IndustryEmployment -> {
                industryType = when (mArea) {
                    is NationalEntity -> IndustryType.CE_INDUSTRY
                    is StateEntity -> {
                        column1Title = getApplication<BLSApplication>().getString(R.string.state)
                        IndustryType.SM_INDUSTRY
                    }
                    else -> IndustryType.SM_INDUSTRY
                }
            }
            is OccupationalEmployment -> {
                industryType = IndustryType.OE_OCCUPATION
                detailTitle = getApplication<BLSApplication>().getString(R.string.occupation_title)
            }
            is ReportType.QuarterlyEmploymentWages -> {
                industryType = IndustryType.QCEW_INDUSTRY
                detailTitle = getApplication<BLSApplication>().getString(R.string.occupation_title)
                column1Title = getApplication<BLSApplication>().getString(R.string.county)
            }
        }
    }

    fun setWageVsLevelIndex(wageVsLevelType: Int) {
        when (wageVsLevelType) {
            0 -> {
                if (reportType is ReportType.QuarterlyEmploymentWages)
                    this.QCEWwageVsLevelTypeOccupation = QCEWReport.DataTypeCode.allEmployees
                else
                    this.wageVsLevelTypeOccupation = OESReport.DataTypeCode.EMPLOYMENT
            }
            1 -> {
                if (reportType is ReportType.QuarterlyEmploymentWages)
                    this.QCEWwageVsLevelTypeOccupation = QCEWReport.DataTypeCode.avgWeeklyWage
                else
                    this.wageVsLevelTypeOccupation = OESReport.DataTypeCode.ANNUALMEANWAGE
            }
        }
    }

    override fun toggleSection(reportRow: HierarchyRow) {

    }

    override fun getIndustryReports() {

        isLoading.value = true
        loadReportCategories()
    }

    fun sortByColumn1() {
        var tmpList = hierarchyRows.value
        hierarchyRows.postValue(tmpList?.sortedWith(compareBy(
                { it.localValue?.length },
                { it.localValue }
        )))
    }
    fun sortByColumn2() {
        var tmpList = hierarchyRows.value
        hierarchyRows.postValue(tmpList?.sortedWith(compareBy(
                { it.nationalValue?.length },
                { it.nationalValue }
        )))
    }

    private fun loadReportCategories() {
        ioThread {

            nationalArea = repository.getNationalArea()

            val rows = ArrayList<HierarchyRow>()
            var parentIdLocal = parentId
            var parentIndustryData: IndustryEntity? = null

            if (parentIdLocal == -1L) {
               // var baseParentIndustries = repository.getChildIndustries(parentCode = parentIdLocal, industryType = industryType)
                var baseParentIndustries = getChildren(parentIdLocal, industryType)

                if  (baseParentIndustries != null && baseParentIndustries.isNotEmpty()) {
                    parentIndustryData = baseParentIndustries.get(0)
                    if (parentIndustryData.id != null) parentIdLocal = parentIndustryData.id!!
                }

            } else {
                parentIndustryData = repository.getIndustry(parentIdLocal)
            }

            if (parentIndustryData != null) {
                val mergeTitle = parentIndustryData.title
                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        parentIndustryData,
                        parentIndustryData.id,
                        mergeTitle,
                        "N/A", "N/A",
                        false))
            }

            //var fetchedData = repository.getChildIndustries(parentIdLocal!!, industryType)
            var fetchedData = getChildren(parentIdLocal!!, industryType)

            fetchedData?.forEach{ industry ->
                val mergeTitle = industry.title + " (" + industry.industryCode + ")"
                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        industry,
                        industry.id,
                        mergeTitle,
                        "N/A", "N/A",
                        industry.superSector))
            }
            hierarchyRows.postValue(rows)

            if (mArea is NationalEntity)
                getNationalReports(rows)
            else
                getLocalReports(rows)

        }
    }

    private fun getChildren(parentId: Long, industryType: IndustryType) : List<IndustryEntity>? {

        var retChildren: List<IndustryEntity>? = null

        if (reportType is OccupationalEmployment &&
                !(mArea is NationalEntity) &&
                this.parentId >= 0) {
            retChildren = repository.getChildLeafIndustries(parentId, industryType)
        } else
            retChildren = repository.getChildIndustries(parentId, industryType)

        return retChildren
    }

    private fun getReportTypesArray(hierarchyRows: ArrayList<HierarchyRow>): MutableList<ReportType> {

        var retReportTypes = mutableListOf<ReportType>()
        hierarchyRows.forEach {

            when (reportType) {
                is ReportType.IndustryEmployment ->
                    retReportTypes.add(ReportType.IndustryEmployment(it.industry!!.industryCode, CESReport.DataTypeCode.ALLEMPLOYEES))
                is OccupationalEmployment ->
                    retReportTypes.add(OccupationalEmployment(it.industry!!.industryCode, wageVsLevelTypeOccupation))
                is ReportType.QuarterlyEmploymentWages -> {
                    val reportTypeQCEW: ReportType.QuarterlyEmploymentWages = this.reportType as ReportType.QuarterlyEmploymentWages
                    retReportTypes.add(ReportType.OccupationalEmploymentQCEW(
                            reportTypeQCEW.ownershipCode,
                            it.industry!!.industryCode,
                            QCEWReport.EstablishmentSize.ALL,
                            QCEWwageVsLevelTypeOccupation))
                }
            }
        }
        return retReportTypes
    }

    private fun getLocalReports(hierarchyRows: ArrayList<HierarchyRow>) {

        reportTypes = getReportTypesArray(hierarchyRows)

        ReportManager.getReport(mArea, reportTypes!!, adjustment = mAdjustment,
                successHandler = {
                    isLoading.postValue(false)
                    localAreaReports = it.toMutableList()
                    updateIndustryRows(it, hierarchyRows)

                    getNationalReports(hierarchyRows)

                    this.hierarchyRows.postValue(hierarchyRows)
                },
                failureHandler = { it ->
                    isLoading.postValue(false)
                    reportError.value = it
                })
    }

    private fun getNationalReports(hierarchyRows: ArrayList<HierarchyRow>) {

        var natReportTypes = getReportTypesArray(hierarchyRows)

        val localAreaReport = localAreaReports?.filter { areaReport ->
            areaReport.reportType == reportTypes?.first() }?.firstOrNull()
        var startYear: String? = null
        localAreaReport?.seriesReport?.latestData()?.let { localReport ->
            startYear = localReport.year
        }

        ReportManager.getReport(nationalArea!!,
                natReportTypes,
                startYear = startYear,
                endYear = startYear,
                adjustment = mAdjustment,
                successHandler = {
                    isLoading.postValue(false)
                    updateIndustryRows(it, hierarchyRows)

                    this.hierarchyRows.postValue(hierarchyRows)
                },
                failureHandler = { it ->
                    isLoading.postValue(false)
                    reportError.value = it
                })
    }

    private fun updateIndustryRows(areaReport: List<AreaReport>, hierarchyRows: ArrayList<HierarchyRow>) {

        for (i in areaReport.indices) {
            val thisAreaRow = areaReport[i]
            val thisIndustryRow = hierarchyRows[i]
            if  (thisAreaRow.seriesReport != null && thisAreaRow.seriesReport!!.data.isNotEmpty()) {
                if (wageVsLevelTypeOccupation == OESReport.DataTypeCode.ANNUALMEANWAGE ||
                        QCEWwageVsLevelTypeOccupation == QCEWReport.DataTypeCode.avgWeeklyWage) {
                    if (thisAreaRow.area is NationalEntity)
                        thisIndustryRow.nationalValue = DataUtil.currencyValue(thisAreaRow.seriesReport!!.data[0].value)
                    else
                        thisIndustryRow.localValue = DataUtil.currencyValue(thisAreaRow.seriesReport!!.data[0].value)
                } else {

                    if (thisAreaRow.area is NationalEntity)
                        thisIndustryRow.nationalValue = DataUtil.numberValue(thisAreaRow.seriesReport!!.data[0].value)
                    else
                        thisIndustryRow.localValue = DataUtil.numberValue(thisAreaRow.seriesReport!!.data[0].value)
                }
                if (mArea is NationalEntity) {
                    thisIndustryRow.localValue = " "
                }
            }
        }

    }
}