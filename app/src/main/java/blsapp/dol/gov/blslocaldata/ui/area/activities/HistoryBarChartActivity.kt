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

 class HistoryBarChartActivity: AppCompatActivity(), OnSeekBarChangeListener, OnChartValueSelectedListener {

    private var chart:BarChart? = null

    private val onValueSelectedRectF = RectF()

     lateinit var mArea: AreaEntity
     private lateinit var viewModel: AreaViewModel

     private var valueLists = mutableListOf<MutableList<BarEntry>>()
     private var titleList = mutableListOf<String>()

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

         loadDataIntoChart()

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
         chart?.let {
             xAxisFormatter = DayAxisValueFormatter(it)
         }

         val xAxis = chart!!.xAxis
         xAxis.position = XAxisPosition.BOTTOM
         xAxis.setDrawGridLines(false)
         xAxis.granularity = 1f // only intervals of 1 day
         xAxis.labelCount = 12
         xAxis.valueFormatter = xAxisFormatter

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

     private fun loadDataIntoChart() {

         val set1:BarDataSet
         val set2:BarDataSet

         if (chart!!.data != null && chart!!.data.dataSetCount > 0 && false)
         {
             if (valueLists.count() > 0) {
                 set1 = chart!!.data.getDataSetByIndex(0) as BarDataSet
                 set1.values = valueLists[0]

                 if (valueLists.count() > 1) {
                     set2 = chart!!.data.getDataSetByIndex(0) as BarDataSet
                     set2.values = valueLists[1]
                 }

                 chart!!.data.notifyDataChanged()
                 chart!!.notifyDataSetChanged()
             }
         }
         else
         {
             if (valueLists.count() > 0) {

                 val dataSets = ArrayList<IBarDataSet>()

                 set1 = BarDataSet(valueLists[0], titleList[0])
                 set1.setDrawIcons(false)
                 set1.color = ContextCompat.getColor(this, R.color.colorPrimary)
                 dataSets.add(set1)

                 if (valueLists.count() > 1) {
                     set2 = BarDataSet(valueLists[1], titleList[1])
                     set2.setDrawIcons(false)
                     set2.color = ContextCompat.getColor(this, R.color.colorHistoryButton)
                     dataSets.add(set2)
                 }

                 val data = BarData(dataSets)
                 data.barWidth = 0.2f
                 if (valueLists.count() > 1) {
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
                 val retList =  processSeriesData(areaReportRow.areaReports)
                 retList.let {
                     valueLists.add(it)
                     areaReportRow.areaType?.let {
                         titleList.add(it)
                     }
                 }
             }
         }
     }

     fun processSeriesData(areaReportRows: List<AreaReport>):MutableList<BarEntry> {

         var values = mutableListOf<BarEntry>()
         var items: SeriesReport? = null

         for (areaReport in areaReportRows) {
             if (areaReport.seriesReport != null) {
                 items = areaReport.seriesReport
                 break
             }
         }

         xAxisLabel.text = "2019"
         val yearToMatch = 2019
         var nextItem = 0
         for (i in 12 downTo 1) {
             val nextMonthDataItem = items!!.data[nextItem].period.replace("M","")
             if (i == nextMonthDataItem.toInt()) {
                 Log.i("GGG", "Graph Item :" + i +" - " + items!!.data[nextItem].value.toFloat())
                 values.add(BarEntry(i.toFloat(), items!!.data[nextItem].value.toFloat()))
                 nextItem++
             } else {
                 Log.i("GGG", "Graph Item :" + i + " - 0.0")
                 values.add(BarEntry(i.toFloat(), 0.0f))
             }
         }

         values.reverse()

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
