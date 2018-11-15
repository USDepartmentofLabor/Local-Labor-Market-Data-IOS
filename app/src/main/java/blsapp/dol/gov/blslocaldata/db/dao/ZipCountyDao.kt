package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy.REPLACE
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.ZipCountyEntity

@Dao
interface ZipCountyDao {
    @Query("SELECT * from ZIP_COUNTY")
    fun getAll(): List<ZipCountyEntity>

    @Query("SELECT distinct countyCode from ZIP_COUNTY where zipCode like '' || :zipCode || '%'")
    fun getCountyCode(zipCode: String): List<String>

    @Insert(onConflict = REPLACE)
    fun insert(zipCounty: ZipCountyEntity)

    @Insert
    fun insertAll(zipCounties: List<ZipCountyEntity>)

    @Query("DELETE from ZIP_COUNTY")
    fun deleteAll()
}
