package blsapp.dol.gov.blslocaldata.network

import android.content.Context
import android.os.Debug
import android.util.Log
import android.view.textclassifier.TextLinks
import blsapp.dol.gov.blslocaldata.BuildConfig
import blsapp.dol.gov.blslocaldata.model.*
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.JsonObjectRequest
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import org.json.JSONObject
import blsapp.dol.gov.blslocaldata.R

/**
 * BlsAPI - Makes requests to the BLS API
 */

class BlsAPI constructor(val appContext: Context) {

    companion object {
        private val BLS_API_URL = "https://api.bls.gov/publicAPI/v2/timeseries/data/"

        @Volatile
        private var INSTANCE: BlsAPI? = null
        fun getInstance(appContext: Context) =
                INSTANCE ?: synchronized(this) {
                    INSTANCE ?: BlsAPI(appContext).also {
                        INSTANCE = it
                    }
                }
    }

    fun getReports(seriesIds: List<String>, startYear: String? = null, endYear: String? = null,
                   successHandler: (BLSReportResponse) -> Unit, failureHandler: (ReportError) -> Unit) {

        val requestQueue = BLSRequestQueue.getInstance(appContext)

        val apiKey = if (BuildConfig.DEBUG)  R.string.bls_api_key_debug else R.string.bls_api_key

        val reportRequest = BLSReportRequest(seriesIds = seriesIds, registrationKey = appContext.getString(apiKey),
                startYear = startYear, endYear = endYear)

//        val gson = GsonBuilder()
//                .registerTypeAdapter(BLSReportRequest::class.java, BLSReportRequestAdapter())
//                .create()
//        gson.toJson(reportRequest)

        Log.w("ggg", "JSON Request: " + reportRequest.toJSON())
        val jsonObjectRequest = JsonObjectRequest(Request.Method.POST, BLS_API_URL, JSONObject(reportRequest.toJSON()),
                Response.Listener { response ->
                    print(response.toString())
                    Log.w("Nidhi", response.toString())
                    val reportReponse = response.toString().toObject<BLSReportResponse>()
                    Log.w("Nidhi", reportReponse.toString())

                    if (reportReponse.status == ReportStatus.REQUEST_SUCCEEDED) {
                        successHandler(reportReponse)
                    }
                    else {
                        failureHandler(ReportError(ReportError.ErrorCode.APIError, ""))
                    }

                },
                Response.ErrorListener { error ->
                    print(error.toString())
                    Log.w("Nidhi", error.toString())
                    failureHandler(ReportError(error))
                })
        requestQueue.addToRequestQueue(jsonObjectRequest)
    }
}