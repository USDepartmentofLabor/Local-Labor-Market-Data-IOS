package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.arch.lifecycle.MutableLiveData
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.area.ReportRow

interface AreaViewModel {
    var mAdjustment: SeasonalAdjustment
    var mArea: AreaEntity
    var reportRows: MutableLiveData<List<ReportRow>>
    var isLoading: MutableLiveData<Boolean>

    fun setAdjustment(adjustment: SeasonalAdjustment)
    fun getReports()

    fun toggleSection(reportRow: ReportRow)
}