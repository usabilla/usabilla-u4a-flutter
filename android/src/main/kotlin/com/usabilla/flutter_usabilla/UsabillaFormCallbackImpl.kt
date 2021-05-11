package com.usabilla.flutter_usabilla

import androidx.fragment.app.FragmentActivity
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.FRAGMENT_TAG
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.KEY_ERROR_MSG
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.activity
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.ubFormResult
import com.usabilla.sdk.ubform.UsabillaFormCallback
import com.usabilla.sdk.ubform.sdk.form.FormClient

class UsabillaFormCallbackImpl : UsabillaFormCallback {

    override fun formLoadSuccess(form: FormClient) {
        val formFragment = form.fragment
        (activity as FragmentActivity).supportFragmentManager
            .beginTransaction()
            .replace(R.id.content, formFragment, FRAGMENT_TAG)
            .commit()
    }

    override fun mainButtonTextUpdated(text: String) {
        // FIXME Need to fix mainButtonTextUpdated
        // val mainButtonTextArg = "mainButtonText"
        // var result: Map<String, Any> = mapOf<String, Any>(mainButtonTextArg to text)
        // response(context, "MainButtonTextUpdated", result)
    }

    override fun formLoadFail() {
        val res: Map<String, Any> =
            mapOf<String, Any>(KEY_ERROR_MSG to "The form could not be loaded")
        ubFormResult.success(res)
        ubFormResult = null
    }
}
