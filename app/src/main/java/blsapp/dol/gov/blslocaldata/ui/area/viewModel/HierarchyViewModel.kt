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

/**
 * HierarchyViewModel - View Model for Industry Comparison View
 */

enum class SortStatus {
    NOT,
    ASCENDING,
    DESCENDING
}

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

    private var localValueSorted:SortStatus = SortStatus.NOT
    private var nationalValueSorted:SortStatus = SortStatus.NOT
    private var localOneMonthChangeSorted:SortStatus = SortStatus.NOT
    private var nationalOneMonthChangeSorted:SortStatus = SortStatus.NOT
    private var localTwelveMonthChangeSorted:SortStatus = SortStatus.NOT
    private var nationalTwelveMonthChangeSorted:SortStatus = SortStatus.NOT

    var localAreaReports: MutableList<AreaReport>? = null

    var periodName: String? = null
    var year: String? = null

    var areaTitle: String? = null
        get() = if (mArea is NationalEntity) getApplication<BLSApplication>().getString(R.string.national) else mArea.title

    var detailTitle:String = getApplication<BLSApplication>().getString(R.string.industries_title)
    var regionTitle:String? = getApplication<BLSApplication>().getString(R.string.metro)

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

    fun isIndustryReport(): Boolean {
        var retValue = false
        when (reportType) {
            is ReportType.IndustryEmployment -> {
                retValue = true;
            }
        }
        return retValue
    }
    fun isNationalArea(): Boolean {
        return (mArea is NationalEntity)
    }
    fun isStateArea(): Boolean {
        return (mArea is StateEntity)
    }
    fun isMetroArea(): Boolean {
        return (mArea is MetroEntity)
    }
    fun isCountyArea(): Boolean {
        return (mArea is CountyEntity)
    }

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
        if (periodName != null) {
            timeTitle = periodName!! + " "
        }
        if (year != null) {
            timeTitle = timeTitle + year!!
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
        if (mArea is NationalEntity) regionTitle = null
        else if (mArea is StateEntity) regionTitle =  getApplication<BLSApplication>().getString(R.string.state)
        else if (mArea is CountyEntity) regionTitle =  getApplication<BLSApplication>().getString(R.string.county)

        when (reportType) {

            is ReportType.IndustryEmployment -> {
                industryType = when (mArea) {
                    is NationalEntity -> IndustryType.CE_INDUSTRY
                    is StateEntity -> {
                        regionTitle = getApplication<BLSApplication>().getString(R.string.state)
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
                regionTitle = getApplication<BLSApplication>().getString(R.string.county)
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

    private fun resetSortStatuses() {
        localValueSorted = SortStatus.NOT
        nationalValueSorted = SortStatus.NOT
        localOneMonthChangeSorted = SortStatus.NOT
        nationalOneMonthChangeSorted = SortStatus.NOT
        localTwelveMonthChangeSorted = SortStatus.NOT
        nationalTwelveMonthChangeSorted = SortStatus.NOT
    }
    private fun completeSort(tmpList: List<HierarchyRow>?, sortStatus: SortStatus):SortStatus {
        val retSortStatusValue:SortStatus = if (sortStatus == SortStatus.ASCENDING) SortStatus.DESCENDING else SortStatus.ASCENDING
        if (tmpList != null && tmpList?.count() > 1 && hierarchyRows.value != null &&  hierarchyRows.value!!.count() > 0) {
            var sortedTmpList = tmpList?.toMutableList()
            if (retSortStatusValue == SortStatus.DESCENDING) {
                sortedTmpList = tmpList?.reversed()?.toMutableList()
            }
            sortedTmpList?.add(0,hierarchyRows.value!!.elementAt(0))
            hierarchyRows.postValue(sortedTmpList)
        }
        resetSortStatuses()
        return retSortStatusValue
    }

    private fun prepSort(): List<HierarchyRow>? {

        var tmpList: List<HierarchyRow>? = null
        if (hierarchyRows.value != null && hierarchyRows.value!!.count() > 1) {
            val count = hierarchyRows.value!!.count()
            tmpList = hierarchyRows.value!!.subList(1, count)
        }
        return tmpList
    }

    fun sortByLocalOneMonthPercentChangeValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.oneMonthPercent?.length },
                { it.oneMonthPercent }
        ))
        localOneMonthChangeSorted = completeSort(tmpList, localOneMonthChangeSorted)
        return localOneMonthChangeSorted
    }

    fun sortByNationalOneMonthPercentChangeValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.oneMonthNationalPercent?.length },
                { it.oneMonthNationalPercent }
        ))
        nationalOneMonthChangeSorted = completeSort(tmpList, nationalOneMonthChangeSorted)
        return nationalOneMonthChangeSorted
    }

    fun sortByLocalTwelveMonthPercentChangeValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.twelveMonthPercent?.length },
                { it.twelveMonthPercent }
        ))
        localTwelveMonthChangeSorted = completeSort(tmpList, localTwelveMonthChangeSorted)
        return localTwelveMonthChangeSorted
    }
    fun sortByNationalTwelveMonthPercentChangeValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.twelveMonthNationalPercent?.length },
                { it.twelveMonthNationalPercent }
        ))
        nationalTwelveMonthChangeSorted = completeSort(tmpList, nationalTwelveMonthChangeSorted)
        return nationalTwelveMonthChangeSorted
    }

    fun sortByLocalValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.localValue?.length },
                { it.localValue }
        ))
        localValueSorted = completeSort(tmpList, localValueSorted)
        return localValueSorted
    }
    fun sortByNationalValue():SortStatus {
        var tmpList= prepSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { it.nationalValue?.length },
                { it.nationalValue }
        ))
        nationalValueSorted = completeSort(tmpList, nationalValueSorted)
        return nationalValueSorted
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
                val mergeTitle = parentIndustryData.title + " (" + parentIndustryData.industryCode + ")"
                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        parentIndustryData,
                        parentIndustryData.id,
                        mergeTitle,
                        "N/A", "N/A",
                        "N/A", "N/A",
                        "N/A", "N/A",
                        "N/A", "N/A",
                        "N/A", "N/A",
                        false))
            }

            //var fetchedData = repository.getChildIndustries(parentIdLocal!!, industryType)
            var fetchedData = getChildren(parentIdLocal!!, industryType)

            fetchedData?.forEach{ industry ->
                val mergeTitle = industry.title
                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        industry,
                        industry.id,
                        mergeTitle,
                        "N/A", "N/A",
                        "N/A", "N/A",
                        "N/A", "N/A",
                        "N/A", "N/A",
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

                periodName = thisAreaRow.seriesReport!!.data[0].periodName
                year = thisAreaRow.seriesReport!!.data[0].year

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
                if (thisAreaRow.area is NationalEntity) {
                    thisIndustryRow.oneMonthNationalValue = DataUtil.changeValueStr(thisAreaRow.seriesReport!!.data[0].calculations?.netChanges?.oneMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR)
                    thisIndustryRow.twelveMonthNationalValue = DataUtil.changeValueStr(thisAreaRow.seriesReport!!.data[0].calculations?.netChanges?.twelveMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR)
                    thisIndustryRow.oneMonthNationalPercent = DataUtil.changeValueByPercent(thisAreaRow.seriesReport!!.data[0].calculations?.percentChanges?.oneMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR, "%")
                    thisIndustryRow.twelveMonthNationalPercent = DataUtil.changeValueByPercent(thisAreaRow.seriesReport!!.data[0].calculations?.percentChanges?.twelveMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR,"%")

                } else {
                    thisIndustryRow.oneMonthValue = DataUtil.changeValueStr(thisAreaRow.seriesReport!!.data[0].calculations?.netChanges?.oneMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR)
                    thisIndustryRow.twelveMonthValue = DataUtil.changeValueStr(thisAreaRow.seriesReport!!.data[0].calculations?.netChanges?.twelveMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR)
                    thisIndustryRow.oneMonthPercent = DataUtil.changeValueByPercent(thisAreaRow.seriesReport!!.data[0].calculations?.percentChanges?.oneMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR, "%")
                    thisIndustryRow.twelveMonthPercent = DataUtil.changeValueByPercent(thisAreaRow.seriesReport!!.data[0].calculations?.percentChanges?.twelveMonth ?: ReportManager.DATA_NOT_AVAILABLE_STR,"%")

                }
                if (mArea is NationalEntity)
                    thisIndustryRow.localValue = " "
                }
            }
        }

    }