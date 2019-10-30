package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.RectF
import android.os.Bundle
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.WindowManager
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.SeriesReport
import blsapp.dol.gov.blslocaldata.model.reports.AreaReport
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.CountyAreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.MetroStateViewModel
import blsapp.dol.gov.blslocaldata.util.DayAxisValueFormatter

import com.github.mikephil.charting.charts.BarChart
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.components.Legend.LegendForm
import com.github.mikephil.charting.components.XAxis.XAxisPosition
import com.github.mikephil.charting.components.YAxis.AxisDependency
import com.github.mikephil.charting.components.YAxis.YAxisLabelPosition
import com.github.mikephil.charting.data.BarData
import com.github.mikephil.charting.data.BarDataSet
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.interfaces.datasets.IBarDataSet
import com.github.mikephil.charting.listener.OnChartValueSelectedListener
import com.github.mikephil.charting.utils.MPPointF
import kotlinx.android.synthetic.main.activity_barchart.*

import java.util.ArrayList

const val X_ITEM_COUNT = 12

 class HistoryBarChartActivity: AppCompatActivity(), OnSeekBarChangeListener, OnChartValueSelectedListener {

    private var chart:BarChart? = null

    private val onValueSelectedRectF = RectF()

     lateinit var mArea: AreaEntity
     private lateinit var viewModel: AreaViewModel

     private var valueLists = mutableListOf<MutableList<BarEntry>>()
     private var titleList = mutableListOf<String>()
     private var xAxisLabels = mutableListOf<String>()

     override fun onCreate(savedInstanceState: Bundle?) {
         super.onCreate(savedInstanceState)
         getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                 WindowManager.LayoutParams.FLAG_FULLSCREEN)
         setContentView(R.layout.activity_barchart)

         mArea = intent.getSerializableExtra(AreaReportActivity.KEY_AREA) as AreaEntity
         viewModel = createViewModel(mArea)
         viewModel.mAdjustment = ReportManager.adjustment
         mArea.let {
             areaTitle.text = it.title
             viewModel.mArea = it
         }
         chartSeasonallyAdjustedSwitch.isChecked = if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED) true else false
         chartSeasonallyAdjustedSwitch.setOnCheckedChangeListener{ _, isChecked ->
             ReportManager.adjustment =
                     if (isChecked) SeasonalAdjustment.ADJUSTED else SeasonalAdjustment.NOT_ADJUSTED
             viewModel.setAdjustment(ReportManager.adjustment)
         }
         attachObserver()
         viewModel.getAreaReports()


         requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR
         supportActionBar?.setHomeActionContentDescription("Back")
         title = "History - Unemployment"

     }

     private fun createViewModel(area: AreaEntity): AreaViewModel {
         when(area) {
             is CountyEntity -> return ViewModelProviders.of(this).get(CountyAreaViewModel::class.java)
         }

         return ViewModelProviders.of(this).get(MetroStateViewModel::class.java)
     }

     private fun attachObserver() {
         viewModel.reportRows.observe(this, Observer<List<AreaReportRow>> {

             displayChart(it)
             //adapter.setReportRows(it!!)
             // recyclerView.smoothScrollToPosition(adapter.itemCount -1)
         })
         viewModel.isLoading.observe(this, Observer<Boolean> {
            // it?.let { showLoadingDialog(it) }
         })
         viewModel.reportError.observe(this, Observer<ReportError> {
           //  it?.let { showError(it) }
         })
     }

     private fun displayChart(areaReportRows: List <AreaReportRow>?) {

         chart = findViewById(R.id.chart)

         buildChartData(areaReportRows)

         setChartLayout()

         val startIndex = 0
         val endIndex = X_ITEM_COUNT
         val titles = titleList
         var xAxisFormatter:IAxisValueFormatter? = null

         if (xAxisLabels.count() > X_ITEM_COUNT) {
             val xAxisLabelsSub = xAxisLabels.subList(startIndex, endIndex)
             xAxisLabelsSub.reverse()
             chart?.let {
                 xAxisFormatter = DayAxisValueFormatter(it, xAxisLabelsSub.toTypedArray())
             }
         } else {
             chart?.let {
                 xAxisFormatter = DayAxisValueFormatter(it, arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
             }
         }
         chart!!.xAxis.valueFormatter = xAxisFormatter

         if (valueLists[0].count() < X_ITEM_COUNT) return

         val values1 = valueLists[0].subList(startIndex, endIndex)

         if (valueLists.count() > 1 && valueLists[1].count() > X_ITEM_COUNT) {
             val values2 = valueLists[1].subList(startIndex, endIndex)
             val values: MutableList<MutableList<BarEntry>> = mutableListOf(values1, values2)
             loadDataIntoChart(titles, values)
         } else {
             val values: MutableList<MutableList<BarEntry>> = mutableListOf(values1)
             loadDataIntoChart(titles, values)
         }

         chart!!.invalidate()
     }

     private fun setChartLayout() {

         chart!!.setOnChartValueSelectedListener(this)
         chart!!.setDrawBarShadow(false)
         chart!!.setDrawValueAboveBar(true)

         chart!!.description.isEnabled = false

         // if more than 60 entries are displayed in the chart, no values will be
         // drawn
         chart!!.setMaxVisibleValueCount(60)
         chart!!.setPinchZoom(false)
         chart!!.setDrawGridBackground(false)

         var xAxisFormatter:IAxisValueFormatter? = null

         val xAxis = chart!!.xAxis
         xAxis.position = XAxisPosition.BOTTOM
         xAxis.setDrawGridLines(false)
         xAxis.granularity = 1f // only intervals of 1 day
         xAxis.labelCount = X_ITEM_COUNT
         xAxis.valueFormatter = xAxisFormatter
         xAxisLabel.text = "Month and Year"

         val leftAxis = chart!!.axisLeft
         leftAxis.setLabelCount(6, false)
         leftAxis.setDrawGridLines(false)
         leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
         leftAxis.spaceTop = 15f
         leftAxis.axisMinimum = 0f // this replaces setStartAtZero(true)

         chart!!.axisRight.setEnabled(false);

         val l = chart!!.legend
         l.verticalAlignment = Legend.LegendVerticalAlignment.TOP
         l.horizontalAlignment = Legend.LegendHorizontalAlignment.RIGHT
         l.orientation = Legend.LegendOrientation.VERTICAL
         l.setDrawInside(false)
         l.form = LegendForm.SQUARE
         l.formSize = 9f
         l.textSize = 11f
         l.xEntrySpace = 4f
     }

     private fun loadDataIntoChart(titles:MutableList<String>,
                                   values:MutableList<MutableList<BarEntry>>) {

         val set1:BarDataSet
         val set2:BarDataSet

         if (chart!!.data != null && chart!!.data.dataSetCount > 0 && false)
         {
             if (values.count() > 0) {
                 set1 = chart!!.data.getDataSetByIndex(0) as BarDataSet
                 set1.values = values[0]

                 if (values.count() > 1) {
                     set2 = chart!!.data.getDataSetByIndex(0) as BarDataSet
                     set2.values = values[1]
                 }

                 chart!!.data.notifyDataChanged()
                 chart!!.notifyDataSetChanged()
             }
         }
         else
         {
             if (values.count() > 0) {

                 val dataSets = ArrayList<IBarDataSet>()

                 set1 = BarDataSet(values[0], titles[0])
                 set1.setDrawIcons(false)
                 set1.color = ContextCompat.getColor(this, R.color.colorPrimary)
                 dataSets.add(set1)

                 if (values.count() > 1) {
                     set2 = BarDataSet(values[1], titles[1])
                     set2.setDrawIcons(false)
                     set2.color = ContextCompat.getColor(this, R.color.colorHistoryButton)
                     dataSets.add(set2)
                 }

                 val data = BarData(dataSets)
                 data.barWidth = 0.2f
                 if (values.count() > 1) {
                     data.groupBars(0.6f, 0.55f, 0.02f)
                 }
                 data.setValueTextSize(10f)
                 data.setDrawValues(false)
//             data.setValueTypeface(tfLight)

                 chart!!.data = data
                 data.notifyDataChanged()
             }
         }
     }

     fun buildChartData(areaReportRows:List<AreaReportRow>?) {

         valueLists = mutableListOf<MutableList<BarEntry>>()
         titleList = mutableListOf<String>()

         if (areaReportRows == null) return
         var items: SeriesReport? = null
         for (areaReportRow in areaReportRows!!) {
             if (areaReportRow.areaReports != null) {
                 areaReportRow.areaType?.let {
                     Log.i("GGG", "Processing: " + it)
                 }
                 val retList =  processSeriesData(areaReportRow.areaReports)
                 retList.let {
                     areaReportRow.areaType?.let {
                         titleList.add(it)
                     }
                     valueLists.add(it)
                 }
             }
         }
     }

     fun processSeriesData(areaReportRows: List<AreaReport>):MutableList<BarEntry> {

         var values = mutableListOf<BarEntry>()
         var items: SeriesReport? = null

         xAxisLabels = mutableListOf<String>()

         for (areaReport in areaReportRows) {
             if (areaReport.seriesReport != null) {
                 items = areaReport.seriesReport
                 break
             }
         }
         var nextIndex = X_ITEM_COUNT
         for (nextItem in items!!.data) {
             val nextMonthDataItem = nextItem.period.replace("M","")
             values.add(BarEntry(nextIndex.toFloat(), nextItem.value.toFloat()))
             val nextXlabel = nextItem.periodName.substring(0,3) + " " + nextItem.year.substring(2,4)
             Log.i("GGG", "Graph Item :" + nextXlabel + " - " + nextItem.value.toFloat())
             xAxisLabels.add(nextXlabel)
             nextIndex--
             if (nextIndex == 0) nextIndex = X_ITEM_COUNT
         }

         return values

     }

     override fun onProgressChanged(seekBar:SeekBar, progress:Int, fromUser:Boolean) {


     }

     override fun onStartTrackingTouch(seekBar:SeekBar) {}

     override fun onStopTrackingTouch(seekBar:SeekBar) {}

     override fun onValueSelected(e:Entry?, h:Highlight) {

         if (e == null)
             return

         val bounds = onValueSelectedRectF
         chart!!.getBarBounds(e as BarEntry?, bounds)
         val position = chart!!.getPosition(e, AxisDependency.LEFT)

         Log.i("bounds", bounds.toString())
         Log.i("position", position.toString())

         Log.i("x-index",
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
 }
