package blsapp.dol.gov.blslocaldata.ui.search

import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R

import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.RowType

import kotlinx.android.synthetic.main.area_item.view.*
import kotlinx.android.synthetic.main.areaheader_item.view.*

/**
 * AreaListAdapter - Area List Adapter View
 */
class AreaListAdapter(
        private val mListener: OnItemClickListener?)
    : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

//    private val mOnClickListener: View.OnClickListener
    private var mAreas = emptyList<AreaRow>()

//    init {
//        mOnClickListener = View.OnClickListener { v ->
//            val item = v.tag as AreaEntity
//            mListener?.onListFragmentInteraction(item)
//        }
//    }

    fun setArea(areas: List<AreaRow>) {
        mAreas = areas
        notifyDataSetChanged()
    }


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        when (viewType) {
            RowType.HEADER.ordinal -> {
                val inflatedView = layoutInflater.inflate(R.layout.areaheader_item, parent, false)
                return AreaHeaderViewHolder(inflatedView)
            }
            else -> {
                val inflatedView = layoutInflater.inflate(R.layout.area_item, parent, false)
                return AreaViewHolder(inflatedView)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val areaRow = mAreas[position]
        if (areaRow.type == RowType.HEADER &&
                holder is AreaHeaderViewHolder) {
            holder.mheaderTextView.text = areaRow.header
            areaRow.image?.let {
                holder.mHeaderImageView.setImageResource(areaRow.image)
            }
            with(holder.mView) {
                tag = areaRow.area
                setOnClickListener {
                    mListener?.onItemClick(areaRow)
                }

            }


        } else if (holder is AreaViewHolder && areaRow.area != null) {
            holder.mTitleTextView.text = areaRow.area!!.title
            holder.mTitleTextView.contentDescription = areaRow.area!!.accessibilityStr
            with(holder.mView) {
                tag = areaRow.area
                setOnClickListener {
                    mListener?.onItemClick(areaRow)
                }

            }
        }
    }
    override fun getItemCount(): Int = mAreas.size
    override fun getItemViewType(position: Int) = mAreas[position].type.ordinal

    inner class AreaHeaderViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
        val mheaderTextView: TextView = mView.header_text
        val mHeaderImageView: ImageView = mView.header_image

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
        fun onItemClick(item: AreaRow)
    }

}
