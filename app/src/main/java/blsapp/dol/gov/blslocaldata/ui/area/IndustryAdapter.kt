package blsapp.dol.gov.blslocaldata.ui.search

import android.support.v4.content.ContextCompat
import android.support.v4.content.ContextCompat.getColor
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity
import blsapp.dol.gov.blslocaldata.model.DataUtil
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.IndustryItemHolder
import blsapp.dol.gov.blslocaldata.ui.viewmodel.IndustryRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.RowType

import kotlinx.android.synthetic.main.area_item.view.*
import kotlinx.android.synthetic.main.areaheader_item.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.textColor

class IndustryAdapter(
        private val mListener: OnItemClickListener?)
    : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

//    private val mOnClickListener: View.OnClickListener
    private var mIndustries = emptyList<IndustryRow>()


    fun setIndustries(industries: List<IndustryRow>) {
        mIndustries = industries
        notifyDataSetChanged()
    }


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val inflatedView = layoutInflater.inflate(R.layout.industry_item, parent, false)
        return IndustryItemHolder(inflatedView)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        val areaRow = mIndustries[position]
        if (holder is IndustryItemHolder) {
            if (position == 0) {
                holder.mView.backgroundColor = getColor(holder.itemView.context, R.color.colorPrimary)
                holder.mIndustryTitle.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
                holder.mIndustryNationalValue.textColor = getColor(holder.itemView.context, R.color.colorPrimaryText)
            } else {
                holder.mView.backgroundColor = getColor(holder.itemView.context,android.R.color.white)
                holder.mIndustryTitle.textColor = getColor(holder.itemView.context,android.R.color.black)
                holder.mIndustryLocalValue.textColor = getColor(holder.itemView.context, android.R.color.black)
                holder.mIndustryNationalValue.textColor = getColor(holder.itemView.context, android.R.color.black)
            }
            holder.mIndustryTitle.text = areaRow.title

            holder.mIndustryLocalValue.text = DataUtil.currencyValue(areaRow.localValue!!)
            holder.mIndustryNationalValue.text = DataUtil.currencyValue(areaRow.nationalValue!!)

            if (areaRow.superSector!!) {
                holder.mSubIndustryIndicator.visibility = View.VISIBLE

                with(holder.mView) {
                    tag = areaRow.industry
                    setOnClickListener {
                        mListener?.onItemClick(areaRow)
                    }
                }
            } else {
                holder.mSubIndustryIndicator.visibility = View.GONE
            }
        }
    }
    override fun getItemCount(): Int = mIndustries.size
    override fun getItemViewType(position: Int) = mIndustries[position].type.ordinal

    inner class AreaHeaderViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
        val mheaderTextView: TextView = mView.header_text

        override fun toString(): String {
            return super.toString() + " '" + mheaderTextView.text + "'"
        }
    }

    inner class AreaViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
        val mTitleTextView: TextView = mView.title

        override fun toString(): String {
            return super.toString() + " '" + mTitleTextView.text + "'"
        }
    }

    interface OnItemClickListener {
        fun onItemClick(item: IndustryRow)
    }

    fun setIndustryRows(industryRows: List<IndustryRow>) {
        mIndustries = industryRows
        notifyDataSetChanged()
    }

}
