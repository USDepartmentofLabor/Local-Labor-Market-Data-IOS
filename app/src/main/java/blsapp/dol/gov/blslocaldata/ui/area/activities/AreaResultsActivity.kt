package blsapp.dol.gov.blslocaldata.ui.area.activities

import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.support.v4.content.ContextCompat
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.MenuItem
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.CountyEntity
import blsapp.dol.gov.blslocaldata.db.entity.MetroEntity
import blsapp.dol.gov.blslocaldata.db.entity.StateEntity
import blsapp.dol.gov.blslocaldata.ui.search.AreaListAdapter
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.RowType
import kotlinx.android.synthetic.main.activity_area_results.*

class AreaResultsActivity : AppCompatActivity(), AreaListAdapter.OnItemClickListener {
    companion object {
        const val KEY_CURRENT_AREA = "Area"
        const val KEY_SUB_AREAS = "SubAreas"
    }

    private var mCurrentArea: AreaEntity? = null
    private var subAreas: List<AreaEntity>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_area_results)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setHomeAsUpIndicator(R.drawable.ic_baseline_home_24px)

        mCurrentArea = intent.getSerializableExtra(KEY_CURRENT_AREA) as AreaEntity
        val subAreas = (intent.getSerializableExtra(KEY_SUB_AREAS) as? List<AreaEntity>)


        titleTextView.text = mCurrentArea?.title
        titleTextView.contentDescription = mCurrentArea?.accessibilityStr

        subAreas?.firstOrNull()?.let {
            when (it) {
                is MetroEntity -> title = "Metro Results"
                is StateEntity -> title = "State Results"
                is CountyEntity -> title = "County Results"
            }
        }
        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        val adapter = AreaListAdapter(this)
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(this)
        subAreas?.let {
            adapter.setArea(getAreaRows(it))
        }

        val decorator = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)

        ContextCompat.getDrawable(this, R.drawable.thin_divider)?.let {
            decorator.setDrawable(it)
        }
        recyclerView.addItemDecoration(decorator)
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

    override fun onItemClick(item: AreaRow) {
        val intent = Intent(applicationContext, AreaReportActivity::class.java)
        intent.putExtra(AreaReportActivity.KEY_AREA, item.area)
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(intent)
    }

    fun getAreaRows(areaList: List<AreaEntity>) : ArrayList<AreaRow> {
        val areaRows = ArrayList<AreaRow>()
        areaRows.add(AreaRow(RowType.HEADER, null, "Select", null))
        val itemRows = areaList.map { AreaRow(RowType.ITEM, it, null, null) }
        areaRows.addAll(itemRows)
        return areaRows
    }

}
