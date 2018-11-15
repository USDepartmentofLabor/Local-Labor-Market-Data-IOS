package blsapp.dol.gov.blslocaldata.model

import com.google.gson.TypeAdapter
import com.google.gson.annotations.SerializedName
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonWriter

class BLSReportRequest(seriesIds: List<String>, registrationKey: String): JSONConvertable {

    @SerializedName("seriesid")
    val seriesIds: List<String>
    @SerializedName("registrationkey")
    val registrationKey: String
    @SerializedName("startyear")
    var startYear: String? = null
    @SerializedName("endyear")
    var endYear: String? = null
    val calculations: Boolean = true
    var latest: Boolean = true
    @SerializedName("annualaverage")
    val annualAverage: Boolean? = false

    init{
        this.seriesIds = seriesIds
        this.registrationKey = registrationKey
    }

    constructor(seriesIds: List<String>, registrationKey: String, startYear: String?, endYear: String? = null) : this(seriesIds, registrationKey) {
        this.startYear = startYear

        endYear?.let {
            this.endYear = it
        } ?: kotlin.run { this.endYear = startYear }

        if (startYear == null) {
            this.latest = true
        } else {
            this.latest = false
        }
    }
}


class BLSReportRequestAdapter: TypeAdapter<BLSReportRequest>() {
    override fun read(`in`: JsonReader?): BLSReportRequest {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
    override fun write(out: JsonWriter?, request: BLSReportRequest?) {
        out?.let { writer ->
            writer.beginObject()

            request?.let { request ->
                writer.name("registrationkey").value(request.registrationKey)
                writer.name("seriesid")
                writer.beginArray()
                request.seriesIds.forEach() {
                    writer.value(it)
                }
                writer.endArray()

                request.startYear?.let {startYear ->
                    writer.name("startyear").value(startYear)
                } ?: run {
                    writer.name("latest").value(true)
                }
                writer.name("calculations").value(request.calculations)
            }
            writer.endObject()
        }

    }
}