package blsapp.dol.gov.blslocaldata.ui.search

import android.content.res.Resources
import android.support.v4.content.ContextCompat.getColor
import android.support.v4.view.AccessibilityDelegateCompat
import android.support.v4.view.ViewCompat
import android.support.v4.view.accessibility.AccessibilityNodeInfoCompat
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryCESHolder
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryHolder
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryQCEWHolder
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow

import kotlinx.android.synthetic.main.area_item.view.*
import kotlinx.android.synthetic.main.areaheader_item.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.textColor

/**
 * HierarchyListAdapter - Industry / Occupation List Adapter Comparison View
 */

class HierarchyListQCEWAdapter( private val mListener: OnItemClickListener?) : HierarchyListAdapter(mListener) {

    interface OnItemClickListener : HierarchyListAdapter.OnItemClickListener {
        override fun onItemClick(item: HierarchyRow) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        }

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val inflatedView = layoutInflater.inflate(R.layout.hierarchy_item_qcew, parent, false)
        return HierarchyEntryQCEWHolder(inflatedView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        super.onBindViewHolder(holder,position)

        val areaRow = mIndustries[position]
        if (holder is HierarchyEntryQCEWHolder) {
            if (position == 0) {
                holder.nationalTwelveMonthValueLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.nationalTwelveMonthPercentLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.twelveMonthValueLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.twelveMonthPercentLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
            } else {
                holder.nationalTwelveMonthValueLabel.textColor = getColor(holder.itemView.context,android.R.color.black)
                holder.nationalTwelveMonthPercentLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.twelveMonthValueLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.twelveMonthPercentLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
            }

            holder.twelveMonthPercentLabel.text = areaRow.twelveMonthPercent
            holder.twelveMonthValueLabel.text = areaRow.twelveMonthValue
            holder.nationalTwelveMonthPercentLabel.text = areaRow.twelveMonthNationalPercent
            holder.nationalTwelveMonthValueLabel.text = areaRow.twelveMonthNationalValue

            if  (areaRow.twelveMonthValue =="ND" || areaRow.twelveMonthValue == "N/A") {
                holder.mIndustryLocalValue.text = ""
                holder.twelveMonthPercentLabel.text = ""
                holder.twelveMonthValueLabel.text = areaRow.twelveMonthValue
                if  (areaRow.twelveMonthValue == "ND")
                    holder.twelveMonthValueLabel.contentDescription = UIUtil.getString(R.string.ndAccessible)
                else
                    holder.twelveMonthValueLabel.contentDescription = UIUtil.getString(R.string.naAccessible)
            }

            if  (areaRow.twelveMonthNationalValue == "ND" || areaRow.twelveMonthNationalValue == "N/A") {
                holder.mIndustryNationalValue?.text = ""
                holder.nationalTwelveMonthPercentLabel.text = ""
                holder.nationalTwelveMonthValueLabel.text = areaRow.twelveMonthNationalValue
            }

            var superSectorAccessibilityText = " "
            if  (areaRow.superSector) {
                superSectorAccessibilityText = UIUtil.getString(R.string.more_details_available)
            }
            holder.itemView.contentDescription = String.format(UIUtil.getString(R.string.qcew_item_accessibility),
                    holder.mIndustryTitle.text,
                    holder.mIndustryLocalValue.text,
                    holder.twelveMonthValueLabel.text,
                    holder.twelveMonthPercentLabel.text,
                    holder.mIndustryNationalValue?.text,
                    holder.nationalTwelveMonthValueLabel.text,
                    holder.nationalTwelveMonthPercentLabel.text,
                    superSectorAccessibilityText
                    )
        }
    }
}
