package blsapp.dol.gov.blslocaldata.ui.area.fragments

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.content.ContextCompat
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.db.entity.CountyEntity
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.ui.area.HistoryAdapter
import blsapp.dol.gov.blslocaldata.ui.area.activities.HistoryActivity
import blsapp.dol.gov.blslocaldata.ui.area.viewModel.AreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.AreaReportRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.CountyAreaViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.MetroStateViewModel
import java.io.Serializable

// TODO: Rename parameter arguments, choose names that match
// the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
private const val ARG_PARAM1 = "param1"
private const val ARG_PARAM2 = "param2"

/**
 * A simple [Fragment] subclass.
 * Activities that contain this fragment must implement the
 * [HistoryTableFragment.OnFragmentInteractionListener] interface
 * to handle interaction events.
 * Use the [HistoryTableFragment.newInstance] factory method to
 * create an instance of this fragment.
 */
class HistoryTableFragment : Fragment() {

    lateinit var mArea: AreaEntity
    private lateinit var viewModel: AreaViewModel

    private lateinit var rootView:View
    private lateinit var historyActivity: HistoryActivity
    private lateinit var historyAdapter: HistoryAdapter


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            if (it.get(HistoryBarChartFragment.KEY_AREA) != null) {
                mArea = it.getSerializable(HistoryBarChartFragment.KEY_AREA) as AreaEntity
            }
        }
        viewModel = createViewModel(mArea)
        viewModel.mAdjustment = ReportManager.adjustment
        mArea.let {
            viewModel.mArea = it
        }
        viewModel.reportRows.observe(this, Observer<List<AreaReportRow>> {
            historyAdapter.setHistoryData(viewModel.historyValuesLists, viewModel.historyTableLabels)
        })
        viewModel.getAreaReports()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.fragment_history_table, container, false)

        val tableView = rootView.findViewById<RecyclerView>(R.id.tableDataRecyclerView)

        historyAdapter = HistoryAdapter()
        tableView.adapter = historyAdapter
        tableView.layoutManager = LinearLayoutManager(historyActivity)

        val decorator = DividerItemDecoration(historyActivity, DividerItemDecoration.VERTICAL)
        ContextCompat.getDrawable(historyActivity,R.drawable.thin_divider)?.let {
            decorator.setDrawable(it) }
        tableView.addItemDecoration(decorator)

        return rootView
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        historyActivity = context as HistoryActivity
    }

    override fun onResume() {
        super.onResume()
        if (viewModel.historyValuesLists.count() > 0) {
            historyAdapter.setHistoryData(viewModel.historyValuesLists, viewModel.historyXAxisLabels)
        }
    }

    private fun createViewModel(area: AreaEntity): AreaViewModel {
        when(area) {
            is CountyEntity -> return ViewModelProviders.of(this).get(CountyAreaViewModel::class.java)
        }
        return ViewModelProviders.of(this).get(MetroStateViewModel::class.java)
    }

    companion object {

        const val KEY_AREA = "Area"

        @JvmStatic
        fun newInstance(area: Serializable?) =
                HistoryTableFragment().apply {
                    arguments = Bundle().apply {
                        if (area != null)
                            putSerializable(KEY_AREA, area)
                    }
                }
    }
}
