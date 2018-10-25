package blsapp.dol.gov.blslocaldata.ui.area

import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.View
import kotlinx.android.synthetic.main.report_sub_section.view.*

class ReportSubSectionHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
    val subSectionsView: RecyclerView = mView.subSections

    lateinit var adapter: ReportListAdapter
    override fun toString(): String {
        return super.toString() + " '" +  "'"
    }

    init {

    }
}

