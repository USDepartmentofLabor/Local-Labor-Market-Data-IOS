package blsapp.dol.gov.blslocaldata.ui.search

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
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryHolder
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow

import kotlinx.android.synthetic.main.area_item.view.*
import kotlinx.android.synthetic.main.areaheader_item.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.textColor

/**
 * HierarchyListAdapter - Industry / Occupation List Adapter Comparison View
 */

open class HierarchyListAdapter(private val mListener: OnItemClickListener?) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

//    private val mOnClickListener: View.OnClickListener
    var mIndustries = emptyList<HierarchyRow>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val inflatedView = layoutInflater.inflate(R.layout.hierarchy_item, parent, false)
        return HierarchyEntryHolder(inflatedView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        val areaRow = mIndustries[position]
        if (holder is HierarchyEntryHolder) {
            if (position == 0) {
                holder.mView.backgroundColor = getColor(holder.itemView.context, R.color.colorPrimary)
                holder.mIndustryTitle.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.mIndustryNationalValue?.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
            } else {
                holder.mView.backgroundColor = getColor(holder.itemView.context,R.color.colorHierarchyCell)
                holder.mIndustryTitle.textColor = getColor(holder.itemView.context,android.R.color.black)
                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.mIndustryNationalValue?.textColor = getColor(holder.itemView.context, android.R.color.black)
            }

            var superSectorAccessibilityText = UIUtil.getString(R.string.more_details_available)
            if (areaRow.superSector) {
                holder.mSubIndustryIndicator.visibility = View.VISIBLE

                with(holder.mView) {
                    tag = areaRow.industry
                    setOnClickListener {
                        mListener?.onItemClick(areaRow)
                    }
                }
            } else {
                holder.mSubIndustryIndicator.visibility = View.GONE
                superSectorAccessibilityText = " "
            }

            holder.mIndustryTitle.text = areaRow.title

            holder.mIndustryLocalValue.text = areaRow.localValue
            holder.mIndustryNationalValue?.text = areaRow.nationalValue

            if  (holder.mIndustryNationalValue?.text != null &&
                    (holder.mIndustryNationalValue?.text!! == "N/A" || holder.mIndustryNationalValue.text.length < 2))
                holder.mIndustryNationalValue?.contentDescription = UIUtil.getString(R.string.naAccessible)
            else
                holder.mIndustryNationalValue?.contentDescription = areaRow.nationalValue

            if  (holder.mIndustryLocalValue.text == "N/A")
                holder.mIndustryLocalValue.contentDescription = UIUtil.getString(R.string.naAccessible)
            else
                holder.mIndustryLocalValue.contentDescription = areaRow.localValue


            if (holder.mIndustryLocalValue.text.length < 2) {
                holder.itemView.contentDescription = String.format(UIUtil.getString(R.string.base_no_region_item_accessibility),
                        holder.mIndustryTitle.text,
                        holder.mIndustryNationalValue?.contentDescription,
                        superSectorAccessibilityText
                )
            } else {
                holder.itemView.contentDescription = String.format(UIUtil.getString(R.string.base_item_accessibility),
                        holder.mIndustryTitle.text,
                        holder.mIndustryLocalValue.contentDescription,
                        holder.mIndustryNationalValue?.contentDescription,
                        superSectorAccessibilityText
                )
            }
        }
    }
    override fun getItemCount(): Int = mIndustries.size
    override fun getItemViewType(position: Int) = mIndustries[position].type.ordinal

    interface OnItemClickListener {
        fun onItemClick(item: HierarchyRow)
    }

    fun setIndustryRows(hierarchyRows: List<HierarchyRow>) {
        mIndustries = hierarchyRows
        notifyDataSetChanged()
    }

}
