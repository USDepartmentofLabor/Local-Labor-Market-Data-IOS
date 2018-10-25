package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.lifecycle.LiveData
import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.MetroEntity

@Dao
interface MetroDao {
    @Query("SELECT * from Metro order by title")
    fun getAll(): List<MetroEntity>

    @Query("SELECT * from Metro where title like '%' || :search || '%'  order by title")
    fun findByTitle(search: String): List<MetroEntity>

    @Query("SELECT * from Metro where code in (:codes)")
    fun findByCodes(codes: List<String>): List<MetroEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(metro: MetroEntity)

    @Query("DELETE from Metro")
    fun deleteAll()
}