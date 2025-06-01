package com.budgifydev.budgify // !!! YOUR ACTUAL PACKAGE NAME HERE !!!

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        // Channel name for Flutter <-> Native communication
        const val METHOD_CHANNEL_NAME = "com.example.budgify/alarm" // !!! YOUR PACKAGE NAME !!!

        // Keys used by package:alarm (version 4.x) when androidFullScreenIntent is true
        // These are the keys package:alarm puts into the intent extras.
        const val PKG_ALARM_EXTRA_ID = "id"
        const val PKG_ALARM_EXTRA_TITLE = "notificationTitle"
        // const val PKG_ALARM_EXTRA_BODY = "notificationBody" // Also available from package:alarm

        // Action for your custom intents (e.g., if AwesomeNotifications tap launches MainActivity directly)
        // This might be less used if package:alarm's FSI is the primary mechanism.
        const val CUSTOM_ALARM_ACTION_TRIGGER = "com.example.budgify.ALARM_TRIGGER" // !!! YOUR PACKAGE NAME !!!

        // Keys for data sent TO FLUTTER via initialIntentData
        // These should be consistent and what Flutter's `getInitialAlarmNativeData` expects.
        const val FLUTTER_EXPECTED_ALARM_ID_KEY = "alarmId"
        const val FLUTTER_EXPECTED_ALARM_TITLE_KEY = "title"
        const val FLUTTER_EXPECTED_INTENT_TYPE_KEY = "type"
        const val FLUTTER_INTENT_TYPE_ALARM = "alarm"
        const val FLUTTER_INTENT_TYPE_OTHER = "other"

        // Keys used in AwesomeNotifications payload (if AN is still used for displaying notifications)
        const val AWESOME_PAYLOAD_ALARM_ID_KEY = "alarmId" // Example, match your AN payload
        const val AWESOME_PAYLOAD_TITLE_KEY = "title"     // Example, match your AN payload
    }

    private var methodChannel: MethodChannel? = null
    private var initialIntentData: Map<String, Any?>? = null

    private fun applyLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager?)?.requestDismissKeyguard(this, null)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD // Use with caution, test thoroughly
            )
        }
        Log.d("MainActivity", "Lock screen flags applied.")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val currentIntent = intent
        if (isAlarmIntent(currentIntent)) {
            Log.d("MainActivity", "onCreate: Alarm intent detected. Applying lock screen flags.")
            applyLockScreenFlags()
        }
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate complete. Intent Action: ${currentIntent?.action}, Extras: ${bundleToPlainMap(currentIntent?.extras)}")
        handleIntent(currentIntent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "configureFlutterEngine called.")
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialIntent" -> {
                    Log.d("MainActivity", "MethodChannel: getInitialIntent called by Flutter. Sending data: $initialIntentData")
                    result.success(initialIntentData)
                    // initialIntentData = null // Optional: Clear after first read if it's a one-time event
                }
                "stopAlarm" -> {
                    // This is called from AlarmScreen's _stopAlarmActions in Flutter.
                    // The primary sound/alarm stopping is done by `Alarm.stop(id)` in Dart,
                    // which communicates with package:alarm's native service/receiver.
                    // This native call is mostly a confirmation or for any specific native cleanup
                    // you might need, but often not required if package:alarm handles it all.
                    val alarmId = call.argument<Int>("alarmId")
                    Log.d("MainActivity", "MethodChannel: 'stopAlarm' (from Flutter) called for ID $alarmId. Native stop is usually handled by the alarm package itself.")
                    // Example: If you had a native media player tied to this, you'd stop it here.
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        Log.d("MainActivity", "onNewIntent called. New Intent Action: ${intent.action}, Extras: ${bundleToPlainMap(intent.extras)}")
        if (isAlarmIntent(intent)) {
            Log.d("MainActivity", "onNewIntent: Alarm intent detected. Applying lock screen flags.")
            applyLockScreenFlags()
        }
        super.onNewIntent(intent)
        setIntent(intent) // Update the activity's current intent
        handleIntent(intent) // Process the new intent
    }

    private fun isAlarmIntent(intent: Intent?): Boolean {
        if (intent == null) return false
        Log.d("MainActivity", "isAlarmIntent checking: Action=${intent.action}, Extras=${bundleToPlainMap(intent.extras)}")

        // Check 1: Intent from package:alarm's fullScreenIntent (PRIORITY)
        // package:alarm (v4+) adds "id" (int) and "notificationTitle" (string) as extras.
        if (intent.hasExtra(PKG_ALARM_EXTRA_ID)) {
            val alarmId = intent.getIntExtra(PKG_ALARM_EXTRA_ID, -1)
            if (alarmId != -1) {
                Log.d("MainActivity", "isAlarmIntent: TRUE (Detected intent from package:alarm via PKG_ALARM_EXTRA_ID: $alarmId).")
                return true
            }
        }
        
        // Check 2: Your custom action (if MainActivity is launched by something else, e.g., an AwesomeNotification tap)
        if (intent.action == CUSTOM_ALARM_ACTION_TRIGGER) {
             Log.d("MainActivity", "isAlarmIntent: TRUE (Detected intent via CUSTOM_ALARM_ACTION_TRIGGER).")
             return true // Make sure this intent also carries ID and Title if it's an alarm
        }

        // Check 3: AwesomeNotifications FLUTTER_NOTIFICATION_CLICK (if AN body tap launches MainActivity)
        if (intent.action == "FLUTTER_NOTIFICATION_CLICK") {
            val payloadBundle = intent.getBundleExtra("payload") // AwesomeNotifications often puts payload here
            if (payloadBundle != null && payloadBundle.containsKey(AWESOME_PAYLOAD_ALARM_ID_KEY)) {
                 Log.d("MainActivity", "isAlarmIntent: TRUE (Detected intent via FLUTTER_NOTIFICATION_CLICK with alarmId in payload).")
                 return true
            }
            // Fallback: check root extras if AN puts it there directly
            if (intent.hasExtra(AWESOME_PAYLOAD_ALARM_ID_KEY)){
                 Log.d("MainActivity", "isAlarmIntent: TRUE (Detected intent via FLUTTER_NOTIFICATION_CLICK with alarmId in root extras).")
                 return true
            }
        }

        Log.d("MainActivity", "isAlarmIntent: FALSE. Not a clearly identifiable alarm intent.")
        return false
    }

    private fun handleIntent(intent: Intent?) {
        val extrasForLogging = bundleToPlainMap(intent?.extras)
        Log.d("MainActivity", "handleIntent processing. Action: ${intent?.action}, Extras: $extrasForLogging")

        if (intent == null) {
            initialIntentData = null
            Log.d("MainActivity", "handleIntent: Intent is null. initialIntentData set to null.")
            return
        }

        var extractedAlarmId: Int = -1
        var extractedTitle: String? = null
        var source = "unknown"

        // Priority 1: Data from package:alarm's full-screen intent
        // This is expected when `androidFullScreenIntent: true` is used in AlarmSettings.
        if (intent.hasExtra(PKG_ALARM_EXTRA_ID)) {
            extractedAlarmId = intent.getIntExtra(PKG_ALARM_EXTRA_ID, -1)
            extractedTitle = intent.getStringExtra(PKG_ALARM_EXTRA_TITLE)
            if (extractedAlarmId != -1) { // Title can sometimes be null/empty if not set properly
                source = "package:alarm FSI"
                Log.d("MainActivity", "handleIntent: Extracted from package:alarm - ID: $extractedAlarmId, Title: '$extractedTitle'")
            }
        }

        // Priority 2: Data from AwesomeNotifications payload (e.g., if user taps an AN notification body)
        // This is relevant if you still use AwesomeNotifications to *display* the alarm notification.
        if (extractedAlarmId == -1) { // Only if not already found
            val payloadBundle = intent.getBundleExtra("payload") // AwesomeNotifications convention
            if (payloadBundle != null) {
                val idStr = payloadBundle.getString(AWESOME_PAYLOAD_ALARM_ID_KEY)
                if (idStr != null) {
                    extractedAlarmId = idStr.toIntOrNull() ?: -1
                } else {
                    // Try as int if string fails or is not present
                    extractedAlarmId = payloadBundle.getInt(AWESOME_PAYLOAD_ALARM_ID_KEY, -1)
                }
                extractedTitle = payloadBundle.getString(AWESOME_PAYLOAD_TITLE_KEY)
                if (extractedAlarmId != -1) {
                    source = "AwesomeN payload"
                    Log.d("MainActivity", "handleIntent: Extracted from AwesomeN payload - ID: $extractedAlarmId, Title: '$extractedTitle'")
                }
            } else if (intent.action == "FLUTTER_NOTIFICATION_CLICK") { // Check root extras for FLUTTER_NOTIFICATION_CLICK
                val idStr = intent.getStringExtra(AWESOME_PAYLOAD_ALARM_ID_KEY)
                 if (idStr != null) {
                    extractedAlarmId = idStr.toIntOrNull() ?: -1
                } else {
                    extractedAlarmId = intent.getIntExtra(AWESOME_PAYLOAD_ALARM_ID_KEY, -1)
                }
                extractedTitle = intent.getStringExtra(AWESOME_PAYLOAD_TITLE_KEY)
                if (extractedAlarmId != -1) {
                    source = "AwesomeN root extras"
                    Log.d("MainActivity", "handleIntent: Extracted from AwesomeN root extras - ID: $extractedAlarmId, Title: '$extractedTitle'")
                }
            }
        }
        
        // Priority 3: Data from your custom intent action (if used)
        if (extractedAlarmId == -1 && intent.action == CUSTOM_ALARM_ACTION_TRIGGER) {
             val idStr = intent.getStringExtra(AWESOME_PAYLOAD_ALARM_ID_KEY) // Assuming you use these keys
             if (idStr != null) {
                 extractedAlarmId = idStr.toIntOrNull() ?: -1
             } else {
                 extractedAlarmId = intent.getIntExtra(AWESOME_PAYLOAD_ALARM_ID_KEY, -1)
             }
             extractedTitle = intent.getStringExtra(AWESOME_PAYLOAD_TITLE_KEY)
             if (extractedAlarmId != -1) {
                 source = "Custom Action extras"
                 Log.d("MainActivity", "handleIntent: Extracted from Custom Action extras - ID: $extractedAlarmId, Title: '$extractedTitle'")
             }
        }

        // Construct initialIntentData for Flutter
        if (extractedAlarmId != -1 && extractedTitle != null) {
            Log.d("MainActivity", "handleIntent: ALARM data packaged for Flutter. Source: $source. ID: $extractedAlarmId, Title: '$extractedTitle'.")
            initialIntentData = mapOf(
                FLUTTER_EXPECTED_INTENT_TYPE_KEY to FLUTTER_INTENT_TYPE_ALARM,
                FLUTTER_EXPECTED_ALARM_ID_KEY to extractedAlarmId,
                FLUTTER_EXPECTED_ALARM_TITLE_KEY to extractedTitle
            )
        } else {
            Log.d("MainActivity", "handleIntent: Not an alarm intent or missing critical data. Action: ${intent.action}. Fallback initialIntentData.")
            initialIntentData = mapOf(
                FLUTTER_EXPECTED_INTENT_TYPE_KEY to FLUTTER_INTENT_TYPE_OTHER,
                "action" to intent.action, // Original action
                "data" to intent.dataString, // Original data URI
                "extras" to bundleToPlainMap(intent.extras) // All extras for debugging or other types
            )
        }
        Log.d("MainActivity", "handleIntent processed. initialIntentData set to: $initialIntentData")
    }

    private fun bundleToPlainMap(bundle: Bundle?): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        if (bundle == null) return map

        for (key in bundle.keySet()) {
            val value = bundle.get(key)
            when (value) {
                null,
                is Boolean, is Byte, is Char, is Short, is Int, is Long, is Float, is Double, is String,
                is BooleanArray, is ByteArray, is CharArray, is ShortArray, is IntArray, is LongArray,
                is FloatArray, is DoubleArray
                -> map[key] = value
                is Bundle -> map[key] = bundleToPlainMap(value)
                is Array<*> -> {
                    if (value.all { it is String? }) {
                        map[key] = value.map { it as String? }.toTypedArray()
                    } else if (value.all { it is Parcelable? }) {
                        map[key] = value.map { item ->
                            if (item is Bundle) bundleToPlainMap(item) else item?.toString()
                        }.toList()
                         Log.d("MainActivity", "Converted Array of Parcelable for key '$key' to List.")
                    } else {
                        map[key] = value.map { it?.toString() }.toList()
                        Log.w("MainActivity", "Converted generic Array type for key '$key' to List<String?>")
                    }
                }
                is ArrayList<*> -> { 
                    if (value.all { it is String? }) {
                        map[key] = value 
                    } else if (value.all { it is Parcelable? }) {
                        map[key] = value.map { item ->
                            if (item is Bundle) bundleToPlainMap(item) else item?.toString()
                        }.toList()
                        Log.d("MainActivity", "Converted ArrayList of Parcelable for key '$key' to List.")
                    } else {
                        map[key] = value.map { it?.toString() }.toList()
                         Log.w("MainActivity", "Converted generic ArrayList type for key '$key' to List<String?>")
                    }
                }
                else -> {
                    try {
                        map[key] = value.toString()
                        Log.d("MainActivity", "Converted unhandled type for key '$key' (${value?.javaClass?.name}) to String in bundleToPlainMap.")
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Failed to convert value for key '$key' (${value?.javaClass?.name}) to String in bundleToPlainMap. Skipping.", e)
                    }
                }
            }
        }
        return map
    }

    override fun onDestroy() {
        Log.d("MainActivity", "onDestroy called.")
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        super.onDestroy()
    }
}