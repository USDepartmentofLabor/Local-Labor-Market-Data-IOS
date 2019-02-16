package blsapp.dol.gov.blslocaldata.ui.area.viewHolders

import android.support.v7.widget.RecyclerView
import android.view.View
import blsapp.dol.gov.blslocaldata.ui.area.ReportListAdapter
import kotlinx.android.synthetic.main.report_sub_section.view.*

/**
 * ReportSubSectionHolder - holds the inflated view for Report sub section views
 */

class ReportSubSectionHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val subSectionsView: RecyclerView = mView.subSections

    lateinit var adapter: ReportListAdapter
    override fun toString(): String {
        return super.toString() + " '" +  "'"
    }

    init {

    }
}

