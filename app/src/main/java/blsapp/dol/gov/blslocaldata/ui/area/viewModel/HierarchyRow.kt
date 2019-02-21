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
                        var localValue: String?,
                        var nationalValue: String?,
                        var superSector: Boolean?)
