package com.sharkbudget.model;

import java.util.ArrayList;
import java.util.List;

public class AppData {
    private List<User> users = new ArrayList<>();
    private List<Transaction> transactions = new ArrayList<>();
    private List<BudgetTarget> budgetTargets = new ArrayList<>();

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }

    public List<Transaction> getTransactions() {
        return transactions;
    }

    public void setTransactions(List<Transaction> transactions) {
        this.transactions = transactions;
    }

    public List<BudgetTarget> getBudgetTargets() {
        return budgetTargets;
    }

    public void setBudgetTargets(List<BudgetTarget> budgetTargets) {
        this.budgetTargets = budgetTargets;
    }
}
