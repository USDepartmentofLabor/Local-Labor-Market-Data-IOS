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
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

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

    fun getReports(seriesIds: List<String>, startYear: String? = null, endYear: String? = null, annualAvg: Boolean = false,
                   successHandler: (BLSReportResponse) -> Unit, failureHandler: (ReportError) -> Unit) {

        val requestQueue = BLSRequestQueue.getInstance(appContext)

        val apiKey = if (BuildConfig.DEBUG)  R.string.bls_api_key_debug else R.string.bls_api_key_production


        var requestIds = seriesIds
        var seriesIdsCopy:List<String>? = null
        if  (seriesIds.count() > 50) {
            requestIds = seriesIds.subList(0, 50)
            seriesIdsCopy = seriesIds.subList(50, seriesIds.size)
        }
        val reportRequest = BLSReportRequest(seriesIds = requestIds, registrationKey = appContext.getString(apiKey),
                startYear = startYear, endYear = endYear, annualAvg = annualAvg)

        val cachedResponse = CacheManager.get(reportRequest)
        if (cachedResponse!= null) {
            doAsync {
                uiThread {
                    successHandler(cachedResponse)
                }
            }
            return
        }

        Log.w("gggAPI", "BLSAPI API Request: " + reportRequest.toJSON())
        val jsonObjectRequest = JsonObjectRequest(Request.Method.POST, BLS_API_URL, JSONObject(reportRequest.toJSON()),
                Response.Listener { response ->
                    val reportReponse = response.toString().toObject<BLSReportResponse>()
                    Log.w("gggAPI", "BLSAPI API Response: " + response.toString())
                    if (reportReponse.status == ReportStatus.REQUEST_SUCCEEDED) {
                        if (seriesIdsCopy != null) {
                            getReports(seriesIdsCopy, startYear, endYear, annualAvg, {nextResponse ->
                                Log.w("Nested Report", nextResponse.toString())
                                reportReponse.series.addAll(nextResponse.series)
                                successHandler(reportReponse)

                            }, failureHandler = {
                                Log.w("Nested Failure", it.toString())
                                failureHandler(it)
                            })

                        } else {
                            CacheManager.put(reportReponse, reportRequest)
                            successHandler(reportReponse)
                        }
                    }
                    else {
                        failureHandler(ReportError(ReportError.ErrorCode.APIError, ""))
                    }
                },
                Response.ErrorListener { error ->
                    failureHandler(ReportError(error))
                })
        requestQueue.addToRequestQueue(jsonObjectRequest)
    }
}