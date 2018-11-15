package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.MetroEntity
import blsapp.dol.gov.blslocaldata.db.entity.StateEntity

class OESReport {
    enum class DataTypeCode(val code: String) {
        EMPLOYMENT("01"),
        EMPLOYMENTPERCENTRELATIVESTDERROR("02"),
        HOURLYMEANWAGE("03"),
        ANNUALMEANWAGE("04"),
        WAGEPERCENTRELATIVESTDERROR("05"),
        HOURLY10PERCENTILEWAGE("06"),
        HOURLY25PERCENTILEWAGE("07"),
        HOURLYMEDIANWAGE("08"),
        HOURLY75PERCENTILEWAGE("09"),
        HOURLY90PERCENTILEWAGE("10"),
        ANNUAL10PERCENTILEWAGE("11"),
        ANNUAL25PERCENTILEWAGE("12"),
        ANNUALMEDIANWAGE("13"),
        ANNUAL75PERCENTILEWAGE("14"),
        ANNUAL90PERCENTILEWAGE("15"),
        EMPLOYMENTPER1000JOBS("16"),
        LOCATIONQUOTIENT("17")
    }

    companion object {
        fun getSeriesId(area: AreaEntity, occupationCode: String = "000000",
                        dataTypeCode: DataTypeCode): SeriesId {

            val code = area.code
            val areaType: String
            val areaCode: String

            when(area) {
                is MetroEntity -> {
                    areaType = "M"
                    areaCode = code.padStart(7, '0')
                }
                is StateEntity -> {
                    areaType = "S"
                    areaCode = code.padEnd(7, '0')
                }
                else -> {
                    areaType = "N"
                    areaCode = code.padEnd(7, '0')
                }
            }

            val industryCode = "000000"
            // OES data are annual and therefore do not need to be seasonally adjusted.
            // The same data should appear whether the seasonally adjusted toggle is turned on or off
            // let seriesId = "OE" + adjustment.rawValue  + areaType + areaCode + industryCode + occupationCode +
            // dataTypeCode.rawValue
            val seriesId = "OE" + SeasonalAdjustment.NOT_ADJUSTED.value  + areaType +
                    areaCode + industryCode + occupationCode + dataTypeCode.code

            return seriesId
        }
    }
}