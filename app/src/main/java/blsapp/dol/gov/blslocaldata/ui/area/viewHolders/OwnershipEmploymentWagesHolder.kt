package blsapp.dol.gov.blslocaldata.ui.area.viewHolders

import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.TextView
import kotlinx.android.synthetic.main.ownership_employment_wages.view.*

class OwnershipEmploymentWagesHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val mAreaTitleTextView: TextView = mView.areaTextView
    val mMonthYearTextView: TextView = mView.monthYearTextView

    // Employment Level
    val mDataValueTextView: TextView = mView.dataValueTextView

    // Average Weekly Wage
    val mWageDataValueTextView: TextView = mView.wageDataValueTextView

    override fun toString(): String {
        return super.toString() + " '" + mDataValueTextView.text + "'"
    }
}

