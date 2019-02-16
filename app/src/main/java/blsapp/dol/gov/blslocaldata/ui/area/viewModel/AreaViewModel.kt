package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.arch.lifecycle.MutableLiveData
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow

/**
 * AreaViewModel - Base ViewModel for Areas (Metro/State/National, County)
 */

interface AreaViewModel {
    var mAdjustment: SeasonalAdjustment
    var mArea: AreaEntity
    var reportRows: MutableLiveData<List<AreaReportRow>>
    var isLoading: MutableLiveData<Boolean>
    var reportError: MutableLiveData<ReportError>

    fun setAdjustment(adjustment: SeasonalAdjustment)
    fun getAreaReports()
    fun toggleSection(reportRow: AreaReportRow)
}