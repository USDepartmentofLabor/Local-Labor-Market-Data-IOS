package blsapp.dol.gov.blslocaldata.ui

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import blsapp.dol.gov.blslocaldata.R
import android.content.Intent
import blsapp.dol.gov.blslocaldata.ui.search.SearchActivity

/**
 * SplashScreenActivity - Splash Screen - launching of app
 */

class SplashScreenActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash_screen)

        val intent = Intent(applicationContext,
                SearchActivity::class.java)
        startActivity(intent)
        finish()
    }
}
