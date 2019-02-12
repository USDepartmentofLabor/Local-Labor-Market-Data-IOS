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
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.IndustryBaseViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType.INDUSTRY_EMPLOYMENT_ITEM
import org.jetbrains.anko.doAsync

class IndustryViewModel(application: Application) : AndroidViewModel(application), IndustryBaseViewModel {

    lateinit override var mArea: AreaEntity
    lateinit override var mAdjustment: SeasonalAdjustment

    override var isLoading = MutableLiveData<Boolean>()
    override var reportError = MutableLiveData<ReportError>()

    private val repository: LocalRepository = (application as BLSApplication).repository

    override var industryRows = MutableLiveData<List<IndustryRow>>()

    override fun setAdjustment(adjustment: SeasonalAdjustment) {
        mAdjustment = adjustment
        loadIndustries()
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

    override fun getIndustries() {

        isLoading.value = true
        loadIndustries()
    }

    fun loadIndustries() {
        ioThread {
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
                        "1000", "2000",
                        false))
            }


            var fetchedData = repository.getChildIndustries(parentIdSafe!!, industryType)

            fetchedData.forEach{ industry ->
                val mergeTitle = industry.title + " (" + industry.industryCode + ")"
                rows.add(IndustryRow(IndustryRowType.ITEM,
                        industry,
                        industry.id,
                        mergeTitle,
                        "100", "200",
                        industry.superSector))
            }
            industryRows.postValue(rows)
            isLoading.postValue(false)
        }
    }

    override fun toggleSection(reportRow: IndustryRow) {

    }
}