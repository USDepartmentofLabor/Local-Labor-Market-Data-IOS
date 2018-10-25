package blsapp.dol.gov.blslocaldata.ui.search

import android.Manifest
import android.annotation.SuppressLint
import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.net.Uri
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler
import android.os.ResultReceiver
import android.provider.Settings
import android.support.design.widget.Snackbar
import android.support.design.widget.Snackbar.*
import android.support.v4.app.ActivityCompat
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.SearchView
import blsapp.dol.gov.blslocaldata.BLSApplication
import blsapp.dol.gov.blslocaldata.BuildConfig
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.AreaEntity
import blsapp.dol.gov.blslocaldata.services.Constants
import blsapp.dol.gov.blslocaldata.services.FetchAddressIntentService
import blsapp.dol.gov.blslocaldata.ui.area.MetroStateActivity
import blsapp.dol.gov.blslocaldata.ui.info.AboutActivity
import blsapp.dol.gov.blslocaldata.ui.viewmodel.*
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.tasks.OnSuccessListener
import kotlinx.android.synthetic.main.activity_search.*
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread


class SearchActivity : AppCompatActivity(), AreaListAdapter.OnItemClickListener {
    private val TAG = SearchActivity::class.java.simpleName
    private var REQUEST_PERMISSIONS_REQUEST_CODE = 34

    private val CURRENT_LOCATION_TEXT = "Current Location"
    private val NATIONAL_TEXT = "National"

    private lateinit var areaViewModel: SearchAreaViewModel
    private var lastLocation: Location? = null
    private lateinit var addressResultReceiver: AddressResultReceiver
    private var fusedLocationClient : FusedLocationProviderClient? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_search)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        addressResultReceiver = AddressResultReceiver(Handler())

        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        val adapter = AreaListAdapter(this)
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(this)

        val repository = (application as BLSApplication).repository
        // Get a new or existing ViewModel from the ViewModelProvider.
        areaViewModel = ViewModelProviders.of(this).get(SearchAreaViewModel::class.java)

        // Add an observer on the LiveData returned by getAlphabetizedWords.
        // The onChanged() method fires when the observed data changes and the activity is
        // in the foreground.
        areaViewModel.areas.observe(this, Observer { areas ->
            // Update the cached copy of the words in the adapter.
            areas?.let { adapter.setArea(getAreaRows(it)) }
        })

        radioGroup.setOnCheckedChangeListener { group, checkedId ->
            var areaType = AreaType.METRO
            when(checkedId) {
                R.id.metroRadioButton -> { areaType = AreaType.METRO }
                R.id.stateRadioButton -> { areaType = AreaType.STATE }
                R.id.countyRadioButton -> { areaType = AreaType.COUNTY }

            }
            areaViewModel.setAreaType(areaType)
        }

        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {

            override fun onQueryTextChange(newText: String?): Boolean {
                areaViewModel.setQuery(newText!!)
                return true
            }

            override fun onQueryTextSubmit(query: String?): Boolean {
//                TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
                return true
            }
        })
    }

    public override fun onStart() {
        super.onStart()

        if (!checkPermissions()) {
            requestPermissions()
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_search, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem) = when (item.itemId) {
        R.id.action_info -> {
            val intent = Intent(applicationContext, AboutActivity::class.java)
            startActivity(intent)
            true
        }
        else -> {
            super.onOptionsItemSelected(item)
        }
   }

    override fun onItemClick(item: AreaRow) {

        when (item.type) {
            RowType.HEADER -> {
                doAsync {
                    var nationalArea = areaViewModel.nationaArea
                    uiThread {
                        displayReport(nationalArea)
                    }
                }
            }
            RowType.ITEM -> {
                item.area?.let {
                    displayReport(it)
                }
            }
        }
    }

    private fun displayReport(area: AreaEntity) {
        val intent = Intent(applicationContext,
                MetroStateActivity::class.java)
        intent.putExtra(MetroStateActivity.KEY_AREA, area)
        startActivity(intent)
    }


    fun getAreaRows(areaList: List<AreaEntity>) : ArrayList<AreaRow> {
        val areaRows = ArrayList<AreaRow>()
        areaRows.add(AreaRow(RowType.HEADER, null, CURRENT_LOCATION_TEXT))
        areaRows.add(AreaRow(RowType.HEADER, null, NATIONAL_TEXT))

        val areaTitle: String
        when(radioGroup.checkedRadioButtonId) {
            R.id.stateRadioButton -> areaTitle = "State"
            R.id.countyRadioButton -> areaTitle = "County"
            else -> areaTitle = "Metro Area"
        }

        areaRows.add(AreaRow(RowType.HEADER, null, areaTitle))

        val itemRows = areaList.map { AreaRow(RowType.ITEM, it, null) }
        areaRows.addAll(itemRows)
        return areaRows
    }

    @SuppressLint("MissingPermission")
    private fun getAddress() {
        fusedLocationClient?.lastLocation?.addOnSuccessListener(this, OnSuccessListener { location ->
            if (location == null) {
                Log.w(TAG, "onSuccess:null")
                return@OnSuccessListener
            }

            lastLocation = location

            // Determine whether a Geocoder is available.
            if (!Geocoder.isPresent()) {
                make(findViewById<View>(android.R.id.content),
                        R.string.no_geocoder_available, LENGTH_LONG).show()
                return@OnSuccessListener
            }

            // If the user pressed the fetch address button before we had the location,
            // this will be set to true indicating that we should kick off the intent
            // service after fetching the location.
//            if (addressRequested)
            startAddressService()
        })?.addOnFailureListener(this) { e -> Log.w(TAG, "getLastLocation:onFailure", e) }
    }

    fun startAddressService() {
        val intent = Intent(this, FetchAddressIntentService::class.java).apply {
            putExtra(Constants.RECEIVER, addressResultReceiver)
            putExtra(Constants.LOCATION_DATA_EXTRA, lastLocation)
        }
        startService(intent)
    }

    fun fetchAddressButtonHander(view: View) {
        if (lastLocation != null) {
            startAddressService()
            return
        }

        // If we have not yet retrieved the user location, we process the user's request by setting
        // addressRequested to true. As far as the user is concerned, pressing the Fetch Address
        // button immediately kicks off the process of getting the address.
//        addressRequested = true
//        updateUIWidgets()
    }

    internal inner class AddressResultReceiver(handler: Handler) : ResultReceiver(handler) {

        override fun onReceiveResult(resultCode: Int, resultData: Bundle?) {

            // Display the address string
            // or an error message sent from the intent service.
            val address = resultData?.getString(Constants.RESULT_DATA_KEY) ?: ""

        }
    }

    // Location Permissions
    private fun checkPermissions(): Boolean {
        val permissionState = ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_COARSE_LOCATION)
        return permissionState == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Shows a [Snackbar].
     *
     * @param snackStrId The id for the string resource for the Snackbar text.
     * @param actionStrId The text of the action item.
     * @param listener The listener associated with the Snackbar action.
     */
    private fun showSnackbar(
            snackStrId: Int,
            actionStrId: Int = 0,
            listener: View.OnClickListener? = null) {
        val snackbar = Snackbar.make(findViewById(android.R.id.content), getString(snackStrId),
                LENGTH_INDEFINITE)
        if (actionStrId != 0 && listener != null) {
            snackbar.setAction(getString(actionStrId), listener)
        }
        snackbar.show()
    }

    private fun requestPermissions() {
        val shouldProvideRationale = ActivityCompat.shouldShowRequestPermissionRationale(this,
                Manifest.permission.ACCESS_COARSE_LOCATION)

        // Provide an additional rationale to the user. This would happen if the user denied the
        // request previously, but didn't check the "Don't ask again" checkbox.
        if (shouldProvideRationale) {
            Log.i(TAG, "Displaying permission rationale to provide additional context.")

            showSnackbar(R.string.permission_rationale, android.R.string.ok,
                    View.OnClickListener {
                        // Request permission
                        ActivityCompat.requestPermissions(this@SearchActivity,
                                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                                REQUEST_PERMISSIONS_REQUEST_CODE)
                    })

        } else {
            Log.i(TAG, "Requesting permission")
            // Request permission. It's possible this can be auto answered if device policy
            // sets the permission in a given state or the user denied the permission
            // previously and checked "Never ask again".
            ActivityCompat.requestPermissions(this@SearchActivity,
                    arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),
                    REQUEST_PERMISSIONS_REQUEST_CODE)
        }
    }

    /**
     * Callback received when a permissions request has been completed.
     */
    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>,
            grantResults: IntArray) {
        Log.i(TAG, "onRequestPermissionResult")

        if (requestCode != REQUEST_PERMISSIONS_REQUEST_CODE) return

        when {
            grantResults.isEmpty() ->
                // If user interaction was interrupted, the permission request is cancelled and you
                // receive empty arrays.
                Log.i(TAG, "User interaction was cancelled.")
                grantResults[0] == PackageManager.PERMISSION_GRANTED -> // Permission granted.
                getAddress()
            else -> // Permission denied.

                // Notify the user via a SnackBar that they have rejected a core permission for the
                // app, which makes the Activity useless. In a real app, core permissions would
                // typically be best requested during a welcome-screen flow.

                // Additionally, it is important to remember that a permission might have been
                // rejected without asking the user for permission (device policy or "Never ask
                // again" prompts). Therefore, a user interface affordance is typically implemented
                // when permissions are denied. Otherwise, your app could appear unresponsive to
                // touches or interactions which have required permissions.

                showSnackbar(R.string.permission_denied_explanation, R.string.settings,
                        View.OnClickListener {
                            // Build intent that displays the App settings screen.
                            val intent = Intent().apply {
                                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                                data = Uri.fromParts("package", BuildConfig.APPLICATION_ID, null)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                        })
        }

    }
}
