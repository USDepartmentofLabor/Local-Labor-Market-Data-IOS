package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.Manifest
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.RectF
import android.net.Uri
import android.os.Bundle
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.WindowManager
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.util.DayAxisValueFormatter
import blsapp.dol.gov.blslocaldata.util.XYMarkerView

import com.github.mikephil.charting.charts.BarChart
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.components.Legend.LegendForm
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.components.XAxis.XAxisPosition
import com.github.mikephil.charting.components.YAxis
import com.github.mikephil.charting.components.YAxis.AxisDependency
import com.github.mikephil.charting.components.YAxis.YAxisLabelPosition
import com.github.mikephil.charting.data.BarData
import com.github.mikephil.charting.data.BarDataSet
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.interfaces.datasets.IBarDataSet
import com.github.mikephil.charting.interfaces.datasets.IDataSet
import com.github.mikephil.charting.listener.OnChartValueSelectedListener
import com.github.mikephil.charting.model.GradientColor
import com.github.mikephil.charting.utils.ColorTemplate
import com.github.mikephil.charting.utils.MPPointF

import java.util.ArrayList

 class HistoryBarChartActivity: AppCompatActivity(), OnSeekBarChangeListener, OnChartValueSelectedListener {

private var chart:BarChart? = null

private val onValueSelectedRectF = RectF()

     override fun onCreate(savedInstanceState: Bundle?) {
         super.onCreate(savedInstanceState)
         getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                 WindowManager.LayoutParams.FLAG_FULLSCREEN)
         setContentView(R.layout.activity_barchart)

         requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR

         supportActionBar?.setHomeActionContentDescription("Back")

         setTitle("History - Unemployment")

         chart = findViewById(R.id.chart)

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

         setData(12, 5f)
         chart!!.invalidate()

     }

     private fun getValues(count: Int, range:Float) : ArrayList<BarEntry> {
         val values = ArrayList<BarEntry>()
         val start = 1f
         var i = start.toInt()
         while (i < start + count)
         {
             val value = (Math.random() * (range + 1)).toFloat()

             if (Math.random() * 100 < 25)
             {
                 values.add(BarEntry(i.toFloat(), value, getResources().getDrawable(R.mipmap.star)))
             }
             else
             {
                 values.add(BarEntry(i.toFloat(), value))
             }
             i++
         }
         return values
     }
     private fun setData(count:Int, range:Float) {


         val values1 = getValues(count, range)
         val values2 = getValues(count, range)

         val set1:BarDataSet
         val set2:BarDataSet

         if (chart!!.data != null && chart!!.data.dataSetCount > 0)
         {
             set1 = chart!!.data.getDataSetByIndex(0) as BarDataSet
             set1.values = values1

             set2 = chart!!.data.getDataSetByIndex(0) as BarDataSet
             set2.values = values2

             chart!!.data.notifyDataChanged()
             chart!!.notifyDataSetChanged()

         }
         else
         {
             set1 = BarDataSet(values1, "National")
             set1.setDrawIcons(false)
             set1.color = ContextCompat.getColor(this, R.color.colorPrimary)

             set2 = BarDataSet(values2, "County")
             set2.setDrawIcons(false)
             set2.color = ContextCompat.getColor(this, R.color.colorHistoryButton)

             val dataSets = ArrayList<IBarDataSet>()
             dataSets.add(set1)
             dataSets.add(set2)

             val data = BarData(dataSets)
             data.barWidth = 0.2f
             data.groupBars(0.6f,0.55f,0.02f)
             data.setValueTextSize(10f)
             data.setDrawValues(false)
//             data.setValueTypeface(tfLight)

             chart!!.data = data
             data.notifyDataChanged()
         }
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
