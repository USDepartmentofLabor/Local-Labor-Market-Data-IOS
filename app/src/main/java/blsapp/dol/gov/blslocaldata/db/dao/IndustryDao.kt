package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.Dao
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import blsapp.dol.gov.blslocaldata.db.entity.IndustryEntity

enum class IndustryType {
    CE_INDUSTRY,
    SM_INDUSTRY,
    QCEW_INDUSTRY,
    OE_OCCUPATION
}

@Dao
interface IndustryDao {
    @Query("SELECT * from Industry")
    fun getAll(): List<IndustryEntity>

    @Query("SELECT * from Industry where industryCode = (:code)")
    fun findByCode(code: String): List<IndustryEntity>

    @Query("SELECT * from Industry where industryCode = (:code) AND industryType = (:type)")
    fun findByCodeAndType(code: String, type: Int): List<IndustryEntity>

    @Query("SELECT * from Industry where parentId = (:parentId)")
    fun findChildrenByParent(parentId: String): List<IndustryEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(industry: IndustryEntity):Long

    @Query("DELETE from Industry")
    fun deleteAll()

}