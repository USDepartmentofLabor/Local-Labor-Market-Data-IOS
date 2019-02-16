package blsapp.dol.gov.blslocaldata.ui.viewmodel

import android.app.Application
import android.arch.lifecycle.*
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.dao.NationalDao
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ioThread
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

enum class AreaType {
    METRO,
    STATE,
    COUNTY
}

/**
 * SearchAreaViewModel - View Model for the Area Screen screen (currently 1st screen in app)
 */
class SearchAreaViewModel(application: Application) : AndroidViewModel(application) {

    val repository: LocalRepository
    private var mAreas = MutableLiveData<List<AreaEntity>>()
    val areas: LiveData<List<AreaEntity>>
        get() = mAreas

    val nationaArea: NationalEntity
        get() = repository.getNationalArea()


    private var query : String? = null
    private var areaType = AreaType.METRO

    fun setQuery(originalInput: String) {
        val input = originalInput.toLowerCase().trim()
        if (input == query) {
            return
        }
        query = input
        loadAreas()
    }

    fun setAreaType(type: AreaType) {
        if (type == areaType) {
            return
        }
        areaType = type
        loadAreas()
    }

//    fun getAreas(searchStr: String? = null): MediatorLiveData<List<AreaEntity>> {
//        return repository.getMetroAreas(searchStr) as LiveData<List<AreaEntity>>

//        when(areaType) {
//            AreaType.METRO -> {
////                loadMetroAreas()
//             return repository.getMetroAreas(searchStr)}
//            AreaType.STATE -> {loadStateAreas()}
//            AreaType.COUNTY -> {loadCountyAreas()}
//        }
////        return areas
//    }

    init {
        val db = BLSDatabase.getInstance(application)
        repository = LocalRepository.getInstance(db)
        loadAreas()
//        mAreas = MediatorLiveData()
//
//        mAreas.addSource(query) { q ->
//            mAreas.postValue(loadAreas())}
    }

    fun loadAreas() {
        ioThread {
            var area: List<AreaEntity> = loadMetroAreas(searchStr = query)
            when (areaType) {
                AreaType.METRO -> {
                    area = loadMetroAreas(searchStr = query)
                }
                AreaType.STATE -> {
                    area = loadStateAreas(searchStr = query)
                }
                AreaType.COUNTY -> {
                    area = loadCountyAreas(searchStr = query)
                }
            }
            mAreas.postValue(area)
        }
    }

    fun loadMetroAreas(searchStr: String?) : List<MetroEntity> {
        return repository.getMetroAreas(searchStr)
    }
    fun loadStateAreas(searchStr: String?) : List<StateEntity> {
        return repository.getStateAreas(searchStr)
    }

    fun loadCountyAreas(searchStr: String?) : List<CountyEntity> {
        return repository.getCountyAreas(searchStr)
    }

}