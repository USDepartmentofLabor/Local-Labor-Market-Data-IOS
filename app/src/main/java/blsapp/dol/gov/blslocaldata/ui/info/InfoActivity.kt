package blsapp.dol.gov.blslocaldata.ui.info

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.view.MenuItem
import blsapp.dol.gov.blslocaldata.R
import kotlinx.android.synthetic.main.activity_info.*
import kotlinx.android.synthetic.main.content_info.*

class InfoActivity : AppCompatActivity() {

    var glossaryFragment: GlossaryFragment? = null
    var aboutFragment: AboutFragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_info)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

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
