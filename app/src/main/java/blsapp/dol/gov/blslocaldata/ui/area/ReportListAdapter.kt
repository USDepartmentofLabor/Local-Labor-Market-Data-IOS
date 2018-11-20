package blsapp.dol.gov.blslocaldata.ui.area

import android.content.Context
import android.opengl.Visibility
import android.support.v4.content.ContextCompat
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.model.DataUtil
import blsapp.dol.gov.blslocaldata.model.SeriesData
import blsapp.dol.gov.blslocaldata.model.SeriesReport
import blsapp.dol.gov.blslocaldata.model.reports.AreaReport
import blsapp.dol.gov.blslocaldata.model.reports.QCEWReport
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.ReportType
import kotlinx.android.synthetic.main.report_header.view.*
import java.text.NumberFormat

enum class ReportRowType {
    HEADER,
    SUB_HEADER,
    UNEMPLOYMENAT_RATE_ITEM,
    INDUSTRY_EMPLOYMENT_ITEM,
    OCCUPATIONAL_EMPLOYMENT_ITEM,
    EMPLOYMENT_WAGES_ITEM,
    OWNERSHIP_EMPLOYMENT_WAGES_ITEM
}

data class ReportRow(var type: ReportRowType, val areaType: String?, val areaReports: List<AreaReport>?,
                     var period: String? = null, var year: String? = null, var header: String?, var headerCollapsed: Boolean = true,
                     var subReportRows: List<ReportRow>? = null)

class ReportListAdapter(private val context: Context, private val mListener: ReportListAdapter.OnReportItemClickListener?)
    : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var mReportRows = emptyList<ReportRow>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        when (viewType) {
            ReportRowType.UNEMPLOYMENAT_RATE_ITEM.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.unemployment_rate, parent, false)
                return UnemploymentRateHolder(inflatedView)
            }
            ReportRowType.INDUSTRY_EMPLOYMENT_ITEM.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.industry_employment, parent, false)
                return IndustryEmploymentHolder(inflatedView)
            }
            ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.occupational_employment, parent, false)
                return OccupationalEmploymentHolder(inflatedView)
            }
            ReportRowType.EMPLOYMENT_WAGES_ITEM.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.employment_wages, parent, false)
                return EmploymentWagesHolder(inflatedView)
            }
            ReportRowType.OWNERSHIP_EMPLOYMENT_WAGES_ITEM.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.ownership_employment_wages, parent, false)
                return OwnershipEmploymentWagesHolder(inflatedView)
            }
            ReportRowType.SUB_HEADER.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.report_sub_section, parent, false)
                val holder = ReportSubSectionHolder(inflatedView)
                val adapter = ReportListAdapter(context, mListener)
                holder.subSectionsView.apply {
                    this.adapter = adapter
                    layoutManager = LinearLayoutManager(this@ReportListAdapter.context)

                    val decorator = DividerItemDecoration(this@ReportListAdapter.context, DividerItemDecoration.VERTICAL)
                    val divider = ContextCompat.getDrawable(this@ReportListAdapter.context, R.drawable.divider)
                    divider?.let {
                        decorator.setDrawable(divider)
                        addItemDecoration(decorator)
                    }
                }

                return holder
            }
            else -> {
                val inflatedView = layoutInflater.inflate(R.layout.report_header, parent, false)
                return ReportHeaderViewHolder(inflatedView)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val reportRow = mReportRows[position]
        if (reportRow.type == ReportRowType.HEADER &&
                holder is ReportHeaderViewHolder) {
            holder.mHeaderTextView.text = reportRow.header
            holder.collapse = reportRow.headerCollapsed
            with(holder.mView) {
                tag = reportRow
                setOnClickListener {
                    mListener?.onItemClick(reportRow)
                }
            }

        } else if (reportRow.type == ReportRowType.SUB_HEADER &&
                holder is ReportSubSectionHolder) {
            reportRow.subReportRows?.let { subRows ->
                (holder.subSectionsView.adapter as? ReportListAdapter)?.setReportRows(subRows)
            }

            with(holder.mView) {
                tag = reportRow
                setOnClickListener {
                    mListener?.onItemClick(reportRow)
                }
            }

        } else {
            if (reportRow.type == ReportRowType.UNEMPLOYMENAT_RATE_ITEM &&
                        holder is UnemploymentRateHolder) {
                displayUnemploymentRate(holder, reportRow)
            } else if (reportRow.type == ReportRowType.INDUSTRY_EMPLOYMENT_ITEM &&
                        holder is IndustryEmploymentHolder) {
                displayIndustryEmployment(holder, reportRow)
            } else if (reportRow.type == ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM &&
                        holder is OccupationalEmploymentHolder) {
                displayOccupationalEmployment(holder, reportRow)
            } else if (reportRow.type == ReportRowType.EMPLOYMENT_WAGES_ITEM &&
                    holder is EmploymentWagesHolder) {
                displayEmploymentWages(holder, reportRow)
            } else if (reportRow.type == ReportRowType.OWNERSHIP_EMPLOYMENT_WAGES_ITEM &&
                        holder is OwnershipEmploymentWagesHolder) {
                displayOwnershipEmploymentWages(holder, reportRow)
            }
        }
    }

    fun displayUnemploymentRate(holder: UnemploymentRateHolder, reportRow: ReportRow) {
        holder.mAreaTitleTextView.text = reportRow.areaType
        reportRow.areaReports?.firstOrNull()?.seriesReport?.let {

            val seriesData: SeriesData?
            val year = reportRow.year
            val period = reportRow.period
            if (year != null && period != null) {
                seriesData = it.data(period, year)
            } else {
                seriesData = it.latestData()
            }

            seriesData?.let {
                holder.mDataValueTextView.text = it.value + "%"
                holder.mMonthYearTextView.text = it.periodName + " " + it.year

                holder.mOneMonthChangeTextView.text =
                        DataUtil.changeValueByPercent(it.calculations?.netChanges?.oneMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

                holder.mTwelveMonthChangeTextView.text =
                        DataUtil.changeValueByPercent(it.calculations?.netChanges?.twelveMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR
            } ?: run {
                holder.mMonthYearTextView.text = ""
                holder.mDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mOneMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mTwelveMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
            }
        }
    }

    fun displayIndustryEmployment(holder: IndustryEmploymentHolder, reportRow: ReportRow) {
        holder.mAreaTitleTextView.text = reportRow.areaType
        reportRow.areaReports?.firstOrNull()?.seriesReport?.let {

            val seriesData: SeriesData?
            val year = reportRow.year
            val period = reportRow.period
            if (year != null && period != null) {
                seriesData = it.data(period, year)
            } else {
                seriesData = it.latestData()
            }


            seriesData?.let {
                holder.mDataValueTextView.text = DataUtil.numberValueByThousand(it.value) ?: ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mMonthYearTextView.text = it.periodName + " " + it.year

                holder.mOneMonthChangeTextView.text =
                            DataUtil.changeValueByThousand(it.calculations?.netChanges?.oneMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

                holder.mTwelveMonthChangeTextView.text =
                            DataUtil.changeValueByThousand(it.calculations?.netChanges?.twelveMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

                holder.mOneMonthRateChangeTextView.text =
                        DataUtil.changeValueByPercent(it.calculations?.percentChanges?.oneMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mTwelveMonthRateChangeTextView.text =
                        DataUtil.changeValueByPercent(it.calculations?.percentChanges?.twelveMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

            } ?: run {
                holder.mMonthYearTextView.text = ""
                holder.mDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mOneMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mTwelveMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mOneMonthRateChangeTextView.text = ""
                holder.mTwelveMonthRateChangeTextView.text = ""
            }
        }
    }

    fun displayOccupationalEmployment(holder: OccupationalEmploymentHolder, reportRow: ReportRow) {
        holder.mAreaTitleTextView.text = reportRow.areaType
        reportRow.areaReports?.firstOrNull()?.seriesReport?.let {

            val seriesData: SeriesData?
            val year = reportRow.year
            val period = reportRow.period
            if (year != null && period != null) {
                seriesData = it.data(period, year)
            } else {
                seriesData = it.latestData()
            }

            seriesData?.let {seriesReport ->
                val currencyValue = DataUtil.currencyValue(seriesReport.value)
                currencyValue?.let {
                    holder.mDataValueTextView.text = it
                } ?: run { holder.mDataValueTextView.text =  ReportManager.DATA_NOT_AVAILABLE_STR }

                holder.mMonthYearTextView.text = seriesReport.year

            } ?: run {
                holder.mMonthYearTextView.text = ""
                holder.mDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
            }
        }
    }

    fun displayEmploymentWages(holder: EmploymentWagesHolder, reportRow: ReportRow) {
        holder.mAreaTitleTextView.text = reportRow.areaType
        val year = reportRow.year
        val period = reportRow.period

        reportRow.areaReports?.forEach { areaReport ->
            when (areaReport.reportType) {
                is ReportType.QuarterlyEmploymentWages -> {
                    if (areaReport.reportType.dataTypeCode == QCEWReport.DataTypeCode.allEmployees) {
                        displayQuaterlyEmployment(holder, areaReport.seriesReport, year, period)
                    }
                    else if (areaReport.reportType.dataTypeCode == QCEWReport.DataTypeCode.avgWeeklyWage) {
                        displayQuaterlyWages(holder, areaReport.seriesReport, year, period)
                    }
                }
            }
        }
    }

    fun displayOwnershipEmploymentWages(holder: OwnershipEmploymentWagesHolder, reportRow: ReportRow) {
        holder.mAreaTitleTextView.text = reportRow.areaType
        val year = reportRow.year
        val period = reportRow.period

        reportRow.areaReports?.forEach { areaReport ->
            when (areaReport.reportType) {
                is ReportType.QuarterlyEmploymentWages -> {
                    if (areaReport.reportType.dataTypeCode == QCEWReport.DataTypeCode.allEmployees) {
                        displayOwnershipQuaterlyEmployment(holder, areaReport.seriesReport, year, period)
                    }
                    else if (areaReport.reportType.dataTypeCode == QCEWReport.DataTypeCode.avgWeeklyWage) {
                        displayOwnershipQuaterlyWages(holder, areaReport.seriesReport, year, period)
                    }
                }
            }
        }
    }

    fun displayQuaterlyEmployment(holder: EmploymentWagesHolder, seriesReport: SeriesReport?, year: String?, period: String?) {
        seriesReport?.let {

            val seriesData: SeriesData?
            if (year != null && period != null) {
                seriesData = it.data(period, year)
            } else {
                seriesData = it.latestData()
            }


            seriesData?.let {
                var dataValue = ReportManager.DATA_NOT_AVAILABLE_STR

                it.value.toDoubleOrNull()?.let { value ->
                    dataValue = NumberFormat.getNumberInstance().format(value)
                }

                val quarterNumber = DataUtil.quarterNumber(it.period)
                holder.mDataValueTextView.text = dataValue
                holder.mMonthYearTextView.text = "Q" + quarterNumber + " " + it.periodName + " " + it.year

                holder.mTwelveMonthChangeTextView.text =
                        DataUtil.changeValueStr(it.calculations?.netChanges?.twelveMonth) ?:  ReportManager.DATA_NOT_AVAILABLE_STR

                holder.mTwelveMonthRateChangeTextView.text =
                        DataUtil.changeValueByPercent(it.calculations?.percentChanges?.twelveMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

            } ?: run {
                holder.mMonthYearTextView.text = ""
                holder.mDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mTwelveMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mTwelveMonthRateChangeTextView.text = ""
            }
        }
    }

    fun displayQuaterlyWages(holder: EmploymentWagesHolder, seriesReport: SeriesReport?, year: String?, period: String?) {
        seriesReport?.let {

            val seriesData: SeriesData?
            if (year != null && period != null) {
                // Period Name is of Format M01, M02 etc
                // Convert it to Quarter format
                val quarterPeriod = DataUtil.quarterPeriod(period)
                seriesData = it.data(quarterPeriod, year)
            } else {
                seriesData = it.latestData()
            }


            seriesData?.let {
                var dataValue = ReportManager.DATA_NOT_AVAILABLE_STR

                DataUtil.currencyValue(it.value)?.let {
                    dataValue = it
                }

                holder.mWageDataValueTextView.text = dataValue

                holder.mWageTwelveMonthChangeTextView.text =
                        DataUtil.changeValueStr(it.calculations?.netChanges?.twelveMonth) ?:  ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mWageTwelveMonthRateChangeTextView.text =
                    DataUtil.changeValueByPercent(it.calculations?.percentChanges?.twelveMonth) ?: ReportManager.DATA_NOT_AVAILABLE_STR

            } ?: run {
                holder.mWageDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mWageTwelveMonthChangeTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
                holder.mWageTwelveMonthRateChangeTextView.text = ""
            }
        }
    }


    fun displayOwnershipQuaterlyEmployment(holder: OwnershipEmploymentWagesHolder, seriesReport: SeriesReport?, year: String?, period: String?) {
        seriesReport?.let {

            val seriesData: SeriesData?
            if (year != null && period != null) {
                seriesData = it.data(period, year)
            } else {
                seriesData = it.latestData()
            }


            seriesData?.let {
                var dataValue = ReportManager.DATA_NOT_AVAILABLE_STR

                it.value.toDoubleOrNull()?.let { value ->
                    dataValue = NumberFormat.getNumberInstance().format(value)
                }

                val quarter = DataUtil.quarterNumber(it.period)
                holder.mDataValueTextView.text = dataValue
                holder.mMonthYearTextView.text = "Q" + quarter + " " + it.periodName + " " + it.year


            } ?: run {
                holder.mMonthYearTextView.text = ""
                holder.mDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
            }
        }
    }

    fun displayOwnershipQuaterlyWages(holder: OwnershipEmploymentWagesHolder, seriesReport: SeriesReport?, year: String?, period: String?) {
        seriesReport?.let {

            val seriesData: SeriesData?
            if (year != null && period != null) {
                val quarterPeriod = DataUtil.quarterPeriod(period)
                seriesData = it.data(quarterPeriod, year)
            } else {
                seriesData = it.latestData()
            }


            seriesData?.let {
                var dataValue = ReportManager.DATA_NOT_AVAILABLE_STR

                DataUtil.currencyValue(it.value)?.let {
                    dataValue = it
                }

                holder.mWageDataValueTextView.text = dataValue

            } ?: run {
                holder.mWageDataValueTextView.text = ReportManager.DATA_NOT_AVAILABLE_STR
            }
        }
    }

    fun setReportRows(reportRows: List<ReportRow>) {
        mReportRows = reportRows
        notifyDataSetChanged()
    }
    fun reportRows(): List<ReportRow> {
        return mReportRows
    }

    override fun getItemCount(): Int = mReportRows.size
    override fun getItemViewType(position: Int) = mReportRows[position].type.ordinal

    inner class ReportHeaderViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
        val mHeaderTextView: TextView = mView.header_text
        val mHeaderImageView: ImageView = mView.showImageView

        init {
            if (DataUtil.isTalkBackActive()) {
                mHeaderImageView.visibility = View.GONE
            }
            else {
                mHeaderImageView.visibility = View.VISIBLE
            }
        }
        override fun toString(): String {
            return super.toString() + " '" + mHeaderTextView.text + "'"
        }

        var collapse: Boolean = true
        set(value) {
            if (value)
            {
                mHeaderImageView.setImageResource(R.drawable.ic_expand_less_black_24dp)
            } else {
                mHeaderImageView.setImageResource(R.drawable.ic_expand_more_black_24dp)
            }
        }

    }

    interface OnReportItemClickListener {
        fun onItemClick(item: ReportRow)
    }

}

