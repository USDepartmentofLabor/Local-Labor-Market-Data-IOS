package blsapp.dol.gov.blslocaldata.db

import android.arch.lifecycle.LiveData
import android.arch.persistence.db.SupportSQLiteDatabase
import android.arch.persistence.room.Room
import android.arch.persistence.room.RoomDatabase
import android.content.Context
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.dao.IndustryType
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ioThread
import java.util.concurrent.Executors

/**
 * LocalRepository - Local Database Accessor fuctions
 */

class LocalRepository private constructor(private val mDatabase: BLSDatabase) {

    fun getMetroAreas(search: String?): List<MetroEntity> {
        if (search == null || search.isEmpty()) {
            return mDatabase.metroDAO().getAll()
        }
        search.toIntOrNull()?.let {
            val cbsaCodes = mDatabase.zipCbsaDAO().getCBSA(search)
            if (cbsaCodes.count() > 0) {
                return mDatabase.metroDAO().findByCodes(cbsaCodes)
            }
        }

        return mDatabase.metroDAO().findByTitle(search)
    }
    fun getCountyAreas(search: String?): List<CountyEntity> {
        if (search == null || search.isEmpty()) {
            return mDatabase.countyDAO().getAll()
        }

        search.toIntOrNull()?.let {
            val countyCodes = mDatabase.zipCountyDAO().getCountyCode(search)
            if (countyCodes.count() > 0) {
                return mDatabase.countyDAO().findByCodes(countyCodes)
            }
        }

        return mDatabase.countyDAO().findByTitle(search)
    }

    fun searchHierarchies(search: String?, industryType:IndustryType): List<IndustryEntity> {
        if (search == null || search.isEmpty()) {
            return mDatabase.industryDAO().getAll()
        }
        return mDatabase.industryDAO().searchByNameAndCode(search, industryType.ordinal)
    }

    fun getStateAreas(search: String?): List<StateEntity> {
        if (search == null || search.isEmpty()) {
            return mDatabase.stateDAO().getAll()
        }

        search.toIntOrNull()?.let {
            val countyCodes = mDatabase.zipCountyDAO().getCountyCode(search)
            val stateCodes = countyCodes.map { it.substring(0,2) }.distinct()
            if (stateCodes.count() > 0) {
                return mDatabase.stateDAO().findByCodes(stateCodes)
            }
        }

        return mDatabase.stateDAO().findByTitle(search)
    }

    fun getNationalArea(): NationalEntity {
        return mDatabase.nationalDAO().getAll()
    }


    fun getCountyAreas(area: AreaEntity): List<CountyEntity>? {
        var counties: List<CountyEntity>? = null
        when(area) {
            is MetroEntity -> {
                val countyCodes = mDatabase.msaCountyDAO().getCountyCodes(area.code)
                counties = mDatabase.countyDAO().findByCodes(countyCodes)
            }

            is StateEntity -> {
                counties = mDatabase.countyDAO().findForStateCodes(area.code)
            }
        }

        return counties
    }

    fun getMetroAreas(area: AreaEntity): List<MetroEntity>? {

        var metros: List<MetroEntity>? = null
        when(area) {
            is CountyEntity -> {
                val metroCodes = mDatabase.msaCountyDAO().getMSACodes(area.code)
                metros = mDatabase.metroDAO().findByCodes(metroCodes)
            }

            is StateEntity -> {
                // Get Counties for State
                val counties = mDatabase.countyDAO().findForStateCodes(area.code)
                // From Counties, get their metro Areas
                val countyCodes = counties.map { it.code }
                val msaCodes = mDatabase.msaCountyDAO().getMSACodes(countyCodes)
                metros = mDatabase.metroDAO().findByCodes(msaCodes)
            }
        }
        return metros
    }

    fun getStateAreas(area: AreaEntity): List<AreaEntity>? {

        var states: List<StateEntity>? = null
        when(area) {
            is CountyEntity -> {
                val stateCode = area.code.substring(0, 2)
                states = mDatabase.stateDAO().findByCodes(listOf(stateCode))
            }

            is MetroEntity -> {
                // Get Counties for Metro
                val counties = mDatabase.msaCountyDAO().getCountyCodes(area.code)
                val stateCodes = counties.map { it.substring(0, 2) }.distinct()
                states = mDatabase.stateDAO().findByCodes(stateCodes)
            }
        }
        return states
    }

    fun getChildLeafIndustries(parentCode: Long, industryType: IndustryType): List<IndustryEntity>? {
        var retIndustries: MutableList <IndustryEntity> = mutableListOf()
        val industries = mDatabase.industryDAO().findChildrenByParentAndType(parentCode, industryType.ordinal)
        for (industry in industries) {
            if (!industry.superSector) {
                retIndustries.add(industry)
            } else {
                val leafChildren = getChildLeafIndustries(industry.id!!.toLong(), industryType)
                if (leafChildren != null && leafChildren.isNotEmpty()) {
                    retIndustries.addAll(leafChildren)
                }
            }
        }
        return retIndustries
    }

    fun getChildIndustries(parentCode: Long, industryType: IndustryType): List<IndustryEntity>? {
        val industries = mDatabase.industryDAO().findChildrenByParentAndType(parentCode, industryType.ordinal)
        return industries
    }

    fun getIndustry(industryId: Long): IndustryEntity? {
        val industries = mDatabase.industryDAO().findIndustryById(industryId)
        var retIndustry: IndustryEntity? = null
        if (industries.isNotEmpty())
            retIndustry = industries.first()
        return retIndustry
    }

    companion object {
        private var instance: LocalRepository? = null

        fun getInstance(database: BLSDatabase): LocalRepository {
            if (instance == null) {
                synchronized(LocalRepository::class.java) {
                    if (instance == null) {
                        instance = LocalRepository(database)
                    }
                }
            }
            return instance!!
        }

        private var stateMap: Map<String, String> = hashMapOf("AL" to "Alabama",
                                "AK" to "alaska",
                                "AZ" to "arizona",
                                "AR" to "arkansas",
                                "CA" to "california",
                                "CO" to "colorado",
                                "CT" to "connecticut",
                                "DE" to "delaware",
                                "DC" to "district of columbia",
                                "FL" to "florida",
                                "GA" to "georgia",
                                "HI" to "hawaii",
                                "ID" to "idaho",
                                "IL" to "illinois",
                                "IN" to "indiana",
                                "IA" to "iowa",
                                "KS" to "kansas",
                                "KY" to "kentucky",
                                "LA" to "louisiana",
                                "ME" to "maine",
                                "MD" to "maryland",
                                "MA" to "massachusetts",
                                "MI" to "michigan",
                                "MN" to "minnesota",
                                "MS" to "mississippi",
                                "MO" to "missouri",
                                "MT" to "montana",
                                "NE" to "nebraska",
                                "NV" to "nevada",
                                "NH" to "new hampshire",
                                "NJ" to "new jersey",
                                "NM" to "new mexico",
                                "NY" to "new york",
                                "NC" to "north carolina",
                                "ND" to "north dakota",
                                "OH" to "ohio",
                                "OK" to "oklahoma",
                                "OR" to "oregon",
                                "PA" to "pennsylvania",
                                "RI" to "rhode island",
                                "SC" to "south carolina",
                                "SD" to "south dakota",
                                "TN" to "tennessee",
                                "TX" to "texas",
                                "UT" to "utah",
                                "VT" to "vermont",
                                "VA" to "virginia",
                                "WA" to "washington",
                                "WV" to "west virginia",
                                "WI" to "wisconsin",
                                "WY" to "wyoming",
                                "PR" to "Puerto Rico")

        fun stateName(stateCode: String): String? {
            return stateMap[stateCode]
        }
    }
}