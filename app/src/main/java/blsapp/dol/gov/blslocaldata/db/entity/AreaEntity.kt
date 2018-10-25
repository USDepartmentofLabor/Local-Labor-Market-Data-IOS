package blsapp.dol.gov.blslocaldata.db.entity

import java.io.Serializable

abstract class AreaEntity: Serializable {
    abstract var id: Long?
    abstract var code: String
    abstract var title: String
    abstract var lausCode: String
}