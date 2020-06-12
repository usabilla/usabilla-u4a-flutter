package com.usabilla.flutter_usabilla

import android.R
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentActivity
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.activity
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.FRAGMENT_TAG
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.KEY_ERROR_MSG
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.ubFormResult
import com.usabilla.sdk.ubform.UsabillaFormCallback
import com.usabilla.sdk.ubform.sdk.form.FormClient

class UsabillaFormCallbackImpl: UsabillaFormCallback {
    private var form: DialogFragment? = null

    override fun formLoadSuccess(formClient: FormClient?) {
        if (formClient != null) {
            form = formClient.fragment
            val supportFragmentManager: androidx.fragment.app.FragmentManager = (activity as FragmentActivity).getSupportFragmentManager()
            supportFragmentManager.beginTransaction().replace(R.id.content, form!!, FRAGMENT_TAG).commit()
            form = null
        }
    }

    override fun mainButtonTextUpdated(s: String?) {
        val mainButtonTextArg: String = "mainButtonText";
        var result: Map<String, Any> = mapOf<String, Any>(mainButtonTextArg to s!!)
        //emitReactEvent(getReactApplicationContext(), "MainButtonTextUpdated", args)
    }

    override fun formLoadFail() {
        var res: Map<String, Any> = mapOf<String, Any>(KEY_ERROR_MSG to "The form could not be loaded")
        val response: List<Map<String, Any>> = listOf(res)
        ubFormResult?.success(response)
    }
}