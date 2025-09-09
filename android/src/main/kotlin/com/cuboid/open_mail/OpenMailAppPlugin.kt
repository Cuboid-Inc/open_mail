package com.cuboid.open_mail

import android.content.Context
import android.content.Intent
import android.content.pm.LabeledIntent
import android.net.Uri
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import org.json.JSONArray
import org.json.JSONObject

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class OpenMailAppPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "open_mail")
        channel.setMethodCallHandler(this)
        init(flutterPluginBinding.applicationContext)
    }

    // The companion object with the static registerWith method has been removed
    // as it was using outdated Flutter plugin APIs and causing compilation errors.
    // Modern Flutter plugins rely on the FlutterPlugin interface implementation.

    fun init(context: Context) {
        applicationContext = context
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "openMailApp") {
            // nativePickerTitle parameter removed; use default system chooser title (or none)
            val opened = emailAppIntent()
            result.success(opened)
        } else if (call.method == "openSpecificMailApp" && call.hasArgument("name")) {
            val opened = specificEmailAppIntent(call.argument("name")!!)
            result.success(opened)
        } else if (call.method == "composeNewEmailInMailApp") {
            val opened = composeNewEmailAppIntent(call.argument("nativePickerTitle") ?: "", call.argument("emailContent") ?: "")
            result.success(opened)
        } else if (call.method == "composeNewEmailInSpecificMailApp") {
            val opened = composeNewEmailInSpecificEmailAppIntent(call.argument("name") ?: "", call.argument("emailContent") ?: "")
            result.success(opened)
        } else if (call.method == "getMainApps") {
            val apps = getInstalledMailApps()
            
            // Create JSON manually rather than using Gson to avoid issues with obfuscation
            val jsonArray = JSONArray()
            for (app in apps) {
                val jsonObj = JSONObject()
                jsonObj.put("name", app.name)
                jsonObj.put("nativeId", app.nativeId)
                jsonArray.put(jsonObj)
            }
            
            result.success(jsonArray.toString())
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun emailAppIntent(): Boolean {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        if (activitiesHandlingEmails.isNotEmpty()) {
            // use the first email package to create the chooserIntent
            val firstEmailPackageName = activitiesHandlingEmails.first().activityInfo.packageName
            val firstEmailInboxIntent = packageManager.getLaunchIntentForPackage(firstEmailPackageName)
            // No explicit title; system will use default
            val emailAppChooserIntent = Intent.createChooser(firstEmailInboxIntent, null)

            // created UI for other email packages and add them to the chooser
            val emailInboxIntents = mutableListOf<LabeledIntent>()
            for (i in 1 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                val packageName = activityHandlingEmail.activityInfo.packageName
                packageManager.getLaunchIntentForPackage(packageName)?.let { intent ->
                    emailInboxIntents.add(
                            LabeledIntent(
                                    intent,
                                    packageName,
                                    activityHandlingEmail.loadLabel(packageManager),
                                    activityHandlingEmail.icon
                            )
                    )
                }
            }
            val extraEmailInboxIntents = emailInboxIntents.toTypedArray()
            val finalIntent = emailAppChooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraEmailInboxIntents)
            finalIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            applicationContext.startActivity(finalIntent)
            return true
        } else {
            return false
        }
    }

    private fun composeNewEmailAppIntent(@NonNull chooserTitle: String, @NonNull contentJson: String): Boolean {
        val packageManager = applicationContext.packageManager
        
        // Parse the JSON manually to avoid GSON issues with release builds
        val jsonObject = try {
            org.json.JSONObject(contentJson)
        } catch (e: Exception) {
            // If parsing fails, return false
            return false
        }
        
        // Extract email content fields directly
        val emailContent = parseEmailContent(jsonObject)
        val emailIntent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:"))

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        if (activitiesHandlingEmails.isNotEmpty()) {
            val emailAppChooserIntent = Intent.createChooser(Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("mailto:")
                type = "text/plain"
                setClassName(activitiesHandlingEmails.first().activityInfo.packageName, activitiesHandlingEmails.first().activityInfo.name)

                putExtra(Intent.EXTRA_EMAIL, emailContent.to?.toTypedArray() ?: emptyArray<String>())
                putExtra(Intent.EXTRA_CC, emailContent.cc?.toTypedArray() ?: emptyArray<String>())
                putExtra(Intent.EXTRA_BCC, emailContent.bcc?.toTypedArray() ?: emptyArray<String>())
                putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
                putExtra(Intent.EXTRA_TEXT, emailContent.body)
            }, chooserTitle)

            val emailComposingIntents = mutableListOf<LabeledIntent>()
            for (i in 1 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                val packageName = activityHandlingEmail.activityInfo.packageName
                    emailComposingIntents.add(
                        LabeledIntent(
                                Intent(Intent.ACTION_SENDTO).apply {
                                    data = Uri.parse("mailto:")
                                    type = "text/plain"
                                    setClassName(activityHandlingEmail.activityInfo.packageName, activityHandlingEmail.activityInfo.name)
                                    putExtra(Intent.EXTRA_EMAIL, emailContent.to?.toTypedArray() ?: emptyArray<String>())
                                    putExtra(Intent.EXTRA_CC, emailContent.cc?.toTypedArray() ?: emptyArray<String>())
                                    putExtra(Intent.EXTRA_BCC, emailContent.bcc?.toTypedArray() ?: emptyArray<String>())
                                    putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
                                    putExtra(Intent.EXTRA_TEXT, emailContent.body)
                                },
                            packageName,
                            activityHandlingEmail.loadLabel(packageManager),
                            activityHandlingEmail.icon
                        )
                    )
            }

            val extraEmailComposingIntents = emailComposingIntents.toTypedArray()
            val finalIntent = emailAppChooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraEmailComposingIntents)
            finalIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            applicationContext.startActivity(finalIntent)
            return true
        } else {
            return false
        }
    }

    private fun specificEmailAppIntent(name: String): Boolean {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        val activityHandlingEmail = activitiesHandlingEmails.firstOrNull {
            it.loadLabel(packageManager) == name
        } ?: return false

        val firstEmailPackageName = activityHandlingEmail.activityInfo.packageName
        val emailInboxIntent = packageManager.getLaunchIntentForPackage(firstEmailPackageName)
                ?: return false

        emailInboxIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        applicationContext.startActivity(emailInboxIntent)
        return true
    }

    private fun composeNewEmailInSpecificEmailAppIntent(@NonNull name: String, @NonNull contentJson: String): Boolean {
        val packageManager = applicationContext.packageManager
        
        // Parse the JSON manually to avoid GSON issues with release builds
        val jsonObject = try {
            org.json.JSONObject(contentJson)
        } catch (e: Exception) {
            // If parsing fails, return false
            return false
        }
        
        // Extract email content fields directly
        val emailContent = parseEmailContent(jsonObject)
        val emailIntent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:"))

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        val specificEmailActivity = activitiesHandlingEmails.firstOrNull {
            it.loadLabel(packageManager) == name
        } ?: return false

        val composeEmailIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:")
            type = "text/plain"
            setClassName(specificEmailActivity.activityInfo.packageName, specificEmailActivity.activityInfo.name)
            putExtra(Intent.EXTRA_EMAIL, emailContent.to?.toTypedArray() ?: emptyArray<String>())
            putExtra(Intent.EXTRA_CC, emailContent.cc?.toTypedArray() ?: emptyArray<String>())
            putExtra(Intent.EXTRA_BCC, emailContent.bcc?.toTypedArray() ?: emptyArray<String>())
            putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
            putExtra(Intent.EXTRA_TEXT, emailContent.body)
        }

        composeEmailIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        applicationContext.startActivity(composeEmailIntent)
        
        return true
    }

    private fun getInstalledMailApps(): List<App> {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager
        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)

        return if (activitiesHandlingEmails.isNotEmpty()) {
            val mailApps = mutableListOf<App>()
            for (i in 0 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                val packageName = activityHandlingEmail.activityInfo.packageName
                val appName = activityHandlingEmail.loadLabel(packageManager).toString()
                mailApps.add(App(name = appName, nativeId = packageName))
            }
            mailApps
        } else {
            emptyList()
        }
    }

    /**
     * Parse email content from JSONObject instead of using GSON
     * This is more reliable in release builds with R8/ProGuard
     */
    private fun parseEmailContent(json: org.json.JSONObject): EmailContent {
        val to = mutableListOf<String>()
        val cc = mutableListOf<String>()
        val bcc = mutableListOf<String>()
        var subject: String? = null
        var body: String? = null

        try {
            if (json.has("to") && !json.isNull("to")) {
                val toArray = json.getJSONArray("to")
                for (i in 0 until toArray.length()) {
                    to.add(toArray.getString(i))
                }
            }
            
            if (json.has("cc") && !json.isNull("cc")) {
                val ccArray = json.getJSONArray("cc")
                for (i in 0 until ccArray.length()) {
                    cc.add(ccArray.getString(i))
                }
            }
            
            if (json.has("bcc") && !json.isNull("bcc")) {
                val bccArray = json.getJSONArray("bcc")
                for (i in 0 until bccArray.length()) {
                    bcc.add(bccArray.getString(i))
                }
            }
            
            if (json.has("subject") && !json.isNull("subject")) {
                subject = json.getString("subject")
            }
            
            if (json.has("body") && !json.isNull("body")) {
                body = json.getString("body")
            }
        } catch (e: Exception) {
            // Ignore parsing errors and use default values
        }

        return EmailContent(to, cc, bcc, subject, body)
    }
}

data class App(
        @SerializedName("name") val name: String,
        @SerializedName("nativeId") val nativeId: String
)

data class EmailContent (
        @SerializedName("to") val to: List<String>? = null,
        @SerializedName("cc") val cc: List<String>? = null,
        @SerializedName("bcc") val bcc: List<String>? = null,
        @SerializedName("subject") val subject: String? = null,
        @SerializedName("body") val body: String? = null
)
