package com.example.schulapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.ListView
import android.widget.RemoteViews
import androidx.viewbinding.ViewBindings
import java.io.File
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject;

data class SchoolTime(val startTime: String, val endTime: String)


//https://stackoverflow.com/a/41943306
//https://www.sitepoint.com/killer-way-to-show-a-list-of-items-in-android-collection-widget/
class TimetableOneDay : AppWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.timetable_one_day).apply {

                //val title = widgetData.getString("headline_title", null)
                //setTextViewText(R.id.widget_image, title ?: "No title set")

                //val description = widgetData.getString("headline_description", null)
                //setTextViewText(R.id.headline_description, description ?: "No description set")

                //load json

                //parse json

                //create timetable

                //update ui
                val schoolTimes : ArrayList<SchoolTime> = ArrayList<SchoolTime>()

                schoolTimes.add(SchoolTime("07:45", "08.30"));
                schoolTimes.add(SchoolTime("08:40", "09.25"));
                schoolTimes.add(SchoolTime("09:45", "10.30"));
                schoolTimes.add(SchoolTime("10:40", "11:25"));
                schoolTimes.add(SchoolTime("11:35", "12:20"));
                schoolTimes.add(SchoolTime("12:50", "13:35"));
                schoolTimes.add(SchoolTime("13:45", "14:30"));
                schoolTimes.add(SchoolTime("14:40", "15:25"));
                schoolTimes.add(SchoolTime("15:30", "16:15"));

                //set list view adapter

            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}