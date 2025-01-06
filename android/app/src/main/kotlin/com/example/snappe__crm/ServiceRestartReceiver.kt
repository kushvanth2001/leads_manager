package com.leads.manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log

class ServiceRestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                // Start the service when the device boots
                startForegroundService(context)
            }
            Intent.ACTION_SCREEN_ON -> {
                // Handle the screen being turned on
                Log.d("ServiceRestartReceiver", "Screen turned on")
            }
            Intent.ACTION_USER_PRESENT -> {
                // Handle the user unlocking the device
                Log.d("ServiceRestartReceiver", "User is present")
                startForegroundService(context)
            }
                 Intent.ACTION_BATTERY_LOW -> {
                // Handle low battery scenario
                Log.d("ServiceRestartReceiver", "Battery is low")
                startForegroundService(context)
            }
        }
    }

    private fun startForegroundService(context: Context) {
        val myForegroundServiceIntent = Intent(context, MyForegroundService::class.java)
        context.startForegroundService(myForegroundServiceIntent)
    }
}
