package blsapp.dol.gov.blslocaldata.ui.area.viewHolders

import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.TextView
import kotlinx.android.synthetic.main.unemployment_rate.view.*

/**
 * UnemploymentRateHolder - holds the inflated view for Unemployment Rate Report view
 */

class UnemploymentRateHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val mDataValueTextView: TextView = mView.dataValueTextView
    val mSeasonalAdjustmentTextView: TextView = mView.seasonallyAdjustedTextView

    val mAreaTitleTextView: TextView = mView.areaTextView
    val mMonthYearTextView: TextView = mView.monthYearTextView
    val mOneMonthChangeTextView: TextView = mView.oneMonthChangeValueTextView
    val mTwelveMonthChangeTextView: TextView = mView.twelveMonthChangeValueTextView

    override fun toString(): String {
        return super.toString() + " '" + mDataValueTextView.text + "'"
    }
}

