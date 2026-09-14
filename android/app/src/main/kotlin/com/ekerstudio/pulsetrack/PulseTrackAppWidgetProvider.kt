package com.ekerstudio.pulsetrack

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PulseTrackAppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_pulse_track).apply {
                val hasData = widgetData.getBoolean("has_data", false) ?: false
                if (hasData) {
                    val date = widgetData.getString("last_workout_date", "--") ?: "--"
                    val avgBpm = widgetData.getString("avg_bpm", "--") ?: "--"
                    val maxBpm = widgetData.getString("max_bpm", "--") ?: "--"
                    val duration = widgetData.getString("duration", "--") ?: "--"
                    setTextViewText(R.id.widget_last_workout_date, date)
                    setTextViewText(R.id.widget_avg_bpm, "$avgBpm BPM")
                    setTextViewText(R.id.widget_max_bpm, "Max $maxBpm")
                    setTextViewText(R.id.widget_duration, duration)
                } else {
                    setTextViewText(R.id.widget_last_workout_date, "No workouts yet")
                    setTextViewText(R.id.widget_avg_bpm, "--")
                    setTextViewText(R.id.widget_max_bpm, "--")
                    setTextViewText(R.id.widget_duration, "--")
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
