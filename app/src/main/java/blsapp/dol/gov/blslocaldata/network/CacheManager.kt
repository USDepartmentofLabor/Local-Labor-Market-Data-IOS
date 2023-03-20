package blsapp.dol.gov.blslocaldata.network

import android.content.Context
import android.util.Log
import blsapp.dol.gov.blslocaldata.model.BLSReportRequest
import blsapp.dol.gov.blslocaldata.model.BLSReportResponse
import blsapp.dol.gov.blslocaldata.model.SeriesReport
import java.util.*

class CacheItem constructor(val seriesReport: BLSReportResponse) {
    val created: Long = System.currentTimeMillis()
}

class CacheManager {

    companion object {

        val cache:HashMap<String,CacheItem> = HashMap<String,CacheItem>()
       // val expirationTime = 2 * 3600 * 1000
        val expirationTime = 2 * 1000

        private fun key(value: BLSReportRequest): String? {
            return (value.toJSON())
        }

        fun get(request: BLSReportRequest):BLSReportResponse? {

            val keyRequest = key(request)
            Log.d("GGG", "Cache Request:" + keyRequest)
            var cacheResult = cache[keyRequest]
            if ( cacheResult != null){
                Log.d("GGG", "Cache Result Found:")
                val timeSinceCached = System.currentTimeMillis() - cacheResult.created
                if (timeSinceCached > expirationTime) {
                    cache.remove(keyRequest)
                    cacheResult = null
                }
                Log.w("GGG", "Cache Response: " + cacheResult?.seriesReport.toString())
            }
            return cacheResult?.seriesReport
        }

        fun put(response: BLSReportResponse, request:BLSReportRequest) {
            val keyRequest = key(request)
            if (keyRequest != null) {
                val reportCacheItem = CacheItem(response)
                cache.put(keyRequest, reportCacheItem)
            }
        }
    }
}