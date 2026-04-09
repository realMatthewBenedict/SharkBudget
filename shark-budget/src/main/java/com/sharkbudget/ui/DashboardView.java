package com.sharkbudget.ui;

import com.sharkbudget.MainApp;
import com.sharkbudget.model.Category;
import com.sharkbudget.model.Transaction;
import com.sharkbudget.model.TransactionType;
import com.sharkbudget.service.BudgetService;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.chart.CategoryAxis;
import javafx.scene.chart.*;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.FileChooser;

import java.io.File;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DashboardView {
    private final AppContext appContext;
    private final MainApp mainApp;
    private final String username;
    private final BorderPane root;
    private final BorderPane contentArea;

    public DashboardView(AppContext appContext, MainApp mainApp, String username) {
        this.appContext = appContext;
        this.mainApp = mainApp;
        this.username = username;
        this.contentArea = new BorderPane();
        this.root = buildView();
        showDashboardPage();
    }

    public Parent getView() {
        return root;
    }

    private BorderPane buildView() {
        BorderPane pane = new BorderPane();
        pane.setLeft(buildSidebar());
        pane.setCenter(contentArea);
        return pane;
    }

    private VBox buildSidebar() {
        VBox sidebar = new VBox(12);
        sidebar.setPadding(new Insets(20));
        sidebar.setPrefWidth(220);
        sidebar.setStyle("-fx-background-color: #f6f8fb;");

        Label appName = new Label("Shark Budget");
        appName.setStyle("-fx-font-size: 22px; -fx-font-weight: bold;");

        Label userLabel = new Label("Signed in as: " + username);
        userLabel.setStyle("-fx-text-fill: #5c6b7a;");

        Button dashboardButton = createMenuButton("Dashboard");
        Button transactionsButton = createMenuButton("Transactions");
        Button addButton = createMenuButton("Add Transaction");
        Button chartsButton = createMenuButton("Charts");
        Button settingsButton = createMenuButton("Settings");
        Button logoutButton = createMenuButton("Logout");

        dashboardButton.setOnAction(e -> showDashboardPage());
        transactionsButton.setOnAction(e -> showTransactionsPage());
        addButton.setOnAction(e -> showAddTransactionPage());
        chartsButton.setOnAction(e -> showChartsPage());
        settingsButton.setOnAction(e -> showSettingsPage());
        logoutButton.setOnAction(e -> mainApp.showLoginView());

        sidebar.getChildren().addAll(appName, userLabel, new Separator(),
                dashboardButton, transactionsButton, addButton, chartsButton, settingsButton,
                new Separator(), logoutButton);
        return sidebar;
    }

    private Button createMenuButton(String text) {
        Button button = new Button(text);
        button.setMaxWidth(Double.MAX_VALUE);
        button.setStyle("-fx-background-color: white; -fx-padding: 10 14 10 14;"
                + "-fx-background-radius: 8; -fx-border-color: #dce3ed; -fx-border-radius: 8;");
        return button;
    }

    private void showDashboardPage() {
        VBox page = new VBox(16);
        page.setPadding(new Insets(20));

        Label title = new Label("Dashboard");
        title.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        HBox filterRow = new HBox(10);
        filterRow.setAlignment(Pos.CENTER_LEFT);

        ComboBox<String> timeRangeBox = new ComboBox<>();
        timeRangeBox.getItems().addAll("This Month", "Last 30 Days", "This Year", "All Time");
        timeRangeBox.setValue("This Month");

        ComboBox<String> categoryBox = new ComboBox<>();
        categoryBox.getItems().add("All");
        for (Category category : Category.values()) {
            categoryBox.getItems().add(category.getDisplayName());
        }
        categoryBox.setValue("All");

        TextField searchField = new TextField();
        searchField.setPromptText("Search transactions...");
        searchField.setPrefWidth(250);

        Button searchButton = new Button("Search");
        Button exportButton = new Button("Export CSV");

        filterRow.getChildren().addAll(new Label("Time Range"), timeRangeBox,
                new Label("Category"), categoryBox, searchField, searchButton, exportButton);

        HBox summaryCards = new HBox(15);
        summaryCards.setPrefHeight(120);

        VBox incomeCard = createSummaryCard("Total Income", "$0.00");
        VBox expenseCard = createSummaryCard("Total Expense", "$0.00");
        VBox netCard = createSummaryCard("Net Balance", "$0.00");
        summaryCards.getChildren().addAll(incomeCard, expenseCard, netCard);

        HBox chartRow = new HBox(15);
        chartRow.setPrefHeight(420);

        VBox lineChartBox = new VBox(10);
        lineChartBox.setPadding(new Insets(15));
        lineChartBox.setStyle("-fx-background-color: white; -fx-border-color: #dde5f0; -fx-border-radius: 10; -fx-background-radius: 10;");
        lineChartBox.setPrefWidth(650);

        Label lineChartLabel = new Label("Cashflow Over Time");
        CategoryAxis lineXAxis = new CategoryAxis();
        NumberAxis lineYAxis = new NumberAxis();
        LineChart<String, Number> lineChart = new LineChart<>(lineXAxis, lineYAxis);
        lineChart.setLegendVisible(false);
        lineChart.setAnimated(false);
        lineChart.setPrefHeight(350);
        lineChartBox.getChildren().addAll(lineChartLabel, lineChart);

        VBox pieChartBox = new VBox(10);
        pieChartBox.setPadding(new Insets(15));
        pieChartBox.setStyle("-fx-background-color: white; -fx-border-color: #dde5f0; -fx-border-radius: 10; -fx-background-radius: 10;");
        pieChartBox.setPrefWidth(350);

        Label pieChartLabel = new Label("Expense by Category");
        PieChart pieChart = new PieChart();
        pieChart.setLegendSide(javafx.geometry.Side.BOTTOM);
        pieChart.setLabelsVisible(true);
        pieChart.setPrefHeight(350);
        pieChartBox.getChildren().addAll(pieChartLabel, pieChart);

        chartRow.getChildren().addAll(lineChartBox, pieChartBox);

        Runnable refreshDashboard = () -> {
            DateRange range = getDateRange(timeRangeBox.getValue());
            Category selectedCategory = parseCategory(categoryBox.getValue());

            double income = appContext.getBudgetService().getTotalIncome(username, range.startDate(), range.endDate(), selectedCategory);
            double expense = appContext.getBudgetService().getTotalExpense(username, range.startDate(), range.endDate(), selectedCategory);
            double net = income - expense;

            ((Label) incomeCard.getChildren().get(1)).setText(String.format("$%.2f", income));
            ((Label) expenseCard.getChildren().get(1)).setText(String.format("$%.2f", expense));
            ((Label) netCard.getChildren().get(1)).setText(String.format("$%.2f", net));

            lineChart.getData().clear();
            XYChart.Series<String, Number> series = new XYChart.Series<>();
            for (BudgetService.DailyCashFlowPoint point : appContext.getBudgetService().getDailyCashFlow(username, range.startDate(), range.endDate())) {
                series.getData().add(new XYChart.Data<>(point.getLabel(), point.getNetAmount()));
            }
            lineChart.getData().add(series);

            ObservableList<PieChart.Data> pieData = FXCollections.observableArrayList();
            Map<String, Double> expenseMap = appContext.getBudgetService().getExpenseByCategory(username, range.startDate(), range.endDate());
            for (Map.Entry<String, Double> entry : expenseMap.entrySet()) {
                pieData.add(new PieChart.Data(entry.getKey(), entry.getValue()));
            }
            pieChart.setData(pieData);
        };

        timeRangeBox.setOnAction(e -> refreshDashboard.run());
        categoryBox.setOnAction(e -> refreshDashboard.run());
        searchButton.setOnAction(e -> showTransactionsPage(searchField.getText(), parseCategory(categoryBox.getValue()), null));
        exportButton.setOnAction(e -> exportCurrentTransactions());

        refreshDashboard.run();

        page.getChildren().addAll(title, filterRow, summaryCards, chartRow);
        contentArea.setCenter(page);
    }

    private VBox createSummaryCard(String title, String value) {
        VBox card = new VBox(8);
        card.setPadding(new Insets(16));
        card.setPrefWidth(250);
        card.setStyle("-fx-background-color: white; -fx-border-color: #dde5f0; -fx-border-radius: 10; -fx-background-radius: 10;");

        Label titleLabel = new Label(title);
        titleLabel.setStyle("-fx-text-fill: #5c6b7a;");

        Label valueLabel = new Label(value);
        valueLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        card.getChildren().addAll(titleLabel, valueLabel);
        return card;
    }

    private void showTransactionsPage() {
        showTransactionsPage("", null, null);
    }

    private void showTransactionsPage(String keyword, Category initialCategory, TransactionType initialType) {
        VBox page = new VBox(15);
        page.setPadding(new Insets(20));

        Label title = new Label("Transactions");
        title.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        HBox topRow = new HBox(10);
        topRow.setAlignment(Pos.CENTER_LEFT);

        TextField searchField = new TextField(keyword == null ? "" : keyword);
        searchField.setPromptText("Search by category, source, note...");
        searchField.setPrefWidth(280);

        ComboBox<String> typeBox = new ComboBox<>();
        typeBox.getItems().addAll("All", "Income", "Expense");
        typeBox.setValue(initialType == null ? "All" : initialType.toString());

        ComboBox<String> categoryBox = new ComboBox<>();
        categoryBox.getItems().add("All");
        for (Category category : Category.values()) {
            categoryBox.getItems().add(category.getDisplayName());
        }
        categoryBox.setValue(initialCategory == null ? "All" : initialCategory.getDisplayName());

        Button searchButton = new Button("Search");
        Button addButton = new Button("Add");

        topRow.getChildren().addAll(searchField, new Label("Type"), typeBox,
                new Label("Category"), categoryBox, searchButton, addButton);

        TableView<Transaction> tableView = new TableView<>();
        tableView.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);

        TableColumn<Transaction, String> dateColumn = new TableColumn<>("Date");
        dateColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().getDate().toString()));

        TableColumn<Transaction, String> typeColumn = new TableColumn<>("Type");
        typeColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().getType().toString()));

        TableColumn<Transaction, String> categoryColumn = new TableColumn<>("Category");
        categoryColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().getCategory().getDisplayName()));

        TableColumn<Transaction, String> sourceColumn = new TableColumn<>("Source / Merchant");
        sourceColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().getSourceOrMerchant()));

        TableColumn<Transaction, String> noteColumn = new TableColumn<>("Note");
        noteColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().getNote() == null ? "" : cell.getValue().getNote()));

        TableColumn<Transaction, String> amountColumn = new TableColumn<>("Amount");
        amountColumn.setCellValueFactory(cell -> new SimpleStringProperty(String.format("$%.2f", cell.getValue().getAmount())));

        TableColumn<Transaction, String> recurringColumn = new TableColumn<>("Recurring");
        recurringColumn.setCellValueFactory(cell -> new SimpleStringProperty(cell.getValue().isRecurring() ? "Yes" : "No"));

        TableColumn<Transaction, Void> actionColumn = new TableColumn<>("Actions");
        actionColumn.setCellFactory(column -> new TableCell<>() {
            private final Button deleteButton = new Button("Delete");

            {
                deleteButton.setOnAction(event -> {
                    Transaction transaction = getTableView().getItems().get(getIndex());
                    appContext.getTransactionService().deleteTransaction(transaction.getId());
                    refreshTransactionTable(tableView, searchField.getText(), parseCategory(categoryBox.getValue()), parseType(typeBox.getValue()));
                });
            }

            @Override
            protected void updateItem(Void item, boolean empty) {
                super.updateItem(item, empty);
                setGraphic(empty ? null : deleteButton);
            }
        });

        tableView.getColumns().addAll(dateColumn, typeColumn, categoryColumn, sourceColumn, noteColumn, amountColumn, recurringColumn, actionColumn);

        searchButton.setOnAction(e -> refreshTransactionTable(tableView, searchField.getText(), parseCategory(categoryBox.getValue()), parseType(typeBox.getValue())));
        addButton.setOnAction(e -> showAddTransactionPage());

        refreshTransactionTable(tableView, searchField.getText(), parseCategory(categoryBox.getValue()), parseType(typeBox.getValue()));

        page.getChildren().addAll(title, topRow, tableView);
        VBox.setVgrow(tableView, Priority.ALWAYS);
        contentArea.setCenter(page);
    }

    private void refreshTransactionTable(TableView<Transaction> tableView, String keyword, Category category, TransactionType type) {
        List<Transaction> transactions = appContext.getTransactionService().searchTransactions(username, keyword, category, type);
        tableView.setItems(FXCollections.observableArrayList(transactions));
    }

    private void showAddTransactionPage() {
        VBox page = new VBox(14);
        page.setPadding(new Insets(20));

        Label title = new Label("Add Transaction");
        title.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        GridPane form = new GridPane();
        form.setHgap(12);
        form.setVgap(12);

        DatePicker datePicker = new DatePicker(LocalDate.now());
        ComboBox<TransactionType> typeBox = new ComboBox<>();
        typeBox.getItems().addAll(TransactionType.values());
        typeBox.setValue(TransactionType.EXPENSE);

        ComboBox<Category> categoryBox = new ComboBox<>();
        categoryBox.getItems().addAll(Category.values());
        categoryBox.setValue(Category.FOOD);

        TextField sourceField = new TextField();
        sourceField.setPromptText("Source or merchant");

        TextField noteField = new TextField();
        noteField.setPromptText("Optional note");

        TextField amountField = new TextField();
        amountField.setPromptText("Amount");

        CheckBox recurringCheckBox = new CheckBox("Recurring bill / payment / subscription");

        form.add(new Label("Date"), 0, 0);
        form.add(datePicker, 1, 0);
        form.add(new Label("Type"), 0, 1);
        form.add(typeBox, 1, 1);
        form.add(new Label("Category"), 0, 2);
        form.add(categoryBox, 1, 2);
        form.add(new Label("Source / Merchant"), 0, 3);
        form.add(sourceField, 1, 3);
        form.add(new Label("Note"), 0, 4);
        form.add(noteField, 1, 4);
        form.add(new Label("Amount"), 0, 5);
        form.add(amountField, 1, 5);
        form.add(recurringCheckBox, 1, 6);

        Label messageLabel = new Label();

        Button saveButton = new Button("Save Transaction");
        Button backButton = new Button("Back to Transactions");

        saveButton.setOnAction(e -> {
            try {
                double amount = Double.parseDouble(amountField.getText().trim());
                Transaction transaction = new Transaction(
                        username,
                        datePicker.getValue(),
                        typeBox.getValue(),
                        categoryBox.getValue(),
                        sourceField.getText().trim(),
                        noteField.getText().trim(),
                        amount,
                        recurringCheckBox.isSelected()
                );
                appContext.getTransactionService().addTransaction(transaction);
                messageLabel.setText("Transaction saved successfully.");
                messageLabel.setStyle("-fx-text-fill: #2a9d8f;");

                sourceField.clear();
                noteField.clear();
                amountField.clear();
                recurringCheckBox.setSelected(false);
            } catch (NumberFormatException ex) {
                messageLabel.setText("Please enter a valid number for amount.");
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            } catch (Exception ex) {
                messageLabel.setText(ex.getMessage());
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            }
        });

        backButton.setOnAction(e -> showTransactionsPage());

        HBox buttonRow = new HBox(10, saveButton, backButton);

        page.getChildren().addAll(title, form, buttonRow, messageLabel);
        contentArea.setCenter(page);
    }

    private void showChartsPage() {
        VBox page = new VBox(15);
        page.setPadding(new Insets(20));

        Label title = new Label("Charts");
        title.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        HBox topRow = new HBox(10);
        topRow.setAlignment(Pos.CENTER_LEFT);

        ComboBox<String> timeRangeBox = new ComboBox<>();
        timeRangeBox.getItems().addAll("This Month", "Last 30 Days", "This Year", "All Time");
        timeRangeBox.setValue("This Year");

        Label summaryLabel = new Label();

        NumberAxis xAxis = new NumberAxis();
        NumberAxis yAxis = new NumberAxis();
        javafx.scene.chart.BarChart<Number, Number> barChart = new javafx.scene.chart.BarChart<>(xAxis, yAxis);
        barChart.setTitle("Monthly Expense Trend");
        barChart.setLegendVisible(false);
        barChart.setPrefHeight(450);

        Runnable refreshChart = () -> {
            DateRange range = getDateRange(timeRangeBox.getValue());
            List<Transaction> transactions = appContext.getBudgetService().getStatisticsTransactions(username, range.startDate(), range.endDate());
            double income = transactions.stream().filter(t -> t.getType() == TransactionType.INCOME).mapToDouble(Transaction::getAmount).sum();
            double expense = transactions.stream().filter(t -> t.getType() == TransactionType.EXPENSE).mapToDouble(Transaction::getAmount).sum();
            summaryLabel.setText(String.format("Income: $%.2f    Expense: $%.2f    Net: $%.2f", income, expense, income - expense));

            XYChart.Series<Number, Number> series = new XYChart.Series<>();
            Map<Integer, Double> monthlyExpenseMap = new java.util.TreeMap<>();
            for (int i = 1; i <= 12; i++) {
                monthlyExpenseMap.put(i, 0.0);
            }
            for (Transaction transaction : transactions) {
                if (transaction.getType() == TransactionType.EXPENSE) {
                    int month = transaction.getDate().getMonthValue();
                    monthlyExpenseMap.put(month, monthlyExpenseMap.getOrDefault(month, 0.0) + transaction.getAmount());
                }
            }
            for (Map.Entry<Integer, Double> entry : monthlyExpenseMap.entrySet()) {
                series.getData().add(new XYChart.Data<>(entry.getKey(), entry.getValue()));
            }
            barChart.getData().setAll(series);
        };

        timeRangeBox.setOnAction(e -> refreshChart.run());
        topRow.getChildren().addAll(new Label("Time Range"), timeRangeBox, summaryLabel);
        refreshChart.run();

        page.getChildren().addAll(title, topRow, barChart);
        VBox.setVgrow(barChart, Priority.ALWAYS);
        contentArea.setCenter(page);
    }

    private void showSettingsPage() {
        VBox page = new VBox(15);
        page.setPadding(new Insets(20));

        Label title = new Label("Settings");
        title.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label budgetLabel = new Label("Monthly Savings Target");
        TextField targetField = new TextField(String.format("%.2f", appContext.getBudgetService().getCurrentMonthlyTarget(username)));
        targetField.setPromptText("Enter target amount");

        Label dataPathLabel = new Label("Your data is stored locally in your home folder inside .sharkbudget/data.json");
        dataPathLabel.setWrapText(true);

        Label messageLabel = new Label();
        Button saveButton = new Button("Save Target");

        saveButton.setOnAction(e -> {
            try {
                double target = Double.parseDouble(targetField.getText().trim());
                appContext.getBudgetService().saveMonthlyTarget(username, target);
                messageLabel.setText("Monthly target saved.");
                messageLabel.setStyle("-fx-text-fill: #2a9d8f;");
            } catch (NumberFormatException ex) {
                messageLabel.setText("Please enter a valid number.");
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            } catch (Exception ex) {
                messageLabel.setText(ex.getMessage());
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            }
        });

        page.getChildren().addAll(title, budgetLabel, targetField, saveButton, messageLabel, new Separator(), dataPathLabel);
        contentArea.setCenter(page);
    }

    private void exportCurrentTransactions() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Export Transactions");
        fileChooser.setInitialFileName("shark_budget_transactions.csv");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("CSV Files", "*.csv"));

        File file = fileChooser.showSaveDialog(contentArea.getScene().getWindow());
        if (file != null) {
            appContext.getExportService().exportTransactionsToCsv(
                    appContext.getTransactionService().getUserTransactions(username),
                    Path.of(file.getAbsolutePath())
            );
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle("Export Complete");
            alert.setHeaderText(null);
            alert.setContentText("Transactions exported successfully.");
            alert.showAndWait();
        }
    }

    private DateRange getDateRange(String option) {
        LocalDate today = LocalDate.now();
        return switch (option) {
            case "This Month" -> new DateRange(YearMonth.now().atDay(1), YearMonth.now().atEndOfMonth());
            case "Last 30 Days" -> new DateRange(today.minusDays(29), today);
            case "This Year" -> new DateRange(LocalDate.of(today.getYear(), 1, 1), LocalDate.of(today.getYear(), 12, 31));
            default -> new DateRange(LocalDate.of(2000, 1, 1), today.plusYears(1));
        };
    }

    private Category parseCategory(String categoryText) {
        if (categoryText == null || categoryText.equals("All")) {
            return null;
        }
        for (Category category : Category.values()) {
            if (category.getDisplayName().equals(categoryText)) {
                return category;
            }
        }
        return null;
    }

    private TransactionType parseType(String typeText) {
        if (typeText == null || typeText.equals("All")) {
            return null;
        }
        if (typeText.equals("Income")) {
            return TransactionType.INCOME;
        }
        if (typeText.equals("Expense")) {
            return TransactionType.EXPENSE;
        }
        return null;
    }

    private record DateRange(LocalDate startDate, LocalDate endDate) {
    }


}
