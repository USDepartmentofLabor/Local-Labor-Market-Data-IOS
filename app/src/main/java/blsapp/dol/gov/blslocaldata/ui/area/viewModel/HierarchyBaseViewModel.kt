package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.arch.lifecycle.MutableLiveData
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow

/**
 * HierarchyBaseViewModel - Base class for Industry and Occupational Comparison reports
 */

interface HierarchyBaseViewModel {
    var mAdjustment: SeasonalAdjustment
    var mArea: AreaEntity
    var hierarchyRows: MutableLiveData<List<HierarchyRow>>
    var isLoading: MutableLiveData<Boolean>
    var reportError: MutableLiveData<ReportError>

    fun setAdjustment(adjustment: SeasonalAdjustment)
    fun getIndustryReports()
    fun toggleSection(reportRow: HierarchyRow)
}