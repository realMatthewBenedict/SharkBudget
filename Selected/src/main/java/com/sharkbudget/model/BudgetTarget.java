package com.sharkbudget.model;

public class BudgetTarget {
    private String username;
    private String period;
    private double targetSavings;

    public BudgetTarget() {
    }

    public BudgetTarget(String username, String period, double targetSavings) {
        this.username = username;
        this.period = period;
        this.targetSavings = targetSavings;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public double getTargetSavings() {
        return targetSavings;
    }

    public void setTargetSavings(double targetSavings) {
        this.targetSavings = targetSavings;
    }
}
