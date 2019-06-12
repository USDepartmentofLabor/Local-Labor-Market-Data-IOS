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
import org.jetbrains.anko.doAsync
import java.util.concurrent.Semaphore


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
    private val isLoadingSemaphore = Semaphore(1, true)

    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()
    override var hierarchyRows = MutableLiveData<List<HierarchyRow>>()
    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
    }

    private var codeSorted:SortStatus = SortStatus.ASCENDING
    private var localValueSorted:SortStatus = SortStatus.NOT
    private var nationalValueSorted:SortStatus = SortStatus.NOT
    private var localOneMonthChangeSorted:SortStatus = SortStatus.NOT
    private var nationalOneMonthChangeSorted:SortStatus = SortStatus.NOT
    private var localTwelveMonthChangeSorted:SortStatus = SortStatus.NOT
    private var nationalTwelveMonthChangeSorted:SortStatus = SortStatus.NOT

    var wageVsLevelTypeSelected: Int = 0

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

    private fun getDirectionMessage(sortStatus: SortStatus) : String {
        if (sortStatus == SortStatus.ASCENDING)
            return getApplication<BLSApplication>().getString(R.string.ascending)
        else
            return getApplication<BLSApplication>().getString(R.string.descending)
    }
    fun getSortedByMessage () : String{

        if (codeSorted != SortStatus.NOT)
            return getDirectionMessage(codeSorted)
        else if (localValueSorted != SortStatus.NOT)
            return getDirectionMessage(localValueSorted)
        else if (nationalValueSorted != SortStatus.NOT)
            return getDirectionMessage(nationalValueSorted)
        else if (localOneMonthChangeSorted != SortStatus.NOT)
            return getDirectionMessage(localOneMonthChangeSorted)
        else if (nationalOneMonthChangeSorted != SortStatus.NOT)
            return getDirectionMessage(nationalOneMonthChangeSorted)
        else if (localTwelveMonthChangeSorted != SortStatus.NOT)
            return getDirectionMessage(localTwelveMonthChangeSorted)
        else if (nationalTwelveMonthChangeSorted != SortStatus.NOT)
            return getDirectionMessage(nationalTwelveMonthChangeSorted)
        else
            return " "
    }

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
                detailTitle = getApplication<BLSApplication>().getString(R.string.occupations_title)
            }
            is ReportType.QuarterlyEmploymentWages -> {
                industryType = IndustryType.QCEW_INDUSTRY
                detailTitle = getApplication<BLSApplication>().getString(R.string.occupations_title)
                regionTitle = getApplication<BLSApplication>().getString(R.string.county)
            }
        }
    }
    fun getWageVsLevelTitles(): MutableList<String>? {
        var retArray:MutableList<String>? = null
        when (reportType) {
            is OccupationalEmployment -> {
                retArray = mutableListOf(
                        getApplication<BLSApplication>().getString(R.string.mean_annual_wage),
                        getApplication<BLSApplication>().getString(R.string.employment_level))
            }
            is ReportType.QuarterlyEmploymentWages -> {
                retArray = mutableListOf(
                        getApplication<BLSApplication>().getString(R.string.employment_level),
                        getApplication<BLSApplication>().getString(R.string.average_weekly_wage_accessible))
            }
        }
        return retArray
    }

    fun setWageVsLevelIndex(wageVsLevelType: Int) {
        when (wageVsLevelType) {
            0 -> {
                if (reportType is ReportType.QuarterlyEmploymentWages)
                    this.QCEWwageVsLevelTypeOccupation = QCEWReport.DataTypeCode.allEmployees
                else
                    this.wageVsLevelTypeOccupation = OESReport.DataTypeCode.ANNUALMEANWAGE
            }
            1 -> {
                if (reportType is ReportType.QuarterlyEmploymentWages)
                    this.QCEWwageVsLevelTypeOccupation = QCEWReport.DataTypeCode.avgWeeklyWage
                else
                    this.wageVsLevelTypeOccupation = OESReport.DataTypeCode.EMPLOYMENT
            }
        }
        wageVsLevelTypeSelected = wageVsLevelType
    }

    override fun toggleSection(reportRow: HierarchyRow) {

    }

    override fun getIndustryReports() {

        isLoading.value = true
        loadReportCategories()
    }

    private fun resetSortStatuses() {
        codeSorted = SortStatus.NOT
        localValueSorted = SortStatus.NOT
        nationalValueSorted = SortStatus.NOT
        localOneMonthChangeSorted = SortStatus.NOT
        nationalOneMonthChangeSorted = SortStatus.NOT
        localTwelveMonthChangeSorted = SortStatus.NOT
        nationalTwelveMonthChangeSorted = SortStatus.NOT
    }

    private fun toggleSortStatus(status:SortStatus):SortStatus {
        var retStatus = status
        if (retStatus != SortStatus.NOT) {
            retStatus = if (retStatus == SortStatus.ASCENDING) SortStatus.DESCENDING else SortStatus.ASCENDING
        }
        return retStatus
    }

    private fun sortByCurrentStatus() {
        if (codeSorted != SortStatus.NOT) {
            codeSorted = toggleSortStatus(codeSorted)
            sortByCode()

        } else if (localValueSorted != SortStatus.NOT) {
            localValueSorted = toggleSortStatus(localValueSorted)
            sortByLocalValue()

        }else if (nationalValueSorted != SortStatus.NOT) {
            nationalValueSorted = toggleSortStatus(nationalValueSorted)
            sortByNationalValue()

        }else if (localOneMonthChangeSorted != SortStatus.NOT) {
            localOneMonthChangeSorted = toggleSortStatus(localOneMonthChangeSorted)
            sortByLocalOneMonthPercentChangeValue()

        }else if (nationalOneMonthChangeSorted != SortStatus.NOT) {
            nationalOneMonthChangeSorted = toggleSortStatus(nationalOneMonthChangeSorted)
            sortByNationalOneMonthPercentChangeValue()

        }else if (localTwelveMonthChangeSorted != SortStatus.NOT) {
            localTwelveMonthChangeSorted = toggleSortStatus(localTwelveMonthChangeSorted)
            sortByLocalTwelveMonthPercentChangeValue()

        }else if (nationalTwelveMonthChangeSorted != SortStatus.NOT) {
            nationalTwelveMonthChangeSorted = toggleSortStatus(nationalTwelveMonthChangeSorted)
            sortByNationalTwelveMonthPercentChangeValue()
        }
    }

    private fun preSort(): List<HierarchyRow>? {

        var tmpList: List<HierarchyRow>? = null
        if (hierarchyRows.value != null && hierarchyRows.value!!.count() > 1) {
            val count = hierarchyRows.value!!.count()
            tmpList = hierarchyRows.value!!.subList(1, count)
        }
        return tmpList
    }

    private fun postSort(tmpList: List<HierarchyRow>?, sortStatus: SortStatus):SortStatus {
        val retSortStatusValue:SortStatus = if (sortStatus == SortStatus.ASCENDING) SortStatus.DESCENDING else SortStatus.ASCENDING
        if (tmpList != null && tmpList.count() > 1 && hierarchyRows.value != null &&  hierarchyRows.value!!.count() > 0) {
            var sortedTmpList = tmpList.toMutableList()
            if (retSortStatusValue == SortStatus.DESCENDING) {
                sortedTmpList = tmpList.reversed().toMutableList()
            }
            sortedTmpList.add(0,hierarchyRows.value!!.elementAt(0))
            hierarchyRows.postValue(sortedTmpList)
        } else {
            hierarchyRows.postValue(hierarchyRows.value)
        }
        resetSortStatuses()
        return retSortStatusValue
    }

    fun convertToFloat(string: String, sortStatus: SortStatus):Float {
        val retSortStatusValue:SortStatus = if (sortStatus == SortStatus.ASCENDING) SortStatus.DESCENDING else SortStatus.ASCENDING
        var newString = string.replace("%","",true)
        newString =newString.replace("$","",true)
        newString =newString.replace("£","",true)
        newString =newString.replace("+","",true)
        newString =newString.replace(",","",true)
        if (retSortStatusValue == SortStatus.DESCENDING) {
            newString = newString.replace("N/A", "0", true)
            newString = newString.replace("ND", "0", true)
        } else {
            newString = newString.replace("N/A", "1000000000", true)
            newString = newString.replace("ND", "1000000000", true)
        }
        newString =newString.replace(" ","",true)
        if (newString == null || newString.length < 1)
            newString = "0"
        return newString.toFloat()
    }

    fun sortByLocalOneMonthPercentChangeValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.oneMonthPercent, localOneMonthChangeSorted) }
        ))
        localOneMonthChangeSorted = postSort(tmpList, localOneMonthChangeSorted)
        return localOneMonthChangeSorted
    }

    fun sortByNationalOneMonthPercentChangeValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.oneMonthNationalPercent, nationalOneMonthChangeSorted) }
        ))
        nationalOneMonthChangeSorted = postSort(tmpList, nationalOneMonthChangeSorted)
        return nationalOneMonthChangeSorted
    }

    fun sortByLocalTwelveMonthPercentChangeValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.twelveMonthPercent,localTwelveMonthChangeSorted) }
        ))
        localTwelveMonthChangeSorted = postSort(tmpList, localTwelveMonthChangeSorted)
        return localTwelveMonthChangeSorted
    }
    fun sortByNationalTwelveMonthPercentChangeValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.twelveMonthNationalPercent, nationalTwelveMonthChangeSorted) }
        ))
        nationalTwelveMonthChangeSorted = postSort(tmpList, nationalTwelveMonthChangeSorted)
        return nationalTwelveMonthChangeSorted
    }

    fun sortByCode():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.industry!!.industryCode, codeSorted) }
        ))
        codeSorted = postSort(tmpList, codeSorted)
        return codeSorted
    }

    fun sortByLocalValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.localValue, localValueSorted) }
        ))
        localValueSorted = postSort(tmpList, localValueSorted)
        return localValueSorted
    }
    fun sortByNationalValue():SortStatus {
        var tmpList= preSort()
        tmpList = tmpList?.sortedWith(compareBy(
                { convertToFloat(it.nationalValue, nationalValueSorted) }
        ))
        nationalValueSorted = postSort(tmpList, nationalValueSorted)
        return nationalValueSorted
    }

    private fun loadReportCategories() {
        if (!isLoadingSemaphore.tryAcquire())
            return

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
                val mergeTitle = parentIndustryData.title + " (" + this.reportType.getNormalizedCode(parentIndustryData.industryCode) + ")"


                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        parentIndustryData,
                        parentIndustryData.id,
                        mergeTitle,
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        false))
            }

            //var fetchedData = repository.getChildIndustries(parentIdLocal!!, industryType)
            var fetchedData = getChildren(parentIdLocal, industryType)

            fetchedData?.forEach{ industry ->

                var mergeTitle = industry.title
                if (!this.isCountyArea()) {
                    mergeTitle = industry.title + " (" + this.reportType.getNormalizedCode(industry.industryCode) + ")"
                }

                rows.add(HierarchyRow(HierarchyRowType.ITEM,
                        industry,
                        industry.id,
                        mergeTitle,
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        " ", " ",
                        industry.superSector))
            }
            hierarchyRows.postValue(rows)

            if (mArea is NationalEntity)
                getNationalReports(rows)
            else
                getLocalReports(rows)

            isLoadingSemaphore.release()
        }
    }

    private fun getChildren(parentId: Long, industryType: IndustryType) : List<IndustryEntity>? {

        var retChildren: List<IndustryEntity>?

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
                is OccupationalEmployment -> {
                    retReportTypes.add(OccupationalEmployment(it.industry!!.industryCode, wageVsLevelTypeOccupation))
                }
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

        var startYear: String? = null
        if  (this.year != null) {
            startYear = this.year
        }
        doAsync {
            reportTypes = getReportTypesArray(hierarchyRows)

            ReportManager.getReport(mArea, reportTypes!!,
                    startYear = startYear,
                    endYear = startYear,
                    adjustment = mAdjustment,
                    annualAvg = true,
                    successHandler = {
                        localAreaReports = it.toMutableList()
                        updateIndustryRows(it, hierarchyRows)

                        getNationalReports(hierarchyRows)
                        //this.hierarchyRows.postValue(hierarchyRows)
                    },
                    failureHandler = { it ->
                        isLoading.postValue(false)
                        reportError.value = it
                    })
        }
    }

    private fun getNationalReports(hierarchyRows: ArrayList<HierarchyRow>) {

        var natReportTypes = getReportTypesArray(hierarchyRows)

        val localAreaReport = localAreaReports?.filter { areaReport ->
            areaReport.reportType == reportTypes?.first() }?.firstOrNull()
        var startYear: String? = null

        localAreaReport?.seriesReport?.latestAnnualData()?.let { localReport ->
            startYear = localReport.year
        }
        if  (this.isCountyArea()) {
            startYear = null
        }
        if  (this.year != null) {
            startYear = this.year
        }

        doAsync {
            ReportManager.getReport(nationalArea!!,
                    natReportTypes,
                    startYear = startYear,
                    endYear = startYear,
                    adjustment = mAdjustment,
                    annualAvg =  true,
                    successHandler = {
                        isLoading.postValue(false)
                        updateIndustryRows(it, hierarchyRows)
                        sortByCurrentStatus()
                        //this.hierarchyRows.postValue(hierarchyRows)
                    },
                    failureHandler = { it ->
                        isLoading.postValue(false)
                        reportError.value = it
                    })

        }
    }

    private fun updateIndustryRows(areaReport: List<AreaReport>, hierarchyRows: ArrayList<HierarchyRow>) {

        for (i in areaReport.indices) {
            val thisAreaRow = areaReport[i]

            val thisIndustryRow = hierarchyRows[i]

            setDefaultNAs(thisIndustryRow)
            if  (thisAreaRow.seriesReport != null && thisAreaRow.seriesReport!!.data.isNotEmpty()) {

                var thisAreaRowData = thisAreaRow.seriesReport!!.data[0]
                if (this.isCountyArea()) {
                    thisAreaRow.seriesReport?.latestAnnualData()?.let { localReport ->

                        //  if  (localReport.period != "M13") return
                        thisAreaRowData = localReport
                    }
                }

                if (periodName == null) {
                    periodName = thisAreaRowData.periodName
                }
                year = thisAreaRowData.year

                if (wageVsLevelTypeOccupation == OESReport.DataTypeCode.ANNUALMEANWAGE ||
                        QCEWwageVsLevelTypeOccupation == QCEWReport.DataTypeCode.avgWeeklyWage) {
                    if (thisAreaRow.area is NationalEntity)
                        thisIndustryRow.nationalValue = DataUtil.currencyValue(thisAreaRowData.value)
                    else
                        thisIndustryRow.localValue = DataUtil.currencyValue(thisAreaRowData.value)
                } else {

                    if (thisAreaRow.area is NationalEntity)
                        thisIndustryRow.nationalValue = DataUtil.numberValue(thisAreaRowData.value)
                    else
                        thisIndustryRow.localValue = DataUtil.numberValue(thisAreaRowData.value)
                }

                if (thisAreaRow.area is NationalEntity) {
                    thisIndustryRow.oneMonthNationalValue = DataUtil.changeValueStr(thisAreaRowData.calculations?.netChanges?.oneMonth)
                    thisIndustryRow.twelveMonthNationalValue = DataUtil.changeValueStr(thisAreaRowData.calculations?.netChanges?.twelveMonth)
                    thisIndustryRow.oneMonthNationalPercent = DataUtil.changeValueByPercent(thisAreaRowData.calculations?.percentChanges?.oneMonth, "%")
                    thisIndustryRow.twelveMonthNationalPercent = DataUtil.changeValueByPercent(thisAreaRowData.calculations?.percentChanges?.twelveMonth, "%")

                } else {
                    thisIndustryRow.oneMonthValue = DataUtil.changeValueStr(thisAreaRowData.calculations?.netChanges?.oneMonth)
                    thisIndustryRow.twelveMonthValue = DataUtil.changeValueStr(thisAreaRowData.calculations?.netChanges?.twelveMonth)
                    thisIndustryRow.oneMonthPercent = DataUtil.changeValueByPercent(thisAreaRowData.calculations?.percentChanges?.oneMonth, "%")
                    thisIndustryRow.twelveMonthPercent = DataUtil.changeValueByPercent(thisAreaRowData.calculations?.percentChanges?.twelveMonth, "%")

                }
                if (mArea is NationalEntity)
                    thisIndustryRow.localValue = " "

                if (thisAreaRowData.footnotes != null && thisAreaRowData.footnotes!![0].code.equals("ND")) {
                    thisIndustryRow.localValue = "ND"
                    thisIndustryRow.nationalValue = "ND"
                    thisIndustryRow.oneMonthValue = "ND"
                    thisIndustryRow.twelveMonthValue = "ND"
                    thisIndustryRow.oneMonthPercent = "ND"
                    thisIndustryRow.twelveMonthPercent = "ND"
                    thisIndustryRow.oneMonthNationalValue = "ND"
                    thisIndustryRow.twelveMonthNationalValue ="ND"
                    thisIndustryRow.oneMonthNationalPercent = "ND"
                    thisIndustryRow.twelveMonthNationalPercent = "ND"
                }
            }
        }
    }

    private fun setDefaultNAs(thisRow: HierarchyRow) {
        thisRow.localValue = if (thisRow.localValue == " ") "N/A" else thisRow.localValue
        thisRow.nationalValue =  if (thisRow.nationalValue == " ") "N/A" else thisRow.nationalValue
        thisRow.oneMonthValue =  if (thisRow.oneMonthValue == " ") "N/A" else thisRow.oneMonthValue
        thisRow.twelveMonthValue =  if (thisRow.twelveMonthValue == " ") "N/A" else thisRow.twelveMonthValue
        thisRow.oneMonthPercent =  if (thisRow.oneMonthPercent == " ") "N/A" else thisRow.oneMonthPercent
        thisRow.twelveMonthPercent =  if (thisRow.twelveMonthPercent == " ") "N/A" else thisRow.twelveMonthPercent
        thisRow.oneMonthNationalValue =  if (thisRow.oneMonthNationalValue == " ") "N/A" else thisRow.oneMonthNationalValue
        thisRow.twelveMonthNationalValue = if (thisRow.twelveMonthNationalValue == " ") "N/A" else thisRow.twelveMonthNationalValue
        thisRow.oneMonthNationalPercent =  if (thisRow.oneMonthNationalPercent == " ") "N/A" else thisRow.oneMonthNationalPercent
        thisRow.twelveMonthNationalPercent =  if (thisRow.twelveMonthNationalPercent == " ") "N/A" else thisRow.twelveMonthNationalPercent
    }
}