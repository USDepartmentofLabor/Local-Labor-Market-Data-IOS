package blsapp.dol.gov.blslocaldata.model

import java.text.NumberFormat

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

        fun numberValueByThousand(valueStr: String): String? {
            val decimalValue = valueStr.toDoubleOrNull()
            decimalValue?.let { value ->
                return NumberFormat.getNumberInstance().format(value * 1000)
            }
            return null
        }

    }
}