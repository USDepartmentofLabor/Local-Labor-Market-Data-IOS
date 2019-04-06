package blsapp.dol.gov.blslocaldata.model

import com.google.gson.TypeAdapter
import com.google.gson.annotations.SerializedName
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonWriter

/**
 * BLSReportRequest - builds the request for BLS API Requests
 */
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
    @SerializedName("annualaverage")
    var annualAverage: Boolean? = false

    init{
        this.seriesIds = seriesIds
        this.registrationKey = registrationKey
    }

    constructor(seriesIds: List<String>, registrationKey: String, startYear: String?, endYear: String? = null, annualAvg: Boolean = false) : this(seriesIds, registrationKey) {

        this.startYear = startYear
        this.annualAverage = annualAvg

        endYear?.let {
            this.endYear = it
        } ?: kotlin.run { this.endYear = startYear }
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