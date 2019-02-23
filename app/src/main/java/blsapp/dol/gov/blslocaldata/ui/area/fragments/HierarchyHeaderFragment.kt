package blsapp.dol.gov.blslocaldata.ui.area.fragments

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner

import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.model.ReportError
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyViewModel
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType
import kotlinx.android.synthetic.main.fragment_hierarchy_header.*
import android.support.graphics.drawable.VectorDrawableCompat
import android.support.v4.content.ContextCompat
import android.support.v4.graphics.drawable.DrawableCompat


/**
 * AreaHeaderFragment - A simple [Fragment] subclass.
 * Activities that contain this fragment must implement the
 * [AreaHeaderFragment.OnFragmentInteractionListener] interface
 * to handle interaction events.
 *
 */
class HierarchyHeaderFragment : Fragment() {
    private var listener: OnFragmentInteractionListener? = null
    private lateinit var viewModel: HierarchyViewModel
    private var wageVsLevelTitles:MutableList<String>? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val headerView = inflater.inflate(R.layout.fragment_hierarchy_header, container, false)

        return headerView
    }

    fun onButtonPressed(uri: Uri) {
        listener?.onFragmentInteraction(uri)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is OnFragmentInteractionListener) {
            listener = context

        } else {
//            throw RuntimeException(context.toString() + " must implement OnFragmentInteractionListener")
        }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        viewModel = ViewModelProviders.of(activity!!).get(HierarchyViewModel::class.java)
        attachObserver()
        updateHeader()
    }
    private fun attachObserver() {
        viewModel.hierarchyRows?.observe(this, Observer<List<HierarchyRow>> {
          //  updateHeader()
        })
    }

    private fun updateHeader() {
        industryAreaTextView.text = viewModel.areaTitle
        industryAreaTextView.contentDescription = viewModel.accessibilityStr
        ownershipTextView.text = viewModel.getOwnershipTitle()
        timePeriodTextView.text = viewModel.getTimePeriodTitle()
        detailTitle.text = viewModel.detailTitle
        setupLevelVsWageSpinner()
        setupColumnHeaders()
    }

    private fun setupColumnHeaders() {
        if  (viewModel.column1Title == null) {
            colum1View.visibility = View.INVISIBLE
        } else {
            column1Title.text = viewModel.column1Title
        }
        column2Title.text = viewModel.column2Title

        val clickListener = View.OnClickListener {view ->

            turnOffArrows()
            when (view.getId()) {
                R.id.colum1View -> {
                    if (viewModel.sortByColumn1())
                        DrawableCompat.setTint(col1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    else
                        DrawableCompat.setTint(col1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                }
                R.id.colum2View -> {
                    if (viewModel.sortByColumn2())
                        DrawableCompat.setTint(col2UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    else
                        DrawableCompat.setTint(col2DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                }
            }
        }
        colum1View.setOnClickListener(clickListener)
        colum2View.setOnClickListener(clickListener)
    }

    private fun turnOffArrows() {
        DrawableCompat.setTint(col1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(col1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(col2UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(col2DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
    }

    private fun setupLevelVsWageSpinner () {

        wageVsLevelTitles = viewModel.getWageVsLevelTitles()
        if (wageVsLevelTitles == null) {
            viewModel.setWageVsLevelIndex(0)
            viewModel.getIndustryReports()
            wageVsLevelSpinner.visibility = View.INVISIBLE
        } else {
            wageVsLevelSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                    viewModel.setWageVsLevelIndex(0)
                }
                override fun onItemSelected(parent: AdapterView<*>?, view: View?, pos: Int, id: Long) {
                    viewModel.setWageVsLevelIndex(pos)
                    viewModel.getIndustryReports()

                    wageVsLevelTitles?.let {
                        dataTitle.text = it[pos]
                    }
                }
            }

            val aa = ArrayAdapter(activity, android.R.layout.simple_spinner_item, viewModel.getWageVsLevelTitles())
            aa.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            wageVsLevelSpinner!!.adapter = aa
        }
    }

    override fun onDetach() {
        super.onDetach()
        listener = null
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     *
     *
     * See the Android Training lesson [Communicating with Other Fragments]
     * (http://developer.android.com/training/basics/fragments/communicating.html)
     * for more information.
     */
    interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        fun onFragmentInteraction(uri: Uri)
    }

}
