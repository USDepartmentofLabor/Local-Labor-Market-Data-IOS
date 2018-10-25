package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.MetroEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity

class CESReport {
    enum class DataTypeCode(val code: String) {
        ALLEMPLOYEES("01"),
        AVGWEEKLYHOURS_ALLEMPLOYEES("02"),
        AVGHOURLYEARNINGS_ALLEMPLOYEES("03"),
        PRODUCTION_NONSUPERVISORYEMPLOYEES("06"),
        AVGWEEKLYHOURS_PRODUCTIONEMPLOYEES("07"),
        AVGHOURLYEARNINGS_PRODUCTIONEMPLOYEES("08"),
        AVGWEEKLYEARNINGS_ALLEMPLOYEES("11"),
        ALLEMPLOYEES_3MONTHAVGCHANGE("26"),
        AVERAGEWEEKLYEARLNINGS_PRODUCTIONEMPLOYEES("30")
    }

    companion object {
        fun getSeriesId(area: AreaEntity, industryCode: String = "00000000",
                    dataTypeCode: DataTypeCode,
                    adjustment: SeasonalAdjustment): SeriesId {

            when (area) {
                is NationalEntity -> {
                    return getNationalSeriesId(dataTypeCode = dataTypeCode, adjustment = adjustment)
                }
            }

            return getLocalAreaSeriesId(area, dataTypeCode = dataTypeCode, adjustment = adjustment)
        }

        fun getNationalSeriesId(industryCode: String = "00000000",
                        dataTypeCode: DataTypeCode,
                        adjustment: SeasonalAdjustment): SeriesId {

            val seriesId = "CE" + adjustment.value  + industryCode + dataTypeCode.code
            return seriesId
        }

        private fun getLocalAreaSeriesId(area: AreaEntity, industryCode: String = "00000000",
                                 dataTypeCode: DataTypeCode,
                                    adjustment: SeasonalAdjustment) : SeriesId {

            val code = area.code
            var areaCode = ""

            if (area is MetroEntity) {
                areaCode = area.stateCode
            }

            areaCode += code
            areaCode = areaCode.padEnd(7, '0')
            val seriesId = "SM" + adjustment.value  + areaCode + industryCode + dataTypeCode.code
            return seriesId
        }
    }
}