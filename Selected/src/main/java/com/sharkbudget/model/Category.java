package com.sharkbudget.model;

public enum Category {
    HOUSING("Housing"),
    BILLS("Bills"),
    TRANSPORT("Transport"),
    FOOD("Food"),
    SALARY("Salary"),
    OTHER("Other");

    private final String displayName;

    Category(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }
}
