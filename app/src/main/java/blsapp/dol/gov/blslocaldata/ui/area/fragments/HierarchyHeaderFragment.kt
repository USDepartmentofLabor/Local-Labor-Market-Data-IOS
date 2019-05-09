package blsapp.dol.gov.blslocaldata.ui.area.fragments

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.support.constraint.ConstraintLayout
import android.support.constraint.ConstraintSet
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
import android.text.method.LinkMovementMethod
import android.text.Spanned
import android.text.SpannableString
import android.text.style.ClickableSpan
import android.util.Log
import android.widget.TextView
import org.jetbrains.anko.support.v4.dimen
import android.view.ViewGroup.MarginLayoutParams
import blsapp.dol.gov.blslocaldata.model.reports.ReportManager
import blsapp.dol.gov.blslocaldata.model.reports.SeasonalAdjustment
import blsapp.dol.gov.blslocaldata.ui.UIUtil
import kotlinx.android.synthetic.main.fragment_hierarchy_header.view.*
import kotlinx.android.synthetic.main.industry_employment.*


/**
 * AreaHeaderFragment - A simple [Fragment] subclass.
 * Activities that contain this fragment must implement the
 * [AreaHeaderFragment.OnFragmentInteractionListener] interface
 * to handle interaction events.
 *
 */
class HierarchyHeaderFragment : Fragment() {

    var selectedWageVsLevelIndex:Int = 0
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
        if (!hierarchyViewModel.isCountyArea()) {
            ownershipTextView.visibility = View.GONE
        }
        attachObserver()
        updateHeader()
        DrawableCompat.setTint(codeSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))

    }
    private fun attachObserver() {
        hierarchyViewModel.hierarchyRows.observe(this, Observer<List<HierarchyRow>> {
           // updateHeader()
        })
    }

    fun reportLoaded() {
        if (hierarchyViewModel.isCountyArea()) {
            timePeriodTextView.text = hierarchyViewModel.getTimePeriodTitle()
        } else {
            timePeriodTextView.text = hierarchyViewModel.getTimePeriodTitle().replace("Annual","")
        }
    }


    fun setupHiearcaryBreadCrumbs(hierarchyString: String?, hierarchyIds:Array<Long>?) {

        if (hierarchyString == null || hierarchyIds == null) {
            hierarchyTextView.visibility = View.INVISIBLE
            return
        }
        val hierarchyStrings = hierarchyString.split("->").toTypedArray()

        var clickSpans : MutableList<ClickableSpan> = mutableListOf<ClickableSpan>()

        for (i in hierarchyStrings.indices) {
            val termsOfServicesClick = object : ClickableSpan() {
                override fun onClick(p0: View?) {
                    Log.d("GGG", "Hierarchy ID: " + hierarchyIds[i])
                    listener?.breadcrumbItemSelected(i)
                }
            }
            clickSpans.add(termsOfServicesClick)
        }

        hierarchyTextView.text = hierarchyString
        makeLinks(hierarchyTextView, hierarchyStrings, clickSpans.toTypedArray())

        hierarchyTextView.visibility = View.VISIBLE
    }

    fun makeLinks(textView: TextView, links: Array<String>, clickableSpans: Array<ClickableSpan>) {
        val spannableString = SpannableString(textView.text)

        var currentEndOfLinks:Int = 0
        for (i in links.indices) {
            val clickableSpan = clickableSpans[i]
            val link = links[i]

            val startIndexOfLink = textView.text.indexOf(link, currentEndOfLinks)

            if  (!UIUtil.isTalkBackActive()) {
                spannableString.setSpan(clickableSpan, startIndexOfLink, startIndexOfLink + link.length,
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            }

            currentEndOfLinks = startIndexOfLink + link.length
        }

        textView.movementMethod = LinkMovementMethod.getInstance()
        textView.setText(spannableString, TextView.BufferType.SPANNABLE)
    }


    private fun updateHeader() {
        industryAreaTextView.text = hierarchyViewModel.areaTitle
        industryAreaTextView.contentDescription = hierarchyViewModel.accessibilityStr
        ownershipTextView.text = hierarchyViewModel.getOwnershipTitle()
        timePeriodTextView.text = hierarchyViewModel.getTimePeriodTitle()
        setupColumnHeaders()
        setupLevelVsWageSpinner()
        turnOffArrows()
    }

    private fun updateAccessiblitiyHintForSort(view:View, textView: TextView) {

        if (view == null || textView == null) return
        val regex = "(000s)".toRegex()
        var hintText = textView.text.replace(regex, " values in thousands")
        hintText = "Sort by " + hintText
        view.contentDescription = hintText
    }

    private fun updateAccessiblitiyHint(view:View, textView: TextView) {

        if (view == null || textView == null) return
        val regex = "(000s)".toRegex()
        var hintText = textView.text.replace(regex, " values in thousands")
        view.contentDescription = hintText
    }

    private fun updateAccessibilityHints() {
        updateAccessiblitiyHintForSort(regionSortButtonView, regionSortButtonTitle)
        updateAccessiblitiyHintForSort(nationalSortButtonView, nationalSortButtonTitle)
        updateAccessiblitiyHintForSort(regionChangeView, regionChangeTitle)
        updateAccessiblitiyHintForSort(oneMonthChangeView, changeColumn1Title)
        updateAccessiblitiyHintForSort(twelveMonthChangeView, changeColumn2Title)
        updateAccessiblitiyHint(dataTitle, dataTitle)
    }

    private fun setupColumnHeaders() {

        if  (hierarchyViewModel.regionTitle == null) {
            regionSortButtonView.visibility = View.GONE
        } else {
            regionSortButtonTitle.text = hierarchyViewModel.regionTitle
        }
        regionChangeTitle.text = getString(R.string.level)

        dataTitle2.visibility = View.INVISIBLE
        hierarchySeasonallyAdjustedSwitch.isChecked = true
        dataTitle.text = getString(R.string.employment_level_000s)
        nationalSortButtonTitle.text = getString(R.string.national)

        if (hierarchyViewModel.isCountyArea()) {
            hierarchySeasonallyAdjustedSwitch.isChecked = false
            detailTitle.text = getString(R.string.industries_title)
            regionChangeView.visibility = View.GONE
            changeColumn1Title.text = getString(R.string.twelve_month_change)
            dataTitle.text = getString(R.string.employment_level)

            var params = oneMonthChangeView.getLayoutParams() as MarginLayoutParams
            val headingParms  = regionSortButtonView.getLayoutParams() as MarginLayoutParams
            params.marginEnd = headingParms.marginEnd
            oneMonthChangeView.layoutParams = params

            regionSortButtonTitle.text = getString(R.string.county)
            nationalSortButtonTitle.text = getString(R.string.national)

        } else if (hierarchyViewModel.isIndustryReport()) {
            if (hierarchyViewModel.isMetroArea()) {
                hierarchySeasonallyAdjustedSwitch.isChecked = false
            }
            detailTitle.text = getString(R.string.industries_title)
            regionSortButtonView.visibility = View.GONE
            nationalSortButtonView.visibility = View.GONE

            val params = dataTitle.layoutParams as ConstraintLayout.LayoutParams
            params.startToStart = oneMonthChangeView.id
            dataTitle.requestLayout()


        } else {
            hierarchySeasonallyAdjustedSwitch.visibility = View.GONE
            detailTitle.text = getString(R.string.occupation_title)
            regionChangeView.visibility = View.GONE
            oneMonthChangeView.visibility = View.GONE
            twelveMonthChangeView.visibility = View.GONE

            val params = dataTitle.layoutParams as ConstraintLayout.LayoutParams
            if (hierarchyViewModel.isNationalArea())
                params.startToStart = nationalSortButtonView.id
            else {
                params.startToStart = regionSortButtonView.id

                var params = dataTitle.getLayoutParams() as MarginLayoutParams
                params.marginStart = 150
                dataTitle.layoutParams = params
            }
            dataTitle.requestLayout()
        }

        codeSortButtonTitle.contentDescription = "Sort by " + detailTitle.text + " code"

        val clickListener = View.OnClickListener {view ->

            turnOffArrows()
            when (view.getId()) {

                R.id.codeSortButtonView -> {
                    if (hierarchyViewModel.sortByCode() == SortStatus.ASCENDING)
                        DrawableCompat.setTint(codeSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    else
                        DrawableCompat.setTint(codeSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                }
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

                R.id.regionChangeView -> {
                    if (hierarchyViewModel.isNationalArea()) {
                        if (hierarchyViewModel.sortByNationalValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByRegionChangeUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByRegionChangeDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    } else {
                        if (hierarchyViewModel.sortByLocalValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByRegionChangeUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByRegionChangeDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    }
                }

                R.id.oneMonthChangeView -> {
                    if (hierarchyViewModel.isCountyArea()) {
                        if (hierarchyViewModel.sortByLocalTwelveMonthPercentChangeValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByColumn1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByColumn1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))

                    } else if (hierarchyViewModel.isNationalArea()) {
                        if (hierarchyViewModel.sortByNationalOneMonthPercentChangeValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByColumn1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByColumn1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    } else {
                        if (hierarchyViewModel.sortByLocalOneMonthPercentChangeValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByColumn1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByColumn1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    }
                }
                R.id.twelveMonthChangeView -> {
                    if (hierarchyViewModel.isCountyArea() || hierarchyViewModel.isNationalArea()) {
                        if (hierarchyViewModel.sortByNationalTwelveMonthPercentChangeValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByColumn2UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByColumn2DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    } else {
                        if (hierarchyViewModel.sortByLocalTwelveMonthPercentChangeValue()== SortStatus.ASCENDING)
                            DrawableCompat.setTint(sortByColumn2UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                        else
                            DrawableCompat.setTint(sortByColumn2DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorSelectedArrow))
                    }
                }
            }
            UIUtil.accessibilityAnnounce(context!!, String.format(UIUtil.getString(R.string.results_sorted), hierarchyViewModel.getSortedByMessage()))
        }
        codeSortButtonView.setOnClickListener(clickListener)
        regionSortButtonView.setOnClickListener(clickListener)
        nationalSortButtonView.setOnClickListener(clickListener)
        regionChangeView.setOnClickListener(clickListener)
        oneMonthChangeView.setOnClickListener(clickListener)
        twelveMonthChangeView.setOnClickListener(clickListener)
        updateAccessibilityHints()

        hierarchySeasonallyAdjustedSwitch.setOnCheckedChangeListener{ _, isChecked ->
            ReportManager.adjustment =
                    if (isChecked) SeasonalAdjustment.ADJUSTED else SeasonalAdjustment.NOT_ADJUSTED
            hierarchyViewModel.setAdjustment(ReportManager.adjustment)
            hierarchyViewModel.getIndustryReports()
        }

        hierarchyViewModel.getIndustryReports()
    }

    private fun turnOffArrows() {
        DrawableCompat.setTint(codeSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(codeSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(regionSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(regionSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(nationalSortButtonUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(nationalSortButtonDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByRegionChangeUpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByRegionChangeDownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByColumn1UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByColumn1DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByColumn2UpArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
        DrawableCompat.setTint(sortByColumn2DownArrow.getDrawable(), ContextCompat.getColor(activity!!, R.color.colorUnSelectedArrow))
    }

    private fun setupLevelVsWageSpinner () {

        wageVsLevelTitles = hierarchyViewModel.getWageVsLevelTitles()
        if (wageVsLevelTitles == null) {
            //hierarchyViewModel.setWageVsLevelIndex(0)
            wageVsLevelSpinner.visibility = View.GONE

            val params = hierarchyTextView.layoutParams as ConstraintLayout.LayoutParams
            params.topToBottom = timePeriodTextView.id
            hierarchyTextView.layoutParams = params
            hierarchyTextView.requestLayout()

        } else {

            val aa = ArrayAdapter(activity, android.R.layout.simple_spinner_item, hierarchyViewModel.getWageVsLevelTitles())
            aa.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            wageVsLevelSpinner!!.adapter = aa

            wageVsLevelSpinner.onItemSelectedListener = null
            wageVsLevelSpinner.setSelection(selectedWageVsLevelIndex)

            wageVsLevelSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                    hierarchyViewModel.setWageVsLevelIndex(0)
                }

                override fun onItemSelected(parent: AdapterView<*>?, view: View?, pos: Int, id: Long) {
                    if (hierarchyViewModel.wageVsLevelTypeSelected  != pos) {
                        handleOnWageVsLevelSpinnerSelection(pos)
                        hierarchyViewModel.getIndustryReports()
                    }
                }
            }
            handleOnWageVsLevelSpinnerSelection(selectedWageVsLevelIndex)
        }
    }


    private fun handleOnWageVsLevelSpinnerSelection(pos: Int) {
        hierarchyViewModel.setWageVsLevelIndex(pos)
        wageVsLevelTitles?.let {
            if (hierarchyViewModel.isCountyArea()) {
                if (pos == 0) {
                    dataTitle.text = getString(R.string.employment_level)
                } else {
                    dataTitle.text = getString(R.string.average_weekly_wage_accessible)
                }
            } else {
                dataTitle.text = it[pos]
            }
            updateAccessibilityHints()
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
        fun breadcrumbItemSelected(itemIndex: Int)
    }

}
