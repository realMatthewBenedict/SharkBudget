package com.sharkbudget.dao;

import com.sharkbudget.model.AppData;

public interface DataStore {
    AppData loadData();
    void saveData(AppData data);
}
