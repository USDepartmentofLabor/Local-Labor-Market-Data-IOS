package blsapp.dol.gov.blslocaldata.db.entity

import android.arch.persistence.room.Entity
import android.arch.persistence.room.PrimaryKey

@Entity(tableName = "State")
data class StateEntity (
        @PrimaryKey(autoGenerate = true) override var id: Long?,
        override var code: String,
        override var title: String,
        override var lausCode: String) : AreaEntity() {

}