package com.sharkbudget.service;

import com.sharkbudget.dao.DataStore;
import com.sharkbudget.model.AppData;
import com.sharkbudget.model.User;

public class AuthService {
    private final DataStore dataStore;

    public AuthService(DataStore dataStore) {
        this.dataStore = dataStore;
    }

    public boolean register(String username, String password) {
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            throw new IllegalArgumentException("Username and password cannot be empty.");
        }

        AppData data = dataStore.loadData();
        boolean exists = data.getUsers().stream()
                .anyMatch(user -> user.getUsername().equalsIgnoreCase(username.trim()));

        if (exists) {
            return false;
        }

        data.getUsers().add(new User(username.trim(), password));
        dataStore.saveData(data);
        return true;
    }

    public boolean login(String username, String password) {
        AppData data = dataStore.loadData();
        return data.getUsers().stream()
                .anyMatch(user -> user.getUsername().equalsIgnoreCase(username.trim())
                        && user.getPassword().equals(password));
    }
}
