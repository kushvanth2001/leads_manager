package com.leads.manager

import android.widget.ImageView
import android.widget.EditText
import android.widget.TextView
import android.widget.Button
import android.view.LayoutInflater
import android.view.WindowManager;
import android.app.AlertDialog;
import android.app.Notification
import android.provider.CallLog
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.net.Uri
import android.os.Looper
import org.json.JSONObject
import android.os.Handler
import android.os.IBinder
import android.widget.Toast
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterMain
import android.util.Log 
import android.app.AlarmManager
import io.flutter.plugin.common.MethodChannel 
import io.flutter.plugins.GeneratedPluginRegistrant
class MyForegroundService : Service() {//CallLogCallback
    private val INTERVAL: Long = 20000 // 20 seconds
    private lateinit var handler: Handler
    private lateinit var phoneStateListener: PhoneStateListener
   private lateinit var telephonyManager: TelephonyManager
    private lateinit var flutterEngine: FlutterEngine
 // private lateinit var callLogObserver: CallLogObserver
    override fun onCreate() {
        super.onCreate()
        handler = Handler()

     //Initialize and register the phone state listener
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
     phoneStateListener = object : PhoneStateListener() {
           override fun onCallStateChanged(state: Int, phoneNumber: String?) {
             super.onCallStateChanged(state, phoneNumber)
                if (state == TelephonyManager.CALL_STATE_IDLE) {
                    // Call function when phone call ends
                 //Schedule the function to be called after 2 seconds
                    handler.postDelayed({
                   callDartFunction("backgroundMainMethod")
                        }, 2000) 
                }
         }
     }
    telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
 // callLogObserver = CallLogObserver(handler, this, this)
   //     contentResolver.registerContentObserver(CallLog.Calls.CONTENT_URI, true, callLogObserver)
        // Initialize Flutter engine
        FlutterMain.startInitialization(applicationContext)
        FlutterMain.ensureInitializationComplete(applicationContext, null)
        flutterEngine = FlutterEngine(applicationContext)
        val entrypoint = DartExecutor.DartEntrypoint(
            FlutterMain.findAppBundlePath() ?: "",
            "backgroundMain"
        )
        flutterEngine.dartExecutor.executeDartEntrypoint(entrypoint)


         GeneratedPluginRegistrant.registerWith(flutterEngine)
            // Set up the method channel to listen for messages from Dart
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.foreground_service")
       methodChannel.setMethodCallHandler { call, result ->
    when (call.method) {
        "showOverlayDialog" -> {
            val jsonString = call.argument<String>("jsonString")
            val dataMap = jsonString?.let { jsonToMap(it) }
            if (dataMap != null) {
                displayOverlayDialog(this, dataMap)
                result.success(null)
            } else {
                result.error("INVALID_DATA", "Failed to parse JSON string", null)
            }
        }
        "showNotLeadOverlayDialog" -> {
            val jsonString = call.argument<String>("jsonString")
            val dataMap = jsonString?.let { jsonToMap(it) }
            if (dataMap != null) {
                displayNotLeadOverlayDialog(this, dataMap)
                result.success(null)
            } else {
                result.error("INVALID_DATA", "Failed to parse JSON string", null)
            }
        }
        else -> result.notImplemented()
    }
}

    }
       // override fun onNewCallLogAdded() {
        // Handle the new call log event here
       // Log.d("CallLogService", "New call log added")
       //  handler.postDelayed({
    //callDartFunction("backgroundMainMethod")
//}, 250) 
        
        // Example: FlutterMethodChannel.invokeMethod("newCallLogAdded")
  //  }
   private fun jsonToMap(jsonString: String): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val jsonObject = JSONObject(jsonString)
        jsonObject.keys().forEach { key ->
            map[key] = jsonObject.get(key)
        }
        return map
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()  // Create the notification channel
        startForeground(1, getNotification())  // Start the service with the notification
        return START_STICKY
    }
override fun onTaskRemoved(rootIntent: Intent?) {
    val restartServiceIntent = Intent(applicationContext, MyForegroundService::class.java).also {
        it.setPackage(packageName)
    }
    val restartServicePendingIntent = PendingIntent.getService(
        this, 1, restartServiceIntent, PendingIntent.FLAG_IMMUTABLE
    )
    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
    alarmManager.setExactAndAllowWhileIdle(
        AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + 1000, restartServicePendingIntent
    )
    super.onTaskRemoved(rootIntent)
}
private fun displayOverlayDialog(context: Context, dataMap: Map<String, Any>?) {
    Handler(Looper.getMainLooper()).post {
        val dialogView = LayoutInflater.from(context).inflate(R.layout.custom_dialog, null)
        val builder = AlertDialog.Builder(context)
            .setView(dialogView)
            .setCancelable(false)

        val dialog = builder.create()
        dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
        dialog.window?.setBackgroundDrawableResource(R.drawable.dialog_background)

        // Extract caller name and other details from the map
        
        val noteEditText = dialogView.findViewById<EditText>(R.id.note)
          dialogView.findViewById<TextView>(R.id.name).text = dataMap?.get("nameormobilenumber") as? String ?: ""
  dialogView.findViewById<TextView>(R.id.email).text = dataMap?.get( "timestamp") as? String ?: ""
        dialogView.findViewById<TextView>(R.id.phone).text ="Call lasted for ${dataMap?.get( "duration") as? String ?: ""}"  
 dialogView.findViewById<ImageView>(R.id.close_button).setOnClickListener {
            dialog.dismiss()
        }


        dialogView.findViewById<ImageView>(R.id.whatsapp_icon).setOnClickListener {
       openWhatsAppChat(this,dataMap?.get("mobileNumber") as? String ?: "")

            dialog.dismiss()
        }
  dialogView.findViewById<ImageView>(R.id.telephone_icon).setOnClickListener {
openDialer(this,dataMap?.get("mobileNumber") as? String ?: "")

            dialog.dismiss()
        }
  dialogView.findViewById<Button>(R.id.open_lead_button).setOnClickListener {
     dialog.dismiss()
          launchAppLink(context = this, id = dataMap?.get("leadid") as? String ?: "")
        }

        dialogView.findViewById<Button>(R.id.send_button).setOnClickListener {
           val note = noteEditText.text.toString()
            if (note.isEmpty()||note=="") {
        Toast.makeText(context, "Can't send empty note", Toast.LENGTH_SHORT).show()
    } else {
        val arguments: MutableMap<Any, Any> = mutableMapOf()
        arguments["leadid"] = dataMap?.get("leadid") as? String ?: ""
        arguments["text"] = note

        callDartFunction("sendnote", arguments)
        // Handle send action, e.g., send the note data

        dialog.dismiss()
    }
        }

        dialog.show()
    }
}  private fun openWhatsAppChat(context: Context, phoneNumber: String) {
    try {
        val uri = Uri.parse("whatsapp://send?phone=$phoneNumber")
        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    } catch (e: Exception) {
        println(phoneNumber)
        println(e)
        Toast.makeText(context, "WhatsApp not installed!", Toast.LENGTH_LONG).show()
    }
}


fun openDialer(context: Context, phoneNumber: String) {
    try {
        val uri = Uri.parse("tel:$phoneNumber")
        val intent = Intent(Intent.ACTION_DIAL, uri).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    } catch (e: Exception) {
        println(phoneNumber)
        println(e)
        Toast.makeText(context, "Unable to open dialer.", Toast.LENGTH_LONG).show()
    }
}

private fun displayNotLeadOverlayDialog(context: Context, dataMap: Map<String, Any>?) {
    Handler(Looper.getMainLooper()).post {
        val dialogView = LayoutInflater.from(context).inflate(R.layout.notlead_custom_dialog, null)
        val builder = AlertDialog.Builder(context)
            .setView(dialogView)
            .setCancelable(false)

        val dialog = builder.create()
        dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
                dialog.window?.setBackgroundDrawableResource(R.drawable.dialog_background)

        // Extract caller name and other details from the map
        val noteEditText = dialogView.findViewById<EditText>(R.id.note)
        dialogView.findViewById<TextView>(R.id.desc).text = "${dataMap?.get("mobilenumber")} This number is not in leads. Do you want to add it?"

        dialogView.findViewById<ImageView>(R.id.close_button).setOnClickListener {
            dialog.dismiss()
        }

        dialogView.findViewById<Button>(R.id.save_lead).setOnClickListener {
            dialog.dismiss()
            launchAppLink2(context, dataMap?.get("mobilenumber") as? String ?: "")
        }

        dialogView.findViewById<Button>(R.id.Immediate_save).setOnClickListener {

            val arguments: MutableMap<Any, Any> = mutableMapOf()
            arguments["mobilenumber"] = dataMap?.get("mobilenumber") as? String ?: ""
        

            callDartFunction("Immediate_save", arguments)
            dialog.dismiss()
        }
   dialogView.findViewById<Button>(R.id.ignore_number).setOnClickListener {

            val arguments: MutableMap<Any, Any> = mutableMapOf()
            arguments["mobilenumber"] = dataMap?.get("mobilenumber") as? String ?: ""
        

            callDartFunction("ignore_number", arguments)
            dialog.dismiss()
        }
        dialog.show()
    }
}

private fun launchAppLink(context: Context, id: String) {
    try {
  
  

    val url = "https://go.1m.fyi/app/leaddetails/$id"
    print(url)
    val appLinkIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
    }

    // Create a pending intent
    val pendingIntent = PendingIntent.getActivity(
        context, 0, appLinkIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // Launch the app link
    pendingIntent.send()
      } catch (e: Exception) {

        println(e);
      }
}
private fun launchAppLink2(context: Context, id: String) {
    val url = "https://go.1m.fyi/app/leaddetails/Immediate_save/$id"
    val appLinkIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
    }

    // Create a pending intent
    val pendingIntent = PendingIntent.getActivity(
        context, 0, appLinkIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // Launch the app link
    pendingIntent.send()
}
    override fun onDestroy() {
        super.onDestroy()
     telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE) // Unregister the listener
        // Optionally, cleanup Flutter engine resources if needed
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    // Create notification channel for Android O and above
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "channel_id", // Channel ID
                "Foreground Service Channel", // Channel name
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "This is the notification channel for the foreground service"
            }

            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Create the notification that will be shown for the foreground service
    private fun getNotification(): Notification {
        // Create an Intent to launch the MainActivity when the notification is clicked
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )

        // Build the notification
        return NotificationCompat.Builder(this, "channel_id")
            .setContentTitle("Capturing CallLogs")
            .setContentText("Running in the background")
            .setSmallIcon(R.drawable.logo)  // Ensure this icon exists
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
    }

    // Function to call the Dart function in Flutter from the service
private fun callDartFunction(functionName: String, arguments:  MutableMap<Any, Any>? = null) {
    if (::flutterEngine.isInitialized && flutterEngine.dartExecutor.isExecutingDart) {
        // If the FlutterEngine is already running, call the method channel
        Log.d("FlutterService", "FlutterEngine already running, invoking method channel")
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.leads.manager/service")
        methodChannel.invokeMethod(functionName, arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d("FlutterService", "Dart method call succeeded: $result")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e("FlutterService", "Dart method call error: $errorCode, $errorMessage")
            }

            override fun notImplemented() {
                Log.e("FlutterService", "Method not implemented")
            }
        })
    } else {
        // If the FlutterEngine is not running, initialize it and call Dart entrypoint
        Log.d("FlutterService", "Initializing FlutterEngine and calling Dart entrypoint")
        
        FlutterMain.startInitialization(applicationContext)
        FlutterMain.ensureInitializationComplete(applicationContext, null)
        
        flutterEngine = FlutterEngine(applicationContext).apply {
            val entrypoint = DartExecutor.DartEntrypoint(
                FlutterMain.findAppBundlePath() ?: "",
                "backgroundMain"
            )
            dartExecutor.executeDartEntrypoint(entrypoint)
            
            // Set up the method channel after initialization
            val methodChannel = MethodChannel(dartExecutor.binaryMessenger, "com.leads.manager/service")
            methodChannel.invokeMethod(functionName, arguments, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.d("FlutterService", "Dart method call succeeded: $result")
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e("FlutterService", "Dart method call error: $errorCode, $errorMessage")
                }

                override fun notImplemented() {
                    Log.e("FlutterService", "Method not implemented")
                }
            })
        }
    }
}


}
