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
import androidx.lifecycle.liveData
import com.usabilla.sdk.ubform.UbConstants
import com.usabilla.sdk.ubform.UbConstants.INTENT_CLOSE_CAMPAIGN
import com.usabilla.sdk.ubform.UbConstants.INTENT_CLOSE_FORM
import com.usabilla.sdk.ubform.Usabilla
import com.usabilla.sdk.ubform.sdk.entity.FeedbackResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.FlutterView
import io.flutter.view.TextureRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import java.util.ArrayList

class FlutterUsabillaPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {

    companion object {
        var ubFormResult: Result? = null
        const val FRAGMENT_TAG = "passive form"
    }

    private val logTag = "UsabillaFlutterBridge"
    private val methodChannelName = "flutter_usabilla"
    private val eventChannelName = "flutter_usabilla_events"
    private val keyRating = "rating"
    private val keyAbandonedPageIndex = "abandonedPageIndex"
    private val keySent = "sent"

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var registry: TextureRegistry
    private lateinit var activity: Activity

    private var ubCampaignResult: Result? = null
    private var eventSink:EventChannel.EventSink? = null

    private val uiScope = CoroutineScope(Dispatchers.Main)
    
    private fun collectClosingFormSharedFlow() {
        uiScope.launch {
            Usabilla.sharedFlowClosingForm.collectLatest {
                if (it.formType == com.usabilla.sdk.ubform.sdk.form.FormType.PASSIVE_FEEDBACK) {
                    val res: Map<String, Any> = getResult(it.feedbackResult)
                    (activity as? FragmentActivity)?.let {
                        val supportFragmentManager: FragmentManager = it.supportFragmentManager
                        supportFragmentManager.findFragmentByTag(FRAGMENT_TAG)?.let { fragment ->
                            supportFragmentManager.beginTransaction().remove(fragment).commit()
                        }
                        ubFormResult?.success(res)
                        ubFormResult = null
                    }
                } else if (it.formType == com.usabilla.sdk.ubform.sdk.form.FormType.CAMPAIGN) {
                    val res: Map<String, Any> = getResult(it.feedbackResult)
                    if (ubCampaignResult != null) {
                        ubCampaignResult?.success(res)
                        ubCampaignResult = null
                    } else {
                        eventSink?.let { it?.success(res) }
                    }
                }
            }
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        registry = flutterPluginBinding.textureRegistry
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, eventChannelName)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        attachReceivers(activity.applicationContext)
    }

    override fun onDetachedFromActivity() {
        detachReceivers(activity.applicationContext)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        attachReceivers(activity.applicationContext)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachReceivers(activity.applicationContext)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "loadFeedbackForm" -> loadFeedbackForm(call, result)
            "loadFeedbackFormWithCurrentViewScreenshot" -> loadFeedbackFormWithCurrentViewScreenshot(
                call,
                result
            )
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

    private fun attachReceivers(context: Context) {
        collectClosingFormSharedFlow()
    }

    private fun detachReceivers(context: Context) {
        uiScope.coroutineContext.cancelChildren()
    }

    private fun getResult(res: FeedbackResult?): Map<String, Any> {
        return mapOf<String, Any>(
            keyRating to (res?.rating ?: -1),
            keyAbandonedPageIndex to (res?.abandonedPageIndex ?: -1),
            keySent to (res?.isSent ?: false)
        )
    }

    private fun initialize(call: MethodCall, result: Result) {
        val appId = getArgumentFromCall<String?>(call, "appId")
        Usabilla.initialize(activity.baseContext, appId)
        Usabilla.updateFragmentManager((activity as FragmentActivity).supportFragmentManager)
        result.success(true)
    }

    private fun loadFeedbackForm(call: MethodCall, result: Result) {
        val formId = getArgumentFromCall<String?>(call, "formId")
        (activity as? FragmentActivity)?.let {
            val fragmentManager = it.supportFragmentManager
            Usabilla.loadFeedbackForm(
                formId = formId!!,
                callback = UsabillaFormCallbackImpl(fragmentManager)
            )
        }
        ubFormResult = result
    }

    private fun loadFeedbackFormWithCurrentViewScreenshot(call: MethodCall, result: Result) {
        val formId = getArgumentFromCall<String?>(call, "formId")
        (activity as? FragmentActivity)?.let {
            val bitmap: Bitmap? = takeScreenshot(it.window.decorView.rootView)
            val fragmentManager = it.supportFragmentManager
            Usabilla.loadFeedbackForm(
                formId = formId!!,
                screenshot = bitmap,
                callback = UsabillaFormCallbackImpl(fragmentManager)
            )
            ubFormResult = result
            return
        }
        Log.e(logTag, "$formId - Loading form not possible. Android activity is not of type FragmentActivity")
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
        Usabilla.sendEvent(activity.baseContext, event!!)
        ubCampaignResult = result
    }

    private fun resetCampaignData(result: Result) {
        Usabilla.resetCampaignData(activity.baseContext)
        result.success(null)
    }

    private fun dismiss(result: Result) {
        result.success(null)
        Usabilla.dismiss(activity.baseContext)
    }

    private fun setCustomVariables(call: MethodCall, result: Result) {
        val customVariables = getArgumentFromCall<HashMap<String, Any>>(call, "customVariables")
        Usabilla.customVariables = customVariables
        result.success(null)
    }

    private fun getDefaultDataMasks(result: Result) {
        result.success(UbConstants.DEFAULT_DATA_MASKS)
    }

    private fun setDataMasking(call: MethodCall, result: Result) {
        val masks = getArgumentFromCall<ArrayList<String>>(call, "masks")
        val character = getArgumentFromCall<String>(call, "character")
        Usabilla.setDataMasking(masks, character[0])
        result.success(null)
    }

    private fun preloadFeedbackForms(call: MethodCall, result: Result) {
        val formIDs = getArgumentFromCall<ArrayList<String>>(call, "formIDs")
        Usabilla.preloadFeedbackForms(formIDs)
        result.success(true)
    }

    private fun removeCachedForms(result: Result) {
        Usabilla.removeCachedForms()
        result.success(null)
    }

    private fun setDebugEnabled(call: MethodCall, result: Result) {
        val debugEnabled = getArgumentFromCall<Boolean>(call, "debugEnabled")
        Usabilla.debugEnabled = debugEnabled
        result.success(true)
    }

    private inline fun <reified T> getArgumentFromCall(call: MethodCall, key: String): T {
        val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
        return args[key] as T
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
