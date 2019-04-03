package blsapp.dol.gov.blslocaldata.db.dao

import android.arch.persistence.room.*
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

    @Query("SELECT * from Industry where industryType = (:type) AND (title LIKE '%' || :search || '%') order by title")
    fun searchByNameAndCode(search: String, type: Int): List<IndustryEntity>

    @Query("SELECT * from Industry where industryCode = (:code) AND industryType = (:type)")
    fun findByCodeAndType(code: String, type: Int): List<IndustryEntity>

    @Query("SELECT * from Industry where parentId = (:parentId) AND industryType = (:type)")
    fun findChildrenByParentAndType(parentId: Long, type: Int): List<IndustryEntity>

    @Query("SELECT * from Industry where id = (:passId)")
    fun findIndustryById(passId: Long): List<IndustryEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(industry: IndustryEntity):Long

    @Update
    fun updateIndustry(industry: IndustryEntity)

    @Query("DELETE from Industry")
    fun deleteAll()

}