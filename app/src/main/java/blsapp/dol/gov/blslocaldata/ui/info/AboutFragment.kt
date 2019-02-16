package blsapp.dol.gov.blslocaldata.ui.info


import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import blsapp.dol.gov.blslocaldata.BuildConfig

import blsapp.dol.gov.blslocaldata.R
import kotlinx.android.synthetic.main.fragment_about.*


/**
 * AboutFragment - Fragment that defines about content for the about screen
 */
class AboutFragment : Fragment() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_about, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        line1.text = getString(R.string.about1)
        line2.text = getString(R.string.about2)
        line3.text = getString(R.string.about3)
        line4.text = getString(R.string.about4)
        line5.text = getString(R.string.about5)
        line6.text = getString(R.string.about6)
        line7.text = getString(R.string.about7)

        versionValue.text = BuildConfig.VERSION_NAME
        releaseDateValue.text = AboutFragment.releaseDate

        moreInfo.text = getString(R.string.more_info)
    }

    companion object {
        val releaseDate = "November 5, 2018"
    }
}
