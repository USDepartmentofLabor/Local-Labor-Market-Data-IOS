package blsapp.dol.gov.blslocaldata.ui.viewmodel

import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity

enum class IndustryRowType {
    HEADER,
    ITEM
}

data class IndustryRow(var type: IndustryRowType, var industry: IndustryEntity?, var itemId: Long?, var title: String?, var localValue: String?, var nationalValue: String?, var superSector: Boolean?)
