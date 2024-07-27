package com.flologames.schulapp;

import android.content.Intent;
import android.widget.RemoteViewsService;

public class TimetableRemoteViewsService extends RemoteViewsService {
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new TimetableRemoteViewsFactory(this.getApplicationContext(), intent);
    }
}
