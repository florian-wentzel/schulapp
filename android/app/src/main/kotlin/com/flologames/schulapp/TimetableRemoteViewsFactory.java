package com.flologames.schulapp;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;

class TimetableRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {
    private final Context context;
    private ArrayList<SchoolLesson> schoolLessons;

    public TimetableRemoteViewsFactory(Context context, Intent intent) {
        this.context = context;
    }

    @Override
    public void onCreate() {
        createSchoolLessons();

        /*schoolLessons.add(new SchoolLesson("07:45", "08:30", "Deutsch", "215", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("08:40", "09:25", "Deutsch", "215", Color.argb(255, 255, 0, 255), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("09:45", "10:30", "Deutsch", "215", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("10:40", "11:25", "Deutsch", "215", Color.argb(255, 255, 255, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("11:35", "12:20", "Deutsch", "215", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("12:50", "13:35", "Deutsch", "215", Color.argb(255, 0, 0, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("13:45", "14:30", "Deutsch", "215", Color.argb(255, 0, 255, 0), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("14:40", "15:25", "Deutsch", "215", Color.argb(255, 0, 0, 255), Color.argb(255, 255, 0, 0)));
        schoolLessons.add(new SchoolLesson("15:30", "16:15", "Deutsch", "215", Color.argb(255, 0, 255, 255), Color.argb(255, 255, 0, 0)));*/
    }

    private void createSchoolLessons(){
        String widgetData = DataHolder.getInstance().getData();

        schoolLessons = new ArrayList<>();

        if(widgetData == null){
            schoolLessons.add(new SchoolLesson("It looks like you don't have a timetable set up yet.", "", "Please add your classes and events in the main app to view your daily schedule here.", "", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
            return;
        }

        String errorInfo = "";
        try{
            int currDayIndex = getWeekDayIndex();

            JSONObject mainObject = new JSONObject(widgetData);

            JSONArray timesArray = mainObject.getJSONArray("times");

            JSONArray days = mainObject.getJSONArray("days");

            if(currDayIndex > days.length() - 1) {
                currDayIndex = days.length() - 1;
            }
            if(currDayIndex < 0) {
                currDayIndex = 0;
            }

            JSONObject currDay = days.getJSONObject(currDayIndex);
            JSONArray currLessons = currDay.getJSONArray("lessons");

            if(timesArray.length() != currLessons.length()) {
                schoolLessons.add(new SchoolLesson("length", "", "", "", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
                return;
            }

            int count = mainObject.getInt("maxLessonCount");

            int timesColor = jsonObjectToColor(mainObject.getJSONObject("timesColor"));


            for(int i = 0; i < count; i++) {
                JSONObject currLesson = currLessons.getJSONObject(i);
                JSONObject currTimes = timesArray.getJSONObject(i);

                String startTime = jsonTimeObjectToString(currTimes, "start");
                String endTime = jsonTimeObjectToString(currTimes, "end");
                String name = currLesson.getString("name");
                String room = currLesson.getString("room");

                int color = jsonObjectToColor(currLesson.getJSONObject("color"));

                schoolLessons.add(new SchoolLesson(startTime, endTime, name, room, color, timesColor));
            }

        } catch (Exception e){
            schoolLessons.add(new SchoolLesson("Error:", errorInfo, e.toString(), "", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
        }
    }

    private int jsonObjectToColor(JSONObject json) throws JSONException {
        int a = json.getInt("a");
        int r = json.getInt("r");
        int g = json.getInt("g");
        int b = json.getInt("b");

        if(a == 0){
            r = 255;
            g = 255;
            b = 255;
        }

        return Color.argb(a, r, g, b);
    }

    @Override
    public void onDataSetChanged() {
        //schoolLessons.add(new SchoolLesson("null", "", "", "", Color.argb(255, 255, 0, 0), Color.argb(255, 255, 0, 0)));
        createSchoolLessons();
    }

    @Override
    public void onDestroy() {
        // Clean up if needed
    }

    @Override
    public int getCount() {
        return schoolLessons.size();
    }

    @Override
    public RemoteViews getViewAt(int position) {
        RemoteViews rv = new RemoteViews(context.getPackageName(), R.layout.time_item_view);
        SchoolLesson schoolLesson = schoolLessons.get(position);
        rv.setTextViewText(R.id.start, schoolLesson.getStartTime());
        rv.setTextViewText(R.id.end, schoolLesson.getEndTime());
        rv.setTextViewText(R.id.name, schoolLesson.getName());
        rv.setTextViewText(R.id.room, schoolLesson.getRoom());

        rv.setInt(R.id.times_background, "setColorFilter", schoolLesson.getTimesColor());
        rv.setInt(R.id.times_background, "setAlpha", Color.alpha(schoolLesson.getTimesColor()));

        rv.setInt(R.id.lesson_background, "setColorFilter", schoolLesson.getColor());
        rv.setInt(R.id.lesson_background, "setAlpha", Color.alpha(schoolLesson.getColor()));

        return rv;
    }

    @Override
    public RemoteViews getLoadingView() {
        return null;
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    private int getWeekDayIndex(){
        Calendar calendar = Calendar.getInstance();

        // Get the current day of the week (Sunday = 1, Monday = 2, ..., Saturday = 7)
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        return dayOfWeek - Calendar.MONDAY;
    }

    private String jsonTimeObjectToString(JSONObject currTimes, String startOrEnd) throws JSONException {
        JSONObject obj = currTimes.getJSONObject(startOrEnd);
        int minute = obj.getInt("minute");
        int hour = obj.getInt("hour");

        String hourString = hour < 10 ? "0" + hour : "" + hour;
        String minuteString = minute < 10 ? "0" + minute : "" + minute;


        return hourString + ":" + minuteString;
    }
}