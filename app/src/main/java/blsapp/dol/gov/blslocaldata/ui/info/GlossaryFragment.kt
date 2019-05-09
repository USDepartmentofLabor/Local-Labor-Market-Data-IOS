package blsapp.dol.gov.blslocaldata.ui.info

import android.support.v4.app.Fragment
import android.os.Bundle
import android.support.v4.view.AccessibilityDelegateCompat
import android.support.v4.view.ViewCompat
import android.support.v4.view.accessibility.AccessibilityNodeInfoCompat
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import kotlinx.android.synthetic.main.fragment_glossary.*
import kotlinx.android.synthetic.main.fragment_glossary.view.*

/**
 * GlossaryFragment - Fragment that displays glossary information used in the app
 */
class GlossaryFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        val glossaryView = inflater.inflate(R.layout.fragment_glossary, container, false)

        setupAccessibilityDelegate(glossaryView.glossaryHeading)
        setupAccessibilityDelegate(glossaryView.title1)
        setupAccessibilityDelegate(glossaryView.title2)
        setupAccessibilityDelegate(glossaryView.title3)
        setupAccessibilityDelegate(glossaryView.title4)
        setupAccessibilityDelegate(glossaryView.title5)
        setupAccessibilityDelegate(glossaryView.title6)
        setupAccessibilityDelegate(glossaryView.title7)

        return glossaryView
    }

    fun setupAccessibilityDelegate(textView: TextView) {

        ViewCompat.setAccessibilityDelegate(textView, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.addAction(AccessibilityNodeInfoCompat.ACTION_FOCUS)
                info.isHeading = true
            }
        })
    }
}
