package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.CountyEntity

@Dao
interface CountyDao {
    @Query("SELECT * from County order by title")
    fun getAll(): List<CountyEntity>

    @Query("SELECT * from County where title like '' || :search || '%' order by title")
    fun findByTitle(search: String): List<CountyEntity>

    @Query("SELECT * from County where code in (:codes) order by title")
    fun findByCodes(codes: List<String>): List<CountyEntity>

    @Query("SELECT * from County where code like '' || :stateCode || '%' order by title")
    fun findForStateCodes(stateCode: String): List<CountyEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(county: CountyEntity)

    @Query("DELETE from County")
    fun deleteAll()
}