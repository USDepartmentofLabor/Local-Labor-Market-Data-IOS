package blsapp.dol.gov.blslocaldata.ui.area.fragments

import android.content.Context
import android.widget.TextView
import blsapp.dol.gov.blslocaldata.R
import com.github.mikephil.charting.components.MarkerView
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.highlight.Highlight

class CustomMarkerView(context: Context, layoutResource: Int): MarkerView(context, layoutResource) {

    private val tvContent: TextView = findViewById<TextView>(R.id.tvContent)

    override fun refreshContent(e: Entry?, highlight: Highlight?) {
        tvContent.text = "3"
        super.refreshContent(e, highlight)
    }

    override fun getX(): Float {
        return (-(width / 2)).toFloat()
    }


    override fun getY(): Float {
        return (-height).toFloat()
    }
}