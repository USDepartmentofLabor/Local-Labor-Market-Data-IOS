package blsapp.dol.gov.blslocaldata.db

import android.arch.persistence.room.Dao
import android.content.Context
import android.util.Log
import blsapp.dol.gov.blslocaldata.R
import blsapp.dol.gov.blslocaldata.db.dao.IndustryDao
import blsapp.dol.gov.blslocaldata.db.dao.IndustryType
import blsapp.dol.gov.blslocaldata.db.entity.*
import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException
import java.io.InputStreamReader
import java.util.*
import kotlin.math.absoluteValue

class LoadDataUtil {

    companion object {

        private val MSA_TITLE = "Metropolitan Statistical Area"
        private val NECTA_TITLE = "Metropolitan NECTA"

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
//            db.industryDAO().deleteAll()
//            loadIndustry(context, db, IndustryType.CE_INDUSTRY, R.raw.ce_industry, "txt")
//            loadIndustry(context, db, IndustryType.SM_INDUSTRY, R.raw.sm_industry, "txt")
//            loadIndustry(context, db, IndustryType.QCEW_INDUSTRY, R.raw.industry_titles, "txt")
//            loadIndustry(context, db, IndustryType.OE_OCCUPATION,  R.raw.oe_occupation, "txt")
//            loadZipCounty(context, db)
//            loadZipCbsa(context, db)
//            loadArea(context, db)
//            loadMsaCounty(context, db)
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

            val lines = readFile(context, R.raw.zip_necta)
            for (line in lines) {
                if (line.count() > 1) {
                    val zipCbsa = ZipCbsaEntity(id = null, zipCode = line[0], cbsaCode = line[1])
                    db.zipCbsaDAO().insert(zipCbsa = zipCbsa)
                }
            }

            val zipCBSAlines = readFile(context, R.raw.zip_cbsa)
            for (line in zipCBSAlines) {
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

//        private fun loadOccupation(context: Context, db: BLSDatabase, resourceId: Int, ext: String) {
//
//            val occupationItems = readFile(context, resourceId, ext)
//            var currentIndex = 1
//
//            val occupationItem = occupationItems[currentIndex]
//
//            val title = occupationItem[1]
//            val code = occupationItem[0]
//
//            val occupation = IndustryEntity(id = null,
//                    industryCode = code,
//                    title = title,
//                    superSector = true,
//                    industryType = IndustryType.OE_OCCUPATION.ordinal,
//                    parentId = -1)
//
//            Log.d("#DB", "Occupation Item: " + occupation.toString())
//            var parentId = db.industryDAO().insert(industry = occupation)
//            occupation.id = parentId
//
//            currentIndex++
//
//            while (currentIndex < occupationItems.count()) {
//                var newIndex = loadSubOccupation( db, currentIndex, parentId, occupationItems)
//                if (newIndex != currentIndex)
//                    currentIndex = newIndex
//                else {
//                    occupation.superSector = false
//                    db.industryDAO().updateIndustry(industry = occupation)
//                }
//            }
//        }
//        private fun loadSubOccupation(db: BLSDatabase, currentIndex: Int, parentId: Long,
//                                    occupations: ArrayList<List<String>> ):Int {
//
//            var currIndex = currentIndex
//            val occupationItem = occupations[currIndex]
//
//            currIndex++
//
//            if (occupationItem.count() <= 1) return currIndex
//
//            val title = occupationItem[1]
//            val code = occupationItem[0]
//
//            val occupation = IndustryEntity(id = null,
//                    industryCode = code,
//                    title = title,
//                    superSector = true,
//                    industryType = IndustryType.OE_OCCUPATION.ordinal,
//                    parentId = parentId)
//
//            Log.d("#DB", "Occupation Item: " + occupation.toString())
//            var parentId = db.industryDAO().insert(industry = occupation)
//            occupation.id = parentId
//
//            var parentCode = occupation.industryCode
//            if (occupation.industryCode.count() > 2)
//                parentCode = occupation.industryCode.trimEnd('0')
//
//            if (parentCode.length == 1) parentCode + "0"
//
//            while (currIndex < occupations.size && occupations[currIndex][0].startsWith(parentCode)) {
//                var newIndex = loadSubOccupation(db, currIndex, parentId, occupations)
//                if (newIndex != currIndex)
//                    currIndex = newIndex
//                else {
//                    occupation.superSector = false
//                    db.industryDAO().updateIndustry(industry = occupation)
//                }
//            }
//            return currIndex
//        }

        private fun loadIndustry(context: Context, db: BLSDatabase, industryType: IndustryType, resourceId: Int, ext: String) {

            val industryItems = readFile(context, resourceId, ext)
            var currentIndex = 1

            while (currentIndex < industryItems.count()-1) {
                var industryItem = industryItems[currentIndex]
                if (industryItem.count() > 1) {

                    var title: String?
                    var parentCode = ""

                    if (industryType == IndustryType.CE_INDUSTRY) {
                        title = industryItem[3]
                        if (industryItem.count() > 7) parentCode = industryItem[7]
                    } else if (industryType == IndustryType.OE_OCCUPATION) {
                        title = industryItem[1]
                    } else {
                        title = industryItem[1]
                        if (industryItem.count() > 2) parentCode = industryItem[2]
                    }
                    var parentId:Long = -1
                    var parentIndustry : IndustryEntity
                    if (parentCode.count() > 0) {
                        val industries = db.industryDAO().findByCodeAndType(parentCode, industryType.ordinal)
                        if (industries.isNotEmpty()) {
                            parentIndustry = industries[0]
                            parentId = parentIndustry.id!!.toLong()
                            Log.d("#DB", "ParentID: $parentId")
                            if (!parentIndustry.superSector) {
                                parentIndustry.superSector = true
                                db.industryDAO().updateIndustry(industry = parentIndustry)
                            }
                        }
                    }

                    val industry = IndustryEntity(id = null,
                            industryCode = industryItem[0],
                            title = title,
                            superSector = true,
                            industryType = industryType.ordinal,
                            parentId = parentId!!)

                    Log.d("#DB", "Parent: " + industry.toString())
                    parentId = db.industryDAO().insert(industry = industry)

                    currentIndex++

                    currentIndex = loadSubIndustry( db, industry, currentIndex, parentId, industryItems)
                }
            }
        }
        private fun loadSubIndustry(db: BLSDatabase, parent: IndustryEntity,
                                    currentIndex: Int, parentId: Long,
                                    industrys: ArrayList<List<String>> ):Int {

            var currIndex = currentIndex
            var parentCode = parent.industryCode
            if (parent.industryCode.count() > 2)
                parentCode = parent.industryCode.trimEnd('0')

            if (parentCode.length == 1) parentCode + "0"

            while (currIndex < industrys.size && industrys[currIndex][0].startsWith(parentCode)) {
                val title = if (parent.industryType == IndustryType.CE_INDUSTRY.ordinal) industrys[currIndex][3] else industrys[currIndex][1]
                val code = industrys[currIndex][0]
                var industry = IndustryEntity(id = null,
                        industryCode = code,
                        title = title,
                        superSector = true,
                        industryType = parent.industryType,
                        parentId = parentId)

                Log.d("#DB", "Child: " + industry.toString())
                var parentId = db.industryDAO().insert(industry = industry)
                industry.id = parentId

                currIndex++
                var newIndex = loadSubIndustry(db, industry, currIndex, parentId, industrys)
                if (newIndex != currIndex)
                    currIndex = newIndex
                else {
                    industry.superSector = false
                    db.industryDAO().updateIndustry(industry = industry)
                }

            }
            return currIndex
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
                                (title.contains(MSA_TITLE, ignoreCase = true) || title.contains(NECTA_TITLE, ignoreCase = true))) {
                            // Get the CBSA/Metropolitan Code
                            // Code is of Format MT + StateCode + CBSACode
                            val cbsaCode = code.substring(4, 9)
                            title = title.replaceFirst(MSA_TITLE, "", ignoreCase = true)
                            title = title.replaceFirst(NECTA_TITLE, "", ignoreCase = true)
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