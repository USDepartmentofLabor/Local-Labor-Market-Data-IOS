package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.app.PendingIntent
import android.app.TaskStackBuilder
import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Intent
import android.graphics.drawable.Drawable
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.support.v4.app.NotificationCompat
import android.support.v4.content.ContextCompat
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.Menu
import android.view.MenuItem
import android.view.View
import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import blsapp.dol.gov.blslocaldata.ui.info.InfoActivity
import kotlinx.android.synthetic.main.activity_metro_state.*
import kotlinx.android.synthetic.main.fragment_area_header.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import android.support.v7.app.AlertDialog
import blsapp.dol.gov.blslocaldata.ui.search.IndustryAdapter
import blsapp.dol.gov.blslocaldata.ui.viewmodel.*


class IndustryResultsActivity : AppCompatActivity(), IndustryAdapter.OnItemClickListener {
    companion object {
        const val KEY_AREA = "Area"
        const val PARENT_ID = "ParentId"
        const val KEY_REPORT_TYPE = "ReportType"
    }

    private lateinit var mArea: AreaEntity
    private var parentId: Long? = null
    private lateinit var viewModel: IndustryViewModel
    private lateinit var adapter: IndustryAdapter
    private lateinit var reportType: ReportRowType


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_industry_results)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)

        mArea = intent.getSerializableExtra(KEY_AREA) as AreaEntity
        parentId = intent.getSerializableExtra(PARENT_ID) as Long?
        reportType = intent.getSerializableExtra(KEY_REPORT_TYPE) as ReportRowType

        if (reportType == ReportRowType.OCCUPATIONAL_EMPLOYMENT_ITEM) {
            title = "Occupations"
        }

        leftButton.visibility = View.GONE
        rightButton.visibility = View.GONE

        areaTitleTextView.text = mArea.title
        areaTitleTextView.contentDescription = mArea.accessibilityStr

        viewModel = ViewModelProviders.of(this).get(IndustryViewModel::class.java)

        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        adapter = IndustryAdapter(this)
        recyclerView.apply {
            adapter = this@IndustryResultsActivity.adapter
            layoutManager = LinearLayoutManager(this@IndustryResultsActivity)
        }
        attachObserver()

        val decorator = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
        ContextCompat.getDrawable(this,R.drawable.divider)?.let {
            decorator.setDrawable(it) }
        recyclerView.addItemDecoration(decorator)

        viewModel.mAdjustment = ReportManager.adjustment
        mArea.let {
            viewModel.mArea = it
        }

        viewModel.setParentId(parentId)
        viewModel.setReportType(reportType)

        seasonallyAdjustedSwitch.isChecked = if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED) true else false
        seasonallyAdjustedSwitch.setOnCheckedChangeListener{ _, isChecked ->
            ReportManager.adjustment =
                    if (isChecked) SeasonalAdjustment.ADJUSTED else SeasonalAdjustment.NOT_ADJUSTED
            viewModel.setAdjustment(ReportManager.adjustment)
        }
        viewModel.getIndustries()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_area, menu)
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

    override fun onItemClick(item: IndustryRow) {
        displaySubIndustries(mArea, item)
    }

    private fun attachObserver() {
        viewModel.industryRows?.observe(this, Observer<List<IndustryRow>> {
            adapter.setIndustryRows(it!!)
        })
        viewModel.isLoading.observe(this, Observer<Boolean> {
            it?.let { showLoadingDialog(it) }
        })
        viewModel.reportError.observe(this, Observer<ReportError> {
            it?.let { showError(it) }
        })
    }

    fun displaySubIndustries(area: AreaEntity?, item: IndustryRow) {

        intent = Intent(applicationContext, IndustryResultsActivity::class.java)
        intent.putExtra(KEY_AREA, mArea)
        intent.putExtra(PARENT_ID, item.itemId)
        intent.putExtra(KEY_REPORT_TYPE, reportType)
        startActivity(intent)

    }

    private fun showLoadingDialog(show: Boolean) {
        if (show) {
            progressBar.visibility = View.VISIBLE
            if (ReportManager.adjustment == SeasonalAdjustment.ADJUSTED)
                UIUtil.accessibilityAnnounce(applicationContext, getString(R.string.loading_seasonally_adjusted_reports))
            else
                UIUtil.accessibilityAnnounce(applicationContext, getString(R.string.loading_not_seasonally_adjusted_reports))
        } else progressBar.visibility = View.GONE
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