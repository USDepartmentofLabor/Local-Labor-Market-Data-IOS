package blsapp.dol.gov.blslocaldata.ui.viewmodel

import blsapp.dol.gov.blslocaldata.model.reports.AreaReport

enum class ReportRowType {
    HEADER,
    SUB_HEADER,
    UNEMPLOYMENAT_RATE_ITEM,
    INDUSTRY_EMPLOYMENT_ITEM,
    OCCUPATIONAL_EMPLOYMENT_ITEM,
    EMPLOYMENT_WAGES_ITEM,
    OWNERSHIP_EMPLOYMENT_WAGES_ITEM,
    UNKNOWN
}

data class ReportRow(var type: ReportRowType, val areaType: String?, val areaReports: List<AreaReport>?,
                     var period: String? = null, var year: String? = null, var header: String?, var headerCollapsed: Boolean = true,
                     var subIndustries: Boolean = false,
                     var subReportRows: List<ReportRow>? = null, var headerType: ReportRowType? = ReportRowType.UNKNOWN)
