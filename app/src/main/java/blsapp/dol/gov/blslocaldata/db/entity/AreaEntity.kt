package blsapp.dol.gov.blslocaldata.db.entity

import blsapp.dol.gov.blslocaldata.db.LocalRepository
import java.io.Serializable

abstract class AreaEntity: Serializable {
    abstract var id: Long?
    abstract var code: String
    abstract var title: String
    abstract var lausCode: String

    val accessibilityStr: String
    get() {
        var str = ""
        var components = title.split(",","-")

        components.forEach { code ->
            val stateCode = code.trim()
            if (stateCode.length == 2) {
                LocalRepository.stateName(stateCode)?.let {
                    str += it
                } ?: kotlin.run { str += stateCode }
            }
            else {
                str += stateCode
            }

            str += ","
        }
        return str
    }
}