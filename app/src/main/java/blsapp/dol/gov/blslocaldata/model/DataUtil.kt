package blsapp.dol.gov.blslocaldata.model

import java.text.DateFormat
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*

class DataUtil {
    companion object {
        fun currencyValue(valueStr: String): String? {

            val currencyFormatter = NumberFormat.getCurrencyInstance()
            val decimalValue = valueStr.toBigDecimalOrNull()
            decimalValue?.let {
                return currencyFormatter.format(decimalValue)
            }
            return null
        }

        fun numberValue(valueStr: String): String? {
            val decimalValue = valueStr.toDoubleOrNull()
            decimalValue?.let { value ->
                return NumberFormat.getNumberInstance().format(value)
            }
            return null
        }

        fun numberValueByThousand(valueStr: String?): String? {
            valueStr?.let {
                val decimalValue = valueStr.toDoubleOrNull()
                decimalValue?.let { value ->
                    return NumberFormat.getNumberInstance().format(value * 1000)
                }
            }
            return null
        }

        fun changeValueByThousand(valueStr: String?): String? {
            valueStr?.let {
                val decimalValue = valueStr.toDoubleOrNull()
                decimalValue?.let { value ->
                    val prefix = if (value > 0) "+" else ""
                    return prefix + NumberFormat.getNumberInstance().format(value * 1000)
                }
            }
            return null
        }


        fun changeValueByPercent(valueStr: String?): String? {
            valueStr?.let {
                val decimalValue = valueStr.toDoubleOrNull()
                decimalValue?.let { value ->
                    val prefix = if (value > 0) "+" else ""
                    return prefix + valueStr + "%"
                }
            }
            return null
        }

        fun changeValueStr(valueStr: String?): String? {
            valueStr?.let {
                val decimalValue = valueStr.toDoubleOrNull()
                decimalValue?.let { value ->
                    val prefix = if (value > 0) "+" else ""
                    return prefix + NumberFormat.getNumberInstance().format(value)
                }
            }
            return null
        }

        // Convert MonthName to Quarter
        // January -> 1
        // June -> 2
        fun quarterNumber(monthNumber: String): Int {
            val month = monthNumber.substring(1,3)
            val quarter = (month.toInt() - 1)/3 + 1
            return quarter
        }
        fun quarterPeriod(monthNumber: String): String {
            val month = monthNumber.substring(1,3)
            val quarter = (month.toInt() - 1)/3 + 1
            return "Q" + quarter.toString().padStart(2, '0')
        }
    }
}