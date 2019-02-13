package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.MutableLiveData
import android.util.Log

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.dao.IndustryType
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ioThread
import blsapp.dol.gov.blslocaldata.model.DataUtil
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.services.FetchAddressIntentService
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.IndustryBaseViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType.INDUSTRY_EMPLOYMENT_ITEM
import org.jetbrains.anko.doAsync

class IndustryViewModel(application: Application) : AndroidViewModel(application), IndustryBaseViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment

    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()

    private val repository: LocalRepository = (application as BLSApplication).repository
    private var nationalArea: NationalEntity? = null

    override var industryRows = MutableLiveData<List<IndustryRow>>()

    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
        loadReportCategories()
    }

    private var parentId: Long? =  null
    private var industryType: IndustryType = IndustryType.CE_INDUSTRY

    fun setParentId(originalInput: Long?) {
        parentId = originalInput
    }

    fun setReportType(reportType: ReportRowType?) {
        when (reportType!!.ordinal) {
            ReportRowType.INDUSTRY_EMPLOYMENT_ITEM.ordinal -> {
                when (mArea) {
                    is NationalEntity -> {
                        industryType = IndustryType.CE_INDUSTRY
                    } else -> {
                        industryType = IndustryType.SM_INDUSTRY
                    }
                }
            }
            ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM.ordinal -> {
                industryType = IndustryType.OE_OCCUPATION
            }
            ReportRowType.OWNERSHIP_EMPLOYMENT_WAGES_ITEM.ordinal -> {
                industryType = IndustryType.QCEW_INDUSTRY
            }
        }
    }

    override fun getReports() {

        isLoading.value = true
        loadReportCategories()
    }

    fun loadReportCategories() {
        ioThread {

            nationalArea = repository.getNationalArea()

            val rows = ArrayList<IndustryRow>()
            var parentIdSafe:Long? = parentId
            var parentIndustryData: IndustryEntity? = null

            if (parentIdSafe == null) {
                parentIdSafe = -1L
                var baseParentIndustries = repository.getChildIndustries(parentCode = parentIdSafe, industryType = industryType)
                if  (baseParentIndustries != null) {
                    parentIndustryData = baseParentIndustries.get(0)
                    parentIdSafe = parentIndustryData.id
                }

            } else {
                parentIndustryData = repository.getIndustry(parentIdSafe)
            }

            if (parentIndustryData != null) {
                val mergeTitle = parentIndustryData.title
                rows.add(IndustryRow(IndustryRowType.ITEM,
                        parentIndustryData,
                        parentIndustryData.id,
                        mergeTitle,
                        "N/A", "N/A",
                        false))
            }

            var fetchedData = repository.getChildIndustries(parentIdSafe!!, industryType)

            fetchedData.forEach{ industry ->
                val mergeTitle = industry.title + " (" + industry.industryCode + ")"
                rows.add(IndustryRow(IndustryRowType.ITEM,
                        industry,
                        industry.id,
                        mergeTitle,
                        "N/A", "N/A",
                        industry.superSector))
            }
            industryRows.postValue(rows)

            if (mArea is NationalEntity)
                getNationalReports(rows)
            else
                getLocalReports(rows)

        }
    }

    fun getLocalReports(industryRows: ArrayList<IndustryRow>) {

        var reportTypes = mutableListOf<ReportType>()

        industryRows.forEach {
            reportTypes.add(ReportType.OccupationalEmployment(it.industry!!.industryCode, OESReport.DataTypeCode.ANNUALMEANWAGE))
        }

        ReportManager.getReport(mArea, reportTypes, adjustment = mAdjustment,
                successHandler = {
                    isLoading.postValue(false)
                    updateIndustryRows(it, industryRows)

                    getNationalReports(industryRows)

                    this.industryRows.postValue(industryRows)
                },
                failureHandler = { it ->
                    isLoading.postValue(false)
                    reportError.value = it
                })
    }

    fun getNationalReports(industryRows: ArrayList<IndustryRow>) {

        var reportTypes = mutableListOf<ReportType>()

        industryRows.forEach {
            reportTypes.add(ReportType.OccupationalEmployment(it.industry!!.industryCode, OESReport.DataTypeCode.ANNUALMEANWAGE))
        }

        ReportManager.getReport(nationalArea!!, reportTypes, adjustment = mAdjustment,
                successHandler = {
                    isLoading.postValue(false)
                    updateIndustryRows(it, industryRows)

                    this.industryRows.postValue(industryRows)
                },
                failureHandler = { it ->
                    isLoading.postValue(false)
                    reportError.value = it
                })
    }

    fun updateIndustryRows(areaReport: List<AreaReport>, industryRows: ArrayList<IndustryRow>) {

        for (i in areaReport.indices) {
            val thisAreaRow = areaReport[i]
            val thisIndustryRow = industryRows[i]
            if  (thisAreaRow.seriesReport != null && thisAreaRow.seriesReport!!.data.isNotEmpty()) {
                if (thisAreaRow.area is NationalEntity)
                    thisIndustryRow.nationalValue = thisAreaRow.seriesReport!!.data[0].value
                else
                    thisIndustryRow.localValue = thisAreaRow.seriesReport!!.data[0].value
            }
        }

    }

    override fun toggleSection(reportRow: IndustryRow) {

    }
}