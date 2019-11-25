package blsapp.dol.gov.blslocaldata.ui.info


import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.view.AccessibilityDelegateCompat
import android.support.v4.view.ViewCompat
import android.support.v4.view.accessibility.AccessibilityNodeInfoCompat
import android.text.Html
import android.text.method.LinkMovementMethod
import android.text.util.Linkify
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.BuildConfig

import blsapp.dol.gov.blslocaldata.R
import kotlinx.android.synthetic.main.fragment_about.*
import java.text.SimpleDateFormat
import java.time.format.DateTimeFormatter
import java.util.*


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
        val retView= inflater.inflate(R.layout.fragment_about, container, false)

        val line9 = retView.findViewById<TextView>(R.id.line9)
        line9.text = Html.fromHtml(getString(R.string.about9_1) +
                "<a href=\"http://play.google.com/store/apps/details?id=gov.dol.ooh_occupational_handbook\">" +
                getString(R.string.about9_2) +
                "</a>")

//        line9.text = Html.fromHtml("Find detail information from BLS about the duties, education and training, pay, job outlook, and more for\n" +
//                "    hundreds of occupations through the CareerInfo app, available on the <a href=\"http://play.google.com/store/apps/details?id=gov.dol.ooh_occupational_handbook\">Google Play Store</a>")
        line9.movementMethod = LinkMovementMethod.getInstance()

        return retView
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        ViewCompat.setAccessibilityDelegate(aboutHeading, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.addAction(AccessibilityNodeInfoCompat.ACTION_FOCUS)
                info.isHeading = true
            }
        })

        line1.text = getString(R.string.about1)
        line2.text = getString(R.string.about2)
        line3.text = getString(R.string.about3)
        line4.text = getString(R.string.about4)
        line5.text = getString(R.string.about5)
        line6.text = getString(R.string.about6)
        line7.text = getString(R.string.about7)
        line8.text = getString(R.string.about8)

        versionValue.text = BuildConfig.VERSION_NAME
        releaseDateValue.text = AboutFragment.releaseDate

    }

    companion object {
        var buildDate = Date(BuildConfig.TIMESTAMP)
        var formatter = SimpleDateFormat("MMMM dd, yyyy", Locale.ENGLISH)
        val releaseDate = formatter.format(buildDate)
    }
}
