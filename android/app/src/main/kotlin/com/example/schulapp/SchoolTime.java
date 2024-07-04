package com.example.schulapp;

public class SchoolTime {
    private String start;
    private String end;

    public SchoolTime(String start, String end){
        this.start = start;
        this.end = end;
    }


    public String getStart() {
        return start;
    }

    public String getEnd() {
        return end;
    }
}
