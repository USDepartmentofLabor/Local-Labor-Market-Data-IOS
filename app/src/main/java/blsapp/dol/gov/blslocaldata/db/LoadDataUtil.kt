package blsapp.dol.gov.blslocaldata.db

import android.content.Context
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.entity.*
import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException
import java.io.InputStreamReader

class LoadDataUtil {

    companion object {

        private val MSA_TITLE = "Metropolitan Statistical Area"
        private val NECTA_ATITLE = "Metropolitan NECTA"

        fun readFile(context: Context, resId: Int, ext: String = "csv"): ArrayList<List<String>> {
            val stream = context.resources.openRawResource(resId)

            var fileReader: BufferedReader? = null
            var line: String?
            val lines = ArrayList<List<String>>()

            try {
                fileReader = BufferedReader(InputStreamReader(stream, "UTF-8"))
                line = fileReader.readLine()

                while (line != null) {
                    val tokens: List<String>

                    if (ext == "csv")
                        tokens = line.split(",")
                    else {
                        tokens = line.split("\t")
                    }
                    if (tokens.count() > 0) {
                        lines.add(tokens)
                    }
                    line = fileReader.readLine()
                }
            }
            catch (e: Exception) {
                e.printStackTrace()
            }
            finally {
                try {
                    fileReader!!.close()
                } catch (e: IOException) {
                    println("Closing fileReader Error!")
                    e.printStackTrace()
                }
            }
            return lines
        }

        fun preloadDB(context: Context, db: BLSDatabase) {
            loadZipCounty(context, db)
            loadZipCbsa(context, db)
            loadArea(context, db)
            loadMsaCounty(context, db)
        }

        private fun loadZipCounty(context: Context, db: BLSDatabase) {
            db.zipCountyDAO().deleteAll()

            val lines = readFile(context, R.raw.zip_county)
            for (line in lines) {
                if (line.count() > 1) {
                    val zipCounty = ZipCountyEntity(id = null, zipCode = line[0], countyCode = line[1])
                    db.zipCountyDAO().insert(zipCounty = zipCounty)
                }
            }
        }

        private fun loadZipCbsa(context: Context, db: BLSDatabase) {
            db.zipCbsaDAO().deleteAll()

            val lines = readFile(context, R.raw.zip_cbsa)
            for (line in lines) {
                if (line.count() > 1) {
                    val zipCbsa = ZipCbsaEntity(id = null, zipCode = line[0], cbsaCode = line[1])
                    db.zipCbsaDAO().insert(zipCbsa = zipCbsa)
                }
            }
        }

        private fun loadMsaCounty(context: Context, db: BLSDatabase) {
            db.msaCountyDAO().deleteAll()

            val lines = readFile(context, R.raw.msa_county, ext = "txt")
            for (line in lines) {
                if (line.count() > 1) {
                    val msaCounty = MSACountyEntity(id = null, msaCode = line[1], countyCode = line[4] + line[5])
                    db.msaCountyDAO().insert(msaCounty = msaCounty)
                }
            }

            val nectaLines = readFile(context, R.raw.msanecta_county, ext = "txt")
            for (line in nectaLines) {
                if (line.count() > 1) {
                    val msaCounty = MSACountyEntity(id = null, msaCode = line[1], countyCode = line[4] + line[5])
                    db.msaCountyDAO().insert(msaCounty = msaCounty)
                }
            }
        }

        private fun loadArea(context: Context, db: BLSDatabase) {
            db.metroDAO().deleteAll()
            db.stateDAO().deleteAll()
            db.countyDAO().deleteAll()
            db.nationalDAO().deleteAll()

            val lines = readFile(context, R.raw.la_area, ext = "txt")

            for (line in lines) {
                if (line.count() > 1) {
                    val areaType = line[0]

                    if (areaType == "A" || areaType == "B" || areaType == "F") {
                        val code = line[1]
                        var title = line[2]

                        val stateCode = code.substring(2, 4)

                        // State
                        if (areaType == "A") {
                            val state = StateEntity(id = null, code = stateCode, title = title, lausCode = code )
                            db.stateDAO().insert(state)
                        }
                        else if (areaType == "B" &&
                                (title.contains(MSA_TITLE, ignoreCase = true) || title.contains(NECTA_ATITLE, ignoreCase = true))) {
                            // Get the CBSA/Metropolitan Code
                            // Code is of Format MT + StateCode + CBSACode
                            val cbsaCode = code.substring(4, 9)
                            title = title.replaceFirst(MSA_TITLE, "", ignoreCase = true)
                            title = title.replaceFirst(NECTA_ATITLE, "", ignoreCase = true)
                            val metro = MetroEntity(id = null, code = cbsaCode, title = title, stateCode = stateCode, lausCode = code )

                            db.metroDAO().insert(metro)
                        }
                        else if (areaType == "F") {
                            val countyCode = code.substring(2, 7)
                            val county = CountyEntity(id = null, code = countyCode, title = title, lausCode = code )
                            db.countyDAO().insert(county)
                        }
                    }
                }

                val national = NationalEntity(id = null, code = "00000", title = "National", lausCode = "0000000")
                db.nationalDAO().insert(national)
            }
        }

    }
}