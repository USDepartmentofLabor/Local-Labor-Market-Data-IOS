package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.support.v4.content.ContextCompat
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.Menu
import android.view.MenuItem
import android.view.View
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.info.InfoActivity
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import android.support.v7.app.AlertDialog
import android.util.AttributeSet
import blsapp.dol.gov.blslocaldata.model.reports.ReportType
import blsapp.dol.gov.blslocaldata.ui.area.fragments.HierarchyHeaderFragment
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListCESAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListQCEWAdapter
import blsapp.dol.gov.blslocaldata.ui.viewmodel.*
import kotlinx.android.synthetic.main.activity_hierarchy_results.*
import kotlinx.android.synthetic.main.fragment_area_header.*
import kotlinx.android.synthetic.main.fragment_hierarchy_header.*

/**
 * HierarchyResultsActivity - Displays a list of industries and key values associated with them
 */
class HierarchyResultsActivity : AppCompatActivity(), HierarchyListAdapter.OnItemClickListener,
                                                        HierarchyListCESAdapter.OnItemClickListener,
                                                        HierarchyListQCEWAdapter.OnItemClickListener{
    companion object {
        const val KEY_AREA = "Area"
        const val PARENT_ID = "ParentId"
        const val KEY_REPORT_TYPE = "ReportType"
        const val KEY_REPORT_ROW_TYPE = "ReportRowType"
    }

    private lateinit var mArea: AreaEntity
    private var parentId: Long? = null
    private lateinit var viewModel: HierarchyViewModel
    private lateinit var adapter: HierarchyListAdapter
    private lateinit var cesAdapter: HierarchyListCESAdapter
    private lateinit var qcewAdapter: HierarchyListQCEWAdapter
    private lateinit var reportType: ReportType
    private lateinit var industryType: ReportRowType

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_hierarchy_results)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)

        mArea = intent.getSerializableExtra(KEY_AREA) as AreaEntity
        parentId = intent.getSerializableExtra(PARENT_ID) as Long?
        reportType = intent.getSerializableExtra(KEY_REPORT_TYPE) as ReportType
        industryType = intent.getSerializableExtra(KEY_REPORT_ROW_TYPE) as ReportRowType

        viewModel = ViewModelProviders.of(this).get(HierarchyViewModel::class.java)
        viewModel.mAdjustment = ReportManager.adjustment
        if (parentId != null) viewModel.setParentId(parentId!!)
        mArea.let {
            viewModel.mArea = it
        }

        viewModel.setReportType(reportType)

        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)

        if  (viewModel.isCountyArea()) {
            qcewAdapter = HierarchyListQCEWAdapter(this)
            recyclerView.apply {
                adapter = this@HierarchyResultsActivity.qcewAdapter
                layoutManager = LinearLayoutManager(this@HierarchyResultsActivity)
            }
        } else if (viewModel.isIndustryReport()) {
            cesAdapter = HierarchyListCESAdapter(this, mArea)
            recyclerView.apply {
                adapter = this@HierarchyResultsActivity.cesAdapter
                layoutManager = LinearLayoutManager(this@HierarchyResultsActivity)
            }

        } else {
            title = getString(R.string.occupation_title)
            adapter = HierarchyListAdapter(this)
            recyclerView.apply {
                adapter = this@HierarchyResultsActivity.adapter
                layoutManager = LinearLayoutManager(this@HierarchyResultsActivity)
            }
        }
        attachObserver()

        val decorator = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
        ContextCompat.getDrawable(this,R.drawable.divider)?.let {
            decorator.setDrawable(it) }
        recyclerView.addItemDecoration(decorator)

        hierarchySeasonallyAdjustedSwitch.isChecked = if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED) true else false
        hierarchySeasonallyAdjustedSwitch.setOnCheckedChangeListener{ _, isChecked ->
            ReportManager.adjustment =
                    if (isChecked) SeasonalAdjustment.ADJUSTED else SeasonalAdjustment.NOT_ADJUSTED
            viewModel.setAdjustment(ReportManager.adjustment)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_hierarchy, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem) = when (item.itemId) {
        R.id.action_info -> {
            val intent = Intent(applicationContext, InfoActivity::class.java)
            startActivity(intent)
            true
        }
        android.R.id.home -> {
            finish()
            true
        }
        else -> {
            super.onOptionsItemSelected(item)
        }
    }

    override fun onItemClick(item: HierarchyRow) {
        displaySubIndustries(mArea, item)
    }

    private fun attachObserver() {
        viewModel.hierarchyRows?.observe(this, Observer<List<HierarchyRow>> {

            var hierarchyHeaderFragment = supportFragmentManager.findFragmentById(R.id.headerFragment) as HierarchyHeaderFragment
            hierarchyHeaderFragment.reportLoaded()

            if  (viewModel.isCountyArea()) {
                qcewAdapter.setIndustryRows(it!!)
            } else if (viewModel.isIndustryReport()) {
                cesAdapter.setIndustryRows(it!!)
            } else {
                adapter.setIndustryRows(it!!)
            }
        })
        viewModel.isLoading.observe(this, Observer<Boolean> {
            it?.let { showLoadingDialog(it) }
        })
        viewModel.reportError.observe(this, Observer<ReportError> {
            it?.let { showError(it) }
        })
    }

    fun displaySubIndustries(area: AreaEntity?, item: HierarchyRow) {

        intent = Intent(applicationContext, HierarchyResultsActivity::class.java)
        intent.putExtra(KEY_AREA, mArea)
        intent.putExtra(PARENT_ID, item.itemId)
        intent.putExtra(KEY_REPORT_TYPE, reportType)
        intent.putExtra(KEY_REPORT_ROW_TYPE, industryType)
        startActivity(intent)

    }

    private fun showLoadingDialog(show: Boolean) {
        if (show) {
            industryProgressBar.visibility = View.VISIBLE
            if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED)
                UIUtil.accessibilityAnnounce(applicationContext, getString(R.string.loading_seasonally_adjusted_reports))
            else
                UIUtil.accessibilityAnnounce(applicationContext, getString(R.string.loading_not_seasonally_adjusted_reports))
        } else industryProgressBar.visibility = View.GONE
    }

    private fun showError(error: ReportError) {
        showMessage(error.displayMessage)
    }

    private fun showMessage(message: String) {

        val builder = AlertDialog.Builder(this)
        builder.setMessage(message)
                .setCancelable(false)
                .setPositiveButton("Ok", null)
        val alert = builder.create()
        alert.show()
    }

}