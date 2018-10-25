package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.MSACountyEntity

@Dao
interface MSACountyDao {
    @Query("SELECT * from MSACounty")
    fun getAll(): List<MSACountyEntity>

    @Query("SELECT msaCode from MSACounty where countyCode = (:countyCode)")
    fun getMSACodes(countyCode: String) : List<String>

    @Query("SELECT distinct msaCode from MSACounty where countyCode in (:countyCodes)")
    fun getMSACodes(countyCodes: List<String>) : List<String>

    @Query("SELECT countyCode from MSACounty where msaCode = (:msaCode)")
    fun getCountyCodes(msaCode: String) : List<String>

    @Query("SELECT distinct countyCode from MSACounty where msaCode in (:msaCodes)")
    fun getCountyCodes(msaCodes: List<String>) : List<String>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(msaCounty: MSACountyEntity)

    @Query("DELETE from MSACounty")
    fun deleteAll()

}