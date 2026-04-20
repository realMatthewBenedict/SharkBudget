package com.sharkbudget.service;

import com.sharkbudget.dao.DataStore;
import com.sharkbudget.model.AppData;
import com.sharkbudget.model.BudgetTarget;
import com.sharkbudget.model.Category;
import com.sharkbudget.model.Transaction;
import com.sharkbudget.model.TransactionType;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class BudgetService {
    private final DataStore dataStore;
    private final TransactionService transactionService;

    public BudgetService(DataStore dataStore, TransactionService transactionService) {
        this.dataStore = dataStore;
        this.transactionService = transactionService;
    }

    public double getTotalIncome(String username, LocalDate startDate, LocalDate endDate, Category category) {
        return filterTransactions(username, startDate, endDate, category).stream()
                .filter(transaction -> transaction.getType() == TransactionType.INCOME)
                .mapToDouble(Transaction::getAmount)
                .sum();
    }

    public double getTotalExpense(String username, LocalDate startDate, LocalDate endDate, Category category) {
        return filterTransactions(username, startDate, endDate, category).stream()
                .filter(transaction -> transaction.getType() == TransactionType.EXPENSE)
                .mapToDouble(Transaction::getAmount)
                .sum();
    }

    public double getNetCashFlow(String username, LocalDate startDate, LocalDate endDate, Category category) {
        return getTotalIncome(username, startDate, endDate, category) - getTotalExpense(username, startDate, endDate, category);
    }

    public Map<String, Double> getExpenseByCategory(String username, LocalDate startDate, LocalDate endDate) {
        Map<String, Double> result = new LinkedHashMap<>();
        for (Category category : Category.values()) {
            double total = filterTransactions(username, startDate, endDate, category).stream()
                    .filter(transaction -> transaction.getType() == TransactionType.EXPENSE)
                    .mapToDouble(Transaction::getAmount)
                    .sum();
            if (total > 0) {
                result.put(category.getDisplayName(), total);
            }
        }
        return result;
    }

    public List<DailyCashFlowPoint> getDailyCashFlow(String username, LocalDate startDate, LocalDate endDate) {
        List<DailyCashFlowPoint> points = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate day = current;
            double income = transactionService.getTransactionsInRange(username, day, day).stream()
                    .filter(transaction -> transaction.getType() == TransactionType.INCOME)
                    .mapToDouble(Transaction::getAmount)
                    .sum();
            double expense = transactionService.getTransactionsInRange(username, day, day).stream()
                    .filter(transaction -> transaction.getType() == TransactionType.EXPENSE)
                    .mapToDouble(Transaction::getAmount)
                    .sum();
            points.add(new DailyCashFlowPoint(day.toString(), income - expense));
            current = current.plusDays(1);
        }
        return points;
    }

    public void saveMonthlyTarget(String username, double targetAmount) {
        if (targetAmount < 0) {
            throw new IllegalArgumentException("Target amount cannot be negative.");
        }

        AppData data = dataStore.loadData();
        String currentPeriod = YearMonth.now().toString();
        BudgetTarget existingTarget = data.getBudgetTargets().stream()
                .filter(target -> target.getUsername().equalsIgnoreCase(username) && target.getPeriod().equals(currentPeriod))
                .findFirst()
                .orElse(null);

        if (existingTarget == null) {
            data.getBudgetTargets().add(new BudgetTarget(username, currentPeriod, targetAmount));
        } else {
            existingTarget.setTargetSavings(targetAmount);
        }
        dataStore.saveData(data);
    }

    public double getCurrentMonthlyTarget(String username) {
        AppData data = dataStore.loadData();
        String currentPeriod = YearMonth.now().toString();
        return data.getBudgetTargets().stream()
                .filter(target -> target.getUsername().equalsIgnoreCase(username) && target.getPeriod().equals(currentPeriod))
                .map(BudgetTarget::getTargetSavings)
                .findFirst()
                .orElse(0.0);
    }

    public List<Transaction> getStatisticsTransactions(String username, LocalDate startDate, LocalDate endDate) {
        return transactionService.getTransactionsInRange(username, startDate, endDate).stream()
                .sorted(Comparator.comparing(Transaction::getDate))
                .toList();
    }

    private List<Transaction> filterTransactions(String username, LocalDate startDate, LocalDate endDate, Category category) {
        return transactionService.getTransactionsInRange(username, startDate, endDate).stream()
                .filter(transaction -> category == null || transaction.getCategory() == category)
                .toList();
    }

    public static class DailyCashFlowPoint {
        private final String label;
        private final double netAmount;

        public DailyCashFlowPoint(String label, double netAmount) {
            this.label = label;
            this.netAmount = netAmount;
        }

        public String getLabel() {
            return label;
        }

        public double getNetAmount() {
            return netAmount;
        }
    }
}
