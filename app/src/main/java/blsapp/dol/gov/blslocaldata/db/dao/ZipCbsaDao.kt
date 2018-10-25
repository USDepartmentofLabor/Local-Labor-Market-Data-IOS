package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.lifecycle.LiveData
import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.ZipCbsaEntity

@Dao
interface ZipCbsaDao {
    @Query("SELECT * from ZIP_CBSA")
    fun getAll(): List<ZipCbsaEntity>

    @Query("SELECT * from ZIP_CBSA where zipCode = :zipCode")
    fun get(zipCode: String): List<ZipCbsaEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(zipCbsa: ZipCbsaEntity)

    @Query("DELETE from ZIP_CBSA")
    fun deleteAll()
}