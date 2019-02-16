package blsapp.dol.gov.blslocaldata.ui.area

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.support.v7.widget.RecyclerView
import android.view.View
import blsapp.dol.gov.blslocaldata.ui.viewmodel.ReportRowType

/**
 * ReportHeaderItemDecoration - Decoration for Report Header
 */
class ReportHeaderItemDecoration constructor(val mDivider: Drawable): RecyclerView.ItemDecoration() {

    override fun onDraw(c: Canvas, parent: RecyclerView, state: RecyclerView.State) {
        super.onDraw(c, parent, state)
        val dividerLeft = parent.paddingLeft
        val dividerRight = parent.width - parent.paddingRight

        val childCount = parent.childCount
        for (i in 0 until childCount) {
            val child = parent.getChildAt(i)

            val reportListAdapter = parent.adapter as ReportListAdapter
            val reportRow = reportListAdapter.reportRows()[i]
            when (reportRow.type) {
                ReportRowType.HEADER -> { decorateHeader(c, parent, child)}
                else -> {decorateItem(c, parent, child)}
            }
//            val params = child.layoutParams as RecyclerView.LayoutParams
//
//            val dividerTop = child.bottom + params.bottomMargin
//            val dividerBottom = dividerTop + mDivider.getIntrinsicHeight()
//
//            mDivider.setBounds(dividerLeft, dividerTop, dividerRight, dividerBottom)
//            mDivider.draw(canvas)
        }

    }

    fun decorateHeader(c: Canvas, parent: RecyclerView, view: View) {
        val top: Float = view.top.toFloat()
        val bottom = view.bottom.toFloat()
        val left = view.left.toFloat()
        val right = view.right.toFloat()

        val params = view.layoutParams as RecyclerView.LayoutParams
        val dividerTop = view.bottom + params.bottomMargin
        val dividerBottom = dividerTop + mDivider.getIntrinsicHeight()


        val paint = Paint()
        paint.color = Color.BLACK
        val borderSize = 1
        c.drawRect(left-borderSize, top-borderSize, right + borderSize, bottom + borderSize, paint)
    }

    fun decorateItem(c: Canvas, parent: RecyclerView, view: View) {
        val top: Float = view.top.toFloat()
        val bottom = view.bottom.toFloat()
        val left = view.left.toFloat()
        val right = view.right.toFloat()

        val paint = Paint()
        paint.color = Color.BLACK
        val borderSize = 20
        c.drawRect(left-borderSize, top-borderSize, right + borderSize, bottom + borderSize, paint)

        paint.color = Color.LTGRAY
        c.drawRect(left-borderSize+2, top-borderSize+2, right + borderSize-2, bottom + borderSize-2, paint)

    }
        fun drawVertical(c: Canvas, parent: RecyclerView) {
        if (parent.childCount == 0) return

        val left = parent.paddingLeft
        val right = parent.width - parent.paddingRight

        val child = parent.getChildAt(0)
        if (child.height == 0) return

        val params = child.layoutParams as RecyclerView.LayoutParams
        var top = child.bottom + params.bottomMargin + mDivider.intrinsicHeight
        var bottom = top + mDivider.intrinsicHeight

        val parentBottom = parent.height - parent.paddingBottom
        while (bottom < parentBottom) {
            mDivider.setBounds(left, top, right, bottom)
            mDivider.draw(c)

            top += mDivider.intrinsicHeight + params.topMargin + child.height + params.bottomMargin + mDivider.intrinsicHeight
            bottom = top + mDivider.intrinsicHeight
        }
    }

    fun drawHorizontal(c: Canvas, parent: RecyclerView) {
        val top = parent.paddingTop
        val bottom = parent.height - parent.paddingBottom

        val childCount = parent.childCount
        for (i in 0 until childCount) {
            val child = parent.getChildAt(i)
            val params = child.layoutParams as RecyclerView.LayoutParams
            val left = child.right + params.rightMargin + mDivider.intrinsicHeight
            val right = left + mDivider.intrinsicWidth
            mDivider.setBounds(left, top, right, bottom)
            mDivider.draw(c)
        }
    }
    override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
        super.getItemOffsets(outRect, view, parent, state)

        var spaceHeight = 10

        val row = parent.getChildAdapterPosition(view)
        val reportListAdapter = parent.adapter as ReportListAdapter
        val reportRow = reportListAdapter.reportRows()[row]
        if (reportRow.type != ReportRowType.HEADER) {
            spaceHeight = 20
        }

        with(outRect) {
            if (parent.getChildAdapterPosition(view) == 0) {
                top = spaceHeight
            }
            if (reportRow.type != ReportRowType.HEADER) {
                top = spaceHeight
            }
            left =  spaceHeight
            right = spaceHeight
            bottom = spaceHeight + 10
        }
    }
}