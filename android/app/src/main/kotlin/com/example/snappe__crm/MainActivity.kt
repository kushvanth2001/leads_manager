package com.leads.manager




import kotlinx.coroutines.*

import android.provider.Settings



import android.net.Uri;
import android.app.AlarmManager;
import android.util.Log
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.provider.CallLog
import android.app.AlertDialog
import android.content.ServiceConnection
import android.widget.TextView
import android.os.Build
import android.app.NotificationChannel
import android.app.NotificationManager

import java.util.concurrent.TimeUnit

import com.google.gson.reflect.TypeToken
import com.google.gson.Gson
import android.content.SharedPreferences
import info.mqtt.android.service.MqttAndroidClient;
import org.eclipse.paho.client.mqttv3.IMqttActionListener
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken
import org.eclipse.paho.client.mqttv3.IMqttToken
import org.eclipse.paho.client.mqttv3.MqttCallback
import org.eclipse.paho.client.mqttv3.MqttConnectOptions
import org.eclipse.paho.client.mqttv3.MqttException
import org.eclipse.paho.client.mqttv3.MqttMessage
import android.app.Activity
import android.app.Application
import android.os.Handler
import android.os.Looper
import android.content.ComponentName
import android.content.Context
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import com.leads.manager.R
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.appcompat.app.AppCompatActivity
// import com.leads.manager.MqttService
// import com.leads.manager.MqttServiceCallback


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.foreground_service"
    companion object {
        const val TAG = "AndroidMqttClient"
    }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startService") {
                 val myForegroundServiceIntent = Intent(this, MyForegroundService::class.java)
        startForegroundService(myForegroundServiceIntent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

private lateinit var mqttClient: MqttAndroidClient
    private val REQUEST_CODE = 1
    private val LOCATION_PERMISSION_REQUEST_CODE = 2
  
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            
            val binder = service as MqttService.MqttBinder
            val mqttService = binder.getService()

            mqttService.setCallback(this@MainActivity)
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "publishMessage" -> {
                            println("//////publishmessage is called//////")
                            val topic = call.argument<String>("topic") ?: ""
                            val msg = call.argument<String>("message") ?: ""
                            Log.d("Mqtt", "mqtt")
                            mqttService.publish(topic, msg, 0, false)
                            result.success(null)
                        }
                        "connectMqtt" -> {
                            println("connectMqtt is called")
                            val url = call.argument<String>("brokerUrl") ?: ""
                            val id = call.argument<String>("clientId") ?: ""
                            mqttService.connect(this@MainActivity, url, id)
                            result.success(null)
                        }
                        "disconnect" -> {
                            println("//////disconnected is called//////")
                            mqttService.disconnect()
                            result.success(null)
                        }
                        "unsubscribe" -> {
                            println("//////unsubscribe is called is called//////")
                            val topic = call.argument<String>("topic") ?: ""
                            mqttService.unsubscribe(topic)
                            result.success(null)
                        }
                        "subscribeToTopic" -> {
                            println("//////subscribe to a topic is called//////")
                            val topic = call.argument<String>("topic") ?: ""
                            mqttService.subscribe(topic, 1)
                        }
                        else -> result.notImplemented()
                    }
                }
        }
        
         override fun onServiceDisconnected(className: ComponentName) {
        // Handle the service being unexpectedly disconnected
        Log.d("MainActivity", "Service disconnected")
    }
        
        }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
         mqttClient = MqttAndroidClient(this@MainActivity, "wss://mqtt-dev.snap.pe", "11")

        Log.d("MainActivity", "for testing")
        
      

        // Create the notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "newsnappemerchant",
                "myFirebaseChannel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
            Log.d("MainActivity", "Notification channel created")
        }
                val serviceIntent = Intent(this, MqttService::class.java)
        startService(serviceIntent) // Start the service without being foreground
        bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
            
    }


    fun onDataReceivedFromService(data: String?) {
        Log.d("MainActivity", "Received data from service: $data")
        
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
                .invokeMethod("onDataReceived", data ?: "")
        
    }
}



// class MainActivity : FlutterActivity() {
//     private lateinit var mqttClient: MqttAndroidClient

//     companion object {
//         const val TAG = "AndroidMqttClient"
//     }

//     private val REQUEST_CODE = 1
//     private val LOCATION_PERMISSION_REQUEST_CODE = 2
   

//     private val serviceConnection = object : ServiceConnection {
//         override fun onServiceConnected(className: ComponentName, service: IBinder) {
            
//             val binder = service as MqttService.MqttBinder
//             val mqttService = binder.getService()

//             mqttService.setCallback(this@MainActivity)
//             MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
//                 .setMethodCallHandler { call, result ->
//                     when (call.method) {
//                         "publishMessage" -> {
//                             println("//////publishmessage is called//////")
//                             val topic = call.argument<String>("topic") ?: ""
//                             val msg = call.argument<String>("message") ?: ""
//                             Log.d("Mqtt", "mqtt")
//                             mqttService.publish(topic, msg, 0, false)
//                             result.success(null)
//                         }
//                         "connectMqtt" -> {
//                             println("connectMqtt is called")
//                             val url = call.argument<String>("brokerUrl") ?: ""
//                             val id = call.argument<String>("clientId") ?: ""
//                             mqttService.connect(this@MainActivity, url, id)
//                             result.success(null)
//                         }
//                         "disconnect" -> {
//                             println("//////disconnected is called//////")
//                             mqttService.disconnect()
//                             result.success(null)
//                         }
//                         "unsubscribe" -> {
//                             println("//////unsubscribe is called is called//////")
//                             val topic = call.argument<String>("topic") ?: ""
//                             mqttService.unsubscribe(topic)
//                             result.success(null)
//                         }
//                         "subscribeToTopic" -> {
//                             println("//////subscribe to a topic is called//////")
//                             val topic = call.argument<String>("topic") ?: ""
//                             mqttService.subscribe(topic, 1)
//                         }
//                         else -> result.notImplemented()
//                     }
//                 }
//         }

//         override fun onServiceDisconnected(className: ComponentName) {
//             // Handle disconnection
//         }
//     }
 

//     fun onDataReceivedFromService(data: String?) {
//         // Handle received data here
//         Log.d("MainActivity", "Received data from service: $data")
//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
//             .invokeMethod("onDataReceived", data ?: "")
//     }

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)

//         Log.d("MainActivity", "for testing")
//         mqttClient = MqttAndroidClient(this@MainActivity, "wss://mqtt-dev.snap.pe", "11")
        
//         // Create the notification channel
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val channel = NotificationChannel("newsnappemerchant", "myFirebaseChannel", NotificationManager.IMPORTANCE_DEFAULT)
//             val manager = getSystemService(NotificationManager::class.java)
//             manager.createNotificationChannel(channel)
//             Log.d("MainActivity", "Notification channel created")
//         }

//         val serviceIntent = Intent(this, MqttService::class.java)
//         startService(serviceIntent) // Start the service without being foreground
//         bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)

         
//         fun checkCallLogPermission() {
//               if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                
//                 val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager


//                 if (!alarmManager.canScheduleExactAlarms()) {
                      
//                     val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
//                         println("$packageName")
//                         data = Uri.parse("package:$packageName")
//                     }
//                     startActivity(intent)
//    CoroutineScope(Dispatchers.Main).launch {
//             delay(6000)
//             println("waited for 4 sec starting mqtt")
//          //   initializeMqtt()
            
//             // Continue with further actions here if needed
//         }

//                 }else{
//                     println("ini")
//                   //initializeMqtt()
//                     println("The Permissioon is there it can send Alarms ${alarmManager.canScheduleExactAlarms()}")
//                 }
//               }
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) == PackageManager.PERMISSION_GRANTED &&
//                 ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
//                 // Both permissions have been granted
//                 Log.d("MainActivity", "READ_CALL_LOG and READ_PHONE_STATE permissions granted")
//                 initializeFlutterApp()
              
//             } else {
//                 // At least one of the permissions has not been granted, so request them
//                 Log.d("MainActivity", "READ_CALL_LOG or READ_PHONE_STATE permission not granted")
//                 showInAppDisclosure()
//             }
        
//         }
     
//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "audio_recorder").setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "startRecording" -> {
//                     AudioRecorder.startRecording(this@MainActivity)
//                     result.success(null)
//                 }
//                 "stopRecording" -> {
//                     AudioRecorder.stopRecording()
//                     result.success(null)
//                 }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }

//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/locationPermission")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                     "checkLocationPermission" -> {
//                         checkLocationPermission()
//                         result.success(null)
//                     }
//                     else -> result.notImplemented()
//                 }
//             }

//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/error_Log")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                     "geterror" -> {
//                         val error = getErrorFromSharedPreferences(this)
//                         result.success(error)
//                     }
//                 }
//             }

//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/callLog")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                     "setSwitchValue" -> {
//                         val switchValue = call.argument<Boolean>("switchValue")
//                         if (switchValue != null) {
//                             val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                             prefs.edit().putBoolean("switchValue", switchValue).apply()
//                         }
//                         result.success(null)
//                     }
//                     "checkCallLogPermission" -> {
//                         checkCallLogPermission()
//                         result.success(null)
//                     }
//                     "getCallInfo" -> {
//                         val phoneNumber = call.arguments as String
//                         val callInfo = getCallInfo(phoneNumber)
//                         result.success(callInfo)
//                     }
//                     "sendClientGroupName" -> {
//                         val clientGroupName = call.argument<String>("clientGroupName")
//                         val clientPhoneNo = call.argument<String>("clientPhoneNo")
//                         val clientName = call.argument<String>("clientName")
//                         val userId = call.argument<String>("userId")
//                         Log.d("TAG", "clientName: $clientName $userId")
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         prefs.edit().putString("clientGroupName", clientGroupName).apply()
//                         prefs.edit().putString("clientPhoneNo", clientPhoneNo).apply()
//                         prefs.edit().putString("clientName", clientName).apply()
//                         prefs.edit().putString("userId", userId).apply()
//                         result.success(null)
//                     }
//                     "sendToken" -> {
//                         val token = call.argument<String>("token")
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         prefs.edit().putString("token", token).apply()
//                         result.success(null)
//                     }
//                     "getPhoneNumbers" -> {
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         val phoneNumbersJson = prefs.getString("callDataNotLeads", "{}")
//                         result.success(phoneNumbersJson)
//                     }
//                     "clearPhoneNumbers" -> {
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         with(prefs.edit()) {
//                             remove("callDataNotLeads")
//                             apply()
//                         }
//                         result.success(null)
//                     }
//                     "deletePhoneNumber" -> {
//                         val gson = Gson()
//                         val phoneNumberToDelete = call.argument<String>("phoneNumber")
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         val retrievedJsonString = prefs.getString("callDataNotLeads", null)
//                         val retrievedPhoneNumberMap: HashMap<String, ArrayList<HashMap<String, Any?>>> =
//                             if (retrievedJsonString != null) {
//                                 gson.fromJson(retrievedJsonString, object : TypeToken<HashMap<String, ArrayList<HashMap<String, Any?>>>>() {}.type)
//                             } else {
//                                 HashMap()
//                             }
//                         if (retrievedPhoneNumberMap.containsKey("$phoneNumberToDelete")) {
//                             retrievedPhoneNumberMap.remove("$phoneNumberToDelete")
//                         }
//                         with(prefs.edit()) {
//                             putString("callDataNotLeads", Gson().toJson(retrievedPhoneNumberMap))
//                             apply()
//                         }
//                         result.success(null)
//                     }
//                     else -> result.notImplemented()
//                 }
//             }


//     //          val intent = Intent(this, TestService::class.java)
//     //    startService(intent)
//     }

//     private fun startLocationWorker() {
//         // val workRequest = PeriodicWorkRequestBuilder<LocationWorker>(60, TimeUnit.MINUTES).build()
//         // WorkManager.getInstance(this).enqueue(workRequest)
//     }

//     private fun connect(context: Context, serverUri: String, clientId: String) {
//         val sharedPrefs: SharedPreferences = context.getSharedPreferences("chats", Context.MODE_PRIVATE)
//         sharedPrefs.edit().putString("chatSessionId", clientId).apply()
//         mqttClient = MqttAndroidClient(context, serverUri, clientId)
//         mqttClient.setCallback(object : MqttCallback {
//             override fun messageArrived(topic: String?, message: MqttMessage?) {
//                 Log.d("ANDROIDMQTT", "Receive message: ${message.toString()} from topic: $topic")
//                 val receivedMessage = message?.payload?.toString(Charsets.UTF_8)
//                 MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
//                     .invokeMethod("onDataReceived", receivedMessage ?: "")
//             }

//             override fun connectionLost(cause: Throwable?) {
//                 val chatSessionId = getChatSessionId(this@MainActivity)
//                 Log.d("ANDROIDMQTT", "Connection lost: $cause")
//                 if (chatSessionId != null) {
//                     reconnectToMqtt(chatSessionId)
//                 }
//             }

//             override fun deliveryComplete(token: IMqttDeliveryToken?) {
//                 Log.d("ANDROIDMQTT", "Delivery complete")
//             }
//         })
//         val options = MqttConnectOptions().apply {
//             isAutomaticReconnect = true
//             isCleanSession = false
//         }

//         try {
//             mqttClient.connect(options, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "Connected successfully")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Failed to connect: ${exception?.message}")
//                 }
//             })
//         } catch (e: MqttException) {
//             Log.d("ANDROIDMQTT", "Failed to connect: ${e.message}")
//         }
//     }

//     private fun reconnectToMqtt(clientId: String) {
//         val brokerUrl = "wss://mqtt-dev.snap.pe"
//         connect(this, brokerUrl, clientId)
//     }

//     private fun getChatSessionId(context: Context): String? {
//         val sharedPrefs: SharedPreferences = context.getSharedPreferences("chats", Context.MODE_PRIVATE)
//         return sharedPrefs.getString("chatSessionId", null)
//     }

//     private fun getErrorFromSharedPreferences(context: Context): String? {
//         val sharedPrefs: SharedPreferences = context.getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
//         return sharedPrefs.getString("error", null)
//     }

//     private fun checkLocationPermission() {
//         if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
//             // Permission granted
//             Log.d(TAG, "Location permission granted")
//             startLocationWorker()
//         } else {
//             // Request permission
//             ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), LOCATION_PERMISSION_REQUEST_CODE)
//         }
//     }

//     override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//         super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//         if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
//             if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
//                 // Permission granted
//                 Log.d(TAG, "Location permission granted")
//                 startLocationWorker()
//             } else {
//                 // Permission denied
//                 Log.d(TAG, "Location permission denied")
//             }
//         }
//     }

//  fun showTemporaryDialog() {
//         val dialog = AlertDialog.Builder(this)
//             .setTitle("Permission Required")
//             .setMessage("This app requires the SCHEDULE_EXACT_ALARM permission to function properly.")
//             .setCancelable(false)
//             .create()

//         dialog.show()

//         // Dismiss the dialog after 1 second using coroutines
//         CoroutineScope(Dispatchers.Main).launch {
//             delay(1000)
//             dialog.dismiss()
//             // Continue with further actions here if needed
//         }
//     }
//           fun showInAppDisclosure() {
//         val builder = AlertDialog.Builder(this)
//         val view = layoutInflater.inflate(R.layout.custom_dialog, null)
//         val title = view.findViewById<TextView>(R.id.dialog_title)
//         val message = view.findViewById<TextView>(R.id.dialog_message)

//         title.text = "Call Log permission"
//         message.text = """
//             Our app provides Customer Relationship Management (CRM) services to assist businesses in managing their leads. 
//             To provide this service, we require access to the call log data on your device. This allows us to display the call logs 
//             associated with a lead’s phone number to the merchant. A foreground service will run even when the app is closed to 
//             retrieve the call logs.
//         """.trimIndent()

//         builder.setView(view)
//         builder.setPositiveButton("OK") { dialog, _ ->
//             // Request the necessary permissions
//             ActivityCompat.requestPermissions(
//                 this,
//                 arrayOf(
//                     Manifest.permission.READ_CALL_LOG,
//                     Manifest.permission.READ_PHONE_STATE,
//                     Manifest.permission.READ_EXTERNAL_STORAGE,
//                     Manifest.permission.WRITE_EXTERNAL_STORAGE,
//                     Manifest.permission.RECORD_AUDIO,
//                     Manifest.permission.POST_NOTIFICATIONS,
//                     Manifest.permission.SCHEDULE_EXACT_ALARM,
//                     Manifest.permission.READ_MEDIA_IMAGES,
//     Manifest.permission.READ_MEDIA_VIDEO,
//     Manifest.permission.READ_MEDIA_AUDIO
//                 ),
//                 REQUEST_CODE
//             )

//             // Check and request the SCHEDULE_EXACT_ALARM permission if needed
          

//             // Delay initialization of Flutter app
//             val handler = Handler(Looper.getMainLooper())
//             handler.postDelayed({ initializeFlutterApp() }, 16000)

//             dialog.dismiss()
//         }
//         builder.setNegativeButton("Cancel") { dialog, _ ->
//             dialog.dismiss()
//         }
//         builder.show()
//     }
//     private fun initializeFlutterApp() {
//           MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/initializeApp").invokeMethod("initializeApp", null)
//     }
//    private fun initializeMqtt() {
//           MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/initializeApp").invokeMethod("startmqtt", null)
//     }

//     private fun getCallInfo(phoneNumber: String): String {
//         // Your code for getting call info
//         return "Call info for $phoneNumber"
//     }
// }

















// class MainActivity : FlutterActivity() {
//       private lateinit var mqttClient: MqttAndroidClient
      

//     companion object {
//         const val TAG = "AndroidMqttClient"
//     }
//     private val REQUEST_CODE = 1
//      private val LOCATION_PERMISSION_REQUEST_CODE = 2
         
//     private val serviceConnection = object : ServiceConnection {
//         override fun onServiceConnected(className: ComponentName, service: IBinder) {
//             val binder = service as MqttService.MqttBinder
//           var  mqttService = binder.getService()
            

//             // Pass MainActivity instance to the service for callbacks
//             mqttService.setCallback(this@MainActivity)
//               MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                     "publishMessage" -> {
//                         println("//////publishmessage is called//////")
//                         val topic = call.argument<String>("topic") ?: ""
//                         val msg = call.argument<String>("message") ?: ""
//                         Log.d("Mqtt", "mqtt")
//                          mqttService.publish(topic, msg, 0, false)
                        
//                          result.success(null)
//                     }

//                     "connectMqtt" -> {
//                           println("connectMqtt is called");
//                         val url = call.argument<String>("brokerUrl") ?: ""
//                         val id = call.argument<String>("clientId") ?: ""
//                         // Log.d("Mqtt", "mqtt")
//                           mqttService.connect(this@MainActivity, url, id)
//                         // connect(context, url, id)
//                         result.success(null)
//                     }

//                     "disconnect" -> {
//                           println("//////disconnected is called//////")
//                  mqttService.disconnect()
//                         result.success(null)
//                     }

//                     "unsubscribe" -> {
//                           println("//////unsubscribe is called is called//////")
//                         val topic = call.argument<String>("topic") ?: ""
//                         mqttService.unsubscribe(topic)
//                         result.success(null)
//                     }

//                     "subscribeToTopic" -> {
//                           println("//////subscribe to a topic is called//////")

//                      val topic = call.argument<String>("topic") ?: ""
//                           // mqttService.subscribe(topic, 1)
                        
//                         mqttService.subscribe(topic, 1)
                     
//                     }
//                     else -> result.notImplemented()
//                 }
//             }
            
//         }

//         override fun onServiceDisconnected(className: ComponentName) {
//             // Handle disconnection
//         }
//     }
//       fun onDataReceivedFromService(data: String?) {
//         // Handle received data here
//         Log.d("MainActivity", "Received data from service: $data")
//                  MethodChannel(
//                     flutterEngine!!.dartExecutor.binaryMessenger,
//                     "samples.flutter.dev/mqtt"
//                 ).invokeMethod("onDataReceived", data ?: "")
//     }
//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)

//         Log.d("MainActivity", "for testing")
//         mqttClient = MqttAndroidClient(this@MainActivity, "wss://mqtt-dev.snap.pe", "11")
//               // Create the notification channel
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val channel = NotificationChannel("newsnappemerchant", "myFirebaseChannel", NotificationManager.IMPORTANCE_DEFAULT)
//             val manager = getSystemService(NotificationManager::class.java)
//             manager.createNotificationChannel(channel)
//              Log.d("MainActivity", "Notification channel created")

        
//       val serviceIntent = Intent(this, MqttService::class.java)
//         startService(serviceIntent) // Start the service without being foreground
//         bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
//         fun checkCallLogPermission() {
                

// // If the permission is not granted, request it.
// // if (permissionState == PackageManager.PERMISSION_DENIED) {
// //     ActivityCompat.requestPermissions(this, arrayOf("android.permission.POST_NOTIFICATIONS"), 1)
// // }

//                 if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) == PackageManager.PERMISSION_GRANTED &&
//                     ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
//                     // Both permissions have been granted
//                     // You can start the CallListenerService here
//                     Log.d("MainActivity", "READ_CALL_LOG and READ_PHONE_STATE permissions granted")
//                      initializeFlutterApp()
//                     val intent = Intent(this, CallListenerService::class.java)
//                     startService(intent)
//                     Log.d("MainActivity", "CallListenerService started")
//                 } else {
//                     // At least one of the permissions has not been granted, so request them
//                     Log.d("MainActivity", "READ_CALL_LOG or READ_PHONE_STATE permission not granted")
//                    showInAppDisclosure()
//                 }

  
//         }
         
        



        
     
   
//                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "audio_recorder").setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "startRecording" -> {
//                     AudioRecorder.startRecording(this@MainActivity)
//                     result.success(null)
//                 }
//                 "stopRecording" -> {
//                     AudioRecorder.stopRecording()
//                     result.success(null)
//                 }
//                 else -> {
//                     result.notImplemented()
//                 }
//             }
//         }
//                  // Set up a MethodCallHandler for the location
//             MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/locationPermission")
//     .setMethodCallHandler { call, result ->
//         when (call.method) {
//             "checkLocationPermission" -> {
//                 checkLocationPermission()
//                 result.success(null)
//             }
//             else -> result.notImplemented()
//         }
//     }
//   MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/error_Log")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
                   

//                     "geterror" -> {
//                   var k=  getErrorFromSharedPreferences(context)
//                         result.success(k)
//                     }}}

//         // Set up a MethodCallHandler for the MethodChannel
//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/callLog")
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                      "setSwitchValue" -> {
//                         val switchValue = call.argument<Boolean>("switchValue")
//                         if (switchValue != null) {
//                             val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                             prefs.edit().putBoolean("switchValue", switchValue).apply()
//                         }
//                         result.success(null)
//                     }

//                     "checkCallLogPermission" -> {
//                         checkCallLogPermission()
//                         result.success(null)
//                     }
//                     "getCallInfo" -> {
//                         val phoneNumber = call.arguments as String
//                         val callInfo = getCallInfo(phoneNumber)
//                         result.success(callInfo)
//                     }
//                     "sendClientGroupName" -> {
//                         val clientGroupName = call.argument<String>("clientGroupName")
//                         val clientPhoneNo = call.argument<String>("clientPhoneNo")
//                         val clientName = call.argument<String>("clientName")
//                          val userId = call.argument<String>("userId")
//                             Log.d("TAG", "clientName: $clientName $userId \n\n\n\n\\n\n\n\n/n/n/n/n/n\\n\n\n\n\n")
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         prefs.edit().putString("clientGroupName", clientGroupName).apply()
//                         prefs.edit().putString("clientPhoneNo", clientPhoneNo).apply()
//                         prefs.edit().putString("clientName", clientName).apply()
//                         prefs.edit().putString("userId", userId).apply()
//                         result.success(null)
//                     }
//                     "sendToken" -> {
//                         val token = call.argument<String>("token")
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         prefs.edit().putString("token", token).apply()
//                         result.success(null)
//                     }
//                      "getPhoneNumbers" -> {
//                         val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                         val phoneNumbersJson = prefs.getString("callDataNotLeads", "{}")
//                         result.success(phoneNumbersJson)
//                     }
//                      "clearPhoneNumbers" -> {
//                             val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                             with (prefs.edit()) {
//                                 remove("callDataNotLeads")
//                                 apply()
//                             }
//                             result.success(null)
//                         }
//                     "deletePhoneNumber" -> {
//                         val gson = Gson()
//                             val phoneNumberToDelete = call.argument<String>("phoneNumber")
//                             val prefs = getSharedPreferences("prefs", Context.MODE_PRIVATE)
//                               val retrievedJsonString = prefs.getString("callDataNotLeads", null)
//                             val retrievedPhoneNumberMap: HashMap<String, ArrayList<HashMap<String, Any?>>> =
//     if (retrievedJsonString != null) {
//         gson.fromJson(retrievedJsonString, object : TypeToken<HashMap<String, ArrayList<HashMap<String, Any?>>>>() {}.type)
//     } else {
//         HashMap()
//     }
//                         if(retrievedPhoneNumberMap.containsKey("$phoneNumberToDelete")){
//                             retrievedPhoneNumberMap.remove("$phoneNumberToDelete")}
//                             with (prefs.edit()) {
//                                 putString("callDataNotLeads", Gson().toJson(retrievedPhoneNumberMap))
//                                 apply()
//                             }
//                             result.success(null)
//                         }
//                     else -> result.notImplemented()
//                 }
//             }
//     }
//                 fun startLocationWorker() {
//                     // Use the params in your worker
//                     val workRequest = PeriodicWorkRequestBuilder<LocationWorker>(60, TimeUnit.MINUTES).build()
//                     WorkManager.getInstance(this).enqueue(workRequest)
//                 }

//     private fun connect(context: Context, serverUri: String, clientId: String) {
//         val serverURI = serverUri
//           val sharedPrefs: SharedPreferences =
//                 context.getSharedPreferences("chats", Context.MODE_PRIVATE)
//             sharedPrefs.edit().putString("chatSessionId", clientId).apply()
//         val currentTimeMillisString = System.currentTimeMillis().toString()
//         println(currentTimeMillisString)
// println(serverUri)
//         mqttClient = MqttAndroidClient(context, "wss://mqtt-dev.snap.pe", clientId)
//         mqttClient.setCallback(object : MqttCallback {
//             override fun messageArrived(topic: String?, message: MqttMessage?) {
//                 Log.d("ANDROIDMQTT", "Receive message: ${message.toString()} from topic: $topic")
//                 val receivedMessage = message?.payload?.toString(Charsets.UTF_8)

//                 MethodChannel(
//                     flutterEngine!!.dartExecutor.binaryMessenger,
//                     "samples.flutter.dev/mqtt"
//                 ).invokeMethod("onDataReceived", receivedMessage ?: "")
//             }

//             override fun connectionLost(cause: Throwable?) {
//                 val chatSessionId = getChatSessionId(this@MainActivity)
//                 Log.d("ANDROIDMQTT", "Connection lost ${cause.toString()}")

//                 try {
//                     var index = 0
//                     while (true && index < 70) {
//                         if (mqttClient != null && mqttClient.isConnected) {
//                             Log.d("ANDROIDMQTT", "Resubscribing......")
//                             subscribe(chatSessionId + "/#", 1)
//                             break
//                         }
//                         index += 1
//                         Thread.sleep(500L)
//                     }
//                     Log.d("ANDROIDMQTT", "Index at exit $index")
//                 } catch (e: MqttException) {
//                     Log.e("ANDROIDMQTT", "Reconnection failed: ${e.message}")
//                 }
//             }

//             override fun deliveryComplete(token: IMqttDeliveryToken?) {
//                 Log.d("ANDROIDMQTT", "delivery completed")
//             }
//         })
//         val options = MqttConnectOptions()

//         options.keepAliveInterval = 60
//         options.isAutomaticReconnect = true
//         options.keepAliveInterval = 20

//         try {
//             mqttClient.connect(options, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "Connection success")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Connection failure")
//               if (exception != null) {

//     if (exception is MqttException) {
//         val errorMessage = exception.message
//         val reasonCause = exception.cause
//         Log.e("ANDROIDMQTT", "Connection failure: $errorMessage")
//           Log.e("ANDROIDMQTT", "Connection failure: $reasonCause")
//     }

//         val errorMessage = exception.message
        
//         if (errorMessage != null) {
//             Log.e("ANDROIDMQTT", "Connection failure: $errorMessage")
//         } else {
//             Log.e("ANDROIDMQTT", "Connection failure: Unknown error (null message)")
//         }
//     } else {
//         Log.e("ANDROIDMQTT", "Connection failure: Unknown reason (exception is null)")
//     }
//                        try {
//                     var index = 0
//                     while (true && index < 70) {
//                         if ( !mqttClient.isConnected) {
//                             Log.d("ANDROIDMQTT", "Connecting......")
//                 //            mqttClient.connect(options, null, object : IMqttActionListener {
//                 // override fun onSuccess(asyncActionToken: IMqttToken?) {
//                 //     Log.d("ANDROIDMQTT", "Connection success")
//                 // }

//                 // override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                 //     Log.d("ANDROIDMQTT", "Connection failure")}})
//                             break
//                         }
//                         index += 1
//                         Thread.sleep(500L)
//                     }
//                     Log.d("ANDROIDMQTT", "Index at exit $index")
//                 } catch (e: MqttException) {
//                     Log.e("ANDROIDMQTT", "Reconnection failed: ${e.message}")
//                 }
//                 }
//             })
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//     private fun subscribe(topic: String, qos: Int = 0) {
//         try {
//             val parts = topic.split("/")
//             val chatSessionId = parts.firstOrNull()
//             val sharedPrefs: SharedPreferences =
//                 context.getSharedPreferences("chats", Context.MODE_PRIVATE)
//             sharedPrefs.edit().putString("chatSessionId", chatSessionId).apply()

//             mqttClient.subscribe(topic, qos, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "Subscribed to $topic")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Failed to subscribe $topic")
//                 }
//             })
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//     private fun unsubscribe(topic: String) {
//         try {
//             mqttClient.unsubscribe(topic, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "Unsubscribed to $topic")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Failed to unsubscribe $topic")
//                 }
//             })
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//     private fun publish(topic: String, msg: String, qos: Int = 0, retained: Boolean = false) {
//         try {
//             val message = MqttMessage()
//             message.payload = msg.toByteArray()
//             message.qos = qos
//             message.isRetained = retained
//             mqttClient.publish(topic, message, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "$msg published to $topic")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Failed to publish $msg to $topic")
//                 }
//             })
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//     private fun disconnect() {
//        try{
//         println("indisconnect mqtt")
//        if (mqttClient != null && mqttClient.isConnected) {
//             try {
//                 mqttClient.disconnect(null, object : IMqttActionListener {
//                     override fun onSuccess(asyncActionToken: IMqttToken?) {
//                         Log.d("ANDROIDMQTT", "MQTT client disconnected successfully")
//                     }

//                     override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                         Log.e(
//                             "ANDROIDMQTT",
//                             "Failed to disconnect MQTT client: ${exception?.message}"
//                         )
//                     }
//                 })
//             } catch (e: MqttException) {
//                 Log.e("ANDROIDMQTT", "Error disconnecting MQTT client: ${e.message}")
//             }
// }}catch(e: Exception){
//     println(e)
// }
//     }
// private fun getErrorFromSharedPreferences(context: Context): String? {
//     val sharedPreferences: SharedPreferences = context.getSharedPreferences("error_pref", Context.MODE_PRIVATE)
//     return sharedPreferences.getString("error_message", null)
// }
//     private fun getChatSessionId(context: Context): String? {
//         val prefsFileName = "chats" // Replace with the actual name you used
//         val sharedPrefs: SharedPreferences =
//             context.getSharedPreferences(prefsFileName, Context.MODE_PRIVATE)

//         // Retrieve the chatSessionId, defaulting to an empty string if not found
//         return sharedPrefs.getString("chatSessionId", "")
//     }



//     override fun onDestroy() {
//         super.onDestroy()
//         Log.d("MyApplication", "App terminated, disconnecting MQTT client")
        
//          try {
//         unbindService(serviceConnection)
//     } catch (e: Exception) {
//         // Print any exception that occurs while unbinding the service
//         Log.e("MyApplication", "Exception occurred during unbinding service: $e")
//     }

//     }
//        private fun initializeFlutterApp() {
//         // Initialize Flutter app by invoking method channel
//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.myapp/initializeApp").invokeMethod("initializeApp", null)
//     }

//             private fun showInAppDisclosure() {
//             val builder = AlertDialog.Builder(this)
//             val view = layoutInflater.inflate(R.layout.custom_dialog, null)
//             val title = view.findViewById<TextView>(R.id.dialog_title)
//             val message = view.findViewById<TextView>(R.id.dialog_message)
//             title.text = "Call Log permission"
//             message.text = "Our app provides Customer Relationship Management (CRM) services to assist businesses in managing their leads. To provide this service, we require access to the call log data on your device. This allows us to display the call logs associated with a lead’s phone number to the merchant. A foreground service will run even when the app is closed to retrieve the call logs."
//             builder.setView(view)
//             builder.setPositiveButton("OK") { dialog, _ ->
//                 // Request the READ_CALL_LOG permission
//           ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CALL_LOG, Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.RECORD_AUDIO,Manifest.permission.POST_NOTIFICATIONS,Manifest.permission.SCHEDULE_EXACT_ALARM), REQUEST_CODE)
//            val handler = Handler(Looper.getMainLooper())

// handler.postDelayed({
//      initializeFlutterApp()
// }, 16000)
           
          
          
//             dialog.dismiss()
//                  }
//                  builder.setNegativeButton("Cancel") { dialog, _ ->
//                   dialog.dismiss()
//                       }
//                 builder.show()
//                  }
                                
//                 private fun getCallInfo(phoneNumber: String): Map<String, Any> {
//                     val callInfo = mutableMapOf<String, Any>()
//                     val selection = "${CallLog.Calls.NUMBER} = ? AND ${CallLog.Calls.DATE} = (SELECT MAX(${CallLog.Calls.DATE}) FROM calls WHERE ${CallLog.Calls.NUMBER} = ?)"
//                     val selectionArgs = arrayOf(phoneNumber, phoneNumber)
//                     val cursor = contentResolver.query(CallLog.Calls.CONTENT_URI, null, selection, selectionArgs, null)
//                     if (cursor?.moveToFirst() == true) {
//                         // Get the call duration and call time
//                         val callDuration = cursor.getString(cursor.getColumnIndex(CallLog.Calls.DURATION))
//                         val callTime = cursor.getString(cursor.getColumnIndex(CallLog.Calls.DATE))
//                         callInfo["duration"] = callDuration
//                         callInfo["time"] = callTime
//                     }
//                     cursor?.close()
//                     return callInfo
//                 }
//                     override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
//                             when (requestCode) {
//                                 REQUEST_CODE -> {
//                                     if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
//                                         // Call log permission was granted
//                                         val intent = Intent(this, CallListenerService::class.java)
//                                         startService(intent)
//                                     } else {
//                                         // Call log permission denied
//                                         // Disable the functionality that depends on this permission or prompt again.
//                                         Log.d("MainActivity", "READ_CALL_LOG or READ_PHONE_STATE permission not granted by user")
//                                     }
//                                     return
//                                 }
//                                 LOCATION_PERMISSION_REQUEST_CODE -> {
//                                     if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
//                                         // Location permission was granted
//                                         startLocationWorker()
//                                     } else {
//                                         // Location permission denied
//                                         // Disable the functionality that depends on this permission or prompt again.
//                                         Log.d("MainActivity", "LOCAtion permission not granted by user")
//                                     }
//                                     return
//                                 }
//                                 else -> {   
//                                     // Ignore all other requests.
//                                 }
//                             }
//                         }
  

// }
// }