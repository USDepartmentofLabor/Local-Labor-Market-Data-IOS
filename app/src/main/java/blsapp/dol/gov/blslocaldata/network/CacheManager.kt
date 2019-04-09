package blsapp.dol.gov.blslocaldata.network

import android.content.Context
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
        val expirationTime = 2 * 3600 * 1000

        private fun key(value: BLSReportRequest): String? {
            return (value.toJSON())
        }

        fun get(request: BLSReportRequest):BLSReportResponse? {

            val keyRequest = key(request)
            var cacheResult = cache[keyRequest]
            if ( cacheResult != null){
                val timeSinceCached = System.currentTimeMillis() - cacheResult.created
                if (timeSinceCached > expirationTime) {
                    cache.remove(keyRequest)
                    cacheResult = null
                }
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