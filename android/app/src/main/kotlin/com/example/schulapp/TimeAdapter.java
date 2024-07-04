package com.example.schulapp;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.List;

class TimeAdapter extends ArrayAdapter<SchoolTime> {

    public TimeAdapter(@NonNull Context context, int resource, @NonNull List<SchoolTime> objects) {
        super(context, resource, objects);
    }

    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        SchoolTime schoolTime = getItem(position);

        if(convertView == null){
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.time_item_view, parent, false);
        }

        TextView startText = (TextView) convertView.findViewById(R.id.start);
        TextView endText = (TextView) convertView.findViewById(R.id.end);

        startText.setText(schoolTime.getStart());
        endText.setText(schoolTime.getEnd());

        return convertView;
    }
}