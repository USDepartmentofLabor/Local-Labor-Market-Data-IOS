package blsapp.dol.gov.blslocaldata.model

import com.google.gson.annotations.SerializedName

data class SeriesData(
        val year: String,
        val period: String,
        val periodName: String,
        val value: String,
        val latest: Boolean,
        val footnotes: List<Footnote>?,
        val calculations: Calculations?
        ): JSONConvertable {
}


data class Footnote(
        val code: String?,
        val text: String?) {
}

data class Calculations(
        @SerializedName("net_changes") val netChanges: NetChanges?,
        @SerializedName("pct_changes") val percentChanges: PercentChanges?) {
}

data class NetChanges(
        @SerializedName("1") val oneMonth: String?,
        @SerializedName("3") val threeMonth: String?,
        @SerializedName("6") val sixMonth: String?,
        @SerializedName("12") val twelveMonth: String?) {
}

data class PercentChanges(
        @SerializedName("1") val oneMonth: String?,
        @SerializedName("3") val threeMonth: String?,
        @SerializedName("6") val sixMonth: String?,
        @SerializedName("12") val twelveMonth: String?) {
}