package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import android.arch.lifecycle.MutableLiveData
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import com.github.mikephil.charting.data.BarEntry

/**
 * AreaViewModel - Base ViewModel for Areas (Metro/State/National, County)
 */

interface AreaViewModel {
    var mAdjustment: SeasonalAdjustment
    var mArea: AreaEntity
    var reportRows: MutableLiveData<List<AreaReportRow>>
    var isLoading: MutableLiveData<Boolean>
    var reportError: MutableLiveData<ReportError>

    var historyValuesLists: MutableList<MutableList<BarEntry>>
    var historyTitleList: MutableList<String>
    var historyXAxisLabels: MutableList<String>

    fun setAdjustment(adjustment: SeasonalAdjustment)
    fun getAreaReports()
    fun toggleSection(reportRow: AreaReportRow)
}