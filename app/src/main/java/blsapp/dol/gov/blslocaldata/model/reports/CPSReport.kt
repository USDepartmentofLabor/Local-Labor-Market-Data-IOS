package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity


/**
 * CPSReport - UnEmployment Report for National Area
 */

class CPSReport {
    enum class LFSTCode(val code: String) {
        UNEMPLOYMENT("30"),
        UNEMPLOYMENT_RATE("40"),
    }

    companion object {
        fun getUnemploymentRateSeriesId(area: AreaEntity,
                        adjustment: SeasonalAdjustment): SeriesId {
            return getSeriesId(area, lfstCode = LFSTCode.UNEMPLOYMENT_RATE, adjustment = adjustment)
        }

        fun getSeriesId(area: AreaEntity,
                        measureCode: LAUSReport.MeasureCode,
                        adjustment: SeasonalAdjustment): SeriesId {

            val lfstCode: LFSTCode
            if (measureCode == LAUSReport.MeasureCode.UNEMPLOYMENT_RATE) {
                lfstCode = LFSTCode.UNEMPLOYMENT_RATE
            }
            else {
                lfstCode = LFSTCode.UNEMPLOYMENT
            }

            return getSeriesId(area, lfstCode, adjustment)
        }

        fun getSeriesId(area: AreaEntity,
                        lfstCode: LFSTCode,
                        adjustment: SeasonalAdjustment): SeriesId {

            var adjustmentCode = adjustment.value
            adjustmentCode += if (adjustment ==  SeasonalAdjustment.ADJUSTED)  "1" else "0"
            val seriesId = "LN" + adjustmentCode  + lfstCode.code + "00000"
            return seriesId
        }
    }
}