package blsapp.dol.gov.blslocaldata

import android.app.Application
import android.content.Context
import blsapp.dol.gov.blslocaldata.db.BLSDatabase
import blsapp.dol.gov.blslocaldata.db.LoadDataUtil
import blsapp.dol.gov.blslocaldata.db.LocalRepository
import blsapp.dol.gov.blslocaldata.db.entity.ZipCountyEntity
import blsapp.dol.gov.blslocaldata.model.DataUtil
import java.security.Provider

/**
 *  BLSApplication - Base Application for the BLS Local Area Data
 */

class BLSApplication : Application() {

    init {
        instance = this
    }

    companion object {

        private var instance: BLSApplication? = null
        fun applicationContext() : BLSApplication {
            return instance as BLSApplication
        }
    }

    val database: BLSDatabase
        get() = BLSDatabase.getInstance(this@BLSApplication)

    val repository: LocalRepository
        get() = LocalRepository.getInstance(database)

    override fun onCreate() {
        super.onCreate()

        ioThread {
           // if (database.zipCountyDAO().getAll().isEmpty()) {
                LoadDataUtil.preloadDB(this, database)
           // }
        }
    }

}
