package blsapp.dol.gov.blslocaldata.ui.area

import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.TextView
import kotlinx.android.synthetic.main.industry_employment.view.*

class IndustryEmploymentHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val mDataValueTextView: TextView = mView.dataValueTextView
    val mAreaTitleTextView: TextView = mView.areaTextView
    val mMonthYearTextView: TextView = mView.monthYearTextView
    val mOneMonthChangeTextView: TextView = mView.oneMonthChangeValueTextView
    val mOneMonthRateChangeTextView: TextView = mView.oneMonthRateChangeTextView
    val mTwelveMonthChangeTextView: TextView = mView.twelveMonthChangeValueTextView
    val mTwelveMonthRateChangeTextView: TextView = mView.twelveMonthRateChangeTextView

    override fun toString(): String {
        return super.toString() + " '" + mDataValueTextView.text + "'"
    }
}

