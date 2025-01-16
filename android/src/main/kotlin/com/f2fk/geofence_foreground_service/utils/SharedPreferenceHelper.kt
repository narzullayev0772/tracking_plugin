package com.f2fk.geofence_foreground_service.utils

import android.content.Context
import android.util.Log

object SharedPreferenceHelper {
    private const val SHARED_PREFS_FILE_NAME = "geofence_foreground_service_plugin"
    private const val CALLBACK_DISPATCHER_HANDLE_KEY =
        "ps.byshy.geofence.CALLBACK_DISPATCHER_HANDLE_KEY"
    private const val LOCATION_KEY = "ps.byshy.geofence.LOCATION_KEY"
    private const val IS_ENTER = "ps.byshy.geofence.IS_ENTER"
    private const val ENTERED_ZONE_ID = "ps.byshy.geofence.ENTERED_ZONE_ID"
    private fun Context.prefs() = getSharedPreferences(SHARED_PREFS_FILE_NAME, Context.MODE_PRIVATE)

    fun saveCallbackDispatcherHandleKey(ctx: Context, callbackHandle: Long) {
        ctx.prefs()
            .edit()
            .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
            .apply()
    }

    fun getCallbackHandle(ctx: Context): Long {
        return ctx.prefs().getLong(CALLBACK_DISPATCHER_HANDLE_KEY, -1L)
    }

    fun hasCallbackHandle(ctx: Context) = ctx.prefs().contains(CALLBACK_DISPATCHER_HANDLE_KEY)

    private fun saveLocations(ctx: Context, locations: List<String>) {
        ctx.prefs()
            .edit()
            .putStringSet(LOCATION_KEY, locations.toSet())
            .apply()
    }

    fun getLocations(ctx: Context): Set<String> {
        return ctx.prefs().getStringSet(LOCATION_KEY, setOf()) ?: setOf()
    }

    fun addLocation(ctx: Context, location: String) {

        Log.d(
            "onLocationResult", location
        )
        val isEnter = ctx.prefs().getBoolean(IS_ENTER, false)
        if (isEnter) {
            val actZoneId = ctx.prefs().getString(ENTERED_ZONE_ID, "")
            val locations = getLocations(ctx).toMutableSet()
            locations.add("$location, $actZoneId")
            saveLocations(ctx, locations.toList())
        }
    }

    fun setEnter(ctx: Context, isEnter: Boolean, zoneId: String) {
        ctx.prefs()
            .edit()
            .putBoolean(IS_ENTER, isEnter)
            .putString(ENTERED_ZONE_ID, zoneId)
            .apply()
    }


}
