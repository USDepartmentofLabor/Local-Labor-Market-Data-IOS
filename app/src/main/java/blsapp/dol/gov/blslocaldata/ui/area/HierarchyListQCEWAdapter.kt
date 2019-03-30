package blsapp.dol.gov.blslocaldata.ui.search

import android.support.v4.content.ContextCompat.getColor
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
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

//        val areaRow = mIndustries[position]
//        if (holder is HierarchyEntryHolder) {
//            if (position == 0) {
//                holder.mView.backgroundColor = getColor(holder.itemView.context, R.color.colorPrimary)
//                holder.mIndustryTitle.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
//                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
//                holder.mIndustryNationalValue?.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
//            } else {
//                holder.mView.backgroundColor = getColor(holder.itemView.context,R.color.colorHierarchyCell)
//                holder.mIndustryTitle.textColor = getColor(holder.itemView.context,android.R.color.black)
//                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, android.R.color.black)
//                holder.mIndustryNationalValue?.textColor = getColor(holder.itemView.context, android.R.color.black)
//            }
//            holder.mIndustryTitle.text = areaRow.title
//
//            holder.mIndustryLocalValue.text = areaRow.localValue!!
//            holder.mIndustryNationalValue?.text = areaRow.nationalValue!!
//
//            if (areaRow.superSector!!) {
//                holder.mSubIndustryIndicator.visibility = View.VISIBLE
//
//                with(holder.mView) {
//                    tag = areaRow.industry
//                    setOnClickListener {
//                        mListener?.onItemClick(areaRow)
//                    }
//                }
//            } else {
//                holder.mSubIndustryIndicator.visibility = View.GONE
//            }
//        }
    }

}