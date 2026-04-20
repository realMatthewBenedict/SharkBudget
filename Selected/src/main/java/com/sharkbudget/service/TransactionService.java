package com.sharkbudget.service;

import com.sharkbudget.dao.DataStore;
import com.sharkbudget.model.AppData;
import com.sharkbudget.model.Category;
import com.sharkbudget.model.Transaction;
import com.sharkbudget.model.TransactionType;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public class TransactionService {
    private final DataStore dataStore;

    public TransactionService(DataStore dataStore) {
        this.dataStore = dataStore;
    }

    public void addTransaction(Transaction transaction) {
        validateTransaction(transaction);
        AppData data = dataStore.loadData();
        data.getTransactions().add(transaction);
        dataStore.saveData(data);
    }

    public void deleteTransaction(String transactionId) {
        AppData data = dataStore.loadData();
        data.getTransactions().removeIf(transaction -> transaction.getId().equals(transactionId));
        dataStore.saveData(data);
    }

    public List<Transaction> getUserTransactions(String username) {
        AppData data = dataStore.loadData();
        return data.getTransactions().stream()
                .filter(transaction -> transaction.getUsername().equalsIgnoreCase(username))
                .sorted(Comparator.comparing(Transaction::getDate).reversed())
                .collect(Collectors.toList());
    }

    public List<Transaction> searchTransactions(String username, String keyword, Category categoryFilter, TransactionType typeFilter) {
        String safeKeyword = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT).trim();

        return getUserTransactions(username).stream()
                .filter(transaction -> safeKeyword.isBlank()
                        || containsText(transaction.getSourceOrMerchant(), safeKeyword)
                        || containsText(transaction.getNote(), safeKeyword)
                        || containsText(transaction.getCategory().getDisplayName(), safeKeyword))
                .filter(transaction -> categoryFilter == null || transaction.getCategory() == categoryFilter)
                .filter(transaction -> typeFilter == null || transaction.getType() == typeFilter)
                .collect(Collectors.toList());
    }

    public List<Transaction> getTransactionsInRange(String username, LocalDate startDate, LocalDate endDate) {
        return getUserTransactions(username).stream()
                .filter(transaction -> !transaction.getDate().isBefore(startDate) && !transaction.getDate().isAfter(endDate))
                .collect(Collectors.toList());
    }

    private boolean containsText(String field, String keyword) {
        return field != null && field.toLowerCase(Locale.ROOT).contains(keyword);
    }

    private void validateTransaction(Transaction transaction) {
        if (transaction == null) {
            throw new IllegalArgumentException("Transaction cannot be null.");
        }
        if (transaction.getUsername() == null || transaction.getUsername().isBlank()) {
            throw new IllegalArgumentException("Username cannot be empty.");
        }
        if (transaction.getDate() == null) {
            throw new IllegalArgumentException("Date is required.");
        }
        if (transaction.getType() == null) {
            throw new IllegalArgumentException("Type is required.");
        }
        if (transaction.getCategory() == null) {
            throw new IllegalArgumentException("Category is required.");
        }
        if (transaction.getSourceOrMerchant() == null || transaction.getSourceOrMerchant().isBlank()) {
            throw new IllegalArgumentException("Source or merchant is required.");
        }
        if (transaction.getAmount() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than 0.");
        }
    }
}
