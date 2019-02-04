package blsapp.dol.gov.blslocaldata.ui

import android.content.Context
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager

class UIUtil {

    companion object {
         fun accessibilityAnnounce(context: Context, message: String) {
            val manager = context
                    .getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
            if (manager.isEnabled) {
                val e = AccessibilityEvent.obtain()
                e.eventType = AccessibilityEvent.TYPE_ANNOUNCEMENT
                e.className = javaClass.name
                e.packageName = context.getPackageName()
                e.text.add(message)
                manager.sendAccessibilityEvent(e)
            }
        }
    }
}