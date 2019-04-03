package blsapp.dol.gov.blslocaldata.ui.area

import android.support.v4.content.ContextCompat
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntryHolder
import blsapp.dol.gov.blslocaldata.ui.area.viewHolders.HierarchyEntrySearchHolder
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.HierarchySearchRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.textColor

class SearchHierarchyAdapter(private val mListener: OnItemClickListener?) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

        //    private val mOnClickListener: View.OnClickListener
        var mIndustries = emptyList<HierarchySearchRow>()

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val layoutInflater = LayoutInflater.from(parent.context)
            val inflatedView = layoutInflater.inflate(R.layout.hierarchy_item_search, parent, false)
            return HierarchyEntrySearchHolder(inflatedView)
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

            val searchRow = mIndustries[position]
            if (holder is HierarchyEntrySearchHolder) {
                holder.mIndustryTitle.text = searchRow.hierarchyTitles

                with(holder.mView) {
                    tag = searchRow
                    setOnClickListener {
                        mListener?.onItemClick(searchRow)
                    }
                }
            }
        }
        override fun getItemCount(): Int = mIndustries.size

        interface OnItemClickListener {
            fun onItemClick(item: HierarchySearchRow)
        }

        fun setIndustryRows(hierarchyRows: List<HierarchySearchRow>) {
            mIndustries = hierarchyRows
            notifyDataSetChanged()
        }

    }
