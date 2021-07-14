package com.usabilla.flutter_usabilla

import androidx.fragment.app.FragmentManager
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.FRAGMENT_TAG
import com.usabilla.flutter_usabilla.FlutterUsabillaPlugin.Companion.ubFormResult
import com.usabilla.sdk.ubform.UsabillaFormCallback
import com.usabilla.sdk.ubform.sdk.form.FormClient

class UsabillaFormCallbackImpl(private val fragmentManager: FragmentManager) :
    UsabillaFormCallback {

    private val keyErrorMessage = "error"

    override fun formLoadSuccess(form: FormClient) {
        val formFragment = form.fragment
        fragmentManager.beginTransaction()
            .replace(android.R.id.content, formFragment, FRAGMENT_TAG)
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
            mapOf<String, Any>(keyErrorMessage to "The form could not be loaded")
        ubFormResult?.success(res)
        ubFormResult = null
    }
}
