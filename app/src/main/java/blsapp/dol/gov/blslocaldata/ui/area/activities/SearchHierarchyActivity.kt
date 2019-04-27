package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Intent
import android.os.Bundle
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.widget.SearchView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity
import blsapp.dol.gov.blslocaldata.model.reports.ReportType
import blsapp.dol.gov.blslocaldata.services.FetchAddressIntentService
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import blsapp.dol.gov.blslocaldata.ui.area.SearchHierarchyAdapter
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.HierarchySearchRow
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.SearchHierarchyViewModel
import blsapp.dol.gov.blslocaldata.ui.search.AreaListAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListAdapter
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType
import blsapp.dol.gov.blslocaldata.ui.viewmodel.SearchAreaViewModel
import kotlinx.android.synthetic.main.activity_search.*
import kotlinx.android.synthetic.main.activity_search_hierarchy.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.textView
import org.jetbrains.anko.uiThread

class SearchHierarchyActivity: AppCompatActivity(), SearchHierarchyAdapter.OnItemClickListener {

    private lateinit var linearLayoutManger: LinearLayoutManager
    private lateinit var searchViewModel: SearchHierarchyViewModel

    private lateinit var mArea: AreaEntity
    private lateinit var reportType: ReportType
    private lateinit var industryType: ReportRowType
    private lateinit var adapter: SearchHierarchyAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_search_hierarchy)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        mArea = intent.getSerializableExtra(HierarchyResultsActivity.KEY_AREA) as AreaEntity
        reportType = intent.getSerializableExtra(HierarchyResultsActivity.KEY_REPORT_TYPE) as ReportType
        industryType = intent.getSerializableExtra(HierarchyResultsActivity.KEY_REPORT_ROW_TYPE) as ReportRowType

        title = getString(R.string.search)
        when (this.reportType) {
            is ReportType.OccupationalEmployment -> {
                title = getString(R.string.search_occupations)
            }
            is ReportType.IndustryEmployment -> {
                title = getString(R.string.search_industries)
            }
            is ReportType.OccupationalEmploymentQCEW -> {
                title = getString(R.string.search_occupations)
            }
            is ReportType.QuarterlyEmploymentWages -> {
                title = getString(R.string.search_occupations)
            }
        }
        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        adapter = SearchHierarchyAdapter(this)
        recyclerView.apply {
            adapter = this@SearchHierarchyActivity.adapter
            layoutManager = LinearLayoutManager(this@SearchHierarchyActivity)
        }

        val decorator = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)

        ContextCompat.getDrawable(this, R.drawable.thin_divider)?.let {
            decorator.setDrawable(it)   }
        recyclerView.addItemDecoration(decorator)

        // Get a new or existing ViewModel from the ViewModelProvider.
        searchViewModel = ViewModelProviders.of(this).get(SearchHierarchyViewModel::class.java)
        searchViewModel.mArea = mArea
        searchViewModel.setReportType(reportType)
        // Add an observer on the LiveData returned by getAlphabetizedWords.
        // The onChanged() method fires when the observed data changes and the activity is
        // in the foreground.
        searchViewModel.hierarchies.observe(this, Observer { hierarchies ->
            // Update the cached copy of the words in the adapter.
            hierarchies?.let {

                adapter.setIndustryRows(hierarchies)
                if (hierarchies.count() == 0 && searchHierarchyView.query.count() > 2) {
                    noResultsFoundTextView.visibility = View.VISIBLE
                } else {
                    noResultsFoundTextView.visibility = View.INVISIBLE
                    UIUtil.accessibilityAnnounce(applicationContext, String.format(getString(R.string.found_n_results), hierarchies.size))
                }

            }
        })

        searchHierarchyView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {

            override fun onQueryTextChange(newText: String?): Boolean {
                val textLength = if (newText != null) newText.length else 0
                if (textLength < 3) {
                    searchViewModel.setQuery(" ")
                    return true
                }
                searchViewModel.setQuery(newText!!)
                if (newText.isEmpty()) {
                    doAsync {
                        uiThread {
                            searchHierarchyView.clearFocus()
                        }
                    }
                }
                return true
            }

            override fun onQueryTextSubmit(query: String?): Boolean {
                searchHierarchyView.clearFocus()
                return true
            }
        })

        searchHierarchyView.setIconified(false)
        searchHierarchyView.requestFocus()
        noResultsFoundTextView.visibility = View.INVISIBLE
    }

    override fun onOptionsItemSelected(item: MenuItem) = when (item.itemId) {
        android.R.id.home -> { finish()
            true
        }
        else -> {
            super.onOptionsItemSelected(item)
        }
    }
    override fun onItemClick(item: HierarchySearchRow) {

        intent = Intent(applicationContext, HierarchyResultsActivity::class.java)
        intent.putExtra(HierarchyResultsActivity.KEY_AREA, mArea)
        intent.putExtra(HierarchyResultsActivity.PARENT_ID, item.itemId)
        intent.putExtra(HierarchyResultsActivity.PARENT_NAME, item.itemTitle)

        val tmpStringArray = item.hierarchyTitles.split("->")
        var tmpString= item.hierarchyTitles
        if (tmpStringArray.count() > 1) {
            tmpString = item.hierarchyTitles.substringBeforeLast(tmpStringArray[tmpStringArray.count() - 1])
            tmpString = tmpString.substring(0, tmpString.length - 3)
        }
        intent.putExtra(HierarchyResultsActivity.HIERARCY_STRING, tmpString)

        if (item.hiearchyIds != null) {
            if (item.hiearchyIds?.count() != tmpStringArray.count()) {
                Log.wtf("GGG", "Mismatch id vs title string counts")
            }
            item.hiearchyIds?.removeAt(item.hiearchyIds!!.count()-1)
            intent.putExtra(HierarchyResultsActivity.HIERARCY_ARRAY, item.hiearchyIds?.toTypedArray())
        }

        intent.putExtra(HierarchyResultsActivity.KEY_REPORT_TYPE, reportType)
        intent.putExtra(HierarchyResultsActivity.KEY_REPORT_ROW_TYPE, industryType)
        startActivity(intent)

    }
}