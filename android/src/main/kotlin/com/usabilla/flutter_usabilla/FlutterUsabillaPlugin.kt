package com.usabilla.flutter_usabilla

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.util.Log
import android.view.View
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.usabilla.sdk.ubform.UbConstants
import com.usabilla.sdk.ubform.UbConstants.INTENT_CLOSE_CAMPAIGN
import com.usabilla.sdk.ubform.UbConstants.INTENT_CLOSE_FORM
import com.usabilla.sdk.ubform.Usabilla
import com.usabilla.sdk.ubform.sdk.entity.FeedbackResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.view.FlutterView
import java.util.*
import kotlin.collections.HashMap

/** FlutterUsabillaPlugin */
class FlutterUsabillaPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private val usabilla: Usabilla = Usabilla
    private val usabillaFormCallbackImpl = UsabillaFormCallbackImpl()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        renderer = flutterPluginBinding.flutterEngine.renderer
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, methodChannelName)
        channel.setMethodCallHandler(FlutterUsabillaPlugin())

        val closeManager: LocalBroadcastManager = LocalBroadcastManager.getInstance(flutterPluginBinding.applicationContext)
        closeManager.registerReceiver(closingFormReceiver, IntentFilter(INTENT_CLOSE_FORM))
        closeManager.registerReceiver(closingCampaignReceiver, IntentFilter(INTENT_CLOSE_CAMPAIGN))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        val closeManager: LocalBroadcastManager = LocalBroadcastManager.getInstance(binding.applicationContext)
        closeManager.unregisterReceiver(closingFormReceiver)
        closeManager.unregisterReceiver(closingCampaignReceiver)
    }

    companion object {
        var renderer: FlutterRenderer? = null
        var activity: Activity? = null
        var ubFormResult: Result? = null
        var ubCampaignResult: Result? = null
        const val methodChannelName = "flutter_usabilla"
        const val FRAGMENT_TAG = "passive form"
        private const val LOG_TAG = "UsabillaFlutterBridge"
        private const val KEY_RATING = "rating"
        private const val KEY_ABANDONED_PAGE_INDEX = "abandonedPageIndex"
        private const val KEY_SENT = "sent"
        const val KEY_ERROR_MSG = "error"
        private const val KEY_SUCCESS_FLAG = "success"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            activity = registrar.activity()
            val channel = MethodChannel(registrar.messenger(), methodChannelName)
            channel.setMethodCallHandler(FlutterUsabillaPlugin())
        }
    }

    private fun getResult(intent: Intent, feedbackResultType: String): Map<String, Any> {
        val res: FeedbackResult = intent.getParcelableExtra(feedbackResultType)
        return mapOf<String, Any>(
                KEY_RATING to res.rating,
                KEY_ABANDONED_PAGE_INDEX to res.abandonedPageIndex,
                KEY_SENT to res.isSent
        )
    }

    private val closingFormReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            intent.let {
                val res: Map<String, Any> = getResult(intent, FeedbackResult.INTENT_FEEDBACK_RESULT)
                val activity: Activity? = activity
                if (activity is FragmentActivity) {
                    val supportFragmentManager: FragmentManager = activity.supportFragmentManager
                    supportFragmentManager.findFragmentByTag(FRAGMENT_TAG)?.let { fragment ->
                        supportFragmentManager.beginTransaction().remove(fragment).commit()
                    }
                    ubFormResult?.let {
                        ubFormResult?.success(res)
                    }
                    ubFormResult = null
                }
            }
        }
    }

    private val closingCampaignReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            intent.let {
                val res: Map<String, Any> = getResult(intent, FeedbackResult.INTENT_FEEDBACK_RESULT_CAMPAIGN)
                ubCampaignResult?.let {
                    ubCampaignResult?.success(res)
                }
                ubCampaignResult = null
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "loadFeedbackForm" -> loadFeedbackForm(call, result)
            "loadFeedbackFormWithCurrentViewScreenshot" -> loadFeedbackFormWithCurrentViewScreenshot(call, result)
            "sendEvent" -> sendEvent(call, result)
            "resetCampaignData" -> resetCampaignData(result)
            "dismiss" -> dismiss(result)
            "setCustomVariables" -> setCustomVariables(call, result)
            "getDefaultDataMasks" -> getDefaultDataMasks(result)
            "setDataMasking" -> setDataMasking(call, result)
            "preloadFeedbackForms" -> preloadFeedbackForms(call, result)
            "removeCachedForms" -> removeCachedForms(result)
            "setDebugEnabled" -> setDebugEnabled(call, result)
            "getPlatformVersion" -> result.success(android.os.Build.VERSION.RELEASE)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val appId = args["appId"] as? String
        activity?.let {
            usabilla.initialize(activity!!.baseContext, appId)
            usabilla.updateFragmentManager((activity as FragmentActivity).supportFragmentManager)
            result.success(null)
            return
        }
        result.success(null)
        Log.e(LOG_TAG, "${appId} - Initialisation not possible. Android activity is null")
    }

    private fun loadFeedbackForm(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val formId = args["formId"] as? String
        usabilla.loadFeedbackForm(formId = formId!!, callback = usabillaFormCallbackImpl)
        ubFormResult = result
        return
    }

    private fun loadFeedbackFormWithCurrentViewScreenshot(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val formId = args["formId"] as? String
        val view: View? = activity?.window?.decorView?.rootView
        activity?.let {
            view?.let {
                //FIXME Need to fix usabilla.takeScreenshot()
                // - it produces just a black image
                //var bitmap: Bitmap? = usabilla.takeScreenshot(view)
                var bitmap: Bitmap? = takeScreenshot(view)
                usabilla.loadFeedbackForm(formId = formId!!, screenshot = bitmap, callback = usabillaFormCallbackImpl)
                ubFormResult = result
                return
            }
        }
        Log.e(LOG_TAG, "${formId} - Loading feedback form not possible. Android activity is null")
    }

    private fun takeScreenshot(view: android.view.View): android.graphics.Bitmap? {
        var bitmap: Bitmap? = null
        view.isDrawingCacheEnabled = true
        if (renderer?.javaClass == FlutterView::class.java) {
            bitmap = (renderer as FlutterView).bitmap
        } else if (renderer?.javaClass == FlutterRenderer::class.java) {
            bitmap = (renderer as FlutterRenderer).bitmap
        }
        view.isDrawingCacheEnabled = false
        return bitmap
    }

    private fun sendEvent(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val event = args["event"] as? String
        activity?.let {
            usabilla.sendEvent(activity!!.baseContext, event!!)
            ubCampaignResult = result
            return
        }
        Log.e(LOG_TAG, "${event} -Sending event to Usabilla is not possible. Android activity is null")
    }

    private fun resetCampaignData(result: Result) {
        activity?.let {
            usabilla.resetCampaignData(activity!!.baseContext)
            result.success(null)
            return
        }
        Log.e(LOG_TAG, "Resetting Usabilla campaigns is not possible. Android activity is null")
    }

    private fun dismiss(result: Result) {
        result.success(null)
        activity?.let {
            usabilla.dismiss(activity!!.baseContext)
            return
        }
        Log.e(LOG_TAG, "Dismissing the Usabilla form is not possible. Android activity is null")
    }

    private fun setCustomVariables(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val customVariables = args["customVariables"] as HashMap<String, Any>
        usabilla.customVariables = customVariables
        result.success(null)
    }

    private fun getDefaultDataMasks(result: Result) {
        result.success(UbConstants.DEFAULT_DATA_MASKS)
    }

    private fun setDataMasking(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val masks = args["masks"] as ArrayList<String>
        val character = args["character"] as String
        usabilla.setDataMasking(masks, character[0])
        result.success(null)
    }

    private fun preloadFeedbackForms(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val formIDs = args["formIDs"] as ArrayList<String>
        usabilla.preloadFeedbackForms(formIDs)
        result.success(true)
    }

    private fun removeCachedForms(result: Result) {
        Usabilla.removeCachedForms()
        result.success(null)
    }

    private fun setDebugEnabled(call: MethodCall, result: Result) {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        val debugEnabled = args["debugEnabled"] as Boolean
        usabilla.debugEnabled = debugEnabled
        result.success(true)
    }
}
