
package com.leads.manager
import android.os.Looper
import android.database.ContentObserver
import android.os.Handler
import android.provider.CallLog
import android.util.Log
import android.content.Context
import android.database.Cursor
import android.content.SharedPreferences

// Your CallLogObserver class code here
class CallLogObserver(handler: Handler, private val context: Context, private val callback: CallLogCallback) : ContentObserver(handler) {
    private var lastCallLogId: String? = null
    private val sharedPreferences = context.getSharedPreferences("CallLogPrefs", Context.MODE_PRIVATE)

    override fun onChange(selfChange: Boolean) {
        super.onChange(selfChange)
        checkForNewCallLogs()
    }

    private fun checkForNewCallLogs() {
        val cursor = context.contentResolver.query(CallLog.Calls.CONTENT_URI, null, null, null, "${CallLog.Calls.DATE} DESC")
        cursor?.use {
            if (it.moveToFirst()) {
                val id = it.getString(it.getColumnIndex(CallLog.Calls._ID))
                val lastCallTimestamp = sharedPreferences.getLong("lastCallTimestamp", 0L)
                val currentCallTimestamp = it.getLong(it.getColumnIndex(CallLog.Calls.DATE))
        val number = it.getString(it.getColumnIndex(CallLog.Calls.NUMBER))
            val type = it.getInt(it.getColumnIndex(CallLog.Calls.TYPE))
            val duration = it.getLong(it.getColumnIndex(CallLog.Calls.DURATION))
            val name = it.getString(it.getColumnIndex(CallLog.Calls.CACHED_NAME))

          
            println("Phone Number: $number")
            println("Call Type: $type")
            println("Call Duration: $duration seconds")
            println("Contact Name: $name")
                    println("Previous Call Log ID: $lastCallLogId")
                    println("Current Call Log ID: $id")
                    println("Previous Call Timestamp: $lastCallTimestamp")
                    println("Current Call Timestamp: $currentCallTimestamp")
                if (lastCallLogId == null || id != lastCallLogId) {
               

                    lastCallLogId = id
                    sharedPreferences.edit().putLong("lastCallTimestamp", currentCallTimestamp).apply()

                    callback.onNewCallLogAdded()
                }
            }
        }
    }
}