package blsapp.dol.gov.blslocaldata.ui.area

import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.TextView
import kotlinx.android.synthetic.main.employment_wages.view.*

class EmploymentWagesHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val mAreaTitleTextView: TextView = mView.areaTextView
    val mMonthYearTextView: TextView = mView.monthYearTextView

    // Employment Level
    val mDataValueTextView: TextView = mView.dataValueTextView
    val mTwelveMonthChangeTextView: TextView = mView.twelveMonthChangeValueTextView
    val mTwelveMonthRateChangeTextView: TextView = mView.twelveMonthRateChangeTextView

    // Average Weekly Wage
    val mWageDataValueTextView: TextView = mView.wageDataValueTextView
    val mWageTwelveMonthChangeTextView: TextView = mView.wageTwelveMonthChangeValueTextView
    val mWageTwelveMonthRateChangeTextView: TextView = mView.wagetwelveMonthRateChangeTextView

    override fun toString(): String {
        return super.toString() + " '" + mDataValueTextView.text + "'"
    }
}

