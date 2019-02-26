package blsapp.dol.gov.blslocaldata.db

import android.arch.persistence.db.SupportSQLiteDatabase
import android.arch.persistence.room.Database
import android.arch.persistence.room.Room
import android.arch.persistence.room.RoomDatabase
import android.content.Context
import android.util.Log
import blsapp.dol.gov.blslocaldata.db.dao.*
import blsapp.dol.gov.blslocaldata.db.entity.*
import blsapp.dol.gov.blslocaldata.ui.search.SearchActivity
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.Executors
import java.nio.file.Files.exists



@Database(entities = arrayOf(ZipCountyEntity::class, ZipCbsaEntity::class, NationalEntity::class,
        MetroEntity::class, StateEntity::class, CountyEntity::class,
        MSACountyEntity::class), version = 1)
abstract class BLSDatabase: RoomDatabase() {

    abstract fun zipCountyDAO(): ZipCountyDao
    abstract fun zipCbsaDAO(): ZipCbsaDao
    abstract fun metroDAO(): MetroDao
    abstract fun stateDAO(): StateDao
    abstract fun countyDAO(): CountyDao
    abstract fun nationalDAO(): NationalDao
    abstract fun msaCountyDAO(): MSACountyDao

    companion object {
        @Volatile
        private var INSTANCE: BLSDatabase? = null
        private val TAG = SearchActivity::class.java.simpleName
        private val DB_NAME = "BLSDatabase.db"

        fun getInstance(context: Context): BLSDatabase {
            val tempInstance = INSTANCE
            if (tempInstance != null) {
                return tempInstance
            }

            synchronized(this) {

                val dbPath = context.getDatabasePath(DB_NAME)
            //    if (!dbPath.exists()) {
                    copyAttachedDatabase(context, DB_NAME)
             //   }
                val instance = Room.databaseBuilder(context.applicationContext,
                        BLSDatabase::class.java,
                        DB_NAME)
                        .fallbackToDestructiveMigration()
                        .build()
                INSTANCE = instance
                return instance
            }
        }

        private fun fillInDB(context: Context, db: BLSDatabase) {
            LoadDataUtil.preloadDB(context, db)
        }

        private fun copyAttachedDatabase(context: Context, databaseName: String) {
            val dbPath = context.getDatabasePath(databaseName)
            // Make sure we have a path to the file
            dbPath.parentFile.mkdirs()

            // Try to copy database file
            try {
                val inputStream = context.assets.open("$databaseName")
                val output = FileOutputStream(dbPath)

                val buffer = ByteArray(8192)

                while (inputStream.read(buffer) > 0) {
                    output.write(buffer)
                    Log.d("#DB", "writing>>")
                }

                output.flush()
                output.close()
                inputStream.close()
            } catch (e: IOException) {
                Log.d(TAG, "Failed to open file", e)
                e.printStackTrace()
            }

        }
    }
}
