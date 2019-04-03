package blsapp.dol.gov.blslocaldata.ui.area.viewModel

import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity

data class HierarchySearchRow(
        var itemId: Long,
        var itemTitle: String,
        var hierarchyTitles: String,
        var hiearchyIds: MutableList<Long>?) {

    constructor(iEntity: IndustryEntity, repository: LocalRepository):this(iEntity.id!!,iEntity.title," ", null) {

        this.itemId = iEntity.id!!
        this.itemTitle = iEntity.title
        buildHierarchy(this,iEntity, repository)
        return
    }

    fun buildHierarchy(row: HierarchySearchRow, currentEntity: IndustryEntity, repository: LocalRepository){

        if (row.hierarchyTitles.count() < 3) {
            row.hierarchyTitles = currentEntity.title
        } else {
            row.hierarchyTitles = currentEntity.title + " -> " + row.hierarchyTitles
        }

        if (row.hiearchyIds == null) {
            row.hiearchyIds = mutableListOf(currentEntity.id!!)
        } else {
            row.hiearchyIds?.add(0,currentEntity.id!!)
        }

        if (currentEntity.parentId != null) {
            val parentEntity = repository.getIndustry(currentEntity.parentId)
            if (parentEntity != null)
                buildHierarchy(row, parentEntity, repository)
        }
        return
    }
}