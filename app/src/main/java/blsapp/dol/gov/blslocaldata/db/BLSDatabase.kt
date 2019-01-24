package blsapp.dol.gov.blslocaldata.db

import android.arch.persistence.db.SupportSQLiteDatabase
import android.arch.persistence.room.Database
import android.arch.persistence.room.Room
import android.arch.persistence.room.RoomDatabase
import android.content.Context
import blsapp.dol.gov.blslocaldata.db.dao.*
import blsapp.dol.gov.blslocaldata.db.entity.*
import java.util.concurrent.Executors

@Database(entities = arrayOf(ZipCountyEntity::class, ZipCbsaEntity::class, NationalEntity::class,
        MetroEntity::class, StateEntity::class, CountyEntity::class,
        MSACountyEntity::class, IndustryEntity::class), version = 2)
abstract class BLSDatabase: RoomDatabase() {
    abstract fun zipCountyDAO(): ZipCountyDao
    abstract fun zipCbsaDAO(): ZipCbsaDao
    abstract fun metroDAO(): MetroDao
    abstract fun stateDAO(): StateDao
    abstract fun countyDAO(): CountyDao
    abstract fun nationalDAO(): NationalDao
    abstract fun msaCountyDAO(): MSACountyDao
    abstract fun industryDAO(): IndustryDao

    companion object {
        @Volatile
        private var INSTANCE: BLSDatabase? = null

        fun getInstance(context: Context): BLSDatabase {
            val tempInstance = INSTANCE
            if (tempInstance != null) {
                return tempInstance
            }
            synchronized(this) {
                val instance = Room.databaseBuilder(context.applicationContext,
                        BLSDatabase::class.java,
                        "BLSDatabase.db")
                        .fallbackToDestructiveMigration()
                        .addCallback(object : Callback() {
                            override fun onCreate(db: SupportSQLiteDatabase) {
                                super.onCreate(db)
                                Executors.newSingleThreadExecutor().execute {
//                                    fillInDB(context, getInstance(context = appContext))
                                }
                            }
                        })
                        .build()
                INSTANCE = instance
                return instance
            }
        }

        private fun fillInDB(context: Context, db: BLSDatabase) {
            LoadDataUtil.preloadDB(context, db)
        }
    }
}
