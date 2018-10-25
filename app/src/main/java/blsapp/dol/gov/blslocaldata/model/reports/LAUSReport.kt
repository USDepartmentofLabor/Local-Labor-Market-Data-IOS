package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity

typealias SeriesId = String

enum class SeasonalAdjustment(val value: String) {
    ADJUSTED("S"),
    NOT_ADJUSTED("U")
}

class LAUSReport {
    enum class MeasureCode(val code: String) {
        UNEMPLOYMENT_RATE("03"),
        UNEMPLOYMENT("04"),
        EMPLOYMENT("05"),
        LABOR_FORCE("06")
    }

    companion object {
        fun unemploymentRateSeriesId(area: AreaEntity, adjustment: SeasonalAdjustment): SeriesId {
            return getSeriedId(area, MeasureCode.UNEMPLOYMENT_RATE, adjustment)
        }

        fun getSeriedId(area: AreaEntity, measureCode: MeasureCode, adjustment: SeasonalAdjustment): SeriesId {
            val seriesId = "LA" + adjustment.value + area.lausCode + measureCode.code
            return seriesId
        }
    }
}