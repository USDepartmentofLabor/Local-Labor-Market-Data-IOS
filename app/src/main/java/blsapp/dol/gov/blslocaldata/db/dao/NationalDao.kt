package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.lifecycle.LiveData
import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.NationalEntity

@Dao
interface NationalDao {
    @Query("SELECT * from National limit 1")
    fun getAll(): NationalEntity

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(national: NationalEntity)

    @Query("DELETE from National")
    fun deleteAll()
}