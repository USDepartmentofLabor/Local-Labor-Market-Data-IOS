package blsapp.dol.gov.blslocaldata.model.reports

import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import java.io.Serializable

/**
 * ReportType - Report Classes based on Type, provides seriesId access based on ReportType
 */

sealed class ReportType : Serializable {
    class Unemployment(val measureCode: LAUSReport.MeasureCode): ReportType()

    class IndustryEmployment(val industryCode: String, val dataType: CESReport.DataTypeCode): ReportType()

    class OccupationalEmployment(val occupationalCode: String, val dataType: OESReport.DataTypeCode): ReportType()

    class OccupationalEmploymentQCEW(val ownershipCode: QCEWReport.OwnershipCode,
                                 val industryCode: String = QCEWReport.IndustryCode.ALL_INDUSTRY.code,
                                 val establishmentSize: QCEWReport.EstablishmentSize = QCEWReport.EstablishmentSize.ALL,
                                 val dataTypeCode: QCEWReport.DataTypeCode): ReportType()

    class QuarterlyEmploymentWages(val ownershipCode: QCEWReport.OwnershipCode,
                                   val industryCode: String = QCEWReport.IndustryCode.ALL_INDUSTRY.code,
                                   val establishmentSize: QCEWReport.EstablishmentSize = QCEWReport.EstablishmentSize.ALL,
                                   val dataTypeCode: QCEWReport.DataTypeCode): ReportType()


    fun getNormalizedCode(inputCode: String ):String {
        var retCode = inputCode
        if (this is OccupationalEmployment) {
            retCode = inputCode.substring(0, 2) + "-" + inputCode.substring(2)
        }
        return retCode
    }
    fun getSeriesId(area: AreaEntity, adjustment: SeasonalAdjustment): SeriesId {
        val seriesId: SeriesId

        when(this) {
            is Unemployment -> {
                if (area is NationalEntity) {
                    seriesId = CPSReport.getSeriesId(area, measureCode, adjustment)
                }
                else {
                    seriesId = LAUSReport.getSeriedId(area, measureCode, adjustment)
                }
            }

            is IndustryEmployment -> {
                seriesId = CESReport.getSeriesId(area, industryCode = industryCode, dataTypeCode = dataType, adjustment = adjustment)
            }

            is OccupationalEmployment -> {
                seriesId = OESReport.getSeriesId(area, occupationalCode, dataType)
            }

            is QuarterlyEmploymentWages -> {
                seriesId = QCEWReport.getSeriesId(area, ownershipCode, industryCode, establishmentSize, dataTypeCode, adjustment)
            }
            is OccupationalEmploymentQCEW -> {
                seriesId = QCEWReport.getSeriesId(area, ownershipCode, industryCode, establishmentSize, dataTypeCode, adjustment)
            }
        }

        return seriesId
    }

}

