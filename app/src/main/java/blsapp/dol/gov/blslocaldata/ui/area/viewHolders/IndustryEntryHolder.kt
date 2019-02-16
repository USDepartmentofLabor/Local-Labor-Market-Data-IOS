package blsapp.dol.gov.blslocaldata.ui.area.viewHolders

import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import kotlinx.android.synthetic.main.industry_item.view.*

/**
 * IndustryEntryHolder - holds the inflated view for the Industry Entries view
 */

class IndustryEntryHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val mIndustryTitle: TextView = mView.title
    val mIndustryLocalValue: TextView = mView.localValue
    val mIndustryNationalValue: TextView = mView.nationalValue
    val mSubIndustryIndicator: ImageView = mView.subIndustriesIndicator

    override fun toString(): String {
        return super.toString() + " '" + mIndustryTitle.text + "'"
    }
}

