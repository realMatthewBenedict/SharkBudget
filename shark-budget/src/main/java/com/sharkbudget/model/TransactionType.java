package com.sharkbudget.model;

public enum TransactionType {
    INCOME("Income"),
    EXPENSE("Expense");

    private final String displayName;

    TransactionType(String displayName) {
        this.displayName = displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }
}
