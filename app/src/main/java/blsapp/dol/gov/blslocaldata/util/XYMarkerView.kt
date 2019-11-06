package blsapp.dol.gov.blslocaldata.util

import android.annotation.SuppressLint
import android.content.Context
import android.support.v4.content.ContextCompat
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import com.github.mikephil.charting.components.MarkerView
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.formatter.IAxisValueFormatter
import com.github.mikephil.charting.formatter.IValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.utils.MPPointF
import java.text.DecimalFormat


/**
 * Custom implementation of the MarkerView.
 *
 * @author Philipp Jahoda
 */
@SuppressLint("ViewConstructor")
class XYMarkerView(context: Context, private val xAxisValueFormatter: IAxisValueFormatter) : MarkerView(context, R.layout.custom_marker_view) {

    private val tvContent: TextView= findViewById(R.id.tvTextValue)
    private val tvBackground: ImageView= findViewById(R.id.tvBackground)
    private val format: DecimalFormat= DecimalFormat("###.0")

    // runs every time the MarkerView is redrawn, can be used to update the
    // content (user-interface)
    override fun refreshContent(e: Entry?, highlight: Highlight?) {

        e?.let {
            if (highlight?.dataSetIndex == 0) {
                tvBackground.background = ContextCompat.getDrawable(context,R.drawable.red_marker)
            } else {
                tvBackground.background = ContextCompat.getDrawable(context,R.drawable.blue_marker)
            }
            tvContent.text = String.format("%s%%", format.format(it.y.toDouble()))
        }

        super.refreshContent(e, highlight)
    }

    override fun getOffset(): MPPointF {
        return MPPointF((-(width / 2)).toFloat(), (-height).toFloat())
    }
}
