package blsapp.dol.gov.blslocaldata.model

import com.android.volley.NetworkError
import com.android.volley.NoConnectionError
import com.android.volley.TimeoutError
import com.google.gson.Gson
import com.google.gson.TypeAdapter
import com.google.gson.annotations.JsonAdapter
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonWriter

/**
 * ReportError - Error Handling for the BLS API
 */
class ReportError constructor(var errorCode: ErrorCode, var errorMessage: String) {
    enum class ErrorCode {
        TimeOutError,
        NetworkError,
        JSONParsingError,
        HttpError,
        NoReponse,
        APIError
    }

    constructor(error: Throwable) : this(ErrorCode.APIError, "") {
        val errorCode: ErrorCode
        val errorMessage: String
        when(error) {
            is TimeoutError -> {
                errorCode = ErrorCode.TimeOutError
                errorMessage = "Request Timed out"

            }
            is NoConnectionError, is NetworkError -> {
                errorCode = ErrorCode.NetworkError
                errorMessage = ""
                }
            else -> {
                errorCode = ErrorCode.APIError
                errorMessage = ""
            }
        }

        this.errorCode = errorCode
        this.errorMessage = errorMessage
    }

    val displayMessage: String
        get()
        {
            val displayMessage: String
            when (errorCode) {
                ErrorCode.NetworkError -> displayMessage = "You do not have internet connection."
                else -> displayMessage = "Error retrieving data. Please try again later."
            }

            return  displayMessage
        }

}

enum class ReportStatus(val value: String) {
    @SerializedName("REQUEST_SUCCEEDED")
    REQUEST_SUCCEEDED("REQUEST_SUCCEEDED"),
    @SerializedName("REQUEST_FAILED")
    REQUEST_FAILED("REQUEST_FAILED"),
    @SerializedName("REQUEST_NOT_PROCESSED")
    REQUEST_NOT_PROCESSED("REQUEST_NOT_PROCESSED"),
    @SerializedName("REQUEST_FAILED_INVALID_PARAMETERS")
    REQUEST_FAILED_INVALID_PARAMETERS("REQUEST_FAILED_INVALID_PARAMETERS"),
}

data class BLSReportResponse(
        val status: ReportStatus,
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