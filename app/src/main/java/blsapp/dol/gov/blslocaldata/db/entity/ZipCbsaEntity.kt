package blsapp.dol.gov.blslocaldata.db.entity

import android.support.annotation.NonNull
import android.arch.persistence.room.ColumnInfo
import android.arch.persistence.room.Entity
import android.arch.persistence.room.PrimaryKey


@Entity(tableName = "ZIP_CBSA")
data class ZipCbsaEntity(
        @PrimaryKey(autoGenerate = true) var id: Long?,
        var zipCode: String,
        var cbsaCode: String) {


}