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
import android.widget.SearchView
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity
import blsapp.dol.gov.blslocaldata.model.reports.ReportType
import blsapp.dol.gov.blslocaldata.ui.area.SearchHierarchyAdapter
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.HierarchySearchRow
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.SearchHierarchyViewModel
import blsapp.dol.gov.blslocaldata.ui.search.AreaListAdapter
import blsapp.dol.gov.blslocaldata.ui.search.HierarchyListAdapter
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType
import blsapp.dol.gov.blslocaldata.ui.viewmodel.SearchAreaViewModel
import kotlinx.android.synthetic.main.activity_search.*
import org.jetbrains.anko.doAsync
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
        title = getString(R.string.search)

        mArea = intent.getSerializableExtra(HierarchyResultsActivity.KEY_AREA) as AreaEntity
        reportType = intent.getSerializableExtra(HierarchyResultsActivity.KEY_REPORT_TYPE) as ReportType
        industryType = intent.getSerializableExtra(HierarchyResultsActivity.KEY_REPORT_ROW_TYPE) as ReportRowType

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

            }
        })

        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {

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
                            searchView.clearFocus()
                        }
                    }
                }
                return true
            }

            override fun onQueryTextSubmit(query: String?): Boolean {
                searchView.clearFocus()
                return true
            }
        })
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

        item.hiearchyIds?.removeAt(tmpStringArray.count()-1)
        intent.putExtra(HierarchyResultsActivity.HIERARCY_ARRAY, item.hiearchyIds?.toTypedArray())

        intent.putExtra(HierarchyResultsActivity.KEY_REPORT_TYPE, reportType)
        intent.putExtra(HierarchyResultsActivity.KEY_REPORT_ROW_TYPE, industryType)
        startActivity(intent)

    }
}