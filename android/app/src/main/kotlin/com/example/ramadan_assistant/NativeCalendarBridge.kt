package com.example.ramadan_assistant

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone
import java.util.concurrent.Executors

/** Android Calendar Provider adapter. Permission prompts are exclusive to Connect. */
class NativeCalendarBridge(private val activity: Activity) {
    companion object { const val REQUEST_CODE = 31041 }
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingConnect: MethodChannel.Result? = null
    private val permissions = arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR)

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        if (!call.method.startsWith("calendar.")) return false
        if (call.method == "calendar.list") {
            if (hasPermission()) {
                run(result) { listCalendars() }
            } else if (pendingConnect != null) {
                result.error("calendar_busy", "Calendar permission request is already open", null)
            } else {
                pendingConnect = result
                ActivityCompat.requestPermissions(activity, permissions, REQUEST_CODE)
            }
            return true
        }
        if (!hasPermission()) {
            result.error("calendar_permission_denied", "Connect to calendars to grant permission", null)
            return true
        }
        when (call.method) {
            "calendar.events" -> run(result) { listEvents(call) }
            "calendar.create" -> run(result) { createEvent(call) }
            "calendar.update" -> run(result) { updateEvent(call); null }
            "calendar.delete" -> run(result) { deleteEvent(call); null }
            else -> result.notImplemented()
        }
        return true
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingConnect
        pendingConnect = null
        if (result != null) {
            if (grantResults.size == permissions.size && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                run(result) { listCalendars() }
            } else {
                result.error("calendar_permission_denied", "Calendar permission was denied", null)
            }
        }
        return true
    }

    fun dispose() {
        pendingConnect?.error("calendar_unavailable", "Calendar screen closed", null)
        pendingConnect = null
        executor.shutdown()
    }

    private fun hasPermission() = permissions.all {
        ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun run(result: MethodChannel.Result, action: () -> Any?) {
        executor.execute {
            try {
                val value = action()
                main.post { result.success(value) }
            } catch (error: SecurityException) {
                main.post { result.error("calendar_permission_denied", "Calendar permission is unavailable", null) }
            } catch (error: ReadOnlyCalendar) {
                main.post { result.error("calendar_read_only", "This calendar is read-only", null) }
            } catch (error: Exception) {
                main.post { result.error("calendar_operation_failed", error.message ?: "Calendar operation failed", null) }
            }
        }
    }

    private fun listCalendars(): List<Map<String, Any>> {
        val rows = mutableListOf<Map<String, Any>>()
        val projection = arrayOf(CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)
        activity.contentResolver.query(CalendarContract.Calendars.CONTENT_URI,
            projection, null, null, CalendarContract.Calendars.CALENDAR_DISPLAY_NAME + " ASC")?.use { cursor ->
            while (cursor.moveToNext()) {
                rows.add(mapOf("id" to cursor.getLong(0),
                    "name" to (cursor.getString(1) ?: ""),
                    "account" to (cursor.getString(2) ?: ""),
                    "writable" to (cursor.getInt(3) >= CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR)))
            }
        }
        return rows
    }

    private fun listEvents(call: MethodCall): List<Map<String, Any?>> {
        val calendarId = long(call, "calendarId")
        val from = long(call, "from")
        val to = long(call, "to")
        require(to > from && to - from <= 366L * 24 * 60 * 60 * 1000) { "Invalid calendar date range" }
        val builder = CalendarContract.Instances.CONTENT_URI.buildUpon()
        ContentUris.appendId(builder, from)
        ContentUris.appendId(builder, to)
        val rows = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(CalendarContract.Instances.EVENT_ID,
            CalendarContract.Instances.TITLE, CalendarContract.Instances.BEGIN,
            CalendarContract.Instances.END, CalendarContract.Instances.DESCRIPTION,
            CalendarContract.Instances.EVENT_LOCATION)
        activity.contentResolver.query(builder.build(), projection,
            CalendarContract.Instances.CALENDAR_ID + "=?", arrayOf(calendarId.toString()),
            CalendarContract.Instances.BEGIN + " ASC")?.use { cursor ->
            // Bound provider reads; the Flutter view queries one month at a time.
            while (cursor.moveToNext() && rows.size < 500) {
                val location = cursor.getString(5)
                rows.add(mapOf("id" to cursor.getLong(0), "title" to (cursor.getString(1) ?: ""),
                    "start" to cursor.getLong(2), "end" to cursor.getLong(3),
                    "notes" to (cursor.getString(4) ?: ""),
                    "meetUrl" to if (validMeet(location)) location else null))
            }
        }
        return rows
    }

    private class ReadOnlyCalendar : Exception()
    private fun requireWritable(calendarId: Long) {
        val uri = ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, calendarId)
        activity.contentResolver.query(uri, arrayOf(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL),
            null, null, null)?.use {
            if (!it.moveToFirst() || it.getInt(0) < CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR) {
                throw ReadOnlyCalendar()
            }
        } ?: throw ReadOnlyCalendar()
    }

    private fun values(call: MethodCall): ContentValues {
        val title = call.argument<String>("title")?.trim() ?: ""
        val start = long(call, "start")
        val end = long(call, "end")
        val calendarId = long(call, "calendarId")
        val localId = call.argument<String>("localId") ?: ""
        require(localId.isNotEmpty() && localId.length <= 200) { "Missing local event identity" }
        require(title.isNotEmpty() && title.length <= 160 && end > start) { "Invalid event details" }
        requireWritable(calendarId)
        val meet = call.argument<String>("meetUrl")
        require(meet.isNullOrEmpty() || validMeet(meet)) { "Invalid Google Meet link" }
        return ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, calendarId)
            put(CalendarContract.Events.TITLE, title)
            put(CalendarContract.Events.DESCRIPTION, call.argument<String>("notes") ?: "")
            put(CalendarContract.Events.DTSTART, start)
            put(CalendarContract.Events.DTEND, end)
            // UTC instants are passed from Dart; provider timezone uses an IANA
            // Android ID, never the ambiguous abbreviation supplied by a locale.
            put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
            put(CalendarContract.Events.EVENT_LOCATION, meet ?: "")
            put(CalendarContract.Events.ALL_DAY, 0)
            put(CalendarContract.Events.CUSTOM_APP_PACKAGE, activity.packageName)
            put(CalendarContract.Events.CUSTOM_APP_URI, localEventUri(localId))
            put(CalendarContract.Events.HAS_ALARM, if (call.argument<Number>("reminderMinutes") == null) 0 else 1)
        }
    }

    private fun createEvent(call: MethodCall): Long {
        val eventValues = values(call)
        // The provider marker makes create idempotent even if Android saved
        // the event and the app died before persisting the returned native ID.
        val existing = findLocalEvent(long(call, "calendarId"), call.argument<String>("localId")!!)
        if (existing != null) {
            activity.contentResolver.update(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, existing),
                eventValues, null, null)
            setReminder(existing, call)
            return existing
        }
        val uri = activity.contentResolver.insert(CalendarContract.Events.CONTENT_URI, eventValues)
            ?: throw IllegalStateException("Calendar did not save the event")
        val eventId = ContentUris.parseId(uri)
        try { setReminder(eventId, call) }
        catch (error: Exception) {
            // Roll back this newly created event if its provider reminder fails.
            activity.contentResolver.delete(uri, null, null)
            throw error
        }
        return eventId
    }

    private fun localEventUri(localId: String) = "tawabti://planner/" + Uri.encode(localId)

    private fun findLocalEvent(calendarId: Long, localId: String): Long? {
        activity.contentResolver.query(CalendarContract.Events.CONTENT_URI,
            arrayOf(CalendarContract.Events._ID),
            CalendarContract.Events.CALENDAR_ID + "=? AND " +
                CalendarContract.Events.CUSTOM_APP_PACKAGE + "=? AND " +
                CalendarContract.Events.CUSTOM_APP_URI + "=? AND " + CalendarContract.Events.DELETED + "=0",
            arrayOf(calendarId.toString(), activity.packageName, localEventUri(localId)), null)?.use {
            if (it.moveToFirst()) return it.getLong(0)
        }
        return null
    }

    private fun updateEvent(call: MethodCall) {
        val id = long(call, "id")
        requireEventCalendar(id, long(call, "calendarId"))
        val updated = activity.contentResolver.update(
            ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, id), values(call), null, null)
        require(updated == 1) { "Calendar event was not found" }
        setReminder(id, call)
    }

    private fun requireEventCalendar(id: Long, calendarId: Long) {
        activity.contentResolver.query(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, id),
            arrayOf(CalendarContract.Events.CALENDAR_ID), null, null, null)?.use {
            require(it.moveToFirst() && it.getLong(0) == calendarId) { "Calendar event does not belong to this calendar" }
        } ?: throw IllegalStateException("Calendar event was not found")
    }

    private fun deleteEvent(call: MethodCall) {
        val id = long(call, "id")
        val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, id)
        activity.contentResolver.query(uri, arrayOf(CalendarContract.Events.CALENDAR_ID), null, null, null)?.use {
            require(it.moveToFirst()) { "Calendar event was not found" }
            requireWritable(it.getLong(0))
        } ?: throw IllegalStateException("Calendar event was not found")
        require(activity.contentResolver.delete(uri, null, null) == 1) { "Calendar did not delete the event" }
    }

    private fun setReminder(id: Long, call: MethodCall) {
        val minutes = call.argument<Number>("reminderMinutes")?.toInt()
        require(minutes == null || minutes in 0..10080) { "Invalid reminder interval" }
        activity.contentResolver.delete(CalendarContract.Reminders.CONTENT_URI,
            CalendarContract.Reminders.EVENT_ID + "=?", arrayOf(id.toString()))
        if (minutes != null) {
            val reminder = ContentValues().apply {
                put(CalendarContract.Reminders.EVENT_ID, id)
                put(CalendarContract.Reminders.MINUTES, minutes)
                put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
            }
            requireNotNull(activity.contentResolver.insert(CalendarContract.Reminders.CONTENT_URI, reminder)) {
                "Calendar did not save its reminder"
            }
        }
    }

    private fun long(call: MethodCall, key: String) =
        call.argument<Number>(key)?.toLong() ?: throw IllegalArgumentException("Missing $key")

    private fun validMeet(value: String?): Boolean {
        if (value == null) return false
        val uri = Uri.parse(value)
        return uri.scheme == "https" && uri.host == "meet.google.com" &&
            uri.userInfo.isNullOrEmpty() && (uri.port == -1 || uri.port == 443) &&
            Regex("^/[a-z]{3}-[a-z]{4}-[a-z]{3}/?$").matches(uri.path ?: "")
    }
}
