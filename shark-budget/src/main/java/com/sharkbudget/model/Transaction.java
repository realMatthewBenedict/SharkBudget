package com.sharkbudget.model;

import java.time.LocalDate;
import java.util.UUID;

public class Transaction {
    private String id;
    private String username;
    private LocalDate date;
    private TransactionType type;
    private Category category;
    private String sourceOrMerchant;
    private String note;
    private double amount;
    private boolean recurring;

    public Transaction() {
    }

    public Transaction(String username, LocalDate date, TransactionType type, Category category,
                       String sourceOrMerchant, String note, double amount, boolean recurring) {
        this.id = UUID.randomUUID().toString();
        this.username = username;
        this.date = date;
        this.type = type;
        this.category = category;
        this.sourceOrMerchant = sourceOrMerchant;
        this.note = note;
        this.amount = amount;
        this.recurring = recurring;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public TransactionType getType() {
        return type;
    }

    public void setType(TransactionType type) {
        this.type = type;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public String getSourceOrMerchant() {
        return sourceOrMerchant;
    }

    public void setSourceOrMerchant(String sourceOrMerchant) {
        this.sourceOrMerchant = sourceOrMerchant;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public boolean isRecurring() {
        return recurring;
    }

    public void setRecurring(boolean recurring) {
        this.recurring = recurring;
    }
}
