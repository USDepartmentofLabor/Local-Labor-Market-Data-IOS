package blsapp.dol.gov.blslocaldata.ui.area.fragments

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.content.res.Configuration
import android.graphics.RectF
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.content.ContextCompat
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.CountyEntity
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.ui.area.activities.HistoryActivity
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.CountyAreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.MetroStateViewModel
import blsapp.dol.gov.blslocaldata.util.DayAxisValueFormatter
import blsapp.dol.gov.blslocaldata.util.XYMarkerView
import com.github.mikephil.charting.charts.BarChart
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.components.YAxis
import com.github.mikephil.charting.data.BarData
import com.github.mikephil.charting.data.BarDataSet
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.interfaces.datasets.IBarDataSet
import com.github.mikephil.charting.listener.OnChartValueSelectedListener
import com.github.mikephil.charting.utils.MPPointF
import kotlinx.android.synthetic.main.fragment_history_bar_chart.*
import java.util.ArrayList
import java.io.Serializable

const val X_ITEM_COUNT = 13

class HistoryBarChartFragment : Fragment(), OnChartValueSelectedListener {

    private var chart:BarChart? = null
    private val onValueSelectedRectF = RectF()

    lateinit var mArea: AreaEntity
    private lateinit var viewModel: AreaViewModel

    private var graphStartingIndex = 0
    private var graphEndingIndex = X_ITEM_COUNT

    private lateinit var rootView:View
    private lateinit var historyActivity: HistoryActivity
    private var maxYaxis = 0.0f
    private var minYaxis = 0.0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        arguments?.let {
            if (it.get(KEY_AREA) != null) {
                mArea = it.getSerializable(KEY_AREA) as AreaEntity
            }
        }
        viewModel = createViewModel(mArea)
        viewModel.mAdjustment = ReportManager.adjustment
        viewModel.reportRows.observe(this, Observer<List<AreaReportRow>> {
            setupChart()
        })
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.fragment_history_bar_chart, container, false)
        chart = rootView.findViewById(R.id.barChart)
        return rootView
    }

    override fun onResume() {
        super.onResume()
        if (viewModel.historyBarGraphValues.count() > 0) {
            setupChart()
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        historyActivity = context as HistoryActivity
    }


    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        setupClickListeners()
    }
    private fun createViewModel(area: AreaEntity): AreaViewModel {
        when(area) {
            is CountyEntity -> return ViewModelProviders.of(historyActivity).get(CountyAreaViewModel::class.java)
        }
        return ViewModelProviders.of(historyActivity).get(MetroStateViewModel::class.java)
    }

    private fun setupClickListeners() {
        previousButton.setOnClickListener {

            if (viewModel.historyBarGraphValues[0].count() > 0 && graphEndingIndex < viewModel.historyBarGraphValues[0].count()) {
                graphStartingIndex += 1
                graphEndingIndex += 1
                setupChart()
            }
            setDirectionButtonVisibility()
        }
        nextButton.setOnClickListener {
            if (graphStartingIndex > 0) {
                graphStartingIndex -= 1
                graphEndingIndex -= 1
                setupChart()
            }
            setDirectionButtonVisibility()
        }
    }

    private fun setDirectionButtonVisibility() {

        nextButton.visibility = if (graphStartingIndex <= 0) View.GONE
        else View.VISIBLE

        previousButton.visibility = if (graphEndingIndex >= viewModel.historyBarGraphValues[0].count()) View.GONE
        else View.VISIBLE
    }

    private fun setupChart() {
        viewModel.extractHistoryData()
        calcMaxYaxisValue()
        setChartLayout()
        displayChart()
    }

    private fun calcMaxYaxisValue() {
        maxYaxis = 0.0f
        minYaxis = 100.0f
        for (nextValuesList in viewModel.historyBarGraphValues) {
            for (nextValue in nextValuesList){
                if (nextValue.y > maxYaxis) {
                    maxYaxis = nextValue.y
                }
                if (nextValue.y < minYaxis) {
                    minYaxis = nextValue.y
                }
            }
        }
        minYaxis -= 0.5f
    }

    private fun setChartLayout() {

        chart!!.setOnChartValueSelectedListener(this)
        chart!!.setDrawBarShadow(false)
        chart!!.setDrawValueAboveBar(true)

        chart!!.description.isEnabled = false
        chart!!.setPinchZoom(false)
        chart!!.setDrawGridBackground(false)

        var xAxisFormatter:IAxisValueFormatter? = null

        val xAxis = chart!!.xAxis
        xAxis.position = XAxis.XAxisPosition.BOTTOM
        xAxis.setDrawGridLines(false)
        xAxis.granularity = 1f // only intervals of 1 day
        xAxis.labelCount = X_ITEM_COUNT
        xAxis.valueFormatter = xAxisFormatter
        xAxisLabel.text = "Month and Year"

        val leftAxis = chart!!.axisLeft
        leftAxis.setLabelCount(6, false)
        leftAxis.setDrawGridLines(false)
        leftAxis.setPosition(YAxis.YAxisLabelPosition.OUTSIDE_CHART)
        leftAxis.spaceTop = 15f
        leftAxis.axisMinimum = minYaxis
        leftAxis.axisMaximum = maxYaxis

        chart!!.axisRight.setEnabled(false);

        val l = chart!!.legend
        l.isEnabled = false

    }
    private fun displayChart() {

        if (viewModel.historyBarGraphValues.count() < 2 || viewModel.historyBarGraphValues[1].count() < X_ITEM_COUNT) {
            return
        }
        var xAxisFormatter:IAxisValueFormatter? = null
        if (viewModel.historyXAxisLabels.count() > X_ITEM_COUNT) {
            val xAxisLabelsSub = viewModel.historyXAxisLabels.subList(graphStartingIndex, graphEndingIndex).toMutableList()
            xAxisLabelsSub.reverse()
            xAxisLabelsSub.add(0, " ")
            chart?.let {
                xAxisFormatter = DayAxisValueFormatter(it, xAxisLabelsSub.toTypedArray())
            }
        }

        xAxisFormatter?.let {
            val mv = XYMarkerView(historyActivity, it)
            mv.setChartView(chart) // For bounds control
            chart!!.setMarker(mv) // Set the marker to the chart
        }

        chart!!.xAxis.valueFormatter = xAxisFormatter

        if (viewModel.historyBarGraphValues[0].count() < X_ITEM_COUNT) return

        val values1 = adjustBarEntriesForVisibleChart(viewModel.historyBarGraphValues[0])

        if (viewModel.historyBarGraphValues.count() > 1 && viewModel.historyBarGraphValues[1].count() > X_ITEM_COUNT) {
            val values2 = adjustBarEntriesForVisibleChart(viewModel.historyBarGraphValues[1])
            val values: MutableList<MutableList<BarEntry>> = mutableListOf(values1, values2)
            loadDataIntoChart(viewModel.historyTitleList, values)
        } else {
            val values: MutableList<MutableList<BarEntry>> = mutableListOf(values1)
            loadDataIntoChart(viewModel.historyTitleList, values)
        }

        chart!!.invalidate()
    }

    private fun adjustBarEntriesForVisibleChart (inList: MutableList<BarEntry>):MutableList<BarEntry> {
        val tmpSet = inList.subList(graphStartingIndex, graphEndingIndex)
        val retValues = tmpSet.sortedBy { it.x }.toMutableList()
        var nextIndex = 1
        for (nextItem in tmpSet) {
            nextItem.x = nextIndex.toFloat()
            nextIndex++
        }
        return retValues
    }

    private fun loadDataIntoChart(titles:MutableList<String>,
                                  values:MutableList<MutableList<BarEntry>>) {

        val set1:BarDataSet
        val set2:BarDataSet

        if (values.count() > 1) {

            val dataSets = ArrayList<IBarDataSet>()

            set1 = BarDataSet(values[0], titles[0])
            set1.color = ContextCompat.getColor(historyActivity, R.color.colorNationalGraphBar)
            dataSets.add(set1)

            set2 = BarDataSet(values[1], titles[1])
            set2.color = ContextCompat.getColor(historyActivity, R.color.colorLocalGraphBar)
            dataSets.add(set2)

            val data = BarData(dataSets)
            data.barWidth = 0.2f
            data.groupBars(0.6f, 0.55f, 0.02f)
            data.setValueTextSize(10f)
            data.setDrawValues(true)
            chart!!.data = data

            data.notifyDataChanged()
            chart!!.notifyDataSetChanged()
        }
    }

    override fun onValueSelected(e:Entry?, h:Highlight) {

        if (e == null)
            return

        val bounds = onValueSelectedRectF
        chart!!.getBarBounds(e as BarEntry?, bounds)
        val position = chart!!.getPosition(e, YAxis.AxisDependency.LEFT)

        Log.i("GGG", "bounds:" + bounds.toString())
        Log.i("GGG","position:" + position.toString())

        Log.i("GGG" ,"x-index " +
                "low: " + chart!!.lowestVisibleX + ", high: "
                + chart!!.highestVisibleX)

        MPPointF.recycleInstance(position)
    }

    override fun onNothingSelected() {}

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)

        val orientation : Int = getResources().getConfiguration().orientation
        val oTag = "Orientation Change"

        if(orientation == (Configuration.ORIENTATION_LANDSCAPE)){
            Log.i(oTag, "Orientation Changed to Landscape")

        }else if (orientation == (Configuration.ORIENTATION_PORTRAIT)){
            Log.i(oTag, "Orientation Changed to Portratit")
        }else{
            Log.i(oTag, "Nothing is coming!!")
        }
    }

    companion object {

        const val KEY_AREA = "Area"

        @JvmStatic
        fun newInstance(area: Serializable?) =
                HistoryBarChartFragment().apply {
                    arguments = Bundle().apply {
                        if (area != null)
                            putSerializable(KEY_AREA, area)
                    }
                }
    }
}
