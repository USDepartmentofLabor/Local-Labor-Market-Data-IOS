package blsapp.dol.gov.blslocaldata.ui.viewmodel

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity

enum class RowType {
    HEADER,
    ITEM
}

/**
 * AreaRow - Area Entry information for display from the ViewModel
 */

data class AreaRow(var type: RowType,
                   var area: AreaEntity?,
                   var header: String?,
                   val image: Int?)
