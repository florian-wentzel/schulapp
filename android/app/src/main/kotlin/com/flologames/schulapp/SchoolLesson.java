package com.flologames.schulapp;

public class SchoolLesson {
    private String startTime;
    private String endTime;
    private String name;
    private String room;
    private int color;
    private int timesColor;

    public SchoolLesson(String startTime, String endTime, String name, String room, int color, int timesColor) {
        this.startTime = startTime;
        this.endTime = endTime;
        this.name = name;
        this.room = room;
        this.color = color;
        this.timesColor = timesColor;
    }

    public String getStartTime() {
        return startTime;
    }
    public String getEndTime() {
        return endTime;
    }
    public String getName() { return name; }
    public String getRoom() { return room; }
    public int getColor(){ return color; }
    public int getTimesColor(){ return timesColor; }
}
