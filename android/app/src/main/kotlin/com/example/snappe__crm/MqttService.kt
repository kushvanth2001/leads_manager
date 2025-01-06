package com.leads.manager






// import android.content.BroadcastReceiver

import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StringCodec
import android.net.ConnectivityManager
import io.flutter.embedding.engine.dart.DartExecutor

import android.app.Service
import android.net.Network
import android.net.NetworkRequest
import android.net.NetworkCapabilities
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Binder
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import info.mqtt.android.service.MqttAndroidClient;
import androidx.core.content.ContextCompat
import org.eclipse.paho.client.mqttv3.IMqttActionListener
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken
import org.eclipse.paho.client.mqttv3.IMqttToken
import org.eclipse.paho.client.mqttv3.MqttCallback
import org.eclipse.paho.client.mqttv3.MqttConnectOptions
import org.eclipse.paho.client.mqttv3.MqttException
import org.eclipse.paho.client.mqttv3.MqttMessage
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.*

class MqttService : Service() {
    private  var mqttClient: MqttAndroidClient= MqttAndroidClient(this@MqttService, "wss://mqtt-dev.snap.pe", "11")
     private lateinit var flutterEngine: FlutterEngine
    private val binder = MqttBinder()
 private var callback: MainActivity? = null
// val msgChannel = BasicMessageChannel<String>(
//     flutterEngine.dartExecutor.binaryMessenger,
//     "samples.flutter.dev/mqttReciver",
//     StringCodec.INSTANCE
// )
    inner class MqttBinder : Binder() {
        fun getService(): MqttService = this@MqttService
    }

    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }

    override fun onCreate() {
        super.onCreate()
     flutterEngine = FlutterEngine(applicationContext)
println("service is initalized")
    // Start executing Dart code to pre-warm the FlutterEngine
    flutterEngine?.dartExecutor?.executeDartEntrypoint(
        DartExecutor.DartEntrypoint.createDefault()
    )
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "samples.flutter.dev/mqtt")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "publishMessage" -> {
                        val topic = call.argument<String>("topic") ?: ""
                        val msg = call.argument<String>("message") ?: ""
                        Log.d("Mqtt", "mqtt")
                        println("test sucessful")
                        publish(topic, msg, 0, false)
                        
                        result.success(null)
                    }
                        "test" -> {
                        println("////test////")
                        
                        result.success(null)
                    }
                    
                    }}
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Start MQTT operations if needed
        return START_STICKY
    }

    override fun onDestroy() {
        disconnect()
        super.onDestroy()
    }
     fun setCallback(callback: MainActivity) { // Define setCallback method
        this.callback = callback
    }

   fun connect(context: Context, serverUri: String, clientId: String) {
    if (mqttClient != null && mqttClient.isConnected) {
        Log.d("ANDROIDMQTT", "Already Connected no need of another connection......")
        return
    }
        val serverURI = serverUri
          val sharedPrefs: SharedPreferences =
                this.getSharedPreferences("chats", Context.MODE_PRIVATE)
            sharedPrefs.edit().putString("chatSessionId", clientId).apply()
        val currentTimeMillisString = System.currentTimeMillis().toString()
        println(currentTimeMillisString)
println(serverUri)
        mqttClient = MqttAndroidClient(context, "wss://mqtt-dev.snap.pe", clientId)
        mqttClient.setCallback(object : MqttCallback {
            override fun messageArrived(topic: String?, message: MqttMessage?) {
                Log.d("ANDROIDMQTT", "Receive message: ${message.toString()} from topic: $topic")
                val receivedMessage = message?.payload?.toString(Charsets.UTF_8)
// BasicMessageChannel<String>(
//     flutterEngine.dartExecutor.binaryMessenger,
//     "samples.flutter.dev/mqttReciver",
//     StringCodec.INSTANCE
// ).send(receivedMessage ?:"")
                // MethodChannel(
                //     flutterEngine!!.dartExecutor.binaryMessenger,
                //     "samples.flutter.dev/mqtt"
                // ).invokeMethod("onDataReceived", receivedMessage ?: "")
                  callback?.onDataReceivedFromService(receivedMessage)
            }

            override fun connectionLost(cause: Throwable?) {
                 CoroutineScope(Dispatchers.IO).launch {
                    println("intizing reconnecting ...")
                val chatSessionId = getChatSessionId(this@MqttService)
                Log.d("ANDROIDMQTT", "Connection lost ${cause.toString()}")

                try {
                    var index = 0
                    while (true && index < 70) {
                        if (mqttClient != null && mqttClient.isConnected) {
                            Log.d("ANDROIDMQTT", "Resubscribing......")
                            //subscribe(chatSessionId + "/#", 1)
                            subscribe(chatSessionId + "/delivery-event", 1)
                            subscribe(chatSessionId + "/notify-dashboard", 1)
                            subscribe(chatSessionId + "/customer-chat/customer", 1)
                            break
                        }
                        index += 1
                        println("$index")
                        delay(500L)
                    }
                    Log.d("ANDROIDMQTT", "Index at exit $index")
                } catch (e: MqttException) {
                    Log.e("ANDROIDMQTT", "Reconnection failed: ${e.message}")
                }
            }}

            override fun deliveryComplete(token: IMqttDeliveryToken?) {
                Log.d("ANDROIDMQTT", "delivery completed")
            }
        })
        val options = MqttConnectOptions()

        options.keepAliveInterval = 60
        options.isAutomaticReconnect = true
        options.keepAliveInterval = 20

        try {
            mqttClient.connect(options, null, object : IMqttActionListener {
                override fun onSuccess(asyncActionToken: IMqttToken?) {

                      try {                     Log.d("ANDROIDMQTT", "Attempting to subscribe on success...")
                        
                    if (mqttClient.isConnected) {
                             val chatSessionId = getChatSessionId(this@MqttService)
                            if (chatSessionId != null) {
                                        subscribe( "$chatSessionId/delivery-event", 1)
                            subscribe( "$chatSessionId/notify-dashboard", 1)
                            subscribe("$chatSessionId/customer-chat/customer", 1)
                                 //subscribe("$chatSessionId/#", 1)
                            }
                        
                        }
                    } catch (e: MqttException) {
                        Log.e("ANDROIDMQTT", "Reconnection attempt failed: ${e.message}")
                    }
                    Log.d("ANDROIDMQTT", "Connection success")
                }

                override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                    Log.d("ANDROIDMQTT", "Connection failure")
              if (exception != null) {

    if (exception is MqttException) {
        val errorMessage = exception.message
        val reasonCause = exception.cause
        Log.e("ANDROIDMQTT", "Connection failure: $errorMessage")
          Log.e("ANDROIDMQTT", "Connection failure: $reasonCause")
    }

        val errorMessage = exception.message
        
        if (errorMessage != null) {
            Log.e("ANDROIDMQTT", "Connection failure: $errorMessage")
        } else {
            Log.e("ANDROIDMQTT", "Connection failure: Unknown error (null message)")
        }
    } else {
        Log.e("ANDROIDMQTT", "Connection failure: Unknown reason (exception is null)")
    }
       CoroutineScope(Dispatchers.IO).launch {
                    println("intizing reconnecting ...")
                val chatSessionId = getChatSessionId(this@MqttService)
              //  Log.d("ANDROIDMQTT", "Connection lost ${cause.toString()}")

                try {
                    var index = 0
                    while (true && index < 70) {
                        if (mqttClient != null && mqttClient.isConnected) {
                            Log.d("ANDROIDMQTT", "Resubscribing......")
                                   subscribe(chatSessionId + "/delivery-event", 1)
                            subscribe(chatSessionId + "/notify-dashboard", 1)
                            subscribe(chatSessionId + "/customer-chat/customer", 1)
                            
                           // subscribe(chatSessionId + "/#", 1)
                            break
                        }else{
                            Log.d("ANDROIDMQTT", "client connection status ${mqttClient.isConnected}") 
                        }
                        index += 1
                        println("$index")
                        delay(500L)
                    }
                    Log.d("ANDROIDMQTT", "Index at exit $index")
                } catch (e: MqttException) {
                    Log.e("ANDROIDMQTT", "Reconnection failed: ${e.message}")
                }
            }
                       //try {
                //     var index = 0
                //     while (true && index < 70) {
                //         if ( !mqttClient.isConnected) {
                //             Log.d("ANDROIDMQTT", "Connecting......")
                // //            mqttClient.connect(options, null, object : IMqttActionListener {
                // // override fun onSuccess(asyncActionToken: IMqttToken?) {
                // //     Log.d("ANDROIDMQTT", "Connection success")
                // // }

                // // override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                // //     Log.d("ANDROIDMQTT", "Connection failure")}})
                //             break
                //         }
                //         index += 1
                //         Thread.sleep(500L)
                //     }
                //     Log.d("ANDROIDMQTT", "Index at exit $index")
                // } catch (e: MqttException) {
                //     Log.e("ANDROIDMQTT", "Reconnection failed: ${e.message}")
                // }
                }
            })
        } catch (e: MqttException) {
            e.printStackTrace()
        }
    }

     fun subscribe(topic: String, qos: Int = 0) {
        try {
            val parts = topic.split("/")
            val chatSessionId = parts.firstOrNull()
            val sharedPrefs: SharedPreferences =
                this.getSharedPreferences("chats", Context.MODE_PRIVATE)
            sharedPrefs.edit().putString("chatSessionId", chatSessionId).apply()

            mqttClient.subscribe(topic, qos, null, object : IMqttActionListener {
                override fun onSuccess(asyncActionToken: IMqttToken?) {
                    Log.d("ANDROIDMQTT", "Subscribed to $topic")
                }

                override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                    Log.d("ANDROIDMQTT", "Failed to subscribe $topic")
                }
            })
        } catch (e: MqttException) {
            e.printStackTrace()
        }
    }

     fun unsubscribe(topic: String) {
        try {
            mqttClient.unsubscribe(topic, null, object : IMqttActionListener {
                override fun onSuccess(asyncActionToken: IMqttToken?) {
                    Log.d("ANDROIDMQTT", "Unsubscribed to $topic")
                }

                override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                    Log.d("ANDROIDMQTT", "Failed to unsubscribe $topic")
                }
            })
        } catch (e: MqttException) {
            e.printStackTrace()
        }
    }

     fun publish(topic: String, msg: String, qos: Int = 0, retained: Boolean = false) {
        try {
            val message = MqttMessage()
            message.payload = msg.toByteArray()
            message.qos = qos
            message.isRetained = retained
            mqttClient.publish(topic, message, null, object : IMqttActionListener {
                override fun onSuccess(asyncActionToken: IMqttToken?) {
                    Log.d("ANDROIDMQTT", "$msg published to $topic")
                }

                override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                    Log.d("ANDROIDMQTT", "Failed to publish $msg to $topic")
                }
            })
        } catch (e: MqttException) {
            e.printStackTrace()
        }
    }

     fun disconnect() {
       try{
        println("indisconnect mqtt")
       if (mqttClient != null && mqttClient.isConnected) {
            try {
                mqttClient.disconnect(null, object : IMqttActionListener {
                    override fun onSuccess(asyncActionToken: IMqttToken?) {
                        Log.d("ANDROIDMQTT", "MQTT client disconnected successfully")
                    }

                    override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
                        Log.e(
                            "ANDROIDMQTT",
                            "Failed to disconnect MQTT client: ${exception?.message}"
                        )
                    }
                })
            } catch (e: MqttException) {
                Log.e("ANDROIDMQTT", "Error disconnecting MQTT client: ${e.message}")
            }
}}catch(e: Exception){
    println(e)
}
    }
         fun getChatSessionId(context: Context): String? {
        val prefsFileName = "chats" // Replace with the actual name you used
        val sharedPrefs: SharedPreferences =
            this.getSharedPreferences(prefsFileName, Context.MODE_PRIVATE)

        // Retrieve the chatSessionId, defaulting to an empty string if not found
        return sharedPrefs.getString("chatSessionId", "")
    }

}











// import android.app.Service
// import android.net.Network
// import android.net.NetworkRequest
// import android.net.NetworkCapabilities
// import android.content.Context
// import android.content.Intent
// import android.content.SharedPreferences
// import android.os.Binder
// import android.os.IBinder
// import android.util.Log
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import info.mqtt.android.service.MqttAndroidClient;
// import androidx.core.content.ContextCompat
// import org.eclipse.paho.client.mqttv3.IMqttActionListener
// import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken
// import org.eclipse.paho.client.mqttv3.IMqttToken
// import org.eclipse.paho.client.mqttv3.MqttCallback
// import org.eclipse.paho.client.mqttv3.MqttConnectOptions
// import org.eclipse.paho.client.mqttv3.MqttException
// import org.eclipse.paho.client.mqttv3.MqttMessage
// import io.flutter.embedding.android.FlutterActivity
// import java.util.concurrent.Executors

// class MqttService : Service() {
//     private  var mqttClient: MqttAndroidClient= MqttAndroidClient(this@MqttService, "wss://mqtt-dev.snap.pe", "11")
//          private val executorService = Executors.newSingleThreadExecutor()

//     private val binder = MqttBinder()
//  private var callback: MainActivity? = null

//     inner class MqttBinder : Binder() {
//         fun getService(): MqttService = this@MqttService
//     }

//     override fun onBind(intent: Intent?): IBinder? {
//         return binder
//     }
//      fun setCallback(callback: MainActivity) { // Define setCallback method
//         this.callback = callback
//     }

//     override fun onCreate() {
//         super.onCreate()

    
          
//     }

//     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        
//         return START_STICKY
//     }


//     override fun onDestroy() {
//         //disconnect()
//         super.onDestroy()
//     }
//   private fun attemptReconnection() {
//         executorService.execute {
//             var index = 0
//             while (index < 70) {
//                 if (mqttClient != null && !mqttClient.isConnected) {
//                     try {
//                         Log.d("ANDROIDMQTT", "Attempting to reconnect...")
                        
//                         if (mqttClient.isConnected) {
//                             val chatSessionId = getChatSessionId(this@MqttService)
//                             if (chatSessionId != null) {
//                                  subscribe("$chatSessionId/#", 1)
//                             }
//                             break
//                         }
//                     } catch (e: MqttException) {
//                         Log.e("ANDROIDMQTT", "Reconnection attempt failed: ${e.message}")
//                     }
//                 }
//                 else{
//                     println("intilazing reconnecting...")
//                        val chatSessionId = getChatSessionId(this@MqttService)
//                             if (chatSessionId != null) {
//                                  connect(this@MqttService,"wss://mqtt-dev.snap.pe" ,chatSessionId )
//                             }
                    
//                 }
//                 index++
//   println(index)
//                 Thread.sleep(400)
//             }
//             Log.d("ANDROIDMQTT", "Reconnection attempts finished")
          

//         }
//     }
//  fun connect(context: Context, serverUri: String, clientId: String) {
//         val serverURI = serverUri
//           val sharedPrefs: SharedPreferences =
//                 this.getSharedPreferences("chats", Context.MODE_PRIVATE)
//             sharedPrefs.edit().putString("chatSessionId", clientId).apply()
//         val currentTimeMillisString = System.currentTimeMillis().toString()
//         println(currentTimeMillisString)
// println(serverUri)
//         mqttClient = MqttAndroidClient(context, "wss://mqtt-dev.snap.pe", clientId)
//         mqttClient.setCallback(object : MqttCallback {
//             override fun messageArrived(topic: String?, message: MqttMessage?) {
//                 Log.d("ANDROIDMQTT", "Receive message: ${message.toString()} from topic: $topic")
//                 val receivedMessage = message?.payload?.toString(Charsets.UTF_8)
//                  callback?.onDataReceivedFromService(receivedMessage)

//                 // MethodChannel(
//                 //     flutterEngine!!.dartExecutor.binaryMessenger,
//                 //     "samples.flutter.dev/mqtt"
//                 // ).invokeMethod("onDataReceived", receivedMessage ?: "")
//             }

//             override fun connectionLost(cause: Throwable?) {
//                 val chatSessionId = getChatSessionId(this@MqttService)
//                 Log.d("ANDROIDMQTT", "Connection lost ${cause.toString()}")
// attemptReconnection()
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
//                       if (mqttClient.isConnected) {
//                             val chatSessionId = getChatSessionId(this@MqttService)
//                             if (chatSessionId != null) {
//                                 subscribe("$chatSessionId/#", 1)
//                             }
                            
//                         }
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
//                 attemptReconnection()
//                 }
//             })
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//      fun subscribe(topic: String, qos: Int = 0) {
        
//         //                 Log.d("client checker", "Is mqttClient null? ${mqttClient == null}")
//         //                 Log.d("client checker", "Is mqttClient connected? ${mqttClient?.isConnected}")

//         //                
//         //                     subscribe(topic, 1)
//         //                     result.success(null)
//         //                 } else {
//         //                     Log.d("Mqtt", "mqttClient is null or not connected")
//         //                     result.success(null)
//         //                 }
         
//         try {
//             if (mqttClient != null && mqttClient.isConnected) {
//             val parts = topic.split("/")
//             val chatSessionId = parts.firstOrNull()
//             val sharedPrefs: SharedPreferences =
//                 this.getSharedPreferences("chats", Context.MODE_PRIVATE)
//             sharedPrefs.edit().putString("chatSessionId", chatSessionId).apply()

//             mqttClient.subscribe(topic, qos, null, object : IMqttActionListener {
//                 override fun onSuccess(asyncActionToken: IMqttToken?) {
//                     Log.d("ANDROIDMQTT", "Subscribed to $topic")
//                 }

//                 override fun onFailure(asyncActionToken: IMqttToken?, exception: Throwable?) {
//                     Log.d("ANDROIDMQTT", "Failed to subscribe $topic")
//                 }
//             })} else {
//                             Log.d("Mqtt", "mqttClient is null or not connected")
                        
//                         }
//         } catch (e: MqttException) {
//             e.printStackTrace()
//         }
//     }

//      fun unsubscribe(topic: String) {
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

//      fun publish(topic: String, msg: String, qos: Int = 0, retained: Boolean = false) {
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

//      fun disconnect() {
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
//         private fun getChatSessionId(context: Context): String? {
//         val prefsFileName = "chats" // Replace with the actual name you used
//         val sharedPrefs: SharedPreferences =
//             this.getSharedPreferences(prefsFileName, Context.MODE_PRIVATE)

//         // Retrieve the chatSessionId, defaulting to an empty string if not found
//         return sharedPrefs.getString("chatSessionId", "")
//     }

// }




// package com.leads.manager
