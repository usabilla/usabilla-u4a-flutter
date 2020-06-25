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
import io.flutter.view.FlutterView
import io.flutter.view.TextureRegistry
import java.util.ArrayList

class FlutterUsabillaPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var registry: TextureRegistry

    private val usabilla: Usabilla = Usabilla
    private val usabillaFormCallbackImpl = UsabillaFormCallbackImpl()

    private val logTag = "UsabillaFlutterBridge"
    private val keyRating = "rating"
    private val keyAbandonedPageIndex = "abandonedPageIndex"
    private val keySent = "sent"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        registry = flutterPluginBinding.textureRegistry
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
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
        var activity: Activity? = null
        var ubFormResult: Result? = null
        var ubCampaignResult: Result? = null

        const val methodChannelName = "flutter_usabilla"
        const val FRAGMENT_TAG = "passive form"
        const val KEY_ERROR_MSG = "error"
    }

    private fun getResult(intent: Intent, feedbackResultType: String): Map<String, Any> {
        val res: FeedbackResult? = intent.getParcelableExtra(feedbackResultType)
        return mapOf<String, Any>(
            keyRating to (res?.rating ?: -1),
            keyAbandonedPageIndex to (res?.abandonedPageIndex ?: -1),
            keySent to (res?.isSent ?: false)
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
                    ubFormResult?.success(res)
                    ubFormResult = null
                }
            }
        }
    }

    private val closingCampaignReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            intent.let {
                val res: Map<String, Any> = getResult(intent, FeedbackResult.INTENT_FEEDBACK_RESULT_CAMPAIGN)
                ubCampaignResult?.success(res)
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
        val appId = getArgumentFromCall<String?>(call, "appId")
        activity?.let {
            usabilla.initialize(it.baseContext, appId)
            usabilla.updateFragmentManager((it as FragmentActivity).supportFragmentManager)
            result.success(true)
            return
        }
        result.success(null)
        Log.e(logTag, "$appId - Initialisation not possible. Android activity is null")
    }

    private fun loadFeedbackForm(call: MethodCall, result: Result) {
        val formId = getArgumentFromCall<String?>(call, "formId")
        usabilla.loadFeedbackForm(formId = formId!!, callback = usabillaFormCallbackImpl)
        ubFormResult = result
        return
    }

    private fun loadFeedbackFormWithCurrentViewScreenshot(call: MethodCall, result: Result) {
        val formId = getArgumentFromCall<String?>(call, "formId")
        activity?.let {
            //FIXME Need to fix usabilla.takeScreenshot()
            // - it produces just a black image
            //var bitmap: Bitmap? = usabilla.takeScreenshot(view)
            val bitmap: Bitmap? = takeScreenshot(it.window.decorView.rootView)
            usabilla.loadFeedbackForm(formId = formId!!, screenshot = bitmap, callback = usabillaFormCallbackImpl)
            ubFormResult = result
            return
        }
        Log.e(logTag, "$formId - Loading feedback form not possible. Android activity is null")
    }

    private fun takeScreenshot(view: View): Bitmap? {
        var bitmap: Bitmap? = null
        view.isDrawingCacheEnabled = true
        if (registry.javaClass == FlutterView::class.java) {
            bitmap = (registry as FlutterView).bitmap
        } else if (registry.javaClass == FlutterRenderer::class.java) {
            bitmap = (registry as FlutterRenderer).bitmap
        }
        view.isDrawingCacheEnabled = false
        return bitmap
    }

    private fun sendEvent(call: MethodCall, result: Result) {
        val event = getArgumentFromCall<String?>(call, "event")
        activity?.let {
            usabilla.sendEvent(it.baseContext, event!!)
            ubCampaignResult = result
            return
        }
        Log.e(logTag, "$event -Sending event to Usabilla is not possible. Android activity is null")
    }

    private fun resetCampaignData(result: Result) {
        activity?.let {
            usabilla.resetCampaignData(it.baseContext)
            result.success(null)
            return
        }
        Log.e(logTag, "Resetting Usabilla campaigns is not possible. Android activity is null")
    }

    private fun dismiss(result: Result) {
        result.success(null)
        activity?.let {
            usabilla.dismiss(it.baseContext)
            return
        }
        Log.e(logTag, "Dismissing the Usabilla form is not possible. Android activity is null")
    }

    private fun setCustomVariables(call: MethodCall, result: Result) {
        val customVariables = getArgumentFromCall<HashMap<String, Any>>(call, "customVariables")
        usabilla.customVariables = customVariables
        result.success(null)
    }

    private fun getDefaultDataMasks(result: Result) {
        result.success(UbConstants.DEFAULT_DATA_MASKS)
    }

    private fun setDataMasking(call: MethodCall, result: Result) {
        val masks = getArgumentFromCall<ArrayList<String>>(call, "masks")
        val character = getArgumentFromCall<String>(call, "character")
        usabilla.setDataMasking(masks, character[0])
        result.success(null)
    }

    private fun preloadFeedbackForms(call: MethodCall, result: Result) {
        val formIDs = getArgumentFromCall<ArrayList<String>>(call, "formIDs")
        usabilla.preloadFeedbackForms(formIDs)
        result.success(true)
    }

    private fun removeCachedForms(result: Result) {
        usabilla.removeCachedForms()
        result.success(null)
    }

    private fun setDebugEnabled(call: MethodCall, result: Result) {
        val debugEnabled = getArgumentFromCall<Boolean>(call, "debugEnabled")
        usabilla.debugEnabled = debugEnabled
        result.success(true)
    }

    private inline fun <reified T> getArgumentFromCall(call: MethodCall, key: String): T {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        return args[key] as T
    }
}
