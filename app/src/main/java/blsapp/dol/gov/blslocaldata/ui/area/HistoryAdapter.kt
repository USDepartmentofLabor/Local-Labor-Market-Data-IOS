package blsapp.dol.gov.blslocaldata.ui.area

import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import com.github.mikephil.charting.data.BarEntry
import kotlinx.android.synthetic.main.fragment_history_table.view.*
import kotlinx.android.synthetic.main.item_history.view.*

class HistoryAdapter: RecyclerView.Adapter<HistoryAdapter.ViewHolder>()  {

    var historyItems = mutableListOf<MutableList<BarEntry>>()
    var historyMonthYears = mutableListOf<String>()

    fun setHistoryData(historyData: MutableList<MutableList<BarEntry>>, monthYearStrs:MutableList<String>) {
        historyMonthYears = monthYearStrs
        historyItems = historyData
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        if (historyItems.count() < 1)
            return 0
        else if (historyItems.count() < 2)
            return historyItems[0].size
        else {
            return if (historyItems[0].size != 0) historyItems[0].size else historyItems[1].size
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_history, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val localData = historyItems[0]
        if (localData.count() > position) {
            holder.localValue.text = localData[position].y.toString() + "%"
        } else {
            holder.localValue.text = " "
        }

        if (historyItems.count() > 1) {
            val nationalData = historyItems[1]
            if (nationalData.count() > position) {
                holder.nationalValue.text = nationalData[position].y.toString() + "%"
            } else {
                holder.nationalValue.text = " "
            }
        }
        if (historyMonthYears.count() > position) {
            holder.monthYear.text = historyMonthYears[position]
        }
    }

    inner class ViewHolder(val mView: View) : RecyclerView.ViewHolder(mView) {
        val monthYear: TextView = mView.monthYearValue
        val localValue: TextView = mView.localValue
        val nationalValue: TextView = mView.nationalValue
    }
}