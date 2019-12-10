package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v7.app.AppCompatActivity
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.fragments.HistoryBarChartFragment
import blsapp.dol.gov.blslocaldata.ui.area.fragments.HistoryLineGraphFragment
import blsapp.dol.gov.blslocaldata.ui.area.fragments.HistoryTableFragment
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.CountyAreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.MetroStateViewModel

import kotlinx.android.synthetic.main.activity_history.*

 class HistoryActivity: AppCompatActivity() {

     lateinit var mArea: AreaEntity
     private lateinit var viewModel: AreaViewModel

     var barChartFragment: HistoryBarChartFragment? = null
     var lineGraphFragment: HistoryLineGraphFragment? = null
     var tableFragment: HistoryTableFragment? = null

     override fun onCreate(savedInstanceState: Bundle?) {
         super.onCreate(savedInstanceState)
         getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                 WindowManager.LayoutParams.FLAG_FULLSCREEN)
         setContentView(R.layout.activity_history)

         mArea = intent.getSerializableExtra(AreaReportActivity.KEY_AREA) as AreaEntity
         viewModel = createViewModel(mArea)
         viewModel.mAdjustment = ReportManager.adjustment
         mArea.let {
             graphAreaTitle.text = it.title
             tableAreaTitle.text = it.title
             viewModel.mArea = it
             when (mArea) {
                 is MetroEntity -> {
                     localLegendName.text = getString(R.string.metro_data)
                 }
                 is StateEntity -> {
                     localLegendName.text = getString(R.string.state_data)
                 }
                 is CountyEntity -> {
                     localLegendName.text = getString(R.string.county_data)
                 }
             }
         }
         viewModel.getAreaReports()

         setupClickListeners()

         supportActionBar?.setHomeActionContentDescription("Back")
         title = getString(R.string.history_unemployment_rate)

         if (UIUtil.isTalkBackActive()) {
             graphTypeRadioGroup.check(R.id.tableViewRadioButton)
         } else {
             graphTypeRadioGroup.check(R.id.lineGraphRadioButton)
         }
        // showLineGraph()

     }

     private fun createViewModel(area: AreaEntity): AreaViewModel {
         when(area) {
             is CountyEntity -> return ViewModelProviders.of(this).get(CountyAreaViewModel::class.java)
         }

         return ViewModelProviders.of(this).get(MetroStateViewModel::class.java)
     }


     private fun setupClickListeners() {
         chartSeasonallyAdjustedSwitch.isChecked = if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED) true else false
         chartSeasonallyAdjustedSwitch.setOnCheckedChangeListener{ _, isChecked ->
             ReportManager.adjustment =
                     if (isChecked) SeasonalAdjustment.ADJUSTED else SeasonalAdjustment.NOT_ADJUSTED
             viewModel.setAdjustment(ReportManager.adjustment)
         }

         graphTypeRadioGroup.setOnCheckedChangeListener { _, checkedId ->
             when (checkedId) {
                 R.id.lineGraphRadioButton -> {
                     showLineGraph()
                     setAreaLegendVisibiity()
                 }
                 R.id.barChartRadioButton -> {
                    if (barChartFragment == null) {
                        barChartFragment = HistoryBarChartFragment.newInstance(mArea)
                    }
                     requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                     setGraphLegendVisibilty(View.VISIBLE)
                     setAreaLegendVisibiity()
                     tableAreaTitle.visibility = View.INVISIBLE
                    displayFragment(barChartFragment as HistoryBarChartFragment)
                 }
                 R.id.tableViewRadioButton -> {
                     if (tableFragment == null) {
                         tableFragment = HistoryTableFragment.newInstance(mArea)
                     }
                     requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
                     setGraphLegendVisibilty(View.INVISIBLE)
                     tableAreaTitle.visibility = View.VISIBLE
                     displayFragment(tableFragment as HistoryTableFragment)
                 }
             }

         }
         attachObserver()
     }

     override fun onOptionsItemSelected(item: MenuItem) = when (item.itemId) {
         android.R.id.home -> {
             finish()
             true
         }
         else -> {
             super.onOptionsItemSelected(item)
         }
     }

     fun showLineGraph() {
         if (lineGraphFragment == null) {
             lineGraphFragment = HistoryLineGraphFragment.newInstance(mArea)
         }
         requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
         setGraphLegendVisibilty(View.VISIBLE)
         tableAreaTitle.visibility = View.INVISIBLE
         displayFragment(lineGraphFragment as HistoryLineGraphFragment)
     }

     fun setGraphLegendVisibilty(visibiltiy: Int) {
         localLegendName.visibility = visibiltiy
         localLegendColor.visibility= visibiltiy
         nationalLegendColor.visibility = visibiltiy
         nationalLegendName.visibility = visibiltiy
         graphAreaTitle.visibility = visibiltiy
     }

     fun displayFragment(targetFragment: Fragment) {
         targetFragment?.let {
             val fragmentTransaction = supportFragmentManager.beginTransaction()
             fragmentTransaction.replace(R.id.fragmentContainer, it)
             fragmentTransaction.addToBackStack(null)
             fragmentTransaction.commit()
         }
     }
     private fun attachObserver() {
         viewModel.reportRows.observe(this, Observer<List<AreaReportRow>> {
            setAreaLegendVisibiity()
         })
     }

     private fun setAreaLegendVisibiity() {

         if (graphTypeRadioGroup.checkedRadioButtonId != R.id.tableViewRadioButton) {
             localLegendName.visibility = View.GONE
             localLegendColor.visibility = View.GONE
             nationalLegendName.visibility = View.GONE
             nationalLegendColor.visibility = View.GONE
             for (nextTitle in viewModel.history.titleList) {
                 if (nextTitle == getString(R.string.national_area)) {
                     nationalLegendName.visibility = View.VISIBLE
                     nationalLegendColor.visibility = View.VISIBLE
                 } else {
                     localLegendName.visibility = View.VISIBLE
                     localLegendColor.visibility = View.VISIBLE
                 }
             }
         }
     }

     override fun onBackPressed() {
         supportFragmentManager.popBackStackImmediate(null, FragmentManager.POP_BACK_STACK_INCLUSIVE)
         super.onBackPressed()
     }
 }
