package com.flologames.schulapp;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

import androidx.annotation.NonNull;

import java.time.ZonedDateTime;
import java.time.temporal.ChronoUnit;

import es.antonborri.home_widget.HomeWidgetProvider;

public class TimetableOneDay extends HomeWidgetProvider {
    public static final String timetableId = "timetable";

    @Override
    public void onUpdate(@NonNull Context context, @NonNull AppWidgetManager appWidgetManager, @NonNull int[] appWidgetIds, @NonNull SharedPreferences widgetData) {
        String widgetStr = widgetData.getString(timetableId, null);
        DataHolder.getInstance().setData(widgetStr);

        for (int appWidgetId : appWidgetIds) {
            Intent intent = new Intent(context, TimetableRemoteViewsService.class);

            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.timetable_one_day);

            views.setRemoteAdapter(R.id.timesListView, intent);

            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.timesListView);
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }

        scheduleUpdates(context);
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        scheduleUpdates(context);
    }

    @Override
    public void onDisabled(Context context) {
        scheduleUpdates(context);
    }

    private void scheduleUpdates(Context context){
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.O) {
            return;
        }

        int[] activeWidgetIds = getActiveWidgetIds(context);

        if(activeWidgetIds.length != 0){
            ZonedDateTime now = ZonedDateTime.now();
            ZonedDateTime nextMidnight = now.truncatedTo(ChronoUnit.DAYS).plusDays(1);
            PendingIntent pendingIntent = getUpdateIntent(context);
            AlarmManager alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
            alarmManager.set(AlarmManager.RTC_WAKEUP, nextMidnight.toInstant().toEpochMilli(), pendingIntent);
        }
    }

    private PendingIntent getUpdateIntent(Context context){
        int[] activeWidgetIds = getActiveWidgetIds(context);

        Intent updateIntent = new Intent(context, this.getClass());

        updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, activeWidgetIds);

        int requestCode = this.getClass().getName().hashCode();
        int flags = PendingIntent.FLAG_CANCEL_CURRENT | PendingIntent.FLAG_IMMUTABLE;

        return PendingIntent.getBroadcast(context, requestCode, updateIntent, flags);
    }

    private int[] getActiveWidgetIds(Context context){
        AppWidgetManager manager = AppWidgetManager.getInstance(context);
        ComponentName name = new ComponentName(context, this.getClass());

        return manager.getAppWidgetIds(name);
    }
}
