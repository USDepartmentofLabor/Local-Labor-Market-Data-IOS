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

import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyRow
import blsapp.dol.gov.blslocaldata.ui.viewmodel.HierarchyViewModel
import kotlinx.android.synthetic.main.fragment_hierarchy_header.*
import android.support.v4.content.ContextCompat
import android.support.v4.graphics.drawable.DrawableCompat
import blsapp.dol.gov.blslocaldata.ui.viewmodel.SortStatus


/**
 * AreaHeaderFragment - A simple [Fragment] subclass.
 * Activities that contain this fragment must implement the
 * [AreaHeaderFragment.OnFragmentInteractionListener] interface
 * to handle interaction events.
 *
 */
class HierarchyHeaderFragment : Fragment() {
    private var listener: OnFragmentInteractionListener? = null
    private lateinit var hierarchyViewModel: HierarchyViewModel
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

        hierarchyViewModel = ViewModelProviders.of(activity!!).get(HierarchyViewModel::class.java)
        attachObserver()
        updateHeader()
    }
    private fun attachObserver() {
        hierarchyViewModel.hierarchyRows?.observe(this, Observer<List<HierarchyRow>> {
          //  updateHeader()
        })
    }

    private fun updateHeader() {
        industryAreaTextView.text = hierarchyViewModel.areaTitle
        industryAreaTextView.contentDescription = hierarchyViewModel.accessibilityStr
        ownershipTextView.text = hierarchyViewModel.getOwnershipTitle()
        timePeriodTextView.text = hierarchyViewModel.getTimePeriodTitle()
        detailTitle.text = hierarchyViewModel.detailTitle
        setupLevelVsWageSpinner()
        setupColumnHeaders()
    }

    private fun setupColumnHeaders() {

        if (hierarchyViewModel.isIndustryReport()) {
            regionSortButtonView.visibility = View.GONE
            nationalSortButtonView.visibility = View.GONE
        } else {
            regionChangeView.visibility = View.GONE
            if (hierarchyViewModel.isCountyArea()) {
                changeColumn1Title.text = getString(R.string.twelve_month_change)
            } else {
                changeColum1View.visibility = View.GONE
                changeColum2View.visibility = View.GONE
            }
        }

        if  (hierarchyViewModel.regionTitle == null) {
            regionSortButtonView.visibility = View.GONE
            if (hierarchyViewModel.isNationalArea()) {
                regionChangeTitle.text = getString(R.string.national)
            }
        } else {
            regionSortButtonTitle.text = hierarchyViewModel.regionTitle
            regionChangeTitle.text = hierarchyViewModel.regionTitle
        }

        val clickListener = View.OnClickListener {view ->

            turnOffArrows()
            when (view.getId()) {
                R.id.regionSortButtonView -> {
                    if (hierarchyViewModel.sortByLocalValue() == SortStatus.ASCENDING)
                        DrawableCompat.setTint(regionSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    else
                        DrawableCompat.setTint(regionSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                }
                R.id.nationalSortButtonView -> {
                    if (hierarchyViewModel.sortByNationalValue()== SortStatus.ASCENDING)
                        DrawableCompat.setTint(nationalSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    else
                        DrawableCompat.setTint(nationalSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                }
            }
        }
        regionSortButtonView.setOnClickListener(clickListener)
        nationalSortButtonView.setOnClickListener(clickListener)
    }

    private fun turnOffArrows() {
        DrawableCompat.setTint(regionSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(regionSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(nationalSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(nationalSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
    }

    private fun setupLevelVsWageSpinner () {

        wageVsLevelTitles = hierarchyViewModel.getWageVsLevelTitles()
        if (wageVsLevelTitles == null) {
            hierarchyViewModel.setWageVsLevelIndex(0)
            hierarchyViewModel.getIndustryReports()
            wageVsLevelSpinner.visibility = View.INVISIBLE
        } else {
            wageVsLevelSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                    hierarchyViewModel.setWageVsLevelIndex(0)
                }
                override fun onItemSelected(parent: AdapterView<*>?, view: View?, pos: Int, id: Long) {
                    hierarchyViewModel.setWageVsLevelIndex(pos)
                    hierarchyViewModel.getIndustryReports()

                    wageVsLevelTitles?.let {
                        dataTitle.text = it[pos]
                    }
                }
            }

            val aa = ArrayAdapter(activity, android.R.layout.simple_spinner_item, hierarchyViewModel.getWageVsLevelTitles())
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
