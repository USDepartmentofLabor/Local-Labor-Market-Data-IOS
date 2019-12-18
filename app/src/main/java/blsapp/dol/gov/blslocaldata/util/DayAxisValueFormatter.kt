package blsapp.dol.gov.blslocaldata.util

import com.github.mikephil.charting.charts.BarLineChartBase
import com.github.mikephil.charting.components.AxisBase
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.formatter.ValueFormatter

/**
 * Created by philipp on 02/06/16.
 */
class DayAxisValueFormatter(private val chart: BarLineChartBase<*>, private val mMonths: Array<String>) : ValueFormatter() {

    override fun getFormattedValue(value: Float, axis: AxisBase?): String {
        return getFormattedValue(value)
    }

  //  private val mMonths = arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

    override fun getFormattedValue(value: Float): String {

        val intValue : Int = value.toInt()
        if  (intValue >= mMonths.count() || intValue < 0)
            return " "
        else
            return mMonths[intValue]
    }
}
