package com.usabilla.flutter_usabilla

import androidx.annotation.NonNull;


import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.util.Log
import android.view.View

import androidx.fragment.app.FragmentActivity
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
public class FlutterUsabillaPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private val usabilla: Usabilla? = Usabilla
  private val usabillaFormCallbackImpl = UsabillaFormCallbackImpl()

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    renderer = flutterPluginBinding.getFlutterEngine().renderer
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), methodChannelName)
    channel.setMethodCallHandler(FlutterUsabillaPlugin());

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
    private var view: FlutterView? = null
    var activity: Activity? = null
    var ubFormResult: Result? = null
    var ubCampaignResult: Result? = null
    const val methodChannelName = "flutter_usabilla"
    const val FRAGMENT_TAG = "passive form"
    private const val LOG_TAG = "Usabilla Flutter Bridge"
    private const val KEY_RATING = "rating"
    private const val KEY_ABANDONED_PAGE_INDEX = "abandonedPageIndex"
    private const val KEY_SENT = "sent"
    const val KEY_ERROR_MSG = "error"
    private const val KEY_SUCCESS_FLAG = "success"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      activity = registrar.activity()
      view =  registrar.view()
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
      if (intent != null) {
        val res: Map<String, Any> = getResult(intent, FeedbackResult.INTENT_FEEDBACK_RESULT)
        val response: List<Map<String, Any>> = listOf(res)
        val activity: Activity? = activity
        if (activity is FragmentActivity) {
          val supportFragmentManager: androidx.fragment.app.FragmentManager = (activity as FragmentActivity).getSupportFragmentManager()
          val fragment = supportFragmentManager.findFragmentByTag(FRAGMENT_TAG)
          if (fragment != null) {
            supportFragmentManager.beginTransaction().remove(fragment).commit()
          }
          if (ubFormResult != null) {
            ubFormResult?.success(response)
          }
          ubFormResult = null
        }
      }
    }
  }

  private val closingCampaignReceiver: BroadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      if (intent != null) {
        val res: Map<String, Any> = getResult(intent, FeedbackResult.INTENT_FEEDBACK_RESULT_CAMPAIGN)
        if (ubCampaignResult != null) {
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
      "sendEvent" -> sendEvent(call,result)
      "resetCampaignData" -> resetCampaignData(result)
      "dismiss" -> dismiss(result)
      "setCustomVariables" -> setCustomVariables(call, result)
      "setDataMasking" -> setDataMasking(call, result)
      "getDefaultDataMasks" -> getDefaultDataMasks(result)
      "getPlatformVersion" -> {
        result.success(android.os.Build.VERSION.RELEASE)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val appId = args["appId"] as? String
    val activity: Activity? = activity
    if (activity != null) {
      usabilla!!.initialize(activity.baseContext, appId)
      usabilla.updateFragmentManager((activity as FragmentActivity).supportFragmentManager)
      result.success(true)
      return
    }
    result.success(null)
    Log.e(LOG_TAG, "${appId} - Initialisation not possible. Android activity is null")
  }

  private fun loadFeedbackForm(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val formId = args["formId"] as? String
    usabilla!!.loadFeedbackForm(formId = formId!!, callback = usabillaFormCallbackImpl)
    ubFormResult = result
  }

  private fun loadFeedbackFormWithCurrentViewScreenshot(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val formId = args["formId"] as? String
    val activity: Activity? = activity
    val view: View? = activity?.window?.decorView?.rootView
    if (activity != null && view != null) {
      //FIXME Need to fix usabilla?.takeScreenshot()
      // - it produces just a black image
      //var bitmap: Bitmap? = usabilla?.takeScreenshot(view)
      var bitmap: Bitmap? = takeScreenshot(view)
      usabilla?.loadFeedbackForm(formId = formId!!, screenshot = bitmap, callback = usabillaFormCallbackImpl)
      ubFormResult = result
    }
    Log.e(LOG_TAG, "${formId} - Loading feedback form not possible. Android activity is null")
  }

  private fun takeScreenshot(view: android.view.View): android.graphics.Bitmap? {
    var bitmap: Bitmap? = null
    view?.isDrawingCacheEnabled = true
    if (renderer?.javaClass == FlutterView::class.java) {
      bitmap = (renderer as FlutterView).bitmap
    } else if (renderer?.javaClass == FlutterRenderer::class.java) {
      bitmap = (renderer as FlutterRenderer).bitmap
    }
    view?.isDrawingCacheEnabled = false
    return bitmap
  }

  private fun sendEvent(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val event = args["event"] as? String
    val activity: Activity? = activity
    if (activity != null) {
      usabilla!!.sendEvent(activity.baseContext, event!!)
      ubCampaignResult = result
      return
    }
    Log.e(LOG_TAG, "${event} -Sending event to Usabilla is not possible. Android activity is null")
  }

  private fun resetCampaignData(result: Result) {
    val activity: Activity? = activity
    if (activity != null) {
      usabilla!!.resetCampaignData(activity.baseContext)
      result.success(null)
      return
    }
    Log.e(LOG_TAG, "Resetting Usabilla campaigns is not possible. Android activity is null")
  }

  private fun dismiss(result: Result) {
    val activity: Activity? = activity
    if (activity != null) {
      result.success(usabilla!!.dismiss(activity.baseContext))
    }
    Log.e(LOG_TAG, "Dismissing the Usabilla form is not possible. Android activity is null")
    result.success(false)
  }

  private fun setCustomVariables(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val customVariables = args["customVariables"] as HashMap<String, Any>
    usabilla!!.customVariables = customVariables
    result.success(null)
  }

  private fun getDefaultDataMasks(result: Result) {
    result.success(UbConstants.DEFAULT_DATA_MASKS)
  }

  private fun setDataMasking(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val masks = args["masks"] as ArrayList<String>
    val character = args["character"] as String
    usabilla!!.setDataMasking(masks, character[0])
    result.success(null)
  }
}
