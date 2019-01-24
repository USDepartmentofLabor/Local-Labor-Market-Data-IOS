package blsapp.dol.gov.blslocaldata.db.entity

import android.arch.persistence.room.Entity
import android.arch.persistence.room.PrimaryKey

@Entity(tableName = "Industry")
data class IndustryEntity(
    @PrimaryKey(autoGenerate = true) var id: Long?,
            val industryCode: String,
            val title: String,
            val superSector: Boolean,
            val industryType: Int,
            val parentId: Long) {
}