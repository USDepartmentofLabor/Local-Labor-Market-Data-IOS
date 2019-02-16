package blsapp.dol.gov.blslocaldata.ui.info

import android.support.v4.app.Fragment
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import blsapp.dol.gov.blslocaldata.R

/**
 * GlossaryFragment - Fragment that displays glossary information used in the app
 */
class GlossaryFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_glossary, container, false)
    }
}
