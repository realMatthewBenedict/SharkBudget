package com.sharkbudget.ui;

import com.sharkbudget.dao.DataStore;
import com.sharkbudget.dao.JsonDataStore;
import com.sharkbudget.service.AuthService;
import com.sharkbudget.service.BudgetService;
import com.sharkbudget.service.ExportService;
import com.sharkbudget.service.TransactionService;

public class AppContext {
    private final DataStore dataStore;
    private final AuthService authService;
    private final TransactionService transactionService;
    private final BudgetService budgetService;
    private final ExportService exportService;

    public AppContext() {
        this.dataStore = new JsonDataStore();
        this.authService = new AuthService(dataStore);
        this.transactionService = new TransactionService(dataStore);
        this.budgetService = new BudgetService(dataStore, transactionService);
        this.exportService = new ExportService();
    }

    public AuthService getAuthService() {
        return authService;
    }

    public TransactionService getTransactionService() {
        return transactionService;
    }

    public BudgetService getBudgetService() {
        return budgetService;
    }

    public ExportService getExportService() {
        return exportService;
    }
}
