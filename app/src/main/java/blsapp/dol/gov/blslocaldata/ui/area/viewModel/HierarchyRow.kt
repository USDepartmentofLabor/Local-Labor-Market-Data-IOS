package blsapp.dol.gov.blslocaldata.ui.viewmodel

import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity

enum class HierarchyRowType {
    HEADER,
    ITEM
}

/**
 * HierarchyRow - Industry Entry information for display from the ViewModel
 */

data class HierarchyRow(var type: HierarchyRowType,
                        var industry: IndustryEntity?,
                        var itemId: Long?,
                        var title: String?,
                        var localValue: String,
                        var nationalValue: String,
                        var oneMonthValue: String,
                        var oneMonthPercent: String,
                        var oneMonthNationalValue: String,
                        var oneMonthNationalPercent: String,
                        var twelveMonthValue: String,
                        var twelveMonthPercent: String,
                        var twelveMonthNationalValue: String,
                        var twelveMonthNationalPercent: String,
                        var superSector: Boolean)
