package blsapp.dol.gov.blslocaldata.db.entity

import android.arch.persistence.room.Entity
import android.arch.persistence.room.PrimaryKey

@Entity(tableName = "MSACounty")
data class MSACountyEntity(
    @PrimaryKey(autoGenerate = true) var id: Long?,
            val msaCode: String,
            val countyCode: String) {
}