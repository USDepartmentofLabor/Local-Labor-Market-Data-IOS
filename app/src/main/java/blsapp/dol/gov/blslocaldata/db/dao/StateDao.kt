package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.StateEntity

@Dao
interface StateDao {
    @Query("SELECT * from State order by title")
    fun getAll(): List<StateEntity>

    @Query("SELECT * from State where title LIKE '' || :search || '%' order by title")
    fun findByTitle(search: String): List<StateEntity>

    @Query("SELECT * from State where code in (:codes) order by title")
    fun findByCodes(codes: List<String>): List<StateEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(state: StateEntity)

    @Query("DELETE from State")
    fun deleteAll()
}