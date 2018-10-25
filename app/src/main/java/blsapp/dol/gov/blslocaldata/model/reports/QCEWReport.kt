package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity

class QCEWReport {
    enum class QCEWDataFileIndex(val code: Int) {
        areaCode(0),
        ownershipCode(1),
        industryCode(2),
        aggLvlCode(3),
        sizeCode(4),
        year(5),
        qtr(6),
        disclosureCode(7),
        month1Emplvl(9),
        month2Emplvl(10),
        month3Emplvl(11),
        totalQtrlyWages(12),
        avgWeeklyWage(15),
        otyDisclosureCode(25),
        otyMonth1EmplvlChange(28),
        otyMonth1EmplvlPctChange(29),
        otyMonth2EmplvlChange(30),
        otyMonth2EmplvlPctChange(31),
        otyMonth3EmplvlChange(32),
        otyMonth3EmplvlPctChange(33),
        otyTotalQtrlyWageChange(34),
        otyTotalQtrlyWagePctChange(35),
        otyAvgWklyWageChange(40),
        otyAvgWklyWagePctChange(41)
    }

    enum class OwnershipCode(val code: String) {
        TOTAL_COVERED("0"),
        PRIVATE_OWNERSHIP("5"),
        FEDERAL_GOVT("1"),
        STATE_GOVT("2"),
        LOCAL_GOVT("3")
    }

    enum class IndustryCode(val code: String) {
        ALL_INDUSTRY("10")
    }

    enum class EstablishmentSize(val code: String) {
        ALL("0")
    }

    enum class AgglvlCode(val code: String) {
        countyTotal("70"),
        countyTotalByOwnership("71")
    }

    enum class DataTypeCode(val code: String) {
        allEmployees("1"),
        numberOfEstablishments("2"),
        totalWages("3"),
        avgWeeklyWage("4"),
        avgAnnualPay("5")
    }

    companion object {

        fun getSeriesId(area: AreaEntity, ownershipCode: OwnershipCode, industryCode:
            IndustryCode, establishmentSize: EstablishmentSize,
                        dataTypeCode: DataTypeCode, adjustment: SeasonalAdjustment) : SeriesId {

            var areaCode = area.code

            if (area is NationalEntity) {
                areaCode = "US000"
            }

            val seriesId = "EN" + adjustment.value  + areaCode + dataTypeCode.code +
                    establishmentSize.code + ownershipCode.code + industryCode.code

            return seriesId
        }
    }

}