package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.app.Application
import android.arch.lifecycle.AndroidViewModel
import android.arch.lifecycle.LiveData
import android.arch.lifecycle.MutableLiveData
import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.dao.IndustryType
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ioThread
import blsapp.dol.gov.blslocaldata.model.reports.ReportType

class SearchHierarchyViewModel(application: Application) : AndroidViewModel(application) {

    lateinit var mArea: AreaEntity
    private var mHierarchies = MutableLiveData<List<HierarchySearchRow>>()
    val hierarchies: LiveData<List<HierarchySearchRow>>
        get() = mHierarchies

    private var query : String? = null
    private var industryType: IndustryType = IndustryType.CE_INDUSTRY
    private val repository: LocalRepository = (application as BLSApplication).repository

    fun setQuery(originalInput: String) {
        val input = originalInput.toLowerCase().trim()
        if (input == query) {
            return
        }
        query = input
        if (input.count() < 3) {
            var hiearchyRows = ArrayList<HierarchySearchRow>()
            mHierarchies.postValue(hiearchyRows)
        }
        loadHierarchies()
    }

    fun setReportType(reportType: ReportType) {
        when (reportType) {
            is ReportType.IndustryEmployment -> {
                industryType = when (mArea) {
                    is NationalEntity -> IndustryType.CE_INDUSTRY
                    is StateEntity -> {
                        IndustryType.SM_INDUSTRY
                    }
                    else -> IndustryType.SM_INDUSTRY
                }
            }
            is ReportType.OccupationalEmployment -> {
                industryType = IndustryType.OE_OCCUPATION
            }
            is ReportType.QuarterlyEmploymentWages -> {
                industryType = IndustryType.QCEW_INDUSTRY
            }
        }
    }

    init {
       // val db = BLSDatabase.getInstance(application)
    }

    fun loadHierarchies() {
        ioThread {

            var hiearchyRows = ArrayList<HierarchySearchRow>()
            val itemList = repository.searchHierarchies(query, industryType)
            val itemRows = itemList.map { HierarchySearchRow(it, repository) }
            hiearchyRows.addAll(itemRows)

            mHierarchies.postValue(hiearchyRows)
        }
    }

}