package blsapp.dol.gov.blslocaldata.util

import com.github.mikephil.charting.charts.BarLineChartBase
import com.github.mikephil.charting.components.AxisBase
import com.github.mikephil.charting.formatter.IAxisValueFormatter

/**
 * Created by philipp on 02/06/16.
 */
class DayAxisValueFormatter(private val chart: BarLineChartBase<*>) : IAxisValueFormatter {

    override fun getFormattedValue(value: Float, axis: AxisBase?): String {
        return getFormattedValue(value)
    }

    private val mMonths = arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun 2018", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

    fun getFormattedValue(value: Float): String {

        val intValue : Int = value.toInt()
        return mMonths[intValue-1]
    }
}
