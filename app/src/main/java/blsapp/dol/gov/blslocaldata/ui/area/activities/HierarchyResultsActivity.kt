package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.content.Intent
import android.net.Uri
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
import android.support.v7.widget.SearchView
import android.util.AttributeSet
import blsapp.dol.gov.blslocaldata.model.HierarchyModel
import blsapp.dol.gov.blslocaldata.model.reports.ReportType
import blsapp.dol.gov.blslocaldata.ui.area.fragments.HierarchyHeaderFragment
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListCESAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListQCEWAdapter
import blsapp.dol.gov.blslocaldata.ui.search.SearchActivity
import blsapp.dol.gov.blslocaldata.ui.viewmodel.*
import kotlinx.android.synthetic.main.activity_hierarchy_results.*
import kotlinx.android.synthetic.main.fragment_area_header.*
import kotlinx.android.synthetic.main.fragment_hierarchy_header.*



/**
 * HierarchyResultsActivity - Displays a list of industries and key values associated with them
 */
class HierarchyResultsActivity : AppCompatActivity(), HierarchyListAdapter.OnItemClickListener,
                                                        HierarchyListCESAdapter.OnItemClickListener,
                                                        HierarchyListQCEWAdapter.OnItemClickListener,
                                                        HierarchyHeaderFragment.OnFragmentInteractionListener{

    companion object {
        const val KEY_AREA = "Area"
        const val PARENT_ID = "ParentId"
        const val PARENT_NAME = "ParentName"
        const val HIERARCY_STRING = "HierarchyString"
        const val HIERARCY_ARRAY = "HierarchyArray"
        const val KEY_REPORT_TYPE = "ReportType"
        const val KEY_REPORT_ROW_TYPE = "ReportRowType"
    }

    private lateinit var mArea: AreaEntity
    private var parentId: Long? = null
    private var parentName: String? = null
    private lateinit var viewModel: HierarchyViewModel
    private lateinit var adapter: HierarchyListAdapter
    private lateinit var cesAdapter: HierarchyListCESAdapter
    private lateinit var qcewAdapter: HierarchyListQCEWAdapter
    private lateinit var reportType: ReportType
    private lateinit var industryType: ReportRowType
    private lateinit var hierarchyHeaderFragment: HierarchyHeaderFragment

    private var hierarchyString: String? = null
    private var hierarchyIDArray: Array<Long>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_hierarchy_results)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)
        supportActionBar?.setHomeAsUpIndicator(R.drawable.ic_baseline_home_24px)
        supportActionBar?.setHomeActionContentDescription("Home")

        mArea = intent.getSerializableExtra(KEY_AREA) as AreaEntity

        parentId = intent.getSerializableExtra(PARENT_ID) as Long?
        parentName = intent.getSerializableExtra(PARENT_NAME) as String?

        reportType = intent.getSerializableExtra(KEY_REPORT_TYPE) as ReportType
        industryType = intent.getSerializableExtra(KEY_REPORT_ROW_TYPE) as ReportRowType

        hierarchyString = intent.getSerializableExtra(HIERARCY_STRING) as String?
        hierarchyIDArray = intent.getSerializableExtra(HIERARCY_ARRAY) as Array<Long>?

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

        if (parentName != null && parentName!!.length > 1) {
            title = parentName
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

    override fun onFragmentInteraction(uri: Uri) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_hierarchy, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem) = when (item.itemId) {
        R.id.action_search -> {
            val intent = Intent(applicationContext, SearchHierarchyActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.putExtra(KEY_AREA, mArea)
            intent.putExtra(KEY_REPORT_TYPE, reportType)
            intent.putExtra(KEY_REPORT_ROW_TYPE, industryType)
            startActivity(intent)

            startActivity(intent)
            true
        }
        android.R.id.home -> {
            val intent = Intent(applicationContext, SearchActivity::class.java)
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            startActivity(intent);
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
        viewModel.hierarchyRows.observe(this, Observer<List<HierarchyRow>> {

            hierarchyHeaderFragment = supportFragmentManager.findFragmentById(R.id.headerFragment) as HierarchyHeaderFragment
            hierarchyHeaderFragment.reportLoaded()

            if  (viewModel.isCountyArea()) {
                qcewAdapter.setIndustryRows(it!!)
            } else if (viewModel.isIndustryReport()) {
                cesAdapter.setIndustryRows(it!!)
            } else {
                adapter.setIndustryRows(it!!)
            }

            hierarchyHeaderFragment.setupHiearcaryBreadCrumbs(hierarchyString, hierarchyIDArray)
        })
        viewModel.isLoading.observe(this, Observer<Boolean> {
            it?.let { showLoadingDialog(it) }
        })
        viewModel.reportError.observe(this, Observer<ReportError> {
            it?.let { showError(it) }
        })
    }


    fun displaySubIndustriesWorker(selectedItemId:Long?, selectedItemTitle:String?, nHierarchyString:String?, nHierarchyArray: MutableList<Long>?) {

        intent = Intent(applicationContext, HierarchyResultsActivity::class.java)
        intent.putExtra(KEY_AREA, mArea)
        intent.putExtra(PARENT_ID, selectedItemId)
        intent.putExtra(PARENT_NAME, selectedItemTitle)

        intent.putExtra(HIERARCY_STRING, nHierarchyString)
        intent.putExtra(HIERARCY_ARRAY, nHierarchyArray?.toTypedArray())

        intent.putExtra(KEY_REPORT_TYPE, reportType)
        intent.putExtra(KEY_REPORT_ROW_TYPE, industryType)
        startActivity(intent)
    }

    fun displaySubIndustries(area: AreaEntity?, item: HierarchyRow) {

        val currItem = viewModel.hierarchyRows.value!!.elementAt(0)
        val titleSplit = currItem.title!!.split("(")
        var nHierarchyString:String? = hierarchyString
        if (nHierarchyString == null) {
            nHierarchyString = titleSplit[0]
        } else {
            nHierarchyString = nHierarchyString + " -> " + titleSplit[0]
        }

        var nHierarchyArray: MutableList<Long>?
        if (hierarchyIDArray == null) {
            nHierarchyArray =  mutableListOf(currItem.itemId!!)
        } else {
            nHierarchyArray = hierarchyIDArray!!.toMutableList()
            nHierarchyArray.add(currItem.itemId!!)
        }

        displaySubIndustriesWorker(item.itemId, item.title, nHierarchyString, nHierarchyArray)
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

    override fun breadcrumbItemSelected(itemIndex: Int) {

        val itemId = hierarchyIDArray!![itemIndex]
        val hierarchyStrings = hierarchyString!!.split("->").toTypedArray()
        val title = hierarchyStrings[itemIndex]

        var nHierarchyString:String? = null
        var nHierarchyArray: MutableList<Long>? = mutableListOf<Long>()
        for (i in 0..itemIndex-1) {
            if (i == 0) nHierarchyString =  hierarchyStrings[i]
            else  nHierarchyString = nHierarchyString + " -> " + hierarchyStrings[i]

            nHierarchyArray?.add(hierarchyIDArray!![i])
        }

        displaySubIndustriesWorker(itemId, title, nHierarchyString, nHierarchyArray)
    }
}