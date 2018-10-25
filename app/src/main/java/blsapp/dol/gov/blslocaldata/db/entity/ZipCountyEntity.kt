package blsapp.dol.gov.blslocaldata.db.entity

import android.support.annotation.NonNull
import android.arch.persistence.room.ColumnInfo
import android.arch.persistence.room.Entity
import android.arch.persistence.room.PrimaryKey


@Entity(tableName = "ZIP_COUNTY")
data class ZipCountyEntity(@PrimaryKey(autoGenerate = true) var id: Long?,
                      @ColumnInfo(name = "zipCode") var zipCode: String,
                      @ColumnInfo(name = "countyCode") var countyCode: String) {


}