package blsapp.dol.gov.blslocaldata.model

import android.util.Log
import com.google.gson.Gson
import com.google.gson.TypeAdapter
import com.google.gson.annotations.JsonAdapter
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonToken
import com.google.gson.stream.JsonWriter

data class BLSReportResponse(
        val status: String,
        val message: List<String>,
        @SerializedName("Results")
        @JsonAdapter(SeriesReportAdapter::class)
        val series: List<SeriesReport>): JSONConvertable {
}

class SeriesReportAdapter: TypeAdapter<List<SeriesReport>>() {
    override fun read(reader: JsonReader): List<SeriesReport> {

        var seriesReports = emptyList<SeriesReport>()
        reader.beginObject()
        while (reader.hasNext()) {
            val name = reader.nextName()
            if (name == "series") {
                val reports: List<SeriesReport> = Gson().fromJson(reader, object : TypeToken<List<SeriesReport>>() {}.type)
                seriesReports += reports
            }
        }
        reader.endObject()
        return seriesReports
    }

    override fun write(out: JsonWriter?, value: List<SeriesReport>?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
}