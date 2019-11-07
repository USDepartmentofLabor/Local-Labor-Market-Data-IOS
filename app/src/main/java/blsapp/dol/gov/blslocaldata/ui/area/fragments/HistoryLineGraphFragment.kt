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
import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.components.YAxis
import com.github.mikephil.charting.data.*
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet
import com.github.mikephil.charting.listener.OnChartValueSelectedListener
import com.github.mikephil.charting.utils.MPPointF
import kotlinx.android.synthetic.main.fragment_history_bar_chart.*
import java.io.Serializable
import java.util.ArrayList

const val LINE_X_ITEM_COUNT = 25

class HistoryLineGraphFragment : Fragment(), OnChartValueSelectedListener {

    private lateinit var chart: LineChart
    private val onValueSelectedRectF = RectF()

    lateinit var mArea: AreaEntity
    private lateinit var viewModel: AreaViewModel

    private var graphStartingIndex = 0
    private var graphEndingIndex = LINE_X_ITEM_COUNT

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
        rootView = inflater.inflate(R.layout.fragment_history_line_graph, container, false)
        chart = rootView.findViewById(R.id.lineChart)
        return rootView
    }

    override fun onResume() {
        super.onResume()
        if (viewModel.history.lineGraphValues.count() > 0) {
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
    private fun setupChart() {
        calcMaxYaxisValue()
        setChartLayout()
        displayChart()
        setDirectionButtonVisibility()
    }

    private fun calcMaxYaxisValue() {
        maxYaxis = 0.0f
        minYaxis = 100.0f
        for (nextValuesList in viewModel.history.lineGraphValues) {
            for (nextValue in nextValuesList){
                if (nextValue.y > maxYaxis) {
                    maxYaxis = nextValue.y
                }
                if (nextValue.y < minYaxis) {
                    minYaxis = nextValue.y
                }
            }
        }
    }

    private fun setupClickListeners() {
        previousButton.setOnClickListener {

            if (viewModel.history.lineGraphValues[0].count() > 0 && graphEndingIndex < viewModel.history.lineGraphValues[0].count()) {
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

        previousButton.visibility = if (graphEndingIndex >= viewModel.history.lineGraphValues[0].count()) View.GONE
        else View.VISIBLE
    }

    private fun setChartLayout() {

        chart.setOnChartValueSelectedListener(this)

        chart.description.isEnabled = false

        // if more than 60 entries are displayed in the chart, no values will be
        // drawn
        // chart.setMaxVisibleValueCount(60)
        chart.setPinchZoom(false)
        chart.setDrawGridBackground(false)

        var xAxisFormatter: IAxisValueFormatter? = null

        val xAxis = chart.xAxis
        xAxis.position = XAxis.XAxisPosition.BOTTOM
        xAxis.setDrawGridLines(false)
        xAxis.granularity = 0.5f // only intervals of 1 day
        xAxis.labelCount = 12
        xAxis.valueFormatter = xAxisFormatter
        xAxisLabel.text = "Month and Year"

        val leftAxis = chart.axisLeft
        leftAxis.setLabelCount(6, false)
        leftAxis.setDrawGridLines(false)
        leftAxis.setPosition(YAxis.YAxisLabelPosition.OUTSIDE_CHART)
        leftAxis.spaceTop = 15f
        leftAxis.axisMinimum = minYaxis // this replaces setStartAtZero(true)
        leftAxis.axisMaximum = maxYaxis

        chart.axisRight.setEnabled(false);

        val l = chart.legend
        // l.form = Legend.LegendForm.LINE
        l.isEnabled = false
    }
    private fun displayChart() {
//
//        if (viewModel.history.lineGraphValues.count() < 2 || viewModel.history.lineGraphValues[1].count() < LINE_X_ITEM_COUNT) {
//            return
//        }
        var xAxisFormatter: IAxisValueFormatter? = null
        if (viewModel.history.xAxisLabels.count() > LINE_X_ITEM_COUNT) {
            chart?.let {
                val xAxisLabelsSub = viewModel.history.xAxisLabels.toMutableList()
                xAxisLabelsSub.reverse()
                xAxisFormatter = DayAxisValueFormatter(it, xAxisLabelsSub.toTypedArray())
            }
        }

        xAxisFormatter?.let {
            val mv = XYMarkerView(historyActivity, it)
            mv.setChartView(chart) // For bounds control
            chart.setMarker(mv) // Set the marker to the chart
        }

        chart.xAxis.valueFormatter = xAxisFormatter

        var values1 = mutableListOf<Entry>()

        if (viewModel.history.lineGraphValues[0].count()>= X_ITEM_COUNT) {
            values1 = viewModel.history.lineGraphValues[0].subList(graphStartingIndex, graphEndingIndex)
        }

        if (viewModel.history.lineGraphValues.count() > 1 && viewModel.history.lineGraphValues[1].count() > LINE_X_ITEM_COUNT) {
            val values2 = viewModel.history.lineGraphValues[1].subList(graphStartingIndex, graphEndingIndex)
            val values: MutableList<MutableList<Entry>> = mutableListOf(values1, values2)
            loadDataIntoChart(viewModel.history.titleList, values)
        } else {
            val values: MutableList<MutableList<Entry>> = mutableListOf(values1)
            loadDataIntoChart(viewModel.history.titleList, values)
        }

        chart.invalidate()
    }

    private fun loadDataIntoChart(titles:MutableList<String>,
                                  values:MutableList<MutableList<Entry>>) {

        val set1: LineDataSet
        val set2: LineDataSet

        if (values.count() > 0) {

            val dataSets = ArrayList<ILineDataSet>()

            set1 = LineDataSet(values[0].sortedBy { it.x }, titles[0])
            set1.setLineWidth(2.5f)
            set1.setCircleRadius(4f)
            set1.setDrawIcons(false)
            set1.color = ContextCompat.getColor(historyActivity, R.color.colorLocalGraphBar)
            dataSets.add(set1)

            if (values.count() > 1) {
                set2 = LineDataSet(values[1].sortedBy { it.x }, titles[1])
                set2.setLineWidth(2.5f)
                set2.setCircleRadius(4f)
                set2.setDrawIcons(false)
                set2.color = ContextCompat.getColor(historyActivity, R.color.colorNationalGraphBar)
                dataSets.add(set2)
            }

            val data = LineData(dataSets)

            data.setValueTextSize(10f)
            data.setDrawValues(false)

            chart.data = data
        }
    }

    override fun onValueSelected(e: Entry?, h: Highlight) {

        if (e == null)
            return

        val bounds = onValueSelectedRectF
//        chart.getBarBounds(e as BarEntry?, bounds)
        val position = chart.getPosition(e, YAxis.AxisDependency.LEFT)

        Log.i("GGG", "bounds:" + bounds.toString())
        Log.i("GGG","position:" + position.toString())

        Log.i("GGG" ,"x-index " +
                "low: " + chart.lowestVisibleX + ", high: "
                + chart.highestVisibleX)

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
                HistoryLineGraphFragment().apply {
                    arguments = Bundle().apply {
                        if (area != null)
                            putSerializable(KEY_AREA, area)
                    }
                }
    }
}
