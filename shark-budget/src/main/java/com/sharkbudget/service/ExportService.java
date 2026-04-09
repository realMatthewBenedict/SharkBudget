package com.sharkbudget.service;

import com.sharkbudget.model.Transaction;

import java.io.BufferedWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public class ExportService {
    public void exportTransactionsToCsv(List<Transaction> transactions, Path outputPath) {
        try (BufferedWriter writer = Files.newBufferedWriter(outputPath)) {
            writer.write("Date,Type,Category,SourceOrMerchant,Note,Amount,Recurring");
            writer.newLine();

            for (Transaction transaction : transactions) {
                writer.write(safe(transaction.getDate().toString()) + ","
                        + safe(transaction.getType().toString()) + ","
                        + safe(transaction.getCategory().getDisplayName()) + ","
                        + safe(transaction.getSourceOrMerchant()) + ","
                        + safe(transaction.getNote()) + ","
                        + transaction.getAmount() + ","
                        + transaction.isRecurring());
                writer.newLine();
            }
        } catch (Exception e) {
            throw new RuntimeException("Could not export CSV file.", e);
        }
    }

    private String safe(String value) {
        if (value == null) {
            return "";
        }
        String cleanValue = value.replace("\"", "\"\"");
        return "\"" + cleanValue + "\"";
    }
}
