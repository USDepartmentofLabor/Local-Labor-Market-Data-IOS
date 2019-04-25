package blsapp.dol.gov.blslocaldata.ui

import android.accessibilityservice.AccessibilityServiceInfo
import android.app.Application
import android.content.Context
import android.content.res.Resources
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager
import blsapp.dol.gov.blslocaldata.BLSApplication

/**
 * UIUtil - Utility class for accessibility functions
 */

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

        fun isTalkBackActive(): Boolean {

            val context = BLSApplication.applicationContext()
            val accessibilityManager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager?

            val serviceInfoList = accessibilityManager!!.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_SPOKEN)

            for (serviceInfo in serviceInfoList) {
                //Could get even more specific here if you wanted. IDs have fully qualified package names in them as well.
                if (serviceInfo.id.endsWith("TalkBackService")) {
                    //TalkBack is on do your thing
                    return true
                }
            }

            return false
        }

        fun getString(strId: Int):String {
            return BLSApplication.applicationContext().getString(strId)
        }
    }
}