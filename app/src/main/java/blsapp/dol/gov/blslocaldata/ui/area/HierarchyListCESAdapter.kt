package blsapp.dol.gov.blslocaldata.ui.search

import android.support.v4.content.ContextCompat.getColor
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryCESHolder
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow

import org.jetbrains.anko.textColor

/**
 * HierarchyListAdapter - Industry / Occupation List Adapter Comparison View
 */

class HierarchyListCESAdapter (private val mListener: OnItemClickListener?, val mArea: AreaEntity) : HierarchyListAdapter(mListener) {

    interface OnItemClickListener : HierarchyListAdapter.OnItemClickListener {
        override fun onItemClick(item: HierarchyRow) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        }

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val inflatedView = layoutInflater.inflate(R.layout.hierarchy_item_ces, parent, false)
        return HierarchyEntryCESHolder(inflatedView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        super.onBindViewHolder(holder,position)

        val areaRow = mIndustries[position]
        if (holder is HierarchyEntryCESHolder) {
            if (position == 0) {
                holder.oneMonthValueLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.oneMonthPercentLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.twelveMonthValueLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.twelveMonthPercentLabel.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
            } else {
                holder.oneMonthValueLabel.textColor = getColor(holder.itemView.context,android.R.color.black)
                holder.oneMonthPercentLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.twelveMonthValueLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.twelveMonthPercentLabel.textColor = getColor(holder.itemView.context, android.R.color.black)
            }

            if  (mArea is NationalEntity ) {
                holder.mIndustryLocalValue.text = areaRow.nationalValue
                holder.oneMonthValueLabel.text = areaRow.oneMonthNationalValue
                holder.twelveMonthValueLabel.text = areaRow.twelveMonthNationalValue
                holder.oneMonthPercentLabel.text = areaRow.oneMonthNationalPercent
                holder.twelveMonthPercentLabel.text = areaRow.twelveMonthNationalPercent
            } else {
                holder.oneMonthValueLabel.text = areaRow.oneMonthValue
                holder.twelveMonthValueLabel.text = areaRow.twelveMonthValue
                holder.oneMonthPercentLabel.text = areaRow.oneMonthPercent
                holder.twelveMonthPercentLabel.text = areaRow.twelveMonthPercent
            }

            if  (holder.mIndustryLocalValue.text == "N/A")
                holder.mIndustryLocalValue.contentDescription = UIUtil.getString(R.string.naAccessible)

            if  (holder.oneMonthValueLabel.text == "N/A")
                holder.oneMonthValueLabel.contentDescription = UIUtil.getString(R.string.naAccessible)

            if  (holder.twelveMonthValueLabel.text == "N/A")
                holder.twelveMonthValueLabel.contentDescription = UIUtil.getString(R.string.naAccessible)

            if  (holder.mIndustryLocalValue.text == "N/A")
                holder.mIndustryLocalValue.contentDescription = UIUtil.getString(R.string.naAccessible)

            if  (holder.twelveMonthPercentLabel.text == "N/A")
                holder.twelveMonthPercentLabel.contentDescription = UIUtil.getString(R.string.naAccessible)

        }
    }

}
