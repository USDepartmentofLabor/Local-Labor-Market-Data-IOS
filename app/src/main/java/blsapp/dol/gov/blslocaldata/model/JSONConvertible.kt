package blsapp.dol.gov.blslocaldata.model

import com.google.gson.Gson

interface JSONConvertable {
    fun toJSON(): String = Gson().toJson(this)
}

inline fun <reified T: JSONConvertable> String.toObject(): T = Gson().fromJson(this, T::class.java)


        /*

        From JSON

val json = "..."
val object = json.toObject<User>()
To JSON

val json = object.toJSON()
         */