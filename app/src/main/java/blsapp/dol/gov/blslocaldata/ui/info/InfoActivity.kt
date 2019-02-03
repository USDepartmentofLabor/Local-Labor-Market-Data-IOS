package blsapp.dol.gov.blslocaldata.ui.info

import android.app.ActionBar
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.view.MenuItem
import blsapp.dol.gov.blslocaldata.R
import kotlinx.android.synthetic.main.activity_info.*
import android.widget.TextView


class InfoActivity : AppCompatActivity() {

    var glossaryFragment: GlossaryFragment? = null
    var aboutFragment: AboutFragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_info)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
     //   supportActionBar?.setHomeAsUpIndicator(R.drawable.ic_baseline_home_24px)

//        supportActionBar?.displayOptions = ActionBar.DISPLAY_SHOW_CUSTOM
//        supportActionBar?.setCustomView(blsapp.dol.gov.blslocaldata.R.layout.nav_header)
//        val tvTitle = supportActionBar?.customView?.findViewById(R.id.header_text) as TextView
//        tvTitle.text = "New Greg Title"

        displayGlossary()
        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.glossaryRadioButton -> {
                    displayGlossary()
                }
                R.id.aboutRadioButton -> {
                    displayAbout()
                }
            }

        }
    }

    override fun onOptionsItemSelected(item: MenuItem?): Boolean {
        when (item?.itemId) {
            android.R.id.home -> {
                finish()
                return true
            }
            else -> {
                return super.onOptionsItemSelected(item)
            }
        }
    }

    fun displayGlossary() {
        if (glossaryFragment == null) {
            glossaryFragment = GlossaryFragment()
        }
        glossaryFragment?.let {
            val fragmentTransaction = supportFragmentManager.beginTransaction()
            fragmentTransaction.replace(R.id.fragmentContainer, it)
            fragmentTransaction.addToBackStack(null)
            fragmentTransaction.commit()
        }
    }

    fun displayAbout() {
        if (aboutFragment == null) {
            aboutFragment = AboutFragment()
        }

        aboutFragment?.let {
            val fragmentTransaction = supportFragmentManager.beginTransaction()

            fragmentTransaction.replace(R.id.fragmentContainer, it)
            fragmentTransaction.addToBackStack(null)
            fragmentTransaction.commit()
        }
    }
}
