package blsapp.dol.gov.blslocaldata

import android.support.test.InstrumentationRegistry
import android.support.test.runner.AndroidJUnit4
import android.util.Log
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.model.reports.*
import blsapp.dol.gov.blslocaldata.network.BlsAPI

import org.junit.Test
import org.junit.runner.RunWith

import org.junit.Assert.*

/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class ExampleInstrumentedTest {
    @Test
    fun useAppContext() {
        // Context of the app under test.
        val appContext = InstrumentationRegistry.getTargetContext()
        assertEquals("blsapp.dol.gov.blslocaldata", appContext.packageName)
    }

    @Test
    fun getReports() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val seriesIds = listOf("LNU04000000")
        BlsAPI.getInstance(appContext).getReports(seriesIds, "2018", endYear = "2017",successHandler =  {}, failureHandler = {})
    }

    @Test
    fun getLAUSSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getCountyAreas("Loudoun")
        if (areas.count() > 0) {
            val seriesid = LAUSReport.unemploymentRateSeriesId(area = areas.first(), adjustment = SeasonalAdjustment.NOT_ADJUSTED)
            Log.w("Test", seriesid)
            assertEquals("LAUCN511070000000003", seriesid)
        }
    }
    @Test
    fun getStateOESSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getStateAreas("Virginia")
        if (areas.count() > 0) {
            val seriesid = OESReport.getSeriesId(area = areas.first(),
                    dataTypeCode = OESReport.DataTypeCode.EMPLOYMENT)
            Log.w("Test", seriesid)
            assertEquals("OEUS510000000000000000001", seriesid)
        }
    }
    @Test
    fun getMetroOESSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getMetroAreas("Washington-Arlington-Alexandria, DC-VA-MD-WV")
        if (areas.count() > 0) {
            val seriesid = OESReport.getSeriesId(area = areas.first(),
                    dataTypeCode = OESReport.DataTypeCode.ANNUALMEANWAGE)
            Log.w("Test", seriesid)
            assertEquals("OEUM004790000000000000004", seriesid)
        }
    }

    @Test
    fun getCPSSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val nationalArea = repository.getNationalArea()
        val seriesid = CPSReport.getUnemploymentRateSeriesId(nationalArea, adjustment = SeasonalAdjustment.ADJUSTED)
        assertEquals("LNS14000000", seriesid)

    }

    @Test
    fun getMetroCESSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getMetroAreas("Washington-Arlington-Alexandria, DC-VA-MD-WV")
        if (areas.count() > 0) {
            val seriesid = CESReport.getSeriesId(area = areas.first(), adjustment = SeasonalAdjustment.NOT_ADJUSTED,
                    dataTypeCode = CESReport.DataTypeCode.ALLEMPLOYEES)
            Log.w("Test", seriesid)
            assertEquals("SMU11479000000000001", seriesid)
        }
    }

    @Test
    fun getStateCESSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getStateAreas("Virginia")
        if (areas.count() > 0) {
            val seriesid = CESReport.getSeriesId(area = areas.first(), adjustment = SeasonalAdjustment.NOT_ADJUSTED,
                    dataTypeCode = CESReport.DataTypeCode.ALLEMPLOYEES)
            Log.w("Test", seriesid)
            assertEquals("SMU51000000000000001", seriesid)
        }
    }

    @Test
    fun getQCEWSeriesId() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getCountyAreas("Loudoun County")
        if (areas.count() > 0) {
            val seriesid = QCEWReport.getSeriesId(area = areas.first(),
                       ownershipCode = QCEWReport.OwnershipCode.PRIVATE_OWNERSHIP,
                        industryCode = QCEWReport.IndustryCode.ALL_INDUSTRY,
                        dataTypeCode = QCEWReport.DataTypeCode.allEmployees,
                        establishmentSize = QCEWReport.EstablishmentSize.ALL,
                        adjustment = SeasonalAdjustment.NOT_ADJUSTED)
            Log.w("Test", seriesid)
            assertEquals("ENU5110710510", seriesid)
        }
    }

    // METROS
    @Test
    fun getMetrosFromCounty() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getCountyAreas("Fairfield County, CT")
        if (areas.count() > 0) {
            val metros = repository.getMetroAreas(areas.first())
            assertEquals(2, metros!!.count())
        }
    }

    @Test
    fun getMetrosFromState() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getStateAreas("Virginia")
        if (areas.count() > 0) {
            val metros = repository.getMetroAreas(areas.first())
            assertEquals(11, metros!!.count())
        }
    }

    // STATES
    @Test
    fun getStatesFromCounty() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getCountyAreas("Loudoun County")
        if (areas.count() > 0) {
            val states = repository.getStateAreas(areas.first())
            assertEquals(1, states!!.count())
            assertEquals("Virginia", states.first().title)
        }
    }
    @Test
    fun getStatesFromMetro() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getMetroAreas("Washington-Arlington-Alexandria, DC-VA-MD-WV")
        if (areas.count() > 0) {
            val states = repository.getStateAreas(areas.first())
            assertEquals(4, states!!.count())
        }
    }


    // County
    @Test
    fun getCountiesFromState() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getStateAreas("Virginia")
        if (areas.count() > 0) {
            val counties = repository.getCountyAreas(areas.first())
            assertEquals(133, counties!!.count())
        }
    }
    @Test
    fun getCountiesFromMetro() {
        val appContext = InstrumentationRegistry.getTargetContext()

        val db = BLSDatabase.getInstance(appContext)
        val repository = LocalRepository.getInstance(db)
        val areas = repository.getMetroAreas("Washington-Arlington-Alexandria, DC-VA-MD-WV")
        if (areas.count() > 0) {
            val counties = repository.getCountyAreas(areas.first())
            assertEquals(24, counties!!.count())
        }
    }

}
